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
  version           = "4.13.4"
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
# COS instance + bucket (used for logdna + AT archiving)
##############################################################################

locals {
  bucket_name     = "${var.prefix}-observability-archive-bucket"
  archive_api_key = var.archive_api_key == null ? var.ibmcloud_api_key : var.archive_api_key
}

module "cos" {
  source                     = "terraform-ibm-modules/cos/ibm"
  version                    = "8.6.2"
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

module "cos_bucket" {
  source  = "terraform-ibm-modules/cos/ibm//modules/buckets"
  version = "8.6.2"
  bucket_configs = [
    {
      bucket_name                   = "${var.prefix}-logs-data"
      kms_encryption_enabled        = false
      region_location               = var.region
      resource_instance_id          = module.cos.cos_instance_id
      kms_encryption_enabled        = true
      kms_guid                      = module.key_protect.kms_guid
      kms_key_crn                   = module.key_protect.keys["observability.observability-key"].crn
      skip_iam_authorization_policy = true

    },
    {
      bucket_name                   = "${var.prefix}-metrics-data"
      kms_encryption_enabled        = false
      region_location               = var.region
      resource_instance_id          = module.cos.cos_instance_id
      kms_encryption_enabled        = true
      kms_guid                      = module.key_protect.kms_guid
      kms_key_crn                   = module.key_protect.keys["observability.observability-key"].crn
      skip_iam_authorization_policy = true
    }
  ]
}


module "event_notification" {
  source            = "terraform-ibm-modules/event-notifications/ibm"
  version           = "1.6.5"
  resource_group_id = module.resource_group.resource_group_id
  name              = "${var.prefix}-en"
  tags              = var.resource_tags
  plan              = "standard"
  service_endpoints = "public"
  region            = var.en_region
}

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
  cloud_logs_retention_period       = 14
  cloud_logs_region                 = "eu-es"
  cloud_logs_data_storage = {
    logs_data = {
      enabled         = true
      bucket_crn      = module.cos_bucket.buckets["${var.prefix}-logs-data"].bucket_crn
      bucket_endpoint = module.cos_bucket.buckets["${var.prefix}-logs-data"].s3_endpoint_direct
    },
    metrics_data = {
      enabled         = true
      bucket_crn      = module.cos_bucket.buckets["${var.prefix}-metrics-data"].bucket_crn
      bucket_endpoint = module.cos_bucket.buckets["${var.prefix}-metrics-data"].s3_endpoint_direct
    }
  }
  cloud_logs_existing_en_instances = [{
    en_instance_id = module.event_notification.guid
    en_region      = var.en_region
  }]
}
