provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
}

locals {
  at_endpoint = "https://api.${var.region}.logging.cloud.ibm.com"
}

provider "logdna" {
  alias      = "at"
  servicekey = module.activity_tracker.resource_key != null ? module.activity_tracker.resource_key : ""
  url        = local.at_endpoint
}

provider "logdna" {
  alias      = "ld"
  servicekey = module.logdna.resource_key != null ? module.logdna.resource_key : ""
  url        = local.at_endpoint
}
