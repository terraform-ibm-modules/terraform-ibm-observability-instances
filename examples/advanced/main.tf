##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.2.0"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Key Protect Instance + Key (used to encrypt bucket)
##############################################################################

locals {
  key_ring_name = "observability"
  key_name      = "observability-key"
}

module "key_protect" {
  source            = "terraform-ibm-modules/kms-all-inclusive/ibm"
  version           = "5.1.2"
  resource_group_id = module.resource_group.resource_group_id
  region            = var.region
  resource_tags     = var.resource_tags
  keys = [
    {
      key_ring_name = local.key_ring_name
      keys = [
        {
          key_name = local.key_name
        }
      ]
    }
  ]
  key_protect_instance_name = "${var.prefix}-kp"
}

##############################################################################
# Event Notification
##############################################################################

module "event_notification_1" {
  source            = "terraform-ibm-modules/event-notifications/ibm"
  version           = "1.20.2"
  resource_group_id = module.resource_group.resource_group_id
  name              = "${var.prefix}-en-1"
  tags              = var.resource_tags
  plan              = "standard"
  service_endpoints = "public"
  region            = var.region
}

module "event_notification_2" {
  source            = "terraform-ibm-modules/event-notifications/ibm"
  version           = "1.20.2"
  resource_group_id = module.resource_group.resource_group_id
  name              = "${var.prefix}-en-2"
  tags              = var.resource_tags
  plan              = "standard"
  service_endpoints = "public"
  region            = var.region
}


##############################################################################
# Event Streams
##############################################################################

locals {
  topic_name = "${var.prefix}-topic"
}

module "event_streams" {
  source            = "terraform-ibm-modules/event-streams/ibm"
  version           = "3.4.11"
  es_name           = "${var.prefix}-eventsteams-instance"
  tags              = var.resource_tags
  region            = var.region
  resource_group_id = module.resource_group.resource_group_id
  plan              = "standard"
  topics = [{
    name       = local.topic_name
    partitions = 1
    config = {
      "cleanup.policy"  = "delete"
      "retention.ms"    = "86400000"  # 1 Day
      "retention.bytes" = "10485760"  # 10 MB
      "segment.bytes"   = "536870912" # 512 MB
    }
  }, ]
  cbr_rules = [
    {
      description      = "${var.prefix}-event streams access"
      enforcement_mode = "report"
      account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
      rule_contexts = [{
        attributes = [
          {
            "name" : "endpointType",
            "value" : "public"
          },
          {
            name  = "networkZoneId"
            value = module.cbr_zone_atracker.zone_id
        }]
      }]
    }
  ]
}

##############################################################################
# COS instance + bucket (used for cloud logs and AT target)
##############################################################################

module "cos" {
  source            = "terraform-ibm-modules/cos/ibm"
  version           = "8.21.21"
  resource_group_id = module.resource_group.resource_group_id
  cos_instance_name = "${var.prefix}-cos"
  cos_tags          = var.resource_tags
  create_cos_bucket = false
}

locals {
  logs_bucket_name    = "${var.prefix}-logs-data"
  metrics_bucket_name = "${var.prefix}-metrics-data"
  at_bucket_name      = "${var.prefix}-at-data"
}

module "buckets" {
  source  = "terraform-ibm-modules/cos/ibm//modules/buckets"
  version = "8.21.21"
  bucket_configs = [
    {
      bucket_name                   = local.logs_bucket_name
      kms_encryption_enabled        = true
      region_location               = var.region
      resource_instance_id          = module.cos.cos_instance_id
      kms_guid                      = module.key_protect.kms_guid
      kms_key_crn                   = module.key_protect.keys["${local.key_ring_name}.${local.key_name}"].crn
      skip_iam_authorization_policy = false
      cbr_rules = [{
        description      = "CBR rule for ICL logs bucket"
        enforcement_mode = "report"
        account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
        rule_contexts = [{
          attributes = [
            {
              "name" : "endpointType",
              "value" : "public"
            },
            {
              name  = "networkZoneId"
              value = module.cbr_zone_icl.zone_id
          }]
        }]
      }]
    },
    {
      bucket_name                   = local.metrics_bucket_name
      kms_encryption_enabled        = true
      region_location               = var.region
      resource_instance_id          = module.cos.cos_instance_id
      kms_guid                      = module.key_protect.kms_guid
      kms_key_crn                   = module.key_protect.keys["${local.key_ring_name}.${local.key_name}"].crn
      skip_iam_authorization_policy = true # Auth policy created in first bucket
      cbr_rules = [{
        description      = "CBR rule for ICL metrics bucket"
        enforcement_mode = "report"
        account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
        rule_contexts = [{
          attributes = [
            {
              "name" : "endpointType",
              "value" : "public"
            },
            {
              name  = "networkZoneId"
              value = module.cbr_zone_icl.zone_id
          }]
        }]
      }]
    },
    {
      bucket_name                   = local.at_bucket_name
      kms_encryption_enabled        = true
      region_location               = var.region
      resource_instance_id          = module.cos.cos_instance_id
      kms_guid                      = module.key_protect.kms_guid
      kms_key_crn                   = module.key_protect.keys["${local.key_ring_name}.${local.key_name}"].crn
      skip_iam_authorization_policy = true # Auth policy created in first bucket
      cbr_rules = [{
        description      = "CBR rule for AT event routing bucket"
        enforcement_mode = "report"
        account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
        rule_contexts = [{
          attributes = [
            {
              "name" : "endpointType",
              "value" : "private"
            },
            {
              name  = "networkZoneId"
              value = module.cbr_zone_atracker.zone_id
          }]
          }, {
          attributes = [
            {
              "name" : "endpointType",
              "value" : "private"
            },
            {
              name  = "networkZoneId"
              value = module.cbr_zone_icl.zone_id
            }
          ]
        }]
      }]
    }
  ]
}

