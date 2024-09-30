##############################################################################
# Outputs
##############################################################################

# Common
output "region" {
  description = "Region that instance(s) are provisioned to."
  value       = var.region
}

##############################################################################

# Log Analysis
output "log_analysis_crn" {
  value       = var.log_analysis_provision ? module.log_analysis[0].crn : null
  description = "DEPRECATED: The id of the provisioned Log Analysis instance."
}

output "log_analysis_guid" {
  value       = var.log_analysis_provision ? module.log_analysis[0].guid : null
  description = "DEPRECATED: The guid of the provisioned Log Analysis instance."
}

output "log_analysis_name" {
  value       = var.log_analysis_provision ? module.log_analysis[0].name : null
  description = "DEPRECATED: The name of the provisioned Log Analysis instance."
}

output "log_analysis_resource_group_id" {
  value       = var.log_analysis_provision ? module.log_analysis[0].resource_group_id : null
  description = "DEPRECATED: The resource group where Log Analysis instance resides"
}

output "log_analysis_resource_key" {
  value       = var.log_analysis_provision ? module.log_analysis[0].resource_key : null
  description = "DEPRECATED: Log Analysis service key for agents to use"
  sensitive   = true
}

output "log_analysis_ingestion_key" {
  value       = var.log_analysis_provision ? module.log_analysis[0].ingestion_key : null
  description = "DEPRECATED: Log Analysis ingest key for agents to use"
  sensitive   = true
}

output "log_analysis_manager_key_name" {
  value       = var.log_analysis_provision ? module.log_analysis[0].manager_key_name : null
  description = "DEPRECATED: The Log Analysis manager key name"
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

##############################################################################

# Activity Tracker
output "activity_tracker_crn" {
  value       = module.activity_tracker.crn
  description = "DEPRECATED: The id of the provisioned Activity Tracker instance."
}

output "activity_tracker_guid" {
  value       = module.activity_tracker.guid
  description = "DEPRECATED: The guid of the provisioned Activity Tracker instance."
}

output "activity_tracker_name" {
  value       = module.activity_tracker.name
  description = "DEPRECATED: The name of the provisioned Activity Tracker instance."
}

output "activity_tracker_resource_group_id" {
  value       = module.activity_tracker.resource_group_id
  description = "DEPRECATED: The resource group where Activity Tracker instance resides"
}

output "activity_tracker_resource_key" {
  value       = module.activity_tracker.resource_key
  description = "DEPRECATED: The resource/service key for agents to use"
  sensitive   = true
}

output "activity_tracker_manager_key_name" {
  value       = module.activity_tracker.manager_key_name
  description = "DEPRECATED: The Activity Tracker manager key name"
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
