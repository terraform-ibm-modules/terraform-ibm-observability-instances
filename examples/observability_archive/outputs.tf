##############################################################################
# Outputs
##############################################################################

output "log_analysis_name" {
  value       = module.observability_instance_creation.log_analysis_name
  description = "The name of the provisioned LogDNA instance."
}

output "cos_bucket" {
  value       = module.cos
  description = "Cloud Object Storage information"
}
