output "crn" {
  value       = length(ibm_resource_instance.logdna) > 0 ? ibm_resource_instance.logdna[0].id : null
  description = "The id of the provisioned LogDNA instance."
}

output "guid" {
  value       = length(ibm_resource_instance.logdna) > 0 ? ibm_resource_instance.logdna[0].guid : null
  description = "The guid of the provisioned LogDNA instance."
}

output "name" {
  value       = length(ibm_resource_instance.logdna) > 0 ? ibm_resource_instance.logdna[0].name : null
  description = "The name of the provisioned LogDNA instance."
}

output "resource_group_id" {
  value       = length(ibm_resource_instance.logdna) > 0 ? ibm_resource_instance.logdna[0].resource_group_id : null
  description = "The resource group where LogDNA instance resides"
}

output "resource_key" {
  value       = length(ibm_resource_key.resource_key) > 0 ? ibm_resource_key.resource_key[0].credentials["service_key"] : null
  description = "LogDNA service key for agents to use"
  sensitive   = true
}

output "ingestion_key" {
  value       = length(ibm_resource_key.resource_key) > 0 ? ibm_resource_key.resource_key[0].credentials.ingestion_key : null
  description = "LogDNA ingest key for agents to use"
  sensitive   = true
}

output "manager_key_name" {
  value       = length(ibm_resource_key.resource_key) > 0 ? ibm_resource_key.resource_key[0].name : null
  description = "The LogDNA manager key name"
}
