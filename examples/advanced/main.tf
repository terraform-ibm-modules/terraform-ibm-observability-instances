##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.6"
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
  version           = "4.16.0"
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

module "event_notification" {
  source            = "terraform-ibm-modules/event-notifications/ibm"
  version           = "1.10.22"
  resource_group_id = module.resource_group.resource_group_id
  name              = "${var.prefix}-en"
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
  version           = "2.3.1"
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
}

# TODO: Remove this resource and create service key when https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/issues/307 is complete
# Resource key used to add an Event Streams Activity Tracker target
resource "ibm_resource_key" "es_resource_key" {
  name                 = "${var.prefix}-eventstreams-service-key"
  resource_instance_id = module.event_streams.id
  role                 = "Writer"
}

##############################################################################
# COS instance + bucket (used for logdna + AT archiving + AT target)
##############################################################################

module "cos" {
  source            = "terraform-ibm-modules/cos/ibm"
  version           = "8.11.15"
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
  version = "8.11.15"
  bucket_configs = [
    {
      bucket_name                   = local.logs_bucket_name
      kms_encryption_enabled        = true
      region_location               = var.region
      resource_instance_id          = module.cos.cos_instance_id
      kms_guid                      = module.key_protect.kms_guid
      kms_key_crn                   = module.key_protect.keys["${local.key_ring_name}.${local.key_name}"].crn
      skip_iam_authorization_policy = false
    },
    {
      bucket_name                   = local.metrics_bucket_name
      kms_encryption_enabled        = true
      region_location               = var.region
      resource_instance_id          = module.cos.cos_instance_id
      kms_guid                      = module.key_protect.kms_guid
      kms_key_crn                   = module.key_protect.keys["${local.key_ring_name}.${local.key_name}"].crn
      skip_iam_authorization_policy = true # Auth policy created in first bucket
    },
    {
      bucket_name                   = local.at_bucket_name
      kms_encryption_enabled        = true
      region_location               = var.region
      resource_instance_id          = module.cos.cos_instance_id
      kms_guid                      = module.key_protect.kms_guid
      kms_key_crn                   = module.key_protect.keys["${local.key_ring_name}.${local.key_name}"].crn
      skip_iam_authorization_policy = true # Auth policy created in first bucket
    }
  ]
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

  # Cloud Logs
  enable_platform_logs   = false
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
  cloud_logs_existing_en_instances = [{
    en_instance_id      = module.event_notification.guid
    en_region           = var.region
    en_integration_name = "${var.prefix}-en"
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
      api_key       = ibm_resource_key.es_resource_key.credentials.apikey
      instance_id   = module.event_streams.id
      brokers       = [module.event_streams.kafka_brokers_sasl[0]]
      topic         = local.topic_name
      target_region = var.region
      target_name   = local.es_target_name
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
    metadata_region_backup    = "eu-de"
    private_api_endpoint_only = false
  }
}
