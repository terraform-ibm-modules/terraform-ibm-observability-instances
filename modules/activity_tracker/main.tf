locals {
  activity_tracker_instance_name = var.activity_tracker_instance_name != null ? var.activity_tracker_instance_name : "activity-tracker-${var.region}"

  # When archive is enabled cos instance information is required identify bucket
  cos_at_validate_condition = var.enable_archive && var.activity_tracker_provision && ((var.at_cos_instance_id == null || var.at_cos_bucket_name == null || var.at_cos_bucket_endpoint == null))
  cos_at_validate_msg       = "'at_cos_instance_id', 'at_cos_bucket_name' and 'at_cos_bucket_endpoint' are required when 'enable_archive' is true"
  # tflint-ignore: terraform_unused_declarations
  cos_at_validate_check = regex("^${local.cos_at_validate_msg}$", (!local.cos_at_validate_condition ? local.cos_at_validate_msg : ""))
}

# Activity Tracker
resource "ibm_resource_instance" "activity_tracker" {
  count = var.activity_tracker_provision ? 1 : 0

  name              = local.activity_tracker_instance_name
  resource_group_id = var.resource_group_id
  service           = "logdnaat"
  plan              = var.activity_tracker_plan
  location          = var.region
  tags              = var.activity_tracker_tags
  service_endpoints = var.activity_tracker_service_endpoints
}

resource "ibm_resource_key" "at_resource_key" {
  count = var.activity_tracker_provision ? 1 : 0

  name                 = var.activity_tracker_manager_key_name
  resource_instance_id = ibm_resource_instance.activity_tracker[0].id
  role                 = "Manager"
  tags                 = var.activity_tracker_manager_key_tags
}

resource "logdna_archive" "activity_tracker_config" {
  count       = var.activity_tracker_provision && var.enable_archive ? 1 : 0
  provider    = logdna.at
  integration = "ibm"
  ibm_config {
    apikey             = var.ibmcloud_api_key
    bucket             = var.at_cos_bucket_name
    endpoint           = var.at_cos_bucket_endpoint
    resourceinstanceid = var.at_cos_instance_id
  }
}
