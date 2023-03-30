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
  value       = module.logdna.crn
  description = "The id of the provisioned LogDNA instance."
}

output "log_analysis_guid" {
  value       = module.logdna.guid
  description = "The guid of the provisioned LogDNA instance."
}

output "log_analysis_name" {
  value       = module.logdna.name
  description = "The name of the provisioned LogDNA instance."
}

output "log_analysis_resource_group_id" {
  value       = module.logdna.resource_group_id
  description = "The resource group where LogDNA instance resides"
}

output "log_analysis_resource_key" {
  value       = module.logdna.resource_key
  description = "LogDNA service key for agents to use"
  sensitive   = true
}

output "log_analysis_ingestion_key" {
  value       = module.logdna.ingestion_key
  description = "LogDNA ingest key for agents to use"
  sensitive   = true
}

output "log_analysis_manager_key_name" {
  value       = module.logdna.manager_key_name
  description = "The LogDNA manager key name"
}

##############################################################################

# Sysdig
output "cloud_monitoring_crn" {
  value       = module.sysdig.crn
  description = "The id of the provisioned Sysdig instance."
}

output "cloud_monitoring_guid" {
  value       = module.sysdig.guid
  description = "The guid of the provisioned Sysdig instance."
}

output "cloud_monitoring_name" {
  value       = module.sysdig.name
  description = "The name of the provisioned Sysdig instance."
}

output "cloud_monitoring_resource_group_id" {
  value       = module.sysdig.resource_group_id
  description = "The resource group where Sysdig monitor instance resides"
}

output "cloud_monitoring_access_key" {
  value       = module.sysdig.access_key
  description = "Sysdig access key for agents to use"
  sensitive   = true
}

output "cloud_monitoring_manager_key_name" {
  value       = module.sysdig.manager_key_name
  description = "The Sysdig manager key name"
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
