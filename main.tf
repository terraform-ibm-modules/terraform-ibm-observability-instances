##############################################################################
# observability-instances-module
#
# Deploy the observability instances - LogDNA, Sysdig and Activity Tracker
##############################################################################

locals {
  logdna_instance_name           = var.logdna_instance_name != null ? var.logdna_instance_name : "logdna-${var.region}"
  sysdig_instance_name           = var.sysdig_instance_name != null ? var.sysdig_instance_name : "sysdig-${var.region}"
  activity_tracker_instance_name = var.activity_tracker_instance_name != null ? var.activity_tracker_instance_name : "activity-tracker-${var.region}"

  enable_event_routing = length(var.logdna_target.endpoints) > 0 || length(var.cos_target.endpoints) > 0 || length(var.eventstreams_target.endpoints) > 0

  default_targets = length(var.default_targets) > 0 ? var.default_targets : (
    length(var.eventstreams_target.endpoints) > 0 ? [ibm_atracker_target.atracker_eventstreams_target[0].id] :
    length(var.cos_target.endpoints) > 0 ? [ibm_atracker_target.atracker_cos_target[0].id] :
    length(var.logdna_target.endpoints) > 0 ? [ibm_atracker_target.atracker_logdna_target[0].id] : []
  )
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

# Activity Tracker Event Routing

# Event Routing To COS
resource "ibm_atracker_target" "atracker_cos_target" {
  count = length(var.cos_target.endpoints) > 0 ? 1 : 0

  dynamic "cos_endpoint" {
    for_each = var.cos_target.endpoints
    content {
      endpoint   = cos_endpoint.value.endpoint
      target_crn = cos_endpoint.value.target_crn
      bucket     = cos_endpoint.value.bucket_name
      api_key    = cos_endpoint.value.api_key
    }
  }
  name        = var.cos_target.target_name
  target_type = "cloud_object_storage"
  region      = var.cos_target.target_region # Region where COS is created
}

# Event Routing To Event Streams
resource "ibm_atracker_target" "atracker_eventstreams_target" {
  count = length(var.eventstreams_target.endpoints) > 0 ? 1 : 0

  dynamic "eventstreams_endpoint" {
    for_each = var.eventstreams_target.endpoints
    content {
      target_crn = eventstreams_endpoint.value.target_crn
      brokers    = eventstreams_endpoint.value.brokers
      topic      = eventstreams_endpoint.value.topic
      api_key    = eventstreams_endpoint.value.api_key
    }
  }
  name        = var.eventstreams_target.target_name
  target_type = "event_streams"
  region      = var.eventstreams_target.target_region # Region where event streams is created
}

# Event Routing To LogDNA
resource "ibm_atracker_target" "atracker_logdna_target" {
  count = length(var.logdna_target.endpoints) > 0 ? 1 : 0

  dynamic "logdna_endpoint" {
    for_each = var.logdna_target.endpoints
    content {
      target_crn    = logdna_endpoint.value.target_crn
      ingestion_key = logdna_endpoint.value.ingestion_key
    }
  }
  name        = var.logdna_target.target_name
  target_type = "logdna"
  region      = var.logdna_target.target_region # Region where LogDNA is created
}

# Event Routing Setting
resource "ibm_atracker_settings" "atracker_settings" {
  count = local.enable_event_routing == true ? 1 : 0

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

# COS Route
resource "ibm_atracker_route" "atracker_cos_route" {
  count = length(var.cos_target.endpoints) > 0 ? 1 : 0

  name = var.cos_target.target_name
  rules {
    target_ids = [ibm_atracker_target.atracker_cos_target[0].id]
    locations  = var.cos_target.regions_targeting_cos # Regions whose events will be forwarded to COS
  }
  lifecycle {
    # Recommended to ensure that if a target ID is removed here and destroyed in a plan, this is updated first
    create_before_destroy = true
  }
}

# Event Streams Route
resource "ibm_atracker_route" "atracker_eventstreams_route" {
  count = length(var.eventstreams_target.endpoints) > 0 ? 1 : 0

  name = var.eventstreams_target.target_name
  rules {
    target_ids = [ibm_atracker_target.atracker_eventstreams_target[0].id]
    locations  = var.eventstreams_target.regions_targeting_eventstreams # Regions whose events will be forwarded to event streams
  }
  lifecycle {
    # Recommended to ensure that if a target ID is removed here and destroyed in a plan, this is updated first
    create_before_destroy = true
  }
}

# LogDNA Route
resource "ibm_atracker_route" "atracker_logdna_route" {
  count = length(var.logdna_target.endpoints) > 0 ? 1 : 0

  name = var.logdna_target.route_name
  rules {
    target_ids = [ibm_atracker_target.atracker_logdna_target[0].id]
    locations  = var.logdna_target.regions_targeting_logdna # Regions whose events will be forwarded to LogDNA
  }
  lifecycle {
    # Recommended to ensure that if a target ID is removed here and destroyed in a plan, this is updated first
    create_before_destroy = true
  }
}
