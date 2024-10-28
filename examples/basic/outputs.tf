##############################################################################
# Outputs
##############################################################################

output "cloud_monitoring_name" {
  value       = module.observability_instances.cloud_monitoring_name
  description = "The name of the provisioned IBM cloud monitoring instance."
}

output "cloud_logs_name" {
  value       = module.observability_instances.cloud_logs_name
  description = "The name of the provisioned Cloud Logs instance."
}

output "cloud_logs_guid" {
  value       = module.observability_instances.cloud_logs_guid
  description = "The name of the provisioned Cloud Logs instance."
}

output "logs_policies_details" {
  value       = module.observability_instances.logs_policies_details
  description = "The details of the Cloud logs policies created."
}
