locals {
  cos_target_region          = var.cos_target_region != null ? var.cos_target_region : var.region
  logdna_target_region       = var.logdna_target_region != null ? var.logdna_target_region : var.region
  eventstreams_target_region = var.eventstreams_target_region != null ? var.eventstreams_target_region : var.region
}

module "resource_group" {
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git?ref=v1.0.5"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

# COS target
module "cos_bucket" {
  source             = "git::https://github.com/terraform-ibm-modules/terraform-ibm-cos?ref=v5.0.0"
  resource_group_id  = module.resource_group.resource_group_id
  region             = local.cos_target_region
  cos_instance_name  = "${var.prefix}-cos-target-instance"
  cos_tags           = var.resource_tags
  bucket_name        = "${var.prefix}-cos-target-bucket"
  encryption_enabled = false
  retention_enabled  = false
}

resource "ibm_resource_key" "cos_resource_key" {
  name                 = "${var.prefix}-cos-service-key"
  resource_instance_id = module.cos_bucket.cos_instance_id
  role                 = "Writer"
}

# Event stream target
resource "ibm_resource_instance" "es_instance" {
  name              = "${var.prefix}-eventsteams-instance"
  service           = "messagehub"
  plan              = "standard"
  location          = local.eventstreams_target_region
  resource_group_id = module.resource_group.resource_group_id
}

resource "ibm_event_streams_topic" "es_topic" {
  resource_instance_id = ibm_resource_instance.es_instance.id
  name                 = "${var.prefix}-topic"
  partitions           = 1
  config = {
    "cleanup.policy"  = "delete"
    "retention.ms"    = "86400000"  # 1 Day
    "retention.bytes" = "10485760"  # 10 MB
    "segment.bytes"   = "536870912" #512 MB
  }
}

resource "ibm_resource_key" "es_resource_key" {
  name                 = "${var.prefix}-eventstreams-service-key"
  resource_instance_id = ibm_resource_instance.es_instance.id
  role                 = "Writer"
}

# LogDNA target
resource "ibm_resource_instance" "logdna" {
  name              = "${var.prefix}-logdna-target-instance"
  resource_group_id = module.resource_group.resource_group_id
  service           = "logdna"
  plan              = "7-day"
  location          = local.logdna_target_region

  parameters = {
    "default_receiver" = true
  }
}

resource "ibm_resource_key" "log_dna_resource_key" {
  name                 = "${var.prefix}-logdna-manager-key"
  resource_instance_id = ibm_resource_instance.logdna.id
  role                 = "Manager"
}

module "test_observability_instance_creation" {
  source = "../../"
  providers = {
    logdna.at = logdna.at
    logdna.ld = logdna.ld
  }
  resource_group_id              = module.resource_group.resource_group_id
  region                         = var.region
  logdna_provision               = false
  sysdig_provision               = false
  activity_tracker_instance_name = "${var.prefix}-activity-tracker-instance"
  activity_tracker_plan          = "7-day"
  logdna_tags                    = var.resource_tags
  sysdig_tags                    = var.resource_tags
  activity_tracker_tags          = var.resource_tags


  cos_target = {
    endpoints = [{
      api_key                    = ibm_resource_key.cos_resource_key.credentials.apikey
      bucket_name                = module.cos_bucket.bucket_name[0]
      endpoint                   = module.cos_bucket.s3_endpoint_private[0]
      target_crn                 = module.cos_bucket.cos_instance_id
      service_to_service_enabled = var.cos_service_to_service_enabled
    }]
    route_name            = "${var.prefix}-cos-route"
    target_name           = "${var.prefix}-cos-target"
    target_region         = local.cos_target_region
    regions_targeting_cos = ["*", "global"]
  }

  eventstreams_target = {
    endpoints = [{
      api_key    = ibm_resource_key.es_resource_key.credentials.apikey
      target_crn = ibm_resource_instance.es_instance.id
      brokers    = ibm_event_streams_topic.es_topic.kafka_brokers_sasl
      topic      = ibm_event_streams_topic.es_topic.name
    }]
    route_name                     = "${var.prefix}-eventstreams-route"
    target_name                    = "${var.prefix}-eventstreams-target"
    target_region                  = local.eventstreams_target_region
    regions_targeting_eventstreams = ["*", "global"]
  }

  logdna_target = {
    endpoints = [{
      target_crn    = ibm_resource_instance.logdna.id
      ingestion_key = ibm_resource_key.log_dna_resource_key.credentials.ingestion_key
    }]
    route_name               = "${var.prefix}-logdna-route"
    target_name              = "${var.prefix}-logdna-target"
    target_region            = local.logdna_target_region
    regions_targeting_logdna = ["*", "global"]
  }
}
