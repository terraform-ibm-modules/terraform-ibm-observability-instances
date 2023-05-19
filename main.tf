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
  access_tags                   = var.activity_tracker_access_tags
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

# LogDNA
module "logdna" {
  source = "./modules/logdna"
  providers = {
    logdna.ld = logdna.ld
  }
  region               = var.region
  resource_group_id    = var.resource_group_id
  enable_archive       = var.enable_archive
  ibmcloud_api_key     = var.ibmcloud_api_key
  logdna_provision     = var.logdna_provision
  instance_name        = var.logdna_instance_name
  plan                 = var.logdna_plan
  manager_key_name     = var.logdna_manager_key_name
  manager_key_tags     = var.logdna_manager_key_tags
  resource_key_role    = var.logdna_resource_key_role
  tags                 = var.logdna_tags
  access_tags          = var.logdna_access_tags
  enable_platform_logs = var.enable_platform_logs
  service_endpoints    = var.logdna_service_endpoints
  cos_instance_id      = var.logdna_cos_instance_id
  cos_bucket_name      = var.logdna_cos_bucket_name
  cos_bucket_endpoint  = var.logdna_cos_bucket_endpoint
}

# Sysdig
module "sysdig" {
  source                  = "./modules/sysdig"
  region                  = var.region
  resource_group_id       = var.resource_group_id
  sysdig_provision        = var.sysdig_provision
  instance_name           = var.sysdig_instance_name
  plan                    = var.sysdig_plan
  manager_key_name        = var.sysdig_manager_key_name
  manager_key_tags        = var.sysdig_manager_key_tags
  tags                    = var.sysdig_tags
  access_tags             = var.sysdig_access_tags
  enable_platform_metrics = var.enable_platform_metrics
  service_endpoints       = var.sysdig_service_endpoints
}
