##############################################################################
# Outputs
##############################################################################

output "log_analysis_name" {
  value       = module.test_observability_instance_creation.log_analysis_name
  description = "The name of the provisioned LogAnalysis instance."
}

output "cloud_monitoring_name" {
  value       = module.test_observability_instance_creation.cloud_monitoring_name
  description = "The name of the provisioned IBM cloud monitoring instance."
}

output "activity_tracker_name" {
  value       = module.test_observability_instance_creation.activity_tracker_name
  description = "The name of the provisioned Activity Tracker instance."
}
