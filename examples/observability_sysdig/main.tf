module "resource_group" {
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git?ref=v1.0.5"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

locals {
  at_endpoint = "https://api.${var.region}.logging.cloud.ibm.com"
}

module "test_observability_instance_creation" {
  source = "../../"
  providers = {
    logdna.at = logdna.at
    logdna.ld = logdna.ld
  }
  resource_group_id          = module.resource_group.resource_group_id
  region                     = var.region
  sysdig_instance_name       = var.prefix
  enable_platform_metrics    = false
  activity_tracker_provision = false
  logdna_provision           = false
  sysdig_plan                = "graduated-tier"
  logdna_tags                = var.resource_tags
  sysdig_tags                = var.resource_tags
  activity_tracker_tags      = var.resource_tags
}
