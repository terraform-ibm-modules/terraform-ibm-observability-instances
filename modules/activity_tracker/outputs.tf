output "activity_tracker_crn" {
  value       = length(ibm_resource_instance.activity_tracker) > 0 ? ibm_resource_instance.activity_tracker[0].id : null
  description = "The id of the provisioned Activity Tracker instance."
}

output "activity_tracker_guid" {
  value       = length(ibm_resource_instance.activity_tracker) > 0 ? ibm_resource_instance.activity_tracker[0].guid : null
  description = "The guid of the provisioned Activity Tracker instance."
}
output "activity_tracker_name" {
  value       = length(ibm_resource_instance.activity_tracker) > 0 ? ibm_resource_instance.activity_tracker[0].name : null
  description = "The name of the provisioned Activity Tracker instance."
}

output "activity_tracker_resource_group_id" {
  value       = length(ibm_resource_instance.activity_tracker) > 0 ? ibm_resource_instance.activity_tracker[0].resource_group_id : null
  description = "The resource group where Activity Tracker instance resides"
}

output "activity_tracker_resource_key" {
  value       = length(ibm_resource_instance.activity_tracker) > 0 ? ibm_resource_key.at_resource_key[0].credentials["service_key"] : null
  description = "The resource/service key for agents to use"
  sensitive   = true
}

output "activity_tracker_manager_key_name" {
  value       = length(ibm_resource_instance.activity_tracker) > 0 ? ibm_resource_key.at_resource_key[0].name : null
  description = "The Activity Tracker manager key name"
}
