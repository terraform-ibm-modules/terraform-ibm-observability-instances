locals {
  instance_name = var.instance_name != null ? var.instance_name : "cloud-monitoring-${var.region}"
}

resource "ibm_resource_instance" "cloud_monitoring" {
  count             = 1 # keeping a count here to prevent breaking change as old boolean variable has been removed
  name              = local.instance_name
  resource_group_id = var.resource_group_id
  service           = "sysdig-monitor"
  plan              = var.plan
  location          = var.region
  tags              = var.tags
  service_endpoints = var.service_endpoints

  parameters = {
    "default_receiver" = var.enable_platform_metrics
  }
}

resource "ibm_resource_tag" "cloud_monitoring_tag" {
  count       = length(var.access_tags) == 0 ? 0 : 1
  resource_id = ibm_resource_instance.cloud_monitoring[0].crn
  tags        = var.access_tags
  tag_type    = "access"
}

resource "ibm_resource_key" "resource_key" {
  count                = 1 # keeping a count here to prevent breaking change as old boolean variable has been removed
  name                 = var.manager_key_name
  resource_instance_id = ibm_resource_instance.cloud_monitoring[0].id
  role                 = "Manager"
  tags                 = var.manager_key_tags
}
