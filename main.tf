##############################################################################
# observability-instances-module
##############################################################################

# Input variable validation
locals {
  # tflint-ignore: terraform_unused_declarations
  resource_group_val = var.resource_group_id == null && (var.cloud_monitoring_provision || var.cloud_logs_provision) ? tobool("resource_group_id is a required input when 'cloud_monitoring_provision' or 'cloud_logs_provision' is true") : true
}

# Activity tracker
module "activity_tracker" {
  source                        = "./modules/activity_tracker"
  activity_tracker_routes       = var.activity_tracker_routes
  cos_targets                   = var.at_cos_targets
  eventstreams_targets          = var.at_eventstreams_targets
  cloud_logs_targets            = var.at_cloud_logs_targets
  global_event_routing_settings = var.global_event_routing_settings
}

# IBM Cloud Metrics Routing

module "metric_routing" {
  source                  = "./modules/metrics_routing"
  metrics_router_routes   = var.metrics_router_routes
  metrics_router_settings = var.metrics_router_settings
  metrics_router_targets  = var.metrics_router_targets
}

# IBM Cloud Monitoring
module "cloud_monitoring" {
  count                   = var.cloud_monitoring_provision ? 1 : 0
  source                  = "./modules/cloud_monitoring"
  region                  = var.region
  resource_group_id       = var.resource_group_id
  instance_name           = var.cloud_monitoring_instance_name
  plan                    = var.cloud_monitoring_plan
  manager_key_name        = var.cloud_monitoring_manager_key_name
  manager_key_tags        = var.cloud_monitoring_manager_key_tags
  tags                    = var.cloud_monitoring_tags
  access_tags             = var.cloud_monitoring_access_tags
  enable_platform_metrics = var.enable_platform_metrics
  service_endpoints       = var.cloud_monitoring_service_endpoints
}

# IBM Cloud Logs
module "cloud_logs" {
  count                         = var.cloud_logs_provision || var.existing_cl_instance != null ? 1 : 0
  source                        = "./modules/cloud_logs"
  region                        = var.region
  resource_group_id             = var.resource_group_id
  existing_cl_instance          = var.existing_cl_instance
  instance_name                 = var.cloud_logs_instance_name
  plan                          = var.cloud_logs_plan
  resource_tags                 = var.cloud_logs_tags
  access_tags                   = var.cloud_logs_access_tags
  retention_period              = var.cloud_logs_retention_period
  data_storage                  = var.cloud_logs_data_storage
  service_endpoints             = var.cloud_logs_service_endpoints
  existing_en_instances         = var.cloud_logs_existing_en_instances
  skip_logs_routing_auth_policy = var.skip_logs_routing_auth_policy
  logs_routing_tenant_regions   = var.logs_routing_tenant_regions
  enable_platform_logs          = var.enable_platform_logs
  policies                      = var.cloud_logs_policies
}
