##############################################################################
# Outputs
##############################################################################

output "cloud_monitoring_crn" {
  value       = module.observability_instances.cloud_monitoring_crn
  description = "The crn of the provisioned IBM Cloud Monitoring instance."
}

output "cloud_logs_crn" {
  value       = module.observability_instances.cloud_logs_crn
  description = "The crn of the provisioned IBM Cloud Logs instance."
}
