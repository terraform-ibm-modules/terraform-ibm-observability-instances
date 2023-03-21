locals {
  instance_name = var.instance_name != null ? var.instance_name : "activity-tracker-${var.region}"

  # When archive is enabled cos instance information is required to identify bucket
  cos_validate_condition = var.enable_archive && var.activity_tracker_provision && ((var.cos_instance_id == null || var.cos_bucket_name == null || var.cos_bucket_endpoint == null))
  cos_validate_msg       = "'cos_instance_id', 'cos_bucket_name' and 'cos_bucket_endpoint' are required when 'enable_archive' is true"
  # tflint-ignore: terraform_unused_declarations
  cos_validate_check = regex("^${local.cos_validate_msg}$", (!local.cos_validate_condition ? local.cos_validate_msg : ""))
}

resource "ibm_resource_instance" "activity_tracker" {
  count             = var.activity_tracker_provision ? 1 : 0
  name              = local.instance_name
  resource_group_id = var.resource_group_id
  service           = "logdnaat"
  plan              = var.plan
  location          = var.region
  tags              = var.tags
  service_endpoints = var.service_endpoints
}

resource "ibm_resource_key" "resource_key" {
  count                = var.activity_tracker_provision ? 1 : 0
  name                 = var.manager_key_name
  resource_instance_id = ibm_resource_instance.activity_tracker[0].id
  role                 = "Manager"
  tags                 = var.manager_key_tags
}

resource "logdna_archive" "archive_config" {
  count       = var.activity_tracker_provision && var.enable_archive ? 1 : 0
  provider    = logdna.at
  integration = "ibm"
  ibm_config {
    apikey             = var.ibmcloud_api_key
    bucket             = var.cos_bucket_name
    endpoint           = var.cos_bucket_endpoint
    resourceinstanceid = var.cos_instance_id
  }
}