##############################################################################
# Get Cloud Account ID
##############################################################################

data "ibm_iam_account_settings" "iam_account_settings" {
}

##############################################################################
# Create CBR Zone
##############################################################################

module "cbr_zone_atracker" {
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module"
  version          = "1.31.0"
  name             = "${var.prefix}-atracker-zone"
  zone_description = "Activity Tracker Event Routing zone"
  account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
  addresses = [{
    type = "serviceRef"
    ref = {
      account_id   = data.ibm_iam_account_settings.iam_account_settings.account_id
      service_name = "atracker"
    }
  }]
}

module "cbr_zone_icl" {
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module"
  version          = "1.31.0"
  name             = "${var.prefix}-icl-zone"
  zone_description = "CBR Network zone containing ICL"
  account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
  addresses = [{
    type = "serviceRef",
    ref = {
      account_id   = data.ibm_iam_account_settings.iam_account_settings.account_id
      service_name = "logs"
    }
  }]

}
module "cbr_zone_monitoring" {
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module"
  version          = "1.31.0"
  name             = "${var.prefix}-monitoring-zone"
  zone_description = "CBR Network zone containing monitoring"
  account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
  addresses = [{
    type = "serviceRef",
    ref = {
      account_id   = data.ibm_iam_account_settings.iam_account_settings.account_id
      service_name = "sysdig-monitor"
    }
  }]
}

##############################################################################
# Observability:
# - Cloud Logs instance
# - Monitoring instance
# - Activity Tracker config:
#   - COS AT target
#   - Cloud Logs AT target
#   - Event Streams AT target
#   - AT route to all above targets
# - Global Event Routing configuration
##############################################################################

locals {
  icl_target_name = "${var.prefix}-icl-target"
  es_target_name  = "${var.prefix}-es-target"
  cos_target_name = "${var.prefix}-cos-target"
  mr_target_name  = "${var.prefix}-cloud-monitoring-target"
  target_ids = [
    module.observability_instances.activity_tracker_targets[local.cos_target_name].id,
    module.observability_instances.activity_tracker_targets[local.es_target_name].id,
    module.observability_instances.activity_tracker_targets[local.icl_target_name].id
  ]
}

module "observability_instances" {
  source = "../../"
  # delete line above and use below syntax to pull module source from hashicorp when consuming this module
  # source    = "terraform-ibm-modules/observability-instances/ibm"
  # version   = "X.Y.Z" # Replace "X.X.X" with a release version to lock into a specific release
  resource_group_id = module.resource_group.resource_group_id
  region            = var.region

  # Monitoring
  enable_platform_metrics      = false
  cloud_monitoring_tags        = var.resource_tags
  cloud_monitoring_access_tags = var.access_tags
  cloud_monitoring_plan        = "graduated-tier"


  # Cloud Logs
  cloud_logs_tags        = var.resource_tags
  cloud_logs_access_tags = var.access_tags
  cloud_logs_data_storage = {
    # logs and metrics buckets must be different
    logs_data = {
      enabled         = true
      bucket_crn      = module.buckets.buckets[local.logs_bucket_name].bucket_crn
      bucket_endpoint = module.buckets.buckets[local.logs_bucket_name].s3_endpoint_direct
    },
    metrics_data = {
      enabled         = true
      bucket_crn      = module.buckets.buckets[local.metrics_bucket_name].bucket_crn
      bucket_endpoint = module.buckets.buckets[local.metrics_bucket_name].s3_endpoint_direct
    }
  }
  # Cloud Logs policies
  cloud_logs_policies = [{
    logs_policy_name     = "${var.prefix}-logs-policy-1"
    logs_policy_priority = "type_low"
    application_rule = [{
      name         = "test-system-app"
      rule_type_id = "start_with"
    }]
    log_rules = [{
      severities = ["info", "debug"]
    }]
    subsystem_rule = [{
      name         = "test-sub-system"
      rule_type_id = "start_with"
    }]
  }]
  # integrate with multiple Event Notifcations instances
  # (NOTE: This may fail due known issue https://github.com/IBM-Cloud/terraform-provider-ibm/issues/5734)
  cloud_logs_existing_en_instances = [{
    en_instance_id      = module.event_notification_1.guid
    en_region           = var.region
    en_integration_name = "${var.prefix}-en-1"
    },
    {
      en_instance_id      = module.event_notification_2.guid
      en_region           = var.region
      en_integration_name = "${var.prefix}-en-2"
  }]

