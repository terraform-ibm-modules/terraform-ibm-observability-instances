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
  value       = module.log_analysis.crn
  description = "The id of the provisioned Log Analysis instance."
}

output "log_analysis_guid" {
  value       = module.log_analysis.guid
  description = "The guid of the provisioned Log Analysis instance."
}

output "log_analysis_name" {
  value       = module.log_analysis.name
  description = "The name of the provisioned Log Analysis instance."
}

output "log_analysis_resource_group_id" {
  value       = module.log_analysis.resource_group_id
  description = "The resource group where Log Analysis instance resides"
}

output "log_analysis_resource_key" {
  value       = module.log_analysis.resource_key
  description = "Log Analysis service key for agents to use"
  sensitive   = true
}

output "log_analysis_ingestion_key" {
  value       = module.log_analysis.ingestion_key
  description = "Log Analysis ingest key for agents to use"
  sensitive   = true
}

output "log_analysis_manager_key_name" {
  value       = module.log_analysis.manager_key_name
  description = "The Log Analysis manager key name"
}

##############################################################################

# IBM Cloud Monitoring
output "cloud_monitoring_crn" {
  value       = module.cloud_monitoring.crn
  description = "The id of the provisioned IBM cloud monitoring instance."
}

output "cloud_monitoring_guid" {
  value       = module.cloud_monitoring.guid
  description = "The guid of the provisioned IBM cloud monitoring instance."
}

output "cloud_monitoring_name" {
  value       = module.cloud_monitoring.name
  description = "The name of the provisioned IBM cloud monitoring instance."
}

output "cloud_monitoring_resource_group_id" {
  value       = module.cloud_monitoring.resource_group_id
  description = "The resource group where IBM cloud monitoring monitor instance resides"
}

output "cloud_monitoring_access_key" {
  value       = module.cloud_monitoring.access_key
  description = "IBM cloud monitoring access key for agents to use"
  sensitive   = true
}

output "cloud_monitoring_manager_key_name" {
  value       = module.cloud_monitoring.manager_key_name
  description = "The IBM cloud monitoring manager key name"
}

##############################################################################

# Activity Tracker
output "activity_tracker_crn" {
  value       = module.activity_tracker.crn
  description = "The id of the provisioned Activity Tracker instance."
}

output "activity_tracker_guid" {
  value       = module.activity_tracker.guid
  description = "The guid of the provisioned Activity Tracker instance."
}

output "activity_tracker_name" {
  value       = module.activity_tracker.name
  description = "The name of the provisioned Activity Tracker instance."
}

output "activity_tracker_resource_group_id" {
  value       = module.activity_tracker.resource_group_id
  description = "The resource group where Activity Tracker instance resides"
}

output "activity_tracker_resource_key" {
  value       = module.activity_tracker.resource_key
  description = "The resource/service key for agents to use"
  sensitive   = true
}

output "activity_tracker_manager_key_name" {
  value       = module.activity_tracker.manager_key_name
  description = "The Activity Tracker manager key name"
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
