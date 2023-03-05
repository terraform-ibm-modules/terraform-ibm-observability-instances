##############################################################################
# observability-instances-module
#
# Deploy the observability instances - LogDNA, Sysdig and Activity Tracker
##############################################################################

locals {
  # Validation approach based on https://stackoverflow.com/a/66682419
  # When archive is enabled ibmcloud api key is required
  apikey_validate_condition = var.enable_archive == true && var.ibmcloud_api_key == null
  apikey_validate_msg       = "'ibmcloud_api_key' is required when 'enable_archive' is true"
  # tflint-ignore: terraform_unused_declarations
  apikey_validate_check = regex("^${local.apikey_validate_msg}$", (!local.apikey_validate_condition ? local.apikey_validate_msg : ""))
}

# Sysdig
module "sysdig" {
  source                   = "./modules/sysdig"
  region                   = var.region
  resource_group_id        = var.resource_group_id
  sysdig_provision         = var.sysdig_provision
  sysdig_instance_name     = var.sysdig_instance_name
  sysdig_plan              = var.sysdig_plan
  sysdig_manager_key_name  = var.sysdig_manager_key_name
  sysdig_manager_key_tags  = var.sysdig_manager_key_tags
  sysdig_tags              = var.sysdig_tags
  enable_platform_metrics  = var.enable_platform_metrics
  sysdig_service_endpoints = var.sysdig_service_endpoints
}

module "activity_tracker" {
  source = "./modules/activity_tracker"
  providers = {
    logdna.at = logdna.at
  }
  region                             = var.region
  resource_group_id                  = var.resource_group_id
  enable_archive                     = var.enable_archive
  ibmcloud_api_key                   = var.ibmcloud_api_key
  activity_tracker_provision         = var.activity_tracker_provision
  activity_tracker_instance_name     = var.activity_tracker_instance_name
  activity_tracker_plan              = var.activity_tracker_plan
  activity_tracker_manager_key_name  = var.activity_tracker_manager_key_name
  activity_tracker_manager_key_tags  = var.activity_tracker_manager_key_tags
  activity_tracker_tags              = var.activity_tracker_tags
  activity_tracker_service_endpoints = var.activity_tracker_service_endpoints
  at_cos_instance_id                 = var.at_cos_instance_id
  at_cos_bucket_name                 = var.at_cos_bucket_name
  at_cos_bucket_endpoint             = var.at_cos_bucket_endpoint
}

module "logdna" {
  source = "./modules/logdna"
  providers = {
    logdna.ld = logdna.ld
  }
  region                     = var.region
  resource_group_id          = var.resource_group_id
  enable_archive             = var.enable_archive
  ibmcloud_api_key           = var.ibmcloud_api_key
  logdna_provision           = var.logdna_provision
  logdna_instance_name       = var.logdna_instance_name
  logdna_plan                = var.logdna_plan
  logdna_manager_key_name    = var.logdna_manager_key_name
  logdna_manager_key_tags    = var.logdna_manager_key_tags
  logdna_tags                = var.logdna_tags
  enable_platform_logs       = var.enable_platform_logs
  logdna_service_endpoints   = var.logdna_service_endpoints
  logdna_cos_instance_id     = var.logdna_cos_instance_id
  logdna_cos_bucket_name     = var.logdna_cos_bucket_name
  logdna_cos_bucket_endpoint = var.logdna_cos_bucket_endpoint
}
