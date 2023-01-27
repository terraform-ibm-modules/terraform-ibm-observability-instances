##############################################################################
# observability-instances-module
#
# Deploy the observability instances - LogDNA, Sysdig and Activity Tracker
##############################################################################

locals {
  logdna_instance_name           = var.logdna_instance_name != null ? var.logdna_instance_name : "logdna-${var.region}"
  sysdig_instance_name           = var.sysdig_instance_name != null ? var.sysdig_instance_name : "sysdig-${var.region}"
  activity_tracker_instance_name = var.activity_tracker_instance_name != null ? var.activity_tracker_instance_name : "activity-tracker-${var.region}"

  # Validation approach based on https://stackoverflow.com/a/66682419
  # When archive is enabled ibmcloud api key is required
  apikey_validate_condition = var.enable_archive == true && var.ibmcloud_api_key == null
  apikey_validate_msg       = "'ibmcloud_api_key' is required when 'enable_archive' is true"
  # tflint-ignore: terraform_unused_declarations
  apikey_validate_check = regex("^${local.apikey_validate_msg}$", (!local.apikey_validate_condition ? local.apikey_validate_msg : ""))

  # When archive is enabled cos instance information is required identify bucket
  cos_at_validate_condition = var.enable_archive && var.activity_tracker_provision && ((var.at_cos_instance_id == null || var.at_cos_bucket_name == null || var.at_cos_bucket_endpoint == null))
  cos_at_validate_msg       = "'at_cos_instance_id', 'at_cos_bucket_name' and 'at_cos_bucket_endpoint' are required when 'enable_archive' is true"
  # tflint-ignore: terraform_unused_declarations
  cos_at_validate_check = regex("^${local.cos_at_validate_msg}$", (!local.cos_at_validate_condition ? local.cos_at_validate_msg : ""))

  cos_logdna_validate_condition = var.enable_archive && var.logdna_provision && ((var.logdna_cos_instance_id == null || var.logdna_cos_bucket_name == null || var.logdna_cos_bucket_endpoint == null))
  cos_logdna_validate_msg       = "'logdna_cos_instance_id', 'logdna_cos_bucket_name' and 'logdna_cos_bucket_endpoint' are required when 'enable_archive' is true"
  # tflint-ignore: terraform_unused_declarations
  cos_logdna_validate_check = regex("^${local.cos_logdna_validate_msg}$", (!local.cos_logdna_validate_condition ? local.cos_logdna_validate_msg : ""))

}

# LogDNA
resource "ibm_resource_instance" "logdna" {
  count = var.logdna_provision ? 1 : 0

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
  count = var.logdna_provision ? 1 : 0

  name                 = var.logdna_manager_key_name
  resource_instance_id = ibm_resource_instance.logdna[0].id
  role                 = "Manager"
}

# Sysdig
resource "ibm_resource_instance" "sysdig" {
  count = var.sysdig_provision ? 1 : 0

  name              = local.sysdig_instance_name
  resource_group_id = var.resource_group_id
  service           = "sysdig-monitor"
  plan              = var.sysdig_plan
  location          = var.region
  tags              = var.sysdig_tags
  service_endpoints = var.sisdig_service_endpoints

  parameters = {
    "default_receiver" = var.enable_platform_metrics
  }
}

resource "ibm_resource_key" "sysdig_resource_key" {
  count = var.sysdig_provision ? 1 : 0

  name                 = var.sysdig_manager_key_name
  resource_instance_id = ibm_resource_instance.sysdig[0].id
  role                 = "Manager"
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
