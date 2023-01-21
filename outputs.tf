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
  value       = length(ibm_resource_instance.logdna) > 0 ? ibm_resource_instance.logdna[0].id : null
  description = "The id of the provisioned LogDNA instance."
}

output "logdna_guid" {
  value       = length(ibm_resource_instance.logdna) > 0 ? ibm_resource_instance.logdna[0].guid : null
  description = "The guid of the provisioned LogDNA instance."
}

output "logdna_name" {
  value       = length(ibm_resource_instance.logdna) > 0 ? ibm_resource_instance.logdna[0].name : null
  description = "The name of the provisioned LogDNA instance."
}

output "logdna_resource_group_id" {
  value       = length(ibm_resource_instance.logdna) > 0 ? ibm_resource_instance.logdna[0].resource_group_id : null
  description = "The resource group where LogDNA instance resides"
}

output "logdna_resource_key" {
  value       = length(ibm_resource_key.log_dna_resource_key) > 0 ? ibm_resource_key.log_dna_resource_key[0].credentials["service_key"] : null
  description = "LogDNA service key for agents to use"
  sensitive   = true
}

output "logdna_ingestion_key" {
  value       = length(ibm_resource_key.log_dna_resource_key) > 0 ? ibm_resource_key.log_dna_resource_key[0].credentials.ingestion_key : null
  description = "LogDNA ingest key for agents to use"
  sensitive   = true
}

output "logdna_manager_key_name" {
  value       = length(ibm_resource_key.log_dna_resource_key) > 0 ? ibm_resource_key.log_dna_resource_key[0].name : null
  description = "The LogDNA manager key name"
}

##############################################################################

# Sysdig
output "sysdig_crn" {
  value       = length(ibm_resource_instance.sysdig) > 0 ? ibm_resource_instance.sysdig[0].id : null
  description = "The id of the provisioned Sysdig instance."
}

output "sysdig_guid" {
  value       = length(ibm_resource_instance.sysdig) > 0 ? ibm_resource_instance.sysdig[0].guid : null
  description = "The guid of the provisioned Sisdig instance."
}

output "sysdig_name" {
  value       = length(ibm_resource_instance.sysdig) > 0 ? ibm_resource_instance.sysdig[0].name : null
  description = "The name of the provisioned Sysdig instance."
}

output "sysdig_resource_group_id" {
  value       = length(ibm_resource_instance.sysdig) > 0 ? ibm_resource_instance.sysdig[0].resource_group_id : null
  description = "The resource group where Sysdig monitor instance resides"
}

output "sysdig_access_key" {
  value       = length(ibm_resource_key.sysdig_resource_key) > 0 ? ibm_resource_key.sysdig_resource_key[0].credentials["Sysdig Access Key"] : null
  description = "Sysdig access key for agents to use"
  sensitive   = true
}

output "sysdig_manager_key_name" {
  value       = length(ibm_resource_key.sysdig_resource_key) > 0 ? ibm_resource_key.sysdig_resource_key[0].name : null
  description = "The Sysdig manager key name"
}

##############################################################################

# Activity Tracker CRN/ID
output "activity_tracker_crn" {
  value       = length(ibm_resource_instance.activity_tracker) > 0 ? ibm_resource_instance.activity_tracker[0].id : null
  description = "The id of the provisioned Activity Tracker instance."
}

# Activity Tracker GUID
output "activity_tracker_guid" {
  value       = length(ibm_resource_instance.activity_tracker) > 0 ? ibm_resource_instance.activity_tracker[0].guid : null
  description = "The guid of the provisioned Activity Tracker instance."
}
# Activity Tracker Name
output "activity_tracker_name" {
  value       = length(ibm_resource_instance.activity_tracker) > 0 ? ibm_resource_instance.activity_tracker[0].name : null
  description = "The name of the provisioned Activity Tracker instance."
}

output "activity_tracker_resource_group_id" {
  value       = length(ibm_resource_instance.activity_tracker) > 0 ? ibm_resource_instance.activity_tracker[0].resource_group_id : null
  description = "The resource group where Activity Tracker instance resides"
}

# Activity Tracker Resource/Service Key
output "activity_tracker_resource_key" {
  value       = length(ibm_resource_instance.activity_tracker) > 0 ? ibm_resource_key.at_resource_key[0].credentials["service_key"] : null
  description = "The resource/service key for agents to use"
  sensitive   = true
}

# Activity Tracker Resource/Service Key name
output "activity_tracker_manager_key_name" {
  value       = length(ibm_resource_instance.activity_tracker) > 0 ? ibm_resource_key.at_resource_key[0].name : null
  description = "The Activity Tracker manager key name"
}

##############################################################################

# Event Routing Target
output "cos_target_name" {
  value       = length(ibm_atracker_target.atracker_cos_target) > 0 ? ibm_atracker_target.atracker_cos_target[0].name : null
  description = "The name of the provisioned COS target."
}

output "eventstreams_target_name" {
  value       = length(ibm_atracker_target.atracker_eventstreams_target) > 0 ? ibm_atracker_target.atracker_eventstreams_target[0].name : null
  description = "The name of the provisioned event streams target."
}

output "logdna_target_name" {
  value       = length(ibm_atracker_target.atracker_logdna_target) > 0 ? ibm_atracker_target.atracker_logdna_target[0].name : null
  description = "The name of the provisioned LogDNA target."
}


# Event Routing Route
output "cos_route_name" {
  value       = length(ibm_atracker_route.atracker_cos_route) > 0 ? ibm_atracker_route.atracker_cos_route[0].name : null
  description = "The name of the provisioned COS target route."
}

output "logdna_route_name" {
  value       = length(ibm_atracker_route.atracker_logdna_route) > 0 ? ibm_atracker_route.atracker_logdna_route[0].name : null
  description = "The name of the provisioned LogDNA target route."
}

output "eventstreams_route_name" {
  value       = length(ibm_atracker_route.atracker_eventstreams_route) > 0 ? ibm_atracker_route.atracker_eventstreams_route[0].name : null
  description = "The name of the provisioned event streams target route."
}
