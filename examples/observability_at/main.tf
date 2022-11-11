provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
}

resource "ibm_resource_group" "test_resource_group" {
  name     = "${var.prefix}-rg"
  quota_id = null
}

module "test_observability_instance_creation" {
  source                         = "../../"
  resource_group_id              = ibm_resource_group.test_resource_group.id
  region                         = var.region
  logdna_provision               = false
  sysdig_provision               = false
  activity_tracker_instance_name = var.prefix
  activity_tracker_plan          = "7-day"
  logdna_tags                    = var.resource_tags
  sysdig_tags                    = var.resource_tags
  activity_tracker_tags          = var.resource_tags
}
