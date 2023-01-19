##############################################################################
# observability-instances-module
#
# Deploy the observability instances - LogDNA, Sysdig and Activity Tracker
##############################################################################

locals {
  logdna_instance_name           = var.logdna_instance_name != null ? var.logdna_instance_name : "logdna-${var.region}"
  sysdig_instance_name           = var.sysdig_instance_name != null ? var.sysdig_instance_name : "sysdig-${var.region}"
  activity_tracker_instance_name = var.activity_tracker_instance_name != null ? var.activity_tracker_instance_name : "activity-tracker-${var.region}"

  cos_target_name          = var.cos_target_name != null ? var.cos_target_name : "cos-target"
  logdna_target_name       = var.logdna_target_name != null ? var.logdna_target_name : "logdna-target"
  eventstreams_target_name = var.eventstreams_target_name != null ? var.eventstreams_target_name : "eventstreams-target"

  cos_route_name          = var.cos_route_name != null ? var.cos_route_name : "cos-route"
  logdna_route_name       = var.logdna_route_name != null ? var.logdna_route_name : "logdna-route"
  eventstreams_route_name = var.eventstreams_route_name != null ? var.eventstreams_route_name : "eventstreams-route"

  default_targets = length(var.default_targets) > 0 ? var.default_targets : [ibm_atracker_target.atracker_eventstreams_target[0].id] ## change this to event streams


}

# LogDNA
resource "ibm_resource_instance" "logdna" {
  count = var.logdna_provision ? 1 : 0

  name              = local.logdna_instance_name
  resource_group_id = var.resource_group_id
  service           = "logdna"
  plan              = var.logdna_plan
  location          = var.region
  tags              = var.logdna_tags

  parameters = {
    "default_receiver" = var.enable_platform_logs
  }
}

resource "ibm_resource_key" "log_dna_resource_key" {
  count = var.logdna_provision ? 1 : 0

  name                 = var.logdna_manager_key_name
  resource_instance_id = ibm_resource_instance.logdna[0].id
  role                 = "Manager"
}

# Sysdig
resource "ibm_resource_instance" "sysdig" {
  count = var.sysdig_provision ? 1 : 0

  name              = local.sysdig_instance_name
  resource_group_id = var.resource_group_id
  service           = "sysdig-monitor"
  plan              = var.sysdig_plan
  location          = var.region
  tags              = var.sysdig_tags

  parameters = {
    "default_receiver" = var.enable_platform_metrics
  }
}

resource "ibm_resource_key" "sysdig_resource_key" {
  count = var.sysdig_provision ? 1 : 0

  name                 = var.sysdig_manager_key_name
  resource_instance_id = ibm_resource_instance.sysdig[0].id
  role                 = "Manager"
}

# Activity Tracker
resource "ibm_resource_instance" "activity_tracker" {
  count = var.activity_tracker_provision ? 1 : 0

  name              = local.activity_tracker_instance_name
  resource_group_id = var.resource_group_id
  service           = "logdnaat"
  plan              = var.activity_tracker_plan
  location          = var.region
  tags              = var.activity_tracker_tags
}

resource "ibm_resource_key" "at_resource_key" {
  count = var.activity_tracker_provision ? 1 : 0

  name                 = var.activity_tracker_manager_key_name
  resource_instance_id = ibm_resource_instance.activity_tracker[0].id
  role                 = "Manager"
}


# Event Routing To COS
resource "ibm_atracker_target" "atracker_cos_target" {
  count = length(var.cos_endpoint) > 0 ? 1 : 0

  dynamic "cos_endpoint" {
    for_each = var.cos_endpoint
    content {
      endpoint   = cos_endpoint.value.endpoint
      target_crn = cos_endpoint.value.target_crn
      bucket     = cos_endpoint.value.bucket_name
      api_key    = cos_endpoint.value.api_key
    }
  }
  name        = local.cos_target_name
  target_type = "cloud_object_storage"
  region      = var.region # review later
}

# Event Routing To LogDNA
resource "ibm_atracker_target" "atracker_logdna_target" {
  count = length(var.logdna_endpoint) > 0 ? 1 : 0

  dynamic "logdna_endpoint" {
    for_each = var.logdna_endpoint
    content {
      target_crn    = logdna_endpoint.value.target_crn
      ingestion_key = logdna_endpoint.value.ingestion_key
    }
  }
  name        = local.logdna_target_name
  target_type = "logdna"
  region      = var.region # review later
}

# Event Routing To Event Streams
resource "ibm_atracker_target" "atracker_eventstreams_target" {
  count = length(var.eventstreams_endpoint) > 0 ? 1 : 0

  dynamic "eventstreams_endpoint" {
    for_each = var.eventstreams_endpoint
    content {
      target_crn = eventstreams_endpoint.value.target_crn
      brokers    = eventstreams_endpoint.value.brokers
      topic      = eventstreams_endpoint.value.topic
      api_key    = eventstreams_endpoint.value.api_key
    }
  }
  name        = local.eventstreams_target_name
  target_type = "event_streams"
  region      = var.region # review later
}

resource "ibm_atracker_settings" "atracker_settings" {

  default_targets           = local.default_targets
  metadata_region_primary   = var.metadata_region_primary
  metadata_region_backup    = var.metadata_region_backup
  permitted_target_regions  = var.permitted_target_regions # allow tracking from following regions only
  private_api_endpoint_only = var.private_api_endpoint_only

  # Optional but recommended lifecycle flag to ensure target delete order is correct
  lifecycle {
    create_before_destroy = true
  }
}

resource "ibm_atracker_route" "atracker_route_cos" {
  count = length(var.cos_endpoint) > 0 ? 1 : 0

  name = local.cos_route_name
  rules {
    target_ids = [ibm_atracker_target.atracker_cos_target[0].id]
    locations  = var.regions_target_cos
  }
  lifecycle {
    # Recommended to ensure that if a target ID is removed here and destroyed in a plan, this is updated first
    create_before_destroy = true
  }
}


resource "ibm_atracker_route" "atracker_route_logdna" {
  count = length(var.logdna_endpoint) > 0 ? 1 : 0

  name = local.logdna_route_name
  rules {
    target_ids = [ibm_atracker_target.atracker_logdna_target[0].id]
    locations  = var.regions_target_logdna
  }
  lifecycle {
    # Recommended to ensure that if a target ID is removed here and destroyed in a plan, this is updated first
    create_before_destroy = true
  }
}

resource "ibm_atracker_route" "atracker_route_eventstreams" {
  count = length(var.eventstreams_endpoint) > 0 ? 1 : 0
  depends_on = [
    ibm_atracker_route.atracker_route_eventstreams
  ]
  name = local.eventstreams_route_name
  rules {
    target_ids = [ibm_atracker_target.atracker_eventstreams_target[0].id]
    locations  = var.regions_target_eventstreams
  }
  lifecycle {
    # Recommended to ensure that if a target ID is removed here and destroyed in a plan, this is updated first
    create_before_destroy = true
  }
}
