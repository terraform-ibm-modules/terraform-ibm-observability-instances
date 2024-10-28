##############################################################################
# Outputs
##############################################################################

# Common
output "region" {
  description = "Region that instance(s) are provisioned to."
  value       = var.region
}

##############################################################################

# IBM Cloud Monitoring
output "cloud_monitoring_crn" {
  value       = length(module.cloud_monitoring) > 0 ? module.cloud_monitoring[0].crn : null
  description = "The id of the provisioned IBM cloud monitoring instance."
}

output "cloud_monitoring_guid" {
  value       = length(module.cloud_monitoring) > 0 ? module.cloud_monitoring[0].guid : null
  description = "The guid of the provisioned IBM cloud monitoring instance."
}

output "cloud_monitoring_name" {
  value       = length(module.cloud_monitoring) > 0 ? module.cloud_monitoring[0].name : null
  description = "The name of the provisioned IBM cloud monitoring instance."
}

output "cloud_monitoring_resource_group_id" {
  value       = length(module.cloud_monitoring) > 0 ? module.cloud_monitoring[0].resource_group_id : null
  description = "The resource group where IBM cloud monitoring monitor instance resides"
}

output "cloud_monitoring_access_key" {
  value       = length(module.cloud_monitoring) > 0 ? module.cloud_monitoring[0].access_key : null
  description = "IBM cloud monitoring access key for agents to use"
  sensitive   = true
}

output "cloud_monitoring_manager_key_name" {
  value       = length(module.cloud_monitoring) > 0 ? module.cloud_monitoring[0].manager_key_name : null
  description = "The IBM cloud monitoring manager key name"
}

########################################################################
# Activity Tracker Event Routing
#########################################################################

output "activity_tracker_targets" {
  value       = module.activity_tracker.activity_tracker_targets
  description = "The map of created targets"
}

output "activity_tracker_routes" {
  value       = module.activity_tracker.activity_tracker_routes
  description = "The map of created routes"
}

##############################################################################

# IBM Cloud Logs
output "cloud_logs_crn" {
  value       = length(module.cloud_logs) > 0 ? module.cloud_logs[0].crn : null
  description = "The id of the provisioned Cloud Logs instance."
}

output "cloud_logs_guid" {
  value       = length(module.cloud_logs) > 0 ? module.cloud_logs[0].guid : null
  description = "The guid of the provisioned Cloud Logs instance."
}

output "cloud_logs_name" {
  value       = length(module.cloud_logs) > 0 ? module.cloud_logs[0].name : null
  description = "The name of the provisioned Cloud Logs instance."
}

output "cloud_logs_resource_group_id" {
  value       = length(module.cloud_logs) > 0 ? module.cloud_logs[0].resource_group_id : null
  description = "The resource group where Cloud Logs instance resides."
}

output "cloud_logs_ingress_endpoint" {
  value       = length(module.cloud_logs) > 0 ? module.cloud_logs[0].ingress_endpoint : null
  description = "The public ingress endpoint of the provisioned Cloud Logs instance."
}

output "cloud_logs_ingress_private_endpoint" {
  value       = length(module.cloud_logs) > 0 ? module.cloud_logs[0].ingress_private_endpoint : null
  description = "The private ingress endpoint of the provisioned Cloud Logs instance."
}

########################################################################
# Metrics Routing
#########################################################################

output "metrics_router_targets" {
  value       = module.metric_routing.metrics_router_targets
  description = "The created metrics routing targets."
}

output "metrics_router_settings" {
  value       = module.metric_routing.metrics_router_settings
  description = "The global metrics routing settings."
}

output "metrics_router_routes" {
  value       = module.metric_routing.metrics_router_routes
  description = "The created metrics routing routes."
}
