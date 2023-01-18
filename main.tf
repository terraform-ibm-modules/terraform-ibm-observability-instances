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

  # When archive is enabled key protect key crn is required to encrypt archive
  kp_validate_condition = var.enable_archive == true && var.key_protect_key_crn == null
  kp_validate_msg       = "'key_protect_key_crn' is required when 'enable_archive' is true"
  # tflint-ignore: terraform_unused_declarations
  kp_validate_check = regex("^${local.kp_validate_msg}$", (!local.kp_validate_condition ? local.kp_validate_msg : ""))

  # When archive is enabled cos instance id is required to create buckets in
  cos_validate_condition = var.enable_archive == true && var.existing_cos_instance_id == null
  cos_validate_msg       = "'existing_cos_instance_id' is required when 'enable_archive' is true"
  # tflint-ignore: terraform_unused_declarations
  cos_validate_check = regex("^${local.cos_validate_msg}$", (!local.cos_validate_condition ? local.cos_validate_msg : ""))

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
}

resource "ibm_resource_key" "at_resource_key" {
  count = var.activity_tracker_provision ? 1 : 0

  name                 = var.activity_tracker_manager_key_name
  resource_instance_id = ibm_resource_instance.activity_tracker[0].id
  role                 = "Manager"
}

##############################################################################
# COS bucket of type
##############################################################################
locals {
  activity_bucket_name = "${local.activity_tracker_instance_name}-ibm-activity-events"
  events_bucket_name   = "${local.logdna_instance_name}-ibm-logdna-events"
}

module "cos_at_bucket" {
  count = var.activity_tracker_provision && var.enable_archive ? 1 : 0
  # Section for general properties
  source            = "terraform-ibm-modules/cos/ibm"
  version           = "5.0.0"
  resource_group_id = var.resource_group_id

  # Use existing kp key
  key_protect_key_crn = var.key_protect_key_crn

  # Use existing cos instance
  create_cos_instance      = false
  existing_cos_instance_id = var.existing_cos_instance_id

  # Section for bucket
  bucket_name        = local.activity_bucket_name
  encryption_enabled = true

  # Section for AT and monitoring/metrics
  activity_tracker_crn = ibm_resource_instance.activity_tracker[0].crn
  sysdig_crn           = ibm_resource_instance.sysdig[0].crn

}

resource "logdna_archive" "activity_tracker_config" {
  count       = var.activity_tracker_provision && var.enable_archive ? 1 : 0
  provider    = logdna.at
  integration = "ibm"
  ibm_config {
    apikey             = var.ibmcloud_api_key
    bucket             = module.cos_at_bucket[0].bucket_name
    endpoint           = module.cos_at_bucket[0].s3_endpoint_private
    resourceinstanceid = var.existing_cos_instance_id
  }
}

module "cos_logdna_bucket" {
  count = var.logdna_provision && var.enable_archive ? 1 : 0
  # Section for general properties
  source            = "terraform-ibm-modules/cos/ibm"
  version           = "5.0.0"
  resource_group_id = var.resource_group_id

  # Use existing kp key
  key_protect_key_crn = var.key_protect_key_crn

  # Use existing cos instance
  create_cos_instance      = false
  existing_cos_instance_id = var.existing_cos_instance_id

  # Section for bucket
  bucket_name        = local.events_bucket_name
  encryption_enabled = true

  # Section for AT and monitoring/metrics
  activity_tracker_crn = ibm_resource_instance.activity_tracker[0].crn
  sysdig_crn           = ibm_resource_instance.sysdig[0].crn

}

resource "logdna_archive" "logdna_config" {
  count       = var.logdna_provision && var.enable_archive ? 1 : 0
  provider    = logdna.ld
  integration = "ibm"
  ibm_config {
    apikey             = var.ibmcloud_api_key
    bucket             = module.cos_logdna_bucket[0].bucket_name
    endpoint           = module.cos_logdna_bucket[0].s3_endpoint_private
    resourceinstanceid = var.existing_cos_instance_id
  }
}
