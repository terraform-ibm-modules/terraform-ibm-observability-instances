########################################################################
# Metric Router Event Routing
#########################################################################

# Metric Routing Target

output "metric_router_targets" {
  value       = ibm_metrics_router_target.metrics_router_targets
  description = "The created metrics routing targets."
}

# Metric Routing Routes

output "metric_router_routes" {
  value       = ibm_metrics_router_route.metrics_router_routes
  description = "The created metrics routing routes."
}

# Metric Routing Global Settings

output "metric_router_settings" {
  value       = ibm_metrics_router_settings.metrics_router_settings
  description = "The global metrics routing settings."
}
