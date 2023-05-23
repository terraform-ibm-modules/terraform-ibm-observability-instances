locals {
  instance_name = var.instance_name != null ? var.instance_name : "log-analysis-${var.region}"

  # When archive is enabled cos instance information is required to identify bucket
  cos_validate_condition = var.enable_archive && var.log_analysis_provision && ((var.cos_instance_id == null || var.cos_bucket_name == null || var.cos_bucket_endpoint == null))
  cos_validate_msg       = "'cos_instance_id', 'cos_bucket_name' and 'cos_bucket_endpoint' are required when 'enable_archive' is true"
  # tflint-ignore: terraform_unused_declarations
  cos_validate_check = regex("^${local.cos_validate_msg}$", (!local.cos_validate_condition ? local.cos_validate_msg : ""))
}

# Log Analysis
resource "ibm_resource_instance" "log_analysis" {
  count             = var.log_analysis_provision ? 1 : 0
  name              = local.instance_name
  resource_group_id = var.resource_group_id
  service           = "logdna"
  plan              = var.plan
  location          = var.region
  tags              = var.tags
  service_endpoints = var.service_endpoints

  parameters = {
    "default_receiver" = var.enable_platform_logs
  }
}

resource "ibm_resource_tag" "logdna_tag" {
  count       = length(var.access_tags) == 0 ? 0 : var.logdna_provision ? 1 : 0
  resource_id = ibm_resource_instance.logdna[0].crn
  tags        = var.access_tags
  tag_type    = "access"
}

resource "ibm_resource_key" "resource_key" {
  count                = var.log_analysis_provision ? 1 : 0
  name                 = var.manager_key_name
  resource_instance_id = ibm_resource_instance.log_analysis[0].id
  role                 = var.resource_key_role
  tags                 = var.manager_key_tags
}

resource "logdna_archive" "archive_config" {
  count       = var.log_analysis_provision && var.enable_archive ? 1 : 0
  provider    = logdna.ld
  integration = "ibm"
  ibm_config {
    apikey             = var.ibmcloud_api_key
    bucket             = var.cos_bucket_name
    endpoint           = var.cos_bucket_endpoint
    resourceinstanceid = var.cos_instance_id
  }
}
