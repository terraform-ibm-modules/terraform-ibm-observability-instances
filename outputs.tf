##############################################################################
# Outputs
##############################################################################

# Common
output "region" {
  description = "Region that instance(s) are provisioned to."
  value       = var.region
}

##############################################################################

# LogDNA
output "logdna_crn" {
  value       = module.logdna.logdna_crn
  description = "The id of the provisioned LogDNA instance."
}

output "logdna_guid" {
  value       = module.logdna.logdna_guid
  description = "The guid of the provisioned LogDNA instance."
}

output "logdna_name" {
  value       = module.logdna.logdna_name
  description = "The name of the provisioned LogDNA instance."
}

output "logdna_resource_group_id" {
  value       = module.logdna.logdna_resource_group_id
  description = "The resource group where LogDNA instance resides"
}

output "logdna_resource_key" {
  value       = module.logdna.logdna_resource_key
  description = "LogDNA service key for agents to use"
  sensitive   = true
}

output "logdna_ingestion_key" {
  value       = module.logdna.logdna_ingestion_key
  description = "LogDNA ingest key for agents to use"
  sensitive   = true
}

output "logdna_manager_key_name" {
  value       = module.logdna.logdna_manager_key_name
  description = "The LogDNA manager key name"
}

##############################################################################

# Sysdig
output "sysdig_crn" {
  value       = module.sysdig.sysdig_crn
  description = "The id of the provisioned Sysdig instance."
}

output "sysdig_guid" {
  value       = module.sysdig.sysdig_guid
  description = "The guid of the provisioned Sysdig instance."
}

output "sysdig_name" {
  value       = module.sysdig.sysdig_name
  description = "The name of the provisioned Sysdig instance."
}

output "sysdig_resource_group_id" {
  value       = module.sysdig.sysdig_resource_group_id
  description = "The resource group where Sysdig monitor instance resides"
}

output "sysdig_access_key" {
  value       = module.sysdig.sysdig_access_key
  description = "Sysdig access key for agents to use"
  sensitive   = true
}

output "sysdig_manager_key_name" {
  value       = module.sysdig.sysdig_manager_key_name
  description = "The Sysdig manager key name"
}

##############################################################################

# Activity Tracker
output "activity_tracker_crn" {
  value       = module.activity_tracker.activity_tracker_crn
  description = "The id of the provisioned Activity Tracker instance."
}

output "activity_tracker_guid" {
  value       = module.activity_tracker.activity_tracker_guid
  description = "The guid of the provisioned Activity Tracker instance."
}

output "activity_tracker_name" {
  value       = module.activity_tracker.activity_tracker_name
  description = "The name of the provisioned Activity Tracker instance."
}

output "activity_tracker_resource_group_id" {
  value       = module.activity_tracker.activity_tracker_resource_group_id
  description = "The resource group where Activity Tracker instance resides"
}

output "activity_tracker_resource_key" {
  value       = module.activity_tracker.activity_tracker_resource_key
  description = "The resource/service key for agents to use"
  sensitive   = true
}

output "activity_tracker_manager_key_name" {
  value       = module.activity_tracker.activity_tracker_manager_key_name
  description = "The Activity Tracker manager key name"
}
##############################################################################
