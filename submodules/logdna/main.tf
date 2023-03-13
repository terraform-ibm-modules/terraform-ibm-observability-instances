locals {
  logdna_instance_name = var.logdna_instance_name != null ? var.logdna_instance_name : "logdna-${var.region}"

  # When archive is enabled cos instance information is required to identify bucket
  cos_logdna_validate_condition = var.enable_archive && var.logdna_provision && ((var.logdna_cos_instance_id == null || var.logdna_cos_bucket_name == null || var.logdna_cos_bucket_endpoint == null))
  cos_logdna_validate_msg       = "'logdna_cos_instance_id', 'logdna_cos_bucket_name' and 'logdna_cos_bucket_endpoint' are required when 'enable_archive' is true"
  # tflint-ignore: terraform_unused_declarations
  cos_logdna_validate_check = regex("^${local.cos_logdna_validate_msg}$", (!local.cos_logdna_validate_condition ? local.cos_logdna_validate_msg : ""))
}

# LogDNA
resource "ibm_resource_instance" "logdna" {
  count             = var.logdna_provision ? 1 : 0
  name              = local.logdna_instance_name
  resource_group_id = var.resource_group_id
  service           = "logdna"
  plan              = var.logdna_plan
  location          = var.region
  tags              = var.logdna_tags
  service_endpoints = var.logdna_service_endpoints

  parameters = {
    "default_receiver" = var.enable_platform_logs
  }
}

resource "ibm_resource_key" "log_dna_resource_key" {
  count                = var.logdna_provision ? 1 : 0
  name                 = var.logdna_manager_key_name
  resource_instance_id = ibm_resource_instance.logdna[0].id
  role                 = "Manager"
  tags                 = var.logdna_manager_key_tags
}

resource "logdna_archive" "logdna_config" {
  count       = var.logdna_provision && var.enable_archive ? 1 : 0
  provider    = logdna.ld
  integration = "ibm"
  ibm_config {
    apikey             = var.ibmcloud_api_key
    bucket             = var.logdna_cos_bucket_name
    endpoint           = var.logdna_cos_bucket_endpoint
    resourceinstanceid = var.logdna_cos_instance_id
  }
}
