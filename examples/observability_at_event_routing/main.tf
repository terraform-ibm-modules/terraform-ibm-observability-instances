locals {
  validate_at_region_name_cnd = var.existing_activity_tracker_crn != null && (var.existing_activity_tracker_region == null || var.existing_activity_tracker_key_name == null)
  validate_at_region_name_msg = "existing_activity_tracker_region and existing_activity_tracker_key_name must also be set when value given for existing_activity_tracker_crn."
  # tflint-ignore: terraform_unused_declarations
  validate_at_region_chk = regex(
    "^${local.validate_at_region_name_msg}$",
    (!local.validate_at_region_name_cnd
      ? local.validate_at_region_name_msg
  : ""))

  activity_tracker_crn          = var.existing_activity_tracker_crn != null ? var.existing_activity_tracker_crn : module.activity_tracker.crn
  activity_tracker_key_name     = var.existing_activity_tracker_crn != null ? var.existing_activity_tracker_key_name : module.activity_tracker.manager_key_name
  activity_tracker_region       = var.existing_activity_tracker_crn != null ? var.existing_activity_tracker_region : var.region
  activity_tracker_resource_key = var.existing_activity_tracker_crn != null ? data.ibm_resource_key.at_resource_key.credentials["service_key"] : module.activity_tracker.resource_key

  cos_target_region          = var.cos_target_region != null ? var.cos_target_region : local.activity_tracker_region
  log_analysis_target_region = var.log_analysis_target_region != null ? var.log_analysis_target_region : local.activity_tracker_region
  eventstreams_target_region = var.eventstreams_target_region != null ? var.eventstreams_target_region : local.activity_tracker_region
}

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.5"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

# COS target

module "cos_bucket_2" {
  source                 = "terraform-ibm-modules/cos/ibm"
  version                = "8.2.10"
  resource_group_id      = module.resource_group.resource_group_id
  region                 = local.cos_target_region
  cos_instance_name      = "${var.prefix}-cos-target-instance-2"
  cos_tags               = var.resource_tags
  bucket_name            = "${var.prefix}-cos-target-bucket-2"
  kms_encryption_enabled = false
  retention_enabled      = false
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

# Log Analysis target
module "log_analysis_1" {
  source = "../../modules/log_analysis"
  providers = {
    logdna.ld = logdna.ld_1
  }
  instance_name     = "${var.prefix}-logdna-target-instance-1"
  resource_group_id = module.resource_group.resource_group_id
  plan              = "7-day"
  region            = local.log_analysis_target_region
  manager_key_name  = "${var.prefix}-logdna-manager-key-1"
  resource_key_role = "Manager"
  access_tags       = var.access_tags
}

########################################################################
# Activity Tracker With Event Routing
#########################################################################

module "activity_tracker" {
  source = "../../modules/activity_tracker"
  providers = {
    logdna.at = logdna.at
  }

  # Activity Tracker
  activity_tracker_provision = var.existing_activity_tracker_crn == null ? true : false
  resource_group_id          = module.resource_group.resource_group_id
  region                     = local.activity_tracker_region
  instance_name              = "${var.prefix}-activity-tracker-instance"
  plan                       = "7-day"
  tags                       = var.resource_tags
  access_tags                = var.access_tags

  # Targets
  cos_targets = [
    {
      bucket_name                       = module.cos_bucket_2.bucket_name
      endpoint                          = module.cos_bucket_2.s3_endpoint_private
      instance_id                       = module.cos_bucket_2.cos_instance_id
      target_region                     = local.cos_target_region
      target_name                       = "${var.prefix}-cos-target-2"
      skip_atracker_cos_iam_auth_policy = false
      service_to_service_enabled        = true
    }
  ]

  eventstreams_targets = [
    {
      api_key       = ibm_resource_key.es_resource_key.credentials.apikey
      instance_id   = ibm_resource_instance.es_instance.id
      brokers       = ibm_event_streams_topic.es_topic.kafka_brokers_sasl
      topic         = ibm_event_streams_topic.es_topic.name
      target_region = local.eventstreams_target_region
      target_name   = "${var.prefix}-eventstreams-target-1"
    }
  ]

  log_analysis_targets = [
    {
      instance_id   = module.log_analysis_1.crn
      ingestion_key = module.log_analysis_1.ingestion_key
      target_region = local.log_analysis_target_region
      target_name   = "${var.prefix}-logdna-target-1"
    }
  ]

  # Routes
  activity_tracker_routes = [
    {
      route_name = "${var.prefix}-route-1"
      locations  = ["*", "global"]
      target_ids = [
        module.activity_tracker.activity_tracker_targets["${var.prefix}-cos-target-2"].id,
        module.activity_tracker.activity_tracker_targets["${var.prefix}-logdna-target-1"].id,
        module.activity_tracker.activity_tracker_targets["${var.prefix}-eventstreams-target-1"].id
      ]
    }
  ]

  # Global Settings
  global_event_routing_settings = {
    default_targets           = var.target_enabled ? [module.activity_tracker.activity_tracker_targets["${var.prefix}-eventstreams-target-1"].id] : []
    permitted_target_regions  = var.permitted_target_regions
    metadata_region_primary   = var.metadata_region_primary
    metadata_region_backup    = var.metadata_region_backup
    private_api_endpoint_only = var.private_api_endpoint_only
  }

}

data "ibm_resource_key" "at_resource_key" {
  name                 = var.existing_activity_tracker_crn != null ? local.activity_tracker_key_name : module.activity_tracker.manager_key_name
  resource_instance_id = local.activity_tracker_crn
}
