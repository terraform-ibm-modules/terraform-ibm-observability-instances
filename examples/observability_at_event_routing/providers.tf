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
  alias      = "ld_1"
  servicekey = module.log_analysis_1.resource_key != null ? module.log_analysis_1.resource_key : ""
  url        = local.at_endpoint
}

provider "logdna" {
  alias      = "ld_2"
  servicekey = module.log_analysis_2.resource_key != null ? module.log_analysis_2.resource_key : ""
  url        = local.at_endpoint
}