  # Activity Tracker targets
  at_cloud_logs_targets = [
    {
      instance_id   = module.observability_instances.cloud_logs_crn
      target_region = var.region
      target_name   = local.icl_target_name
    }
  ]
  at_cos_targets = [
    {
      bucket_name                       = local.at_bucket_name
      endpoint                          = module.buckets.buckets[local.at_bucket_name].s3_endpoint_direct
      instance_id                       = module.cos.cos_instance_id
      target_region                     = var.region
      target_name                       = local.cos_target_name
      skip_atracker_cos_iam_auth_policy = false
      service_to_service_enabled        = true
    }
  ]
  at_eventstreams_targets = [
    {
      instance_id                      = module.event_streams.id
      brokers                          = [module.event_streams.kafka_brokers_sasl[0]]
      topic                            = local.topic_name
      target_region                    = var.region
      target_name                      = local.es_target_name
      service_to_service_enabled       = true
      skip_atracker_es_iam_auth_policy = false
    }
  ]

  # Activity Tracker route
  activity_tracker_routes = [
    {
      locations  = ["*", "global"]
      target_ids = local.target_ids
      route_name = "${var.prefix}-route"
    }
  ]

  # Global Event Routing Settings
  global_event_routing_settings = {
    default_targets           = local.target_ids
    permitted_target_regions  = ["us-south", "eu-de", "us-east", "eu-es", "eu-gb", "au-syd", "br-sao", "ca-tor", "eu-es", "jp-tok", "jp-osa", "in-che", "eu-fr2"]
    metadata_region_primary   = "us-south"
    private_api_endpoint_only = false
  }

  # Metric Routing

  metrics_router_targets = [
    {
      destination_crn = module.observability_instances.cloud_monitoring_crn
      target_name     = local.mr_target_name
      target_region   = var.region
    }
  ]

  metrics_router_routes = [
    {
      name = "${var.prefix}-metric-routing-route"
      rules = [
        {
          action = "send"
          targets = [{
            id = module.observability_instances.metrics_router_targets[local.mr_target_name].id
          }]
          inclusion_filters = [{
            operand  = "location"
            operator = "is"
            values   = ["us-south"]
          }]
        }
      ]
    }
  ]

  /*
  Uncomment below to set metrics router settings. A `primary_metadata_region` is required to be set before metrics routing can be configured.
  metrics_router_settings = {
    default_targets = [{
      id = module.observability_instances.metrics_router_targets[local.mr_target_name].id
    }]
    permitted_target_regions  = ["us-south", "eu-de", "us-east", "eu-es", "eu-gb", "au-syd", "br-sao", "ca-tor", "jp-tok", "jp-osa"]
    primary_metadata_region   = var.region
    private_api_endpoint_only = false
  }
  */

  # CBR
  cbr_rule_at_region = var.region
  cbr_rules_icl = [{
    description      = "${var.prefix}-icl access from network zone to access the cloud logs instance."
    account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
    enforcement_mode = "report"
    rule_contexts = [{
      attributes = [
        {
          "name" : "endpointType",
          "value" : "private"
        },
        {
          name  = "networkZoneId"
          value = module.cbr_zone_icl.zone_id
        }
      ]
      }, {
      attributes = [
        {
          "name" : "endpointType",
          "value" : "private"
        },
        {
          name  = "networkZoneId"
          value = module.cbr_zone_atracker.zone_id
        }
      ]
    }]
  }]

  cbr_rules_cloud_monitoring = [{
    description      = "${var.prefix}-cloud-monitoring access from network zone."
    account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
    enforcement_mode = "report"
    rule_contexts = [{
      attributes = [
        {
          "name" : "endpointType",
          "value" : "private"
        },
        {
          name  = "networkZoneId"
          value = module.cbr_zone_monitoring.zone_id
        }
      ]
    }]
  }]

  cbr_rules_at = [{
    description       = "${var.prefix}-at-event-routing access from network zones."
    account_id        = data.ibm_iam_account_settings.iam_account_settings.account_id
    resource_group_id = module.resource_group.resource_group_id
    enforcement_mode  = "report"
    rule_contexts = [{
      attributes = [
        {
          "name" : "endpointType",
          "value" : "private"
        },
        {
          name  = "networkZoneId"
          value = module.cbr_zone_atracker.zone_id
        }
      ]
      }, {
      attributes = [
        {
          "name" : "endpointType",
          "value" : "private"
        },
        {
          name  = "networkZoneId"
          value = module.cbr_zone_icl.zone_id
        }
      ]
    }]
  }]
}
