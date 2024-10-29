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
