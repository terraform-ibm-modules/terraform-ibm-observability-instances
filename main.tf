##############################################################################
# observability-instances-module
#
# Deploy the observability instances - Log Analysis, Cloud Monitoring and Activity Tracker
##############################################################################

# Activity tracker
module "activity_tracker" {
  source = "./modules/activity_tracker"
  providers = {
    logdna.at = logdna.at
  }
  region                          = var.region
  resource_group_id               = var.resource_group_id
  activity_tracker_enable_archive = var.activity_tracker_enable_archive
  ibmcloud_api_key                = var.ibmcloud_api_key
  activity_tracker_provision      = var.activity_tracker_provision
  instance_name                   = var.activity_tracker_instance_name
  plan                            = var.activity_tracker_plan
  manager_key_name                = var.activity_tracker_manager_key_name
  manager_key_tags                = var.activity_tracker_manager_key_tags
  tags                            = var.activity_tracker_tags
  access_tags                     = var.activity_tracker_access_tags
  service_endpoints               = var.activity_tracker_service_endpoints
  cos_instance_id                 = var.at_cos_instance_id
  cos_bucket_name                 = var.at_cos_bucket_name
  cos_bucket_endpoint             = var.at_cos_bucket_endpoint
  activity_tracker_routes         = var.activity_tracker_routes
  cos_targets                     = var.cos_targets
  eventstreams_targets            = var.eventstreams_targets
  log_analysis_targets            = var.log_analysis_targets
  global_event_routing_settings   = var.global_event_routing_settings
}

# Log Analysis
module "log_analysis" {
  source = "./modules/log_analysis"
  providers = {
    logdna.ld = logdna.ld
  }
  region                      = var.region
  resource_group_id           = var.resource_group_id
  log_analysis_enable_archive = var.log_analysis_enable_archive
  ibmcloud_api_key            = var.ibmcloud_api_key
  log_analysis_provision      = var.log_analysis_provision
  instance_name               = var.log_analysis_instance_name
  plan                        = var.log_analysis_plan
  manager_key_name            = var.log_analysis_manager_key_name
  manager_key_tags            = var.log_analysis_manager_key_tags
  resource_key_role           = var.log_analysis_resource_key_role
  tags                        = var.log_analysis_tags
  access_tags                 = var.log_analysis_access_tags
  enable_platform_logs        = var.enable_platform_logs
  service_endpoints           = var.log_analysis_service_endpoints
  cos_instance_id             = var.log_analysis_cos_instance_id
  cos_bucket_name             = var.log_analysis_cos_bucket_name
  cos_bucket_endpoint         = var.log_analysis_cos_bucket_endpoint
}

# IBM Cloud Monitoring
module "cloud_monitoring" {
  source                     = "./modules/cloud_monitoring"
  region                     = var.region
  resource_group_id          = var.resource_group_id
  cloud_monitoring_provision = var.cloud_monitoring_provision
  instance_name              = var.cloud_monitoring_instance_name
  plan                       = var.cloud_monitoring_plan
  manager_key_name           = var.cloud_monitoring_manager_key_name
  manager_key_tags           = var.cloud_monitoring_manager_key_tags
  tags                       = var.cloud_monitoring_tags
  access_tags                = var.cloud_monitoring_access_tags
  enable_platform_metrics    = var.enable_platform_metrics
  service_endpoints          = var.cloud_monitoring_service_endpoints
}

# IBM Cloud Logs
module "cloud_logs" {
  source                = "./modules/cloud_logs"
  region                = var.cloud_logs_region != null ? var.cloud_logs_region : var.region
  resource_group_id     = var.resource_group_id
  cloud_logs_provision  = var.cloud_logs_provision
  instance_name         = var.cloud_logs_instance_name
  plan                  = var.cloud_logs_plan
  tags                  = var.cloud_logs_tags
  access_tags           = var.cloud_logs_access_tags
  retention_period      = var.cloud_logs_retention_period
  data_storage          = var.cloud_logs_data_storage
  service_endpoints     = var.cloud_logs_service_endpoints
  existing_en_instances = var.cloud_logs_existing_en_instances
}
