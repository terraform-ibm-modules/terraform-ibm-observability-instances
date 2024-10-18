########################################################################
# IBM Cloud Metric Routing
#########################################################################

# metric routing to cloud monitoring s2s auth policy
resource "ibm_iam_authorization_policy" "metrics_router_cloud_monitoring" {
  for_each                    = { for target in var.metrics_router_targets : target.target_name => target if !target.skip_mrouter_sysdig_iam_auth_policy }
  source_service_name         = "metrics-router"
  target_service_name         = "sysdig-monitor"
  target_resource_instance_id = regex(".*:(.*)::", each.value.instance_id)[0]
  roles                       = ["Supertenant Metrics Publisher"]
  description                 = "Permit metrics routing service Supertenant Metrics Publisher access to Cloud Monitoring instance ${each.value.instance_id}"
}

resource "ibm_metrics_router_target" "metrics_router_targets" {
  for_each        = { for target in var.metrics_router_targets : target.target_name => target }
  destination_crn = each.value.destination_crn
  name            = each.key
  region          = each.value.target_region
}

resource "ibm_metrics_router_route" "metrics_router_routes" {
  for_each = { for route in var.metric_router_routes : route.route_name => route }
  name     = each.key
  dynamic "rules" {
    for_each = each.value.rules
    content {
      action = rules.value.action
      dynamic "targets" {
        for_each = rules.value.targets
        content {
          id = targets.value.id
        }
      }
      dynamic "inclusion_filters" {
        for_each = rules.value.inclusion_filters
        content {
          operand  = inclusion_filters.value.operand
          operator = inclusion_filters.value.operator
          values   = inclusion_filters.value.values
        }
      }
    }
  }
}

########################################################################
# Metrics Routing Global Settings
#########################################################################

resource "ibm_metrics_router_settings" "metrics_router_settings" {
  dynamic "default_targets" {
    for_each = var.metric_router_settings.default_targets
    content {
      id = default_targets.value.id
    }
  }
  permitted_target_regions  = var.metric_router_settings.permitted_target_regions
  primary_metadata_region   = var.metric_router_settings.primary_metadata_region
  backup_metadata_region    = var.metric_router_settings.backup_metadata_region
  private_api_endpoint_only = var.metric_router_settings.private_api_endpoint_only

  lifecycle {
    create_before_destroy = true
  }
}
