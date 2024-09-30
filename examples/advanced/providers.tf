provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}

locals {
  at_endpoint = "https://api.${var.region}.logging.cloud.ibm.com"
}

provider "logdna" {
  alias      = "at"
  servicekey = ""
  url        = local.at_endpoint
}

provider "logdna" {
  alias      = "ld"
  servicekey = ""
  url        = local.at_endpoint
}
