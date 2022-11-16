##############################################################################
# Outputs
##############################################################################

output "logdna_name" {
  value       = module.test_observability_instance_creation.logdna_name
  description = "The name of the provisioned LogDNA instance."
}

output "sysdig_name" {
  value       = module.test_observability_instance_creation.sysdig_name
  description = "The name of the provisioned Sysdig instance."
}

output "activity_tracker_name" {
  value       = module.test_observability_instance_creation.activity_tracker_name
  description = "The name of the provisioned Activity Tracker instance."
}
