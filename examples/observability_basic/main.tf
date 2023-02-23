module "resource_group" {
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git?ref=v1.0.5"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

module "test_observability_instance_creation" {
  source = "../../"
  providers = {
    logdna.at = logdna.at
    logdna.ld = logdna.ld
  }
  region                            = var.region
  logdna_instance_name              = var.prefix
  resource_group_id                 = module.resource_group.resource_group_id
  sysdig_instance_name              = var.prefix
  activity_tracker_instance_name    = var.prefix
  logdna_plan                       = "7-day"
  sysdig_plan                       = "graduated-tier"
  activity_tracker_plan             = "7-day"
  enable_platform_logs              = false
  enable_platform_metrics           = false
  logdna_tags                       = var.resource_tags
  sysdig_tags                       = var.resource_tags
  activity_tracker_tags             = var.resource_tags
  logdna_key_tags                   = var.resource_tags
  sysdig_manager_key_tags           = var.resource_tags
  activity_tracker_manager_key_tags = var.resource_tags
}
