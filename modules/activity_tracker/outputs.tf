########################################################################
# Activity Tracker Event Routing
#########################################################################

# Event Routing Target
output "activity_tracker_targets" {
  value       = local.activity_tracker_targets
  description = "The map of created targets"
}

# Event Routing Route
output "activity_tracker_routes" {
  value       = local.activity_tracker_routes
  description = "The map of created routes"
}
