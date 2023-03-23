##############################################################################
# Outputs
##############################################################################

output "activity_tracker_name" {
  value       = module.activity_tracker.name
  description = "The name of the provisioned Activity Tracker instance."
}

output "activity_tracker_targets" {
  value       = module.activity_tracker.activity_tracker_targets
  description = "The map of created targets"
}

output "activity_tracker_routes" {
  value       = module.activity_tracker.activity_tracker_routes
  description = "The map of created routes"
}
