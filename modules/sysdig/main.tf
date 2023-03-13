locals {
  sysdig_instance_name = var.sysdig_instance_name != null ? var.sysdig_instance_name : "sysdig-${var.region}"
}

resource "ibm_resource_instance" "sysdig" {
  count = var.sysdig_provision ? 1 : 0

  name              = local.sysdig_instance_name
  resource_group_id = var.resource_group_id
  service           = "sysdig-monitor"
  plan              = var.sysdig_plan
  location          = var.region
  tags              = var.sysdig_tags
  service_endpoints = var.sysdig_service_endpoints

  parameters = {
    "default_receiver" = var.enable_platform_metrics
  }
}

resource "ibm_resource_key" "sysdig_resource_key" {
  count = var.sysdig_provision ? 1 : 0

  name                 = var.sysdig_manager_key_name
  resource_instance_id = ibm_resource_instance.sysdig[0].id
  role                 = "Manager"
  tags                 = var.sysdig_manager_key_tags
}
