output "crn" {
  value       = ibm_resource_instance.cloud_logs.id
  description = "The id of the provisioned Cloud Logs instance."
}

output "guid" {
  value       = ibm_resource_instance.cloud_logs.guid
  description = "The guid of the provisioned Cloud Logs instance."
}

output "name" {
  value       = ibm_resource_instance.cloud_logs.name
  description = "The name of the provisioned Cloud Logs instance."
}

output "resource_group_id" {
  value       = ibm_resource_instance.cloud_logs.resource_group_id
  description = "The resource group where Cloud Logs instance resides"
}
