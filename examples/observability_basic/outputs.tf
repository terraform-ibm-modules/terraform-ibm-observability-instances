##############################################################################
# Outputs
##############################################################################

output "logdna_name" {
  value       = module.activity_tracker.logdna_name
  description = "The name of the provisioned LogDNA instance."
}

output "sysdig_name" {
  value       = module.activity_tracker.sysdig_name
  description = "The name of the provisioned Sysdig instance."
}

output "activity_tracker_name" {
  value       = module.activity_tracker.activity_tracker_name
  description = "The name of the provisioned Activity Tracker instance."
}
