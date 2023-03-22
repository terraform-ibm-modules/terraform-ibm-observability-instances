output "crn" {
  value       = length(ibm_resource_instance.activity_tracker) > 0 ? ibm_resource_instance.activity_tracker[0].id : null
  description = "The id of the provisioned Activity Tracker instance."
}

output "guid" {
  value       = length(ibm_resource_instance.activity_tracker) > 0 ? ibm_resource_instance.activity_tracker[0].guid : null
  description = "The guid of the provisioned Activity Tracker instance."
}
output "name" {
  value       = length(ibm_resource_instance.activity_tracker) > 0 ? ibm_resource_instance.activity_tracker[0].name : null
  description = "The name of the provisioned Activity Tracker instance."
}

output "resource_group_id" {
  value       = length(ibm_resource_instance.activity_tracker) > 0 ? ibm_resource_instance.activity_tracker[0].resource_group_id : null
  description = "The resource group where Activity Tracker instance resides"
}

output "resource_key" {
  value       = length(ibm_resource_instance.activity_tracker) > 0 ? ibm_resource_key.resource_key[0].credentials["service_key"] : null
  description = "The resource/service key for agents to use"
  sensitive   = true
}

output "manager_key_name" {
  value       = length(ibm_resource_instance.activity_tracker) > 0 ? ibm_resource_key.resource_key[0].name : null
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

output "cos_target_id" {
  value       = length(ibm_atracker_target.atracker_cos_target) > 0 ? ibm_atracker_target.atracker_cos_target[0].id : null
  description = "The id of the provisioned COS target."
}

output "eventstreams_target_id" {
  value       = length(ibm_atracker_target.atracker_eventstreams_target) > 0 ? ibm_atracker_target.atracker_eventstreams_target[0].id : null
  description = "The id of the provisioned event streams target."
}

output "logdna_target_id" {
  value       = length(ibm_atracker_target.atracker_logdna_target) > 0 ? ibm_atracker_target.atracker_logdna_target[0].id : null
  description = "The id of the provisioned LogDNA target."
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
