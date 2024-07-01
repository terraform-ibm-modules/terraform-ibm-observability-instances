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

module "test_observability_instance_creation" {
  source = "../../"
  providers = {
    logdna.at = logdna.at
    logdna.ld = logdna.ld
  }
  region                            = var.region
  log_analysis_instance_name        = "${var.prefix}-log-analysis"
  cloud_monitoring_instance_name    = "${var.prefix}-cloud-monitoring"
  activity_tracker_instance_name    = "${var.prefix}-activity-tracker"
  resource_group_id                 = module.resource_group.resource_group_id
  log_analysis_plan                 = "7-day"
  cloud_monitoring_plan             = "graduated-tier"
  activity_tracker_plan             = "7-day"
  enable_platform_logs              = false
  enable_platform_metrics           = false
  log_analysis_tags                 = var.resource_tags
  cloud_monitoring_tags             = var.resource_tags
  activity_tracker_tags             = var.resource_tags
  log_analysis_manager_key_tags     = var.resource_tags
  cloud_monitoring_manager_key_tags = var.resource_tags
  activity_tracker_manager_key_tags = var.resource_tags
  log_analysis_access_tags          = var.access_tags
  cloud_monitoring_access_tags      = var.access_tags
  activity_tracker_access_tags      = var.access_tags
}
