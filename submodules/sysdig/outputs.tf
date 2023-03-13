output "sysdig_crn" {
  value       = length(ibm_resource_instance.sysdig) > 0 ? ibm_resource_instance.sysdig[0].id : null
  description = "The id of the provisioned Sysdig instance."
}

output "sysdig_guid" {
  value       = length(ibm_resource_instance.sysdig) > 0 ? ibm_resource_instance.sysdig[0].guid : null
  description = "The guid of the provisioned Sysdig instance."
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
