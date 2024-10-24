##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.6"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# COS instance
##############################################################################

module "cos" {
  source            = "terraform-ibm-modules/cos/ibm"
  version           = "8.13.2"
  resource_group_id = module.resource_group.resource_group_id
  cos_instance_name = "${var.prefix}-cos"
  cos_tags          = var.resource_tags
  create_cos_bucket = false
}

##############################################################################
# COS buckets
##############################################################################

locals {
  logs_bucket_name    = "${var.prefix}-logs-data"
  metrics_bucket_name = "${var.prefix}-metrics-data"
}

module "buckets" {
  source  = "terraform-ibm-modules/cos/ibm//modules/buckets"
  version = "8.13.2"
  bucket_configs = [
    {
      bucket_name            = local.logs_bucket_name
      kms_encryption_enabled = false
      region_location        = var.region
      resource_instance_id   = module.cos.cos_instance_id
    },
    {
      bucket_name            = local.metrics_bucket_name
      kms_encryption_enabled = false
      region_location        = var.region
      resource_instance_id   = module.cos.cos_instance_id
    }
  ]
}

##############################################################################
# Observability:
# - Cloud Logs instance
# - Monitoring instance
# - AT route to Cloud Logs target
##############################################################################

locals {
  target_name      = "${var.prefix}-icl-target"
  logs_policy_name = "${var.prefix}-logs-policy"
}

module "observability_instances" {
  source = "../../"
  # delete line above and use below syntax to pull module source from hashicorp when consuming this module
  # source    = "terraform-ibm-modules/observability-instances/ibm"
  # version   = "X.Y.Z" # Replace "X.X.X" with a release version to lock into a specific release
  resource_group_id            = module.resource_group.resource_group_id
  region                       = var.region
  enable_platform_logs         = false
  enable_platform_metrics      = false
  cloud_monitoring_tags        = var.resource_tags
  cloud_logs_tags              = var.resource_tags
  cloud_monitoring_access_tags = var.access_tags
  cloud_logs_access_tags       = var.access_tags
  cloud_logs_data_storage = {
    # logs and metrics buckets must be different
    logs_data = {
      enabled         = true
      bucket_crn      = module.buckets.buckets[local.logs_bucket_name].bucket_crn
      bucket_endpoint = module.buckets.buckets[local.logs_bucket_name].s3_endpoint_direct
    },
    metrics_data = {
      enabled         = true
      bucket_crn      = module.buckets.buckets[local.metrics_bucket_name].bucket_crn
      bucket_endpoint = module.buckets.buckets[local.metrics_bucket_name].s3_endpoint_direct
    }
  }
  at_cloud_logs_targets = [
    {
      instance_id   = module.observability_instances.cloud_logs_crn
      target_region = var.region
      target_name   = local.target_name
    }
  ]
  activity_tracker_routes = [
    {
      locations  = ["*", "global"]
      target_ids = [module.observability_instances.activity_tracker_targets[local.target_name].id]
      route_name = "${var.prefix}-icl-route"
    }
  ]
  create_ibm_logs_policy = true
  logs_policy_name       = local.logs_policy_name
  logs_policy_priority   = "type_medium"
  # application_rules = [{
  #   name         = "otel-links-test"
  #   rule_type_id = "start_with"
  # }]
  log_rules = [{
    severities = ["info"]
  }]
  # subsystem_rules = [{
  #   name         = "otel-links-test"
  #   rule_type_id = "start_with"
  # }]
}
