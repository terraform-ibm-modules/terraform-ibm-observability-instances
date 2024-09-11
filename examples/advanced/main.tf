##############################################################################
# Local Resource Block
##############################################################################
locals {
  bucket_name     = "${var.prefix}-observability-archive-bucket"
  archive_api_key = var.archive_api_key == null ? var.ibmcloud_api_key : var.archive_api_key

  eventstreams_target_region = var.eventstreams_target_region != null ? var.eventstreams_target_region : var.region
  cos_target_region          = var.cos_target_region != null ? var.cos_target_region : var.region
  log_analysis_target_region = var.log_analysis_target_region != null ? var.log_analysis_target_region : var.region
}

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

module "key_protect" {
  source            = "terraform-ibm-modules/kms-all-inclusive/ibm"
  version           = "4.15.11"
  resource_group_id = module.resource_group.resource_group_id
  region            = var.region
  resource_tags     = var.resource_tags
  keys = [
    {
      key_ring_name = "observability"
      keys = [
        {
          key_name = "observability-key"
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
  version           = "1.10.11"
  resource_group_id = module.resource_group.resource_group_id
  name              = "${var.prefix}-en"
  tags              = var.resource_tags
  plan              = "standard"
  service_endpoints = "public"
  region            = var.en_region
}


##############################################################################
# Event stream target
##############################################################################

resource "ibm_resource_instance" "es_instance" {
  name              = "${var.prefix}-eventsteams-instance"
  service           = "messagehub"
  plan              = "standard"
  location          = local.eventstreams_target_region
  resource_group_id = module.resource_group.resource_group_id
}

resource "ibm_event_streams_topic" "es_topic" {
  resource_instance_id = ibm_resource_instance.es_instance.id
  name                 = "${var.prefix}-topic"
  partitions           = 1
  config = {
    "cleanup.policy"  = "delete"
    "retention.ms"    = "86400000"  # 1 Day
    "retention.bytes" = "10485760"  # 10 MB
    "segment.bytes"   = "536870912" #512 MB
  }
}

resource "ibm_resource_key" "es_resource_key" {
  name                 = "${var.prefix}-eventstreams-service-key"
  resource_instance_id = ibm_resource_instance.es_instance.id
  role                 = "Writer"
}

##############################################################################
# COS instance + bucket (used for logdna + AT archiving + AT target)
##############################################################################

module "cos" {
  source                     = "terraform-ibm-modules/cos/ibm"
  version                    = "8.11.7"
  resource_group_id          = module.resource_group.resource_group_id
  region                     = var.region
  cos_instance_name          = "${var.prefix}-cos"
  cos_tags                   = var.resource_tags
  bucket_name                = local.bucket_name
  existing_kms_instance_guid = module.key_protect.kms_guid
  retention_enabled          = false
  activity_tracker_crn       = module.observability_instance_creation.activity_tracker_crn
  monitoring_crn             = module.observability_instance_creation.cloud_monitoring_crn
  kms_key_crn                = module.key_protect.keys["observability.observability-key"].crn
}

module "cloud_logs_buckets" {
  depends_on = [module.cos] # The `cos` module execution must be fully completed, including the instantiation of the cos_instance and configuration of the default bucket, as a prerequisite to executing the cloud_logs_buckets module. This ensures that the cloud_logs_buckets module can utilize the authentication policy created by the `cos` module.
  source     = "terraform-ibm-modules/cos/ibm//modules/buckets"
  version    = "8.11.7"
  bucket_configs = [
    {
      bucket_name                   = "${var.prefix}-logs-data"
      kms_encryption_enabled        = true
      region_location               = var.region
      resource_instance_id          = module.cos.cos_instance_id
      kms_guid                      = module.key_protect.kms_guid
      kms_key_crn                   = module.key_protect.keys["observability.observability-key"].crn
      skip_iam_authorization_policy = true # A bucket created in the cos module already creates the IAM policy to access the KMS.
    },
    {
      bucket_name                   = "${var.prefix}-metrics-data"
      kms_encryption_enabled        = true
      region_location               = var.region
      resource_instance_id          = module.cos.cos_instance_id
      kms_guid                      = module.key_protect.kms_guid
      kms_key_crn                   = module.key_protect.keys["observability.observability-key"].crn
      skip_iam_authorization_policy = true
    }
  ]
}

module "activity_tracker_event_routing_bucket" {
  source                     = "terraform-ibm-modules/cos/ibm"
  version                    = "8.11.7"
  resource_group_id          = module.resource_group.resource_group_id
  region                     = local.cos_target_region
  cos_instance_name          = "${var.prefix}-cos"
  cos_tags                   = var.resource_tags
  bucket_name                = "${var.prefix}-cos-target-bucket-1"
  kms_encryption_enabled     = true
  retention_enabled          = false
  existing_kms_instance_guid = module.key_protect.kms_guid
  kms_key_crn                = module.key_protect.keys["observability.observability-key"].crn
}

##############################################################################
# Observability Instance
##############################################################################

module "observability_instance_creation" {
  source = "../../"
  providers = {
    logdna.at = logdna.at
    logdna.ld = logdna.ld
  }
  resource_group_id                 = module.resource_group.resource_group_id
  region                            = var.region
  log_analysis_instance_name        = "${var.prefix}-log-analysis"
  cloud_monitoring_instance_name    = "${var.prefix}-cloud-monitoring"
  activity_tracker_instance_name    = "${var.prefix}-activity-tracker"
  cloud_logs_instance_name          = "${var.prefix}-cloud-logs"
  enable_platform_metrics           = false
  enable_platform_logs              = false
  log_analysis_plan                 = "7-day"
  cloud_monitoring_plan             = "graduated-tier"
  activity_tracker_plan             = "7-day"
  cloud_logs_plan                   = "standard"
  log_analysis_tags                 = var.resource_tags
  cloud_monitoring_tags             = var.resource_tags
  activity_tracker_tags             = var.resource_tags
  log_analysis_manager_key_tags     = var.resource_tags
  cloud_monitoring_manager_key_tags = var.resource_tags
  activity_tracker_manager_key_tags = var.resource_tags
  cloud_logs_tags                   = var.resource_tags
  log_analysis_access_tags          = var.access_tags
  cloud_monitoring_access_tags      = var.access_tags
  activity_tracker_access_tags      = var.access_tags
  cloud_logs_access_tags            = var.access_tags
  log_analysis_enable_archive       = true
  activity_tracker_enable_archive   = true
  ibmcloud_api_key                  = local.archive_api_key
  log_analysis_cos_instance_id      = module.cos.cos_instance_id
  log_analysis_cos_bucket_name      = local.bucket_name
  log_analysis_cos_bucket_endpoint  = module.cos.s3_endpoint_public
  at_cos_bucket_name                = local.bucket_name
  at_cos_instance_id                = module.cos.cos_instance_id
  at_cos_bucket_endpoint            = module.cos.s3_endpoint_private

  cos_targets = [
    {
      bucket_name                       = module.activity_tracker_event_routing_bucket.bucket_name
      endpoint                          = module.activity_tracker_event_routing_bucket.s3_endpoint_private
      instance_id                       = module.activity_tracker_event_routing_bucket.cos_instance_id
      target_region                     = local.cos_target_region
      target_name                       = "${var.prefix}-cos-target"
      skip_atracker_cos_iam_auth_policy = false
      service_to_service_enabled        = true
    }
  ]

  eventstreams_targets = [
    {
      api_key       = ibm_resource_key.es_resource_key.credentials.apikey
      instance_id   = ibm_resource_instance.es_instance.id
      brokers       = ibm_event_streams_topic.es_topic.kafka_brokers_sasl
      topic         = ibm_event_streams_topic.es_topic.name
      target_region = local.eventstreams_target_region
      target_name   = "${var.prefix}-eventstreams-target"
    }
  ]
  log_analysis_targets = [
    {
      instance_id   = module.observability_instance_creation.log_analysis_crn
      ingestion_key = module.observability_instance_creation.log_analysis_ingestion_key
      target_region = local.log_analysis_target_region
      target_name   = "${var.prefix}-log-analysis"
    }
  ]

  activity_tracker_routes = [
    {
      route_name = "${var.prefix}-route"
      locations  = ["*", "global"]
      target_ids = [
        module.observability_instance_creation.activity_tracker_targets["${var.prefix}-cos-target"].id,
        module.observability_instance_creation.activity_tracker_targets["${var.prefix}-log-analysis"].id,
        module.observability_instance_creation.activity_tracker_targets["${var.prefix}-eventstreams-target"].id
      ]
    }
  ]

  global_event_routing_settings = {
    default_targets           = [module.observability_instance_creation.activity_tracker_targets["${var.prefix}-eventstreams-target"].id]
    permitted_target_regions  = var.permitted_target_regions
    metadata_region_primary   = var.metadata_region_primary
    metadata_region_backup    = var.metadata_region_backup
    private_api_endpoint_only = var.private_api_endpoint_only
  }

  cloud_logs_retention_period = 14
  cloud_logs_data_storage = {
    logs_data = {
      enabled         = true
      bucket_crn      = module.cloud_logs_buckets.buckets["${var.prefix}-logs-data"].bucket_crn
      bucket_endpoint = module.cloud_logs_buckets.buckets["${var.prefix}-logs-data"].s3_endpoint_direct
    },
    metrics_data = {
      enabled         = true
      bucket_crn      = module.cloud_logs_buckets.buckets["${var.prefix}-metrics-data"].bucket_crn
      bucket_endpoint = module.cloud_logs_buckets.buckets["${var.prefix}-metrics-data"].s3_endpoint_direct
    }
  }
  cloud_logs_existing_en_instances = [{
    en_instance_id = module.event_notification.guid
    en_region      = var.en_region
  }]
  # Only 1 account level tenant can be created per region, so to prevent tests from clashing, not creating any tenants until https://github.ibm.com/GoldenEye/issues/issues/10676 is implemented
  # logs_routing_tenant_regions = [var.region]
}
