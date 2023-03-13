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
