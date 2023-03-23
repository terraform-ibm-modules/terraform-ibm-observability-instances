locals {
  instance_name = var.instance_name != null ? var.instance_name : "activity-tracker-${var.region}"

  # When archive is enabled cos instance information is required to identify bucket
  cos_validate_condition = var.enable_archive && var.activity_tracker_provision && ((var.cos_instance_id == null || var.cos_bucket_name == null || var.cos_bucket_endpoint == null))
  cos_validate_msg       = "'cos_instance_id', 'cos_bucket_name' and 'cos_bucket_endpoint' are required when 'enable_archive' is true"
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

resource "ibm_resource_key" "resource_key" {
  count                = var.activity_tracker_provision ? 1 : 0
  name                 = var.manager_key_name
  resource_instance_id = ibm_resource_instance.activity_tracker[0].id
  role                 = "Manager"
  tags                 = var.manager_key_tags
}

resource "logdna_archive" "archive_config" {
  count       = var.activity_tracker_provision && var.enable_archive ? 1 : 0
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

# COS Route
resource "ibm_atracker_route" "atracker_cos_route" {
  count = length(var.cos_target == null ? [] : [1])
  name  = var.cos_target.route_name
  rules {
    locations  = var.cos_target.regions_targeting_cos
    target_ids = [ibm_atracker_target.atracker_cos_target[0].id]
  }
  lifecycle {
    create_before_destroy = true
  }
}

# COS target
resource "ibm_atracker_target" "atracker_cos_target" {
  count = length(var.cos_target == null ? [] : [1])
  cos_endpoint {
    endpoint   = var.cos_target.cos_endpoint.endpoint
    bucket     = var.cos_target.cos_endpoint.bucket_name
    target_crn = var.cos_target.cos_endpoint.target_crn
    api_key    = var.cos_target.cos_endpoint.api_key
  }
  name        = var.cos_target.target_name
  target_type = "cloud_object_storage"
  region      = var.cos_target.target_region
}

# Event Streams Route
resource "ibm_atracker_route" "atracker_eventstreams_route" {
  count = length(var.eventstreams_target == null ? [] : [1])
  name  = var.eventstreams_target.route_name
  rules {
    locations  = var.eventstreams_target.regions_targeting_eventstreams
    target_ids = [ibm_atracker_target.atracker_eventstreams_target[0].id]
  }
  lifecycle {
    create_before_destroy = true
  }
}

# Event Streams target
resource "ibm_atracker_target" "atracker_eventstreams_target" {
  count = length(var.eventstreams_target == null ? [] : [1])
  eventstreams_endpoint {
    target_crn = var.eventstreams_target.eventstreams_endpoint.target_crn
    brokers    = var.eventstreams_target.eventstreams_endpoint.brokers
    topic      = var.eventstreams_target.eventstreams_endpoint.topic
    api_key    = var.eventstreams_target.eventstreams_endpoint.api_key
  }
  name        = var.eventstreams_target.target_name
  target_type = "event_streams"
  region      = var.eventstreams_target.target_region
}

# LogDNA Route
resource "ibm_atracker_route" "atracker_logdna_route" {
  count = length(var.logdna_target == null ? [] : [1])
  name  = var.logdna_target.route_name
  rules {
    locations  = var.logdna_target.regions_targeting_logdna
    target_ids = [ibm_atracker_target.atracker_logdna_target[0].id]
  }
  lifecycle {
    create_before_destroy = true
  }
}

# LogDNA target
resource "ibm_atracker_target" "atracker_logdna_target" {
  count = length(var.logdna_target == null ? [] : [1])
  logdna_endpoint {
    target_crn    = var.logdna_target.logdna_endpoint.target_crn
    ingestion_key = var.logdna_target.logdna_endpoint.ingestion_key
  }
  name        = var.logdna_target.target_name
  target_type = "logdna"
  region      = var.logdna_target.target_region
}
