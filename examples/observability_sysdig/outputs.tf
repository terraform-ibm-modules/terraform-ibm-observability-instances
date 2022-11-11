##############################################################################
# Outputs
##############################################################################

output "sysdig_name" {
  value       = module.test_observability_instance_creation.sysdig_name
  description = "The name of the provisioned Sysdig instance."
}
