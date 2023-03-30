##############################################################################
# observability-instances-module
#
# Deploy the observability instances - LogDNA, Sysdig and Activity Tracker
##############################################################################

# Activity tracker
module "activity_tracker" {
  source = "./modules/activity_tracker"
  providers = {
    logdna.at = logdna.at
  }
  region                        = var.region
  resource_group_id             = var.resource_group_id
  enable_archive                = var.enable_archive
  ibmcloud_api_key              = var.ibmcloud_api_key
  activity_tracker_provision    = var.activity_tracker_provision
  instance_name                 = var.activity_tracker_instance_name
  plan                          = var.activity_tracker_plan
  manager_key_name              = var.activity_tracker_manager_key_name
  manager_key_tags              = var.activity_tracker_manager_key_tags
  tags                          = var.activity_tracker_tags
  service_endpoints             = var.activity_tracker_service_endpoints
  cos_instance_id               = var.at_cos_instance_id
  cos_bucket_name               = var.at_cos_bucket_name
  cos_bucket_endpoint           = var.at_cos_bucket_endpoint
  activity_tracker_routes       = var.activity_tracker_routes
  cos_targets                   = var.cos_targets
  eventstreams_targets          = var.eventstreams_targets
  logdna_targets                = var.logdna_targets
  global_event_routing_settings = var.global_event_routing_settings
}

# Log Analysis
module "logdna" {
  source = "./modules/logdna"
  providers = {
    logdna.ld = logdna.ld
  }
  region               = var.region
  resource_group_id    = var.resource_group_id
  enable_archive       = var.enable_archive
  ibmcloud_api_key     = var.ibmcloud_api_key
  logdna_provision     = var.log_analysis_provision
  instance_name        = var.log_analysis_instance_name
  plan                 = var.log_analysis_plan
  manager_key_name     = var.log_analysis_manager_key_name
  manager_key_tags     = var.log_analysis_manager_key_tags
  resource_key_role    = var.log_analysis_resource_key_role
  tags                 = var.log_analysis_tags
  enable_platform_logs = var.enable_platform_logs
  service_endpoints    = var.log_analysis_service_endpoints
  cos_instance_id      = var.log_analysis_cos_instance_id
  cos_bucket_name      = var.log_analysis_cos_bucket_name
  cos_bucket_endpoint  = var.log_analysis_cos_bucket_endpoint
}

# IBM Cloud Monitoring
module "sysdig" {
  source                  = "./modules/sysdig"
  region                  = var.region
  resource_group_id       = var.resource_group_id
  sysdig_provision        = var.cloud_monitoring_provision
  instance_name           = var.cloud_monitoring_instance_name
  plan                    = var.cloud_monitoring_plan
  manager_key_name        = var.cloud_monitoring_manager_key_name
  manager_key_tags        = var.cloud_monitoring_manager_key_tags
  tags                    = var.cloud_monitoring_tags
  enable_platform_metrics = var.enable_platform_metrics
  service_endpoints       = var.cloud_monitoring_service_endpoints
}
