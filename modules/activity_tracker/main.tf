locals {
  instance_name = var.instance_name != null ? var.instance_name : "activity-tracker-${var.region}"

  # When archive is enabled cos instance information is required to identify bucket
  cos_validate_condition = var.activity_tracker_enable_archive && var.activity_tracker_provision && ((var.cos_instance_id == null || var.cos_bucket_name == null || var.cos_bucket_endpoint == null))
  cos_validate_msg       = "'cos_instance_id', 'cos_bucket_name' and 'cos_bucket_endpoint' are required when 'activity_tracker_enable_archive' is true"
  # tflint-ignore: terraform_unused_declarations
  cos_validate_check = regex("^${local.cos_validate_msg}$", (!local.cos_validate_condition ? local.cos_validate_msg : ""))
}

resource "ibm_resource_instance" "activity_tracker" {
  count             = var.activity_tracker_provision ? 1 : 0
  name              = local.instance_name
  resource_group_id = var.resource_group_id
  service           = "logdnaat"
  plan              = var.plan
  location          = var.region
  tags              = var.tags
  service_endpoints = var.service_endpoints
}

resource "ibm_resource_tag" "activity_tracker_tag" {
  count       = length(var.access_tags) == 0 ? 0 : var.activity_tracker_provision ? 1 : 0
  resource_id = ibm_resource_instance.activity_tracker[0].crn
  tags        = var.access_tags
  tag_type    = "access"
}

resource "ibm_resource_key" "resource_key" {
  count                = var.activity_tracker_provision ? 1 : 0
  name                 = var.manager_key_name
  resource_instance_id = ibm_resource_instance.activity_tracker[0].id
  role                 = "Manager"
  tags                 = var.manager_key_tags
}

resource "logdna_archive" "archive_config" {
  count       = var.activity_tracker_provision && var.activity_tracker_enable_archive ? 1 : 0
  provider    = logdna.at
  integration = "ibm"
  ibm_config {
    apikey             = var.ibmcloud_api_key
    bucket             = var.cos_bucket_name
    endpoint           = var.cos_bucket_endpoint
    resourceinstanceid = var.cos_instance_id
  }
}

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
  for_each = nonsensitive({ for target in var.eventstreams_targets : target.target_name => target })
  eventstreams_endpoint {
    target_crn = each.value.instance_id
    brokers    = each.value.brokers
    topic      = each.value.topic
    api_key    = each.value.api_key
  }
  name        = each.key
  target_type = "event_streams"
  region      = each.value.target_region
}

# Log Analysis targets
resource "ibm_atracker_target" "atracker_log_analysis_targets" {
  for_each = nonsensitive({ for target in var.log_analysis_targets : target.target_name => target })
  logdna_endpoint {
    target_crn    = each.value.instance_id
    ingestion_key = each.value.ingestion_key
  }
  name        = each.key
  target_type = "logdna"
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

  log_analysis_targets = {
    for log_analysis_target in ibm_atracker_target.atracker_log_analysis_targets :
    log_analysis_target["name"] => {
      id  = log_analysis_target["id"]
      crn = log_analysis_target["crn"]
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

  activity_tracker_targets = merge(local.cos_targets, local.log_analysis_targets, local.eventstreams_targets, local.cloud_log_targets)

}
