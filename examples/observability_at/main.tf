module "resource_group" {
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git?ref=v1.0.2"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}


module "test_observability_instance_creation" {
  source                         = "../../"
  resource_group_id              = module.resource_group.resource_group_id
  region                         = var.region
  logdna_provision               = false
  sysdig_provision               = false
  activity_tracker_instance_name = var.prefix
  activity_tracker_plan          = "7-day"
  logdna_tags                    = var.resource_tags
  sysdig_tags                    = var.resource_tags
  activity_tracker_tags          = var.resource_tags
}
