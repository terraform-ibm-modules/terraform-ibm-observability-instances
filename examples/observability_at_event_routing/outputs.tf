##############################################################################
# Outputs
##############################################################################

output "activity_tracker_name" {
  value       = module.activity_tracker.name
  description = "The name of the provisioned Activity Tracker instance."
}

output "cos_target_id" {
  value       = module.activity_tracker.cos_target_id
  description = "The id of the provisioned COS target route."
}

output "eventstreams_target_id" {
  value       = module.activity_tracker.eventstreams_target_id
  description = "The id of the provisioned event streams target route."
}

output "logdna_target_id" {
  value       = module.activity_tracker.logdna_target_id
  description = "The id of the provisioned LogDNA target route."
}

output "cos_target_name" {
  value       = module.activity_tracker.cos_target_name
  description = "The name of the provisioned COS target."
}

output "eventstreams_target_name" {
  value       = module.activity_tracker.eventstreams_target_name
  description = "The name of the provisioned event streams target."
}

output "logdna_target_name" {
  value       = module.activity_tracker.logdna_target_name
  description = "The name of the provisioned LogDNA target."
}

output "cos_route_name" {
  value       = module.activity_tracker.cos_route_name
  description = "The name of the provisioned COS target route."
}

output "eventstreams_route_name" {
  value       = module.activity_tracker.eventstreams_route_name
  description = "The name of the provisioned event streams target route."
}

output "logdna_route_name" {
  value       = module.activity_tracker.logdna_route_name
  description = "The name of the provisioned LogDNA target route."
}
