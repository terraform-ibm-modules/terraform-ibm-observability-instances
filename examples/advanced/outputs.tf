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

output "metric_router_targets" {
  value       = module.observability_instances.metrics_router_targets
  description = "The created metrics routing targets."
}

output "metric_router_settings" {
  value       = module.observability_instances.metrics_router_settings
  description = "The global metrics routing settings."
}

output "metric_router_routes" {
  value       = module.observability_instances.metrics_router_routes
  description = "The created metrics routing routes."
}
