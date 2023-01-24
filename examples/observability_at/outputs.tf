##############################################################################
# Outputs
##############################################################################

output "activity_tracker_name" {
  value       = module.test_observability_instance_creation.activity_tracker_name
  description = "The name of the provisioned Activity Tracker instance."
}


output "cos_target_name" {
  value       = module.test_observability_instance_creation.cos_target_name
  description = "The name of the provisioned COS target."
}

output "eventstreams_target_name" {
  value       = module.test_observability_instance_creation.eventstreams_target_name
  description = "The name of the provisioned event streams target."
}

output "logdna_target_name" {
  value       = module.test_observability_instance_creation.logdna_target_name
  description = "The name of the provisioned LogDNA target."
}

output "cos_route_name" {
  value       = module.test_observability_instance_creation.cos_route_name
  description = "The name of the provisioned COS target route."
}

output "eventstreams_route_name" {
  value       = module.test_observability_instance_creation.eventstreams_route_name
  description = "The name of the provisioned event streams target route."
}

output "logdna_route_name" {
  value       = module.test_observability_instance_creation.logdna_route_name
  description = "The name of the provisioned LogDNA target route."
}
