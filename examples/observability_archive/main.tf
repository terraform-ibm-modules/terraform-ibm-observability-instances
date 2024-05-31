##############################################################################
# Local Resource Block
##############################################################################
locals {
  bucket_name     = "${var.prefix}-observability-archive-bucket"
  archive_api_key = var.archive_api_key == null ? var.ibmcloud_api_key : var.archive_api_key

  eventstreams_target_region = var.eventstreams_target_region != null ? var.eventstreams_target_region : var.region
  cos_target_region          = var.cos_target_region != null ? var.cos_target_region : var.region
}

##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.5"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Key Protect Instance + Key (used to encrypt bucket)
##############################################################################

module "key_protect" {
  source            = "terraform-ibm-modules/kms-all-inclusive/ibm"
  version           = "4.11.8"
  resource_group_id = module.resource_group.resource_group_id
  region            = var.region
  resource_tags     = var.resource_tags
  keys = [
    {
      key_ring_name = "observability"
      keys = [
        {
          key_name = "observability-key"
        }
      ]
    }
  ]
  key_protect_instance_name = "${var.prefix}-kp"
}

##############################################################################
# Event stream target
##############################################################################

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

##############################################################################
# COS instance + bucket (used for logdna + AT archiving + AT target)
##############################################################################

module "cos" {
  source                     = "terraform-ibm-modules/cos/ibm"
  version                    = "8.2.10"
  resource_group_id          = module.resource_group.resource_group_id
  region                     = var.region
  cos_instance_name          = "${var.prefix}-cos"
  cos_tags                   = var.resource_tags
  bucket_name                = local.bucket_name
  existing_kms_instance_guid = module.key_protect.kms_guid
  retention_enabled          = false
  activity_tracker_crn       = module.observability_instance_creation.activity_tracker_crn
  sysdig_crn                 = module.observability_instance_creation.cloud_monitoring_crn
  kms_key_crn                = module.key_protect.keys["observability.observability-key"].crn
}

module "cos_bucket_1" {
  source                 = "terraform-ibm-modules/cos/ibm"
  version                = "8.2.8"
  resource_group_id      = module.resource_group.resource_group_id
  region                 = local.cos_target_region
  cos_instance_name      = "${var.prefix}-cos"
  cos_tags               = var.resource_tags
  bucket_name            = "${var.prefix}-cos-target-bucket-1"
  kms_encryption_enabled = false
  retention_enabled      = false
}

##############################################################################
# Observability Instance
##############################################################################

module "observability_instance_creation" {
  source = "../../"
  providers = {
    logdna.at = logdna.at
    logdna.ld = logdna.ld
  }
  resource_group_id                 = module.resource_group.resource_group_id
  region                            = var.region
  log_analysis_instance_name        = "${var.prefix}-log-analysis"
  cloud_monitoring_instance_name    = "${var.prefix}-cloud-monitoring"
  activity_tracker_instance_name    = "${var.prefix}-activity-tracker"
  enable_platform_metrics           = false
  enable_platform_logs              = false
  log_analysis_plan                 = "7-day"
  cloud_monitoring_plan             = "graduated-tier"
  activity_tracker_plan             = "7-day"
  log_analysis_tags                 = var.resource_tags
  cloud_monitoring_tags             = var.resource_tags
  activity_tracker_tags             = var.resource_tags
  log_analysis_manager_key_tags     = var.resource_tags
  cloud_monitoring_manager_key_tags = var.resource_tags
  activity_tracker_manager_key_tags = var.resource_tags
  log_analysis_access_tags          = var.access_tags
  cloud_monitoring_access_tags      = var.access_tags
  activity_tracker_access_tags      = var.access_tags
  enable_archive                    = true
  ibmcloud_api_key                  = local.archive_api_key
  log_analysis_cos_instance_id      = module.cos.cos_instance_id
  log_analysis_cos_bucket_name      = local.bucket_name
  log_analysis_cos_bucket_endpoint  = module.cos.s3_endpoint_public
  at_cos_bucket_name                = local.bucket_name
  at_cos_instance_id                = module.cos.cos_instance_id
  at_cos_bucket_endpoint            = module.cos.s3_endpoint_private

  cos_targets = [
    {
      bucket_name                       = module.cos_bucket_1.bucket_name
      endpoint                          = module.cos_bucket_1.s3_endpoint_private
      instance_id                       = module.cos_bucket_1.cos_instance_id
      target_region                     = local.cos_target_region
      target_name                       = "${var.prefix}-cos-target-1"
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
      target_region = var.region
      target_name   = "${var.prefix}-eventstreams-target-1"
    }
  ]
  log_analysis_targets = [
    {
      instance_id   = module.observability_instance_creation.log_analysis_crn
      ingestion_key = module.observability_instance_creation.log_analysis_ingestion_key
      target_region = var.region
      target_name   = "${var.prefix}-log-analysis"
    }
  ]

  activity_tracker_routes = [
    {
      route_name = "${var.prefix}-route"
      locations  = ["*", "global"]
      target_ids = [
        module.observability_instance_creation.activity_tracker_targets["${var.prefix}-cos-target-1"].id,
        module.observability_instance_creation.activity_tracker_targets["${var.prefix}-log-analysis"].id,
        module.observability_instance_creation.activity_tracker_targets["${var.prefix}-eventstreams-target-1"].id
      ]
    }
  ]

  global_event_routing_settings = {
    default_targets           = [module.observability_instance_creation.activity_tracker_targets["${var.prefix}-eventstreams-target-1"].id]
    permitted_target_regions  = var.permitted_target_regions
    metadata_region_primary   = var.metadata_region_primary
    metadata_region_backup    = var.metadata_region_backup
    private_api_endpoint_only = var.private_api_endpoint_only
  }
}
