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

output "logs_policy_id" {
  value       = module.observability_instances.logs_policy_id
  description = "The id of the Cloud logs policy created."
}

output "logs_policy_status" {
  value       = module.observability_instances.logs_policy_status
  description = "The status of the Cloud logs policy created."
}

output "logs_policy_order" {
  value       = module.observability_instances.logs_policy_order
  description = "The order of the policy created in relation to the other policies."
}
