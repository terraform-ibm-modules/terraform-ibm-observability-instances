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

output "cloud_logs_policies" {
  value       = module.observability_instances.logs_policies_details
  description = "The details of the Cloud logs policies created."
}
