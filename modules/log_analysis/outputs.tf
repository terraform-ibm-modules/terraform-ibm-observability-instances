output "crn" {
  value       = length(ibm_resource_instance.log_analysis) > 0 ? ibm_resource_instance.log_analysis[0].id : null
  description = "The id of the provisioned Log Analysis instance."
}

output "guid" {
  value       = length(ibm_resource_instance.log_analysis) > 0 ? ibm_resource_instance.log_analysis[0].guid : null
  description = "The guid of the provisioned Log Analysis instance."
}

output "name" {
  value       = length(ibm_resource_instance.log_analysis) > 0 ? ibm_resource_instance.log_analysis[0].name : null
  description = "The name of the provisioned Log Analysis instance."
}

output "resource_group_id" {
  value       = length(ibm_resource_instance.log_analysis) > 0 ? ibm_resource_instance.log_analysis[0].resource_group_id : null
  description = "The resource group where Log Analysis instance resides"
}

output "resource_key" {
  value       = length(ibm_resource_key.resource_key) > 0 ? ibm_resource_key.resource_key[0].credentials["service_key"] : null
  description = "Log Analysis service key for agents to use"
  sensitive   = true
}

output "ingestion_key" {
  value       = length(ibm_resource_key.resource_key) > 0 ? ibm_resource_key.resource_key[0].credentials.ingestion_key : null
  description = "Log Analysis ingest key for agents to use"
  sensitive   = true
}

output "manager_key_name" {
  value       = length(ibm_resource_key.resource_key) > 0 ? ibm_resource_key.resource_key[0].name : null
  description = "The Log Analysis manager key name"
}
