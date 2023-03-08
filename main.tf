##############################################################################
# observability-instances-module
#
# Deploy the observability instances - Log Analysis, IBM Cloud Monitoring and Activity Tracker
##############################################################################

locals {
  log_analysis_instance_name     = var.log_analysis_instance_name != null ? var.log_analysis_instance_name : "log_analysis-${var.region}"
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

  cos_log_analysis_validate_condition = var.enable_archive && var.log_analysis_provision && ((var.log_analysis_cos_instance_id == null || var.log_analysis_cos_bucket_name == null || var.log_analysis_cos_bucket_endpoint == null))
  cos_log_analysis_validate_msg       = "'log_analysis_cos_instance_id', 'log_analysis_cos_bucket_name' and 'log_analysis_cos_bucket_endpoint' are required when 'enable_archive' is true"
  # tflint-ignore: terraform_unused_declarations
  cos_log_analysis_validate_check = regex("^${local.cos_log_analysis_validate_msg}$", (!local.cos_log_analysis_validate_condition ? local.cos_log_analysis_validate_msg : ""))

}

# LogAnalysis
resource "ibm_resource_instance" "log_analysis" {
  count = var.log_analysis_provision ? 1 : 0

  name              = local.log_analysis_instance_name
  resource_group_id = var.resource_group_id
  service           = "logdna"
  plan              = var.log_analysis_plan
  location          = var.region
  tags              = var.log_analysis_tags
  service_endpoints = var.log_analysis_service_endpoints

  parameters = {
    "default_receiver" = var.enable_platform_logs
  }
}

resource "ibm_resource_key" "log_analysis_resource_key" {
  count = var.log_analysis_provision ? 1 : 0

  name                 = var.log_analysis_manager_key_name
  resource_instance_id = ibm_resource_instance.log_analysis[0].id
  role                 = var.log_analysis_resource_key_role
  tags                 = var.log_analysis_manager_key_tags
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

resource "logdna_archive" "log_analysis_config" {
  count       = var.log_analysis_provision && var.enable_archive ? 1 : 0
  provider    = logdna.ld
  integration = "ibm"
  ibm_config {
    apikey             = var.ibmcloud_api_key
    bucket             = var.log_analysis_cos_bucket_name
    endpoint           = var.log_analysis_cos_bucket_endpoint
    resourceinstanceid = var.log_analysis_cos_instance_id
  }
}
