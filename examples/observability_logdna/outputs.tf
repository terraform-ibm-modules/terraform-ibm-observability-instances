##############################################################################
# Outputs
##############################################################################

output "logdna_name" {
  value       = module.test_observability_instance_creation.logdna_name
  description = "The name of the provisioned LogDNA instance."
}
