##############################################################################
# Outputs
##############################################################################

output "activity_tracker_name" {
  value       = module.test_observability_instance_creation.activity_tracker_name
  description = "The name of the provisioned Activity Tracker instance."
}


