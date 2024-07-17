output "crn" {
  value       = length(ibm_resource_instance.cloud_logs) > 0 ? ibm_resource_instance.cloud_logs[0].id : null
  description = "The id of the provisioned Cloud Logs instance."
}

output "guid" {
  value       = length(ibm_resource_instance.cloud_logs) > 0 ? ibm_resource_instance.cloud_logs[0].guid : null
  description = "The guid of the provisioned Cloud Logs instance."
}

output "name" {
  value       = length(ibm_resource_instance.cloud_logs) > 0 ? ibm_resource_instance.cloud_logs[0].name : null
  description = "The name of the provisioned Cloud Logs instance."
}

output "resource_group_id" {
  value       = length(ibm_resource_instance.cloud_logs) > 0 ? ibm_resource_instance.cloud_logs[0].resource_group_id : null
  description = "The resource group where Cloud Logs instance resides"
}
