module "resource_group" {
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git?ref=v1.0.5"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

locals {
  bucket_name = "${var.prefix}-logdna-archive-bucket"
}

module "cos_bucket" {
  source             = "terraform-ibm-modules/cos/ibm"
  version            = "5.4.0"
  resource_group_id  = module.resource_group.resource_group_id
  region             = var.region
  encryption_enabled = false
  cos_instance_name  = "${var.prefix}-cos"
  cos_tags           = var.resource_tags
  bucket_name        = local.bucket_name
}

module "test_observability_instance_creation" {
  source = "../../"
  providers = {
    logdna.at = logdna.at
    logdna.ld = logdna.ld
  }
  resource_group_id          = module.resource_group.resource_group_id
  region                     = var.region
  logdna_instance_name       = var.prefix
  enable_platform_logs       = false
  sysdig_provision           = false
  activity_tracker_provision = false
  logdna_plan                = "7-day"
  logdna_tags                = var.resource_tags
  sysdig_tags                = var.resource_tags
  activity_tracker_tags      = var.resource_tags

  enable_archive             = true
  ibmcloud_api_key           = var.ibmcloud_api_key
  logdna_cos_instance_id     = module.cos_bucket.cos_instance_id
  logdna_cos_bucket_name     = local.bucket_name
  logdna_cos_bucket_endpoint = module.cos_bucket.s3_endpoint_public[0]
}
