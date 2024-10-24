output "crn" {
  value       = ibm_resource_instance.cloud_logs.id
  description = "The id of the provisioned Cloud Logs instance."
}

output "guid" {
  value       = ibm_resource_instance.cloud_logs.guid
  description = "The guid of the provisioned Cloud Logs instance."
}

output "name" {
  value       = ibm_resource_instance.cloud_logs.name
  description = "The name of the provisioned Cloud Logs instance."
}

output "resource_group_id" {
  value       = ibm_resource_instance.cloud_logs.resource_group_id
  description = "The resource group where Cloud Logs instance resides."
}

output "ingress_endpoint" {
  value       = ibm_resource_instance.cloud_logs.extensions.external_ingress
  description = "The public ingress endpoint of the provisioned Cloud Logs instance."
}

output "ingress_private_endpoint" {
  value       = ibm_resource_instance.cloud_logs.extensions.external_ingress_private
  description = "The private ingress endpoint of the provisioned Cloud Logs instance."
}

output "logs_policy_id" {
  value       = ibm_logs_policy.logs_policy_instance[0].policy_id
  description = "The id of the Cloud logs policy created."
}

output "logs_policy_status" {
  value       = ibm_logs_policy.logs_policy_instance[0].enabled
  description = "The status of the Cloud logs policy created."
}

output "logs_policy_order" {
  value       = ibm_logs_policy.logs_policy_instance[0].order
  description = "The order of the policy created in relation to the other policies."
}
