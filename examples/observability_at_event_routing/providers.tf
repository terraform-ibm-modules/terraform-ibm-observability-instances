provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = local.activity_tracker_region
}

locals {
  at_endpoint = "https://api.${local.activity_tracker_region}.logging.cloud.ibm.com"
}

provider "logdna" {
  alias      = "at"
  servicekey = local.activity_tracker_resource_key != null ? local.activity_tracker_resource_key : ""
  url        = local.at_endpoint
}

provider "logdna" {
  alias      = "ld"
  servicekey = module.logdna.resource_key != null ? module.logdna.resource_key : ""
  url        = local.at_endpoint
}
