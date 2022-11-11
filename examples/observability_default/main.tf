provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
}

module "resource_group" {
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git?ref=v1.0.2"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

module "test_observability_instance_creation" {
  source                         = "../../"
  region                         = var.region
  logdna_instance_name           = var.prefix
  resource_group_id              = module.resource_group.resource_group_id
  sysdig_instance_name           = var.prefix
  activity_tracker_instance_name = var.prefix
  logdna_plan                    = var.logdna_plan
  sysdig_plan                    = var.sysdig_plan
  activity_tracker_plan          = var.activity_tracker_plan
  enable_platform_logs           = var.enable_platform_logs
  enable_platform_metrics        = var.enable_platform_metrics
  logdna_tags                    = var.resource_tags
  sysdig_tags                    = var.resource_tags
  activity_tracker_tags          = var.resource_tags
}
