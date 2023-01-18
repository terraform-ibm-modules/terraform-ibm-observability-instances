provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
}

provider "logdna" {
  alias      = "at"
  servicekey = module.test_observability_instance_creation.activity_tracker_resource_key != null ? module.test_observability_instance_creation.activity_tracker_resource_key : ""
  url        = local.at_endpoint
}

provider "logdna" {
  alias      = "ld"
  servicekey = module.test_observability_instance_creation.logdna_resource_key != null ? module.test_observability_instance_creation.logdna_resource_key : ""
  url        = local.at_endpoint
}
