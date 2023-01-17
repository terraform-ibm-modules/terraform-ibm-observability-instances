##############################################################################
# Outputs
##############################################################################

output "activity_tracker_name" {
  value       = module.test_observability_instance_creation.activity_tracker_name
  description = "The name of the provisioned Activity Tracker instance."
}

output "es_instance" {
  value       = ibm_resource_instance.es_instance_1
  description = "event streams instance"
}

output "topic" {
  value       = ibm_event_streams_topic.es_topic_1
  description = "event streams topic instance"
}
