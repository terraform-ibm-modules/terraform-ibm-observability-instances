provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
}

locals {
  at_endpoint = "https://api.${var.region}.logging.cloud.ibm.com"
}

provider "logdna" {
  alias      = "at"
  servicekey = module.observability_instance_creation.activity_tracker_resource_key != null ? module.observability_instance_creation.activity_tracker_resource_key : ""
  url        = local.at_endpoint
}

provider "logdna" {
  alias      = "ld"
  servicekey = module.observability_instance_creation.logdna_resource_key != null ? module.observability_instance_creation.logdna_resource_key : ""
  url        = local.at_endpoint
}

data "ibm_iam_auth_token" "token_data" {
}

provider "restapi" {
  uri                   = "https:"
  write_returns_object  = false
  create_returns_object = false
  debug                 = false # set to true to show detailed logs, but use carefully as it might print sensitive values.
  headers = {
    Authorization = data.ibm_iam_auth_token.token_data.iam_access_token
    # Does the module have to output the value to use it here?
    Bluemix-Instance = module.key_protect.key_protect_guid
    Content-Type     = "application/vnd.ibm.kms.policy+json"
  }
}
