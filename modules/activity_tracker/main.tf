########################################################################
# Activity Tracker Event Routing
#########################################################################

resource "time_sleep" "wait_for_authorization_policy" {
  depends_on      = [ibm_iam_authorization_policy.atracker_cos]
  create_duration = "30s"
}

# atracker to COS s2s auth policy
resource "ibm_iam_authorization_policy" "atracker_cos" {
  for_each                    = nonsensitive({ for target in var.cos_targets : target.target_name => target if target.service_to_service_enabled && !target.skip_atracker_cos_iam_auth_policy })
  source_service_name         = "atracker"
  target_service_name         = "cloud-object-storage"
  target_resource_instance_id = regex(".*:(.*)::", each.value.instance_id)[0]
  roles                       = ["Object Writer"]
  description                 = "Permit AT service Object Writer access to COS instance ${each.value.instance_id}"
}

resource "time_sleep" "wait_for_cloud_logs_auth_policy" {
  depends_on      = [ibm_iam_authorization_policy.atracker_cloud_logs]
  create_duration = "30s"
}

# atracker to cloud logs s2s auth policy
resource "ibm_iam_authorization_policy" "atracker_cloud_logs" {
  for_each                    = { for target in var.cloud_logs_targets : target.target_name => target }
  source_service_name         = "atracker"
  target_service_name         = "logs"
  target_resource_instance_id = regex(".*:(.*)::", each.value.instance_id)[0]
  roles                       = ["Sender"]
  description                 = "Permit AT service Sender access to Cloud Logs instance ${each.value.instance_id}"
}

# workaround for https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4478
resource "time_sleep" "wait_for_event_stream_auth_policy" {
  depends_on      = [ibm_iam_authorization_policy.atracker_es]
  create_duration = "30s"
}

# atracker to event stream s2s auth policy
resource "ibm_iam_authorization_policy" "atracker_es" {
  for_each                    = nonsensitive({ for target in var.eventstreams_targets : target.target_name => target if target.service_to_service_enabled && !target.skip_atracker_es_iam_auth_policy })
  source_service_name         = "atracker"
  target_service_name         = "messagehub"
  target_resource_instance_id = regex(".*:(.*)::", each.value.instance_id)[0]
  roles                       = ["Writer"]
  description                 = "Permit AT service `Writer` access to the eventstream instance ${each.value.instance_id}"
}

# COS targets
resource "ibm_atracker_target" "atracker_cos_targets" {
  depends_on = [time_sleep.wait_for_authorization_policy]
  for_each   = nonsensitive({ for target in var.cos_targets : target.target_name => target })
  cos_endpoint {
    endpoint                   = each.value.endpoint
    bucket                     = each.value.bucket_name
    target_crn                 = each.value.instance_id
    api_key                    = each.value.api_key
    service_to_service_enabled = each.value.service_to_service_enabled
  }
  name        = each.key
  target_type = "cloud_object_storage"
  region      = each.value.target_region
}

# Event Streams targets
resource "ibm_atracker_target" "atracker_eventstreams_targets" {
  depends_on = [time_sleep.wait_for_event_stream_auth_policy]
  for_each   = nonsensitive({ for target in var.eventstreams_targets : target.target_name => target })
  eventstreams_endpoint {
    target_crn                 = each.value.instance_id
    brokers                    = each.value.brokers
    topic                      = each.value.topic
    api_key                    = each.value.api_key
    service_to_service_enabled = each.value.service_to_service_enabled
  }
  name        = each.key
  target_type = "event_streams"
  region      = each.value.target_region
}

# Cloud Logs targets
resource "ibm_atracker_target" "atracker_cloud_logs_targets" {
  depends_on = [time_sleep.wait_for_cloud_logs_auth_policy]
  for_each   = { for target in var.cloud_logs_targets : target.target_name => target if !target.skip_atracker_cloud_logs_iam_auth_policy }
  cloudlogs_endpoint {
    target_crn = each.value.instance_id
  }
  name        = each.key
  target_type = "cloud_logs"
  region      = each.value.target_region
}

# Routes
resource "ibm_atracker_route" "atracker_routes" {
  for_each = { for route in var.activity_tracker_routes : route.route_name => route }
  name     = each.key
  rules {
    locations  = each.value.locations
    target_ids = each.value.target_ids
  }
  lifecycle {
    create_before_destroy = true
  }
}

########################################################################
# Event Routing Global Settings
#########################################################################

resource "ibm_atracker_settings" "atracker_settings" {
  count                     = length(var.global_event_routing_settings == null ? [] : [1])
  default_targets           = var.global_event_routing_settings.default_targets
  metadata_region_primary   = var.global_event_routing_settings.metadata_region_primary
  metadata_region_backup    = var.global_event_routing_settings.metadata_region_backup
  permitted_target_regions  = var.global_event_routing_settings.permitted_target_regions
  private_api_endpoint_only = var.global_event_routing_settings.private_api_endpoint_only

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  # Used for outputs only
  cos_targets = {
    for cos_target in ibm_atracker_target.atracker_cos_targets :
    cos_target["name"] => {
      id  = cos_target["id"]
      crn = cos_target["crn"]
    }
  }

  eventstreams_targets = {
    for eventstreams_target in ibm_atracker_target.atracker_eventstreams_targets :
    eventstreams_target["name"] => {
      id  = eventstreams_target["id"]
      crn = eventstreams_target["crn"]
    }
  }

  cloud_log_targets = {
    for cloud_log_target in ibm_atracker_target.atracker_cloud_logs_targets :
    cloud_log_target["name"] => {
      id  = cloud_log_target["id"]
      crn = cloud_log_target["crn"]
    }
  }

  activity_tracker_routes = {
    for atracker_route in ibm_atracker_route.atracker_routes :
    atracker_route["name"] => {
      id  = atracker_route["id"]
      crn = atracker_route["crn"]
    }
  }

  activity_tracker_targets = merge(local.cos_targets, local.eventstreams_targets, local.cloud_log_targets)

}

########################################################################
# Context Based Restrictions
#########################################################################

locals {
  default_operations = [{
    api_types = [
      {
        "api_type_id" : "crn:v1:bluemix:public:context-based-restrictions::::api-type:"
      }
    ]
  }]
}

module "cbr_rule" {
  count            = length(var.cbr_rules_at)
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module"
  version          = "1.29.0"
  rule_description = var.cbr_rules_at[count.index].description
  enforcement_mode = var.cbr_rules_at[count.index].enforcement_mode
  rule_contexts    = var.cbr_rules_at[count.index].rule_contexts
  resources = [{
    attributes = [
      {
        name  = "accountId"
        value = var.cbr_rules_at[count.index].account_id
      },
      {
        name  = "serviceName"
        value = "atracker"
      }
    ]
  }]
  operations = var.cbr_rules_at[count.index].operations == null ? local.default_operations : var.cbr_rules_at[count.index].operations
}
