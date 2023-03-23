##############################################################################
# Outputs
##############################################################################

output "activity_tracker_name" {
  value       = module.activity_tracker.name
  description = "The name of the provisioned Activity Tracker instance."
}

output "activity_tracker_targets" {
  value       = module.activity_tracker.activity_tracker_targets
  description = "Map of created targets"
}

output "activity_tracker_routes" {
  value       = module.activity_tracker.activity_tracker_routes
  description = "Map of created routes"
}
