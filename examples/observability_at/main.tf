module "resource_group" {
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git?ref=v1.0.5"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}


#target
module "cos_bucket" {
  source             = "git::https://github.com/terraform-ibm-modules/terraform-ibm-cos?ref=v5.0.0"
  resource_group_id  = module.resource_group.resource_group_id
  region             = var.region
  cos_instance_name  = "${var.prefix}-cos-test"
  cos_tags           = var.resource_tags
  bucket_name        = "${var.prefix}-cos-bucket"
  encryption_enabled = false
  retention_enabled  = false
}



module "test_observability_instance_creation" {
  source                         = "../../"
  resource_group_id              = module.resource_group.resource_group_id
  region                         = var.region
  logdna_provision               = false
  sysdig_provision               = false
  activity_tracker_instance_name = var.prefix
  activity_tracker_plan          = "7-day"
  logdna_tags                    = var.resource_tags
  sysdig_tags                    = var.resource_tags
  activity_tracker_tags          = var.resource_tags
  cos_endpoint = [
    {
      api_key : var.ibmcloud_api_key,
      bucket_name : module.cos_bucket.bucket_name[0],
      endpoint : module.cos_bucket.s3_endpoint_private[0],
      target_crn : module.cos_bucket.cos_instance_id
      service_to_service_enabled = false
  }]

  regions_target_cos = [var.region, "global"] # review later
}
