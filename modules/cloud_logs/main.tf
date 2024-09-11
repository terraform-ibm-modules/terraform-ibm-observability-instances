locals {
  instance_name = var.instance_name != null ? var.instance_name : "cloud-logs-${var.region}"
}


# Cloud Logs
resource "ibm_resource_instance" "cloud_logs" {
  name              = local.instance_name
  resource_group_id = var.resource_group_id
  service           = "logs"
  plan              = var.plan
  tags              = var.resource_tags
  location          = var.region
  parameters = {
    "logs_bucket_crn"         = var.data_storage.logs_data.enabled ? var.data_storage.logs_data.bucket_crn : null
    "logs_bucket_endpoint"    = var.data_storage.logs_data.enabled ? var.data_storage.logs_data.bucket_endpoint : null
    "metrics_bucket_crn"      = var.data_storage.metrics_data.enabled ? var.data_storage.metrics_data.bucket_crn : null
    "metrics_bucket_endpoint" = var.data_storage.metrics_data.enabled ? var.data_storage.metrics_data.bucket_endpoint : null
    "retention_period"        = var.retention_period
  }
  service_endpoints = var.service_endpoints
}

resource "ibm_resource_tag" "cloud_logs_tag" {
  count       = length(var.access_tags) == 0 ? 0 : 1
  resource_id = ibm_resource_instance.cloud_logs.crn
  tags        = var.access_tags
  tag_type    = "access"
}

##############################################################################
# Get Cloud Account ID
##############################################################################

data "ibm_iam_account_settings" "iam_account_settings" {
}

resource "ibm_iam_authorization_policy" "cos_policy" {
  for_each                 = { for index, bucket in var.data_storage : index => bucket if bucket.enabled && !bucket.skip_cos_auth_policy }
  source_service_name      = "logs"
  source_resource_group_id = var.resource_group_id
  roles                    = ["Writer"]
  description              = "Allow Cloud logs instances `Writer` access to the COS bucket with ID ${regex("bucket:(.*)", each.value.bucket_crn)[0]}, in the COS instance with ID ${regex(".*:(.*):bucket:.*", each.value.bucket_crn)[0]}."

  resource_attributes {
    name     = "serviceName"
    operator = "stringEquals"
    value    = "cloud-object-storage"
  }

  resource_attributes {
    name     = "accountId"
    operator = "stringEquals"
    value    = data.ibm_iam_account_settings.iam_account_settings.account_id
  }

  resource_attributes {
    name     = "serviceInstance"
    operator = "stringEquals"
    value    = regex(".*:(.*):bucket:.*", each.value.bucket_crn)[0]
  }

  resource_attributes {
    name     = "resourceType"
    operator = "stringEquals"
    value    = "bucket"
  }

  resource_attributes {
    name     = "resource"
    operator = "stringEquals"
    value    = regex("bucket:(.*)", each.value.bucket_crn)[0]
  }
}

##############################################################################
# EN Integration
##############################################################################

# Create IAM Authorization Policies to allow Cloud Logs to access event notification
resource "ibm_iam_authorization_policy" "en_policy" {
  for_each                    = { for idx, en in var.existing_en_instances : idx => en if !en.skip_en_auth_policy }
  source_service_name         = "logs"
  source_resource_instance_id = ibm_resource_instance.cloud_logs.guid
  target_service_name         = "event-notifications"
  target_resource_instance_id = each.value.en_instance_id
  roles                       = ["Event Source Manager"]
  description                 = "Allow Cloud Logs with instance ID ${ibm_resource_instance.cloud_logs.guid} 'Event Source Manager' role access on the Event Notification instance GUID ${each.value.en_instance_id}"
}

resource "time_sleep" "wait_for_en_authorization_policy" {
  depends_on      = [ibm_iam_authorization_policy.en_policy]
  create_duration = "30s"
}

resource "ibm_logs_outgoing_webhook" "en_integration" {
  depends_on  = [time_sleep.wait_for_en_authorization_policy]
  for_each    = { for idx, en in var.existing_en_instances : idx => en }
  instance_id = ibm_resource_instance.cloud_logs.guid
  region      = var.region
  name        = each.value.en_integration_name == null ? "${local.instance_name}-en-integration-${each.key}" : each.value.en_integration_name
  type        = "ibm_event_notifications"

  ibm_event_notifications {
    event_notifications_instance_id = each.value.en_instance_id
    region_id                       = each.value.en_region
  }
}

##############################################################################
# Logs Routing
##############################################################################

# Create required auth policy to allow log routing service to send logs to the cloud logs instance
resource "ibm_iam_authorization_policy" "logs_routing_policy" {
  count               = !var.skip_logs_routing_auth_policy ? 1 : 0
  source_service_name = "logs-router"
  roles               = ["Sender"]
  description         = "Allow Logs Routing `Sender` access to the IBM Cloud Logs with ID ${ibm_resource_instance.cloud_logs.guid}."

  resource_attributes {
    name     = "serviceName"
    operator = "stringEquals"
    value    = "logs"
  }

  resource_attributes {
    name     = "accountId"
    operator = "stringEquals"
    value    = data.ibm_iam_account_settings.iam_account_settings.account_id
  }

  resource_attributes {
    name     = "serviceInstance"
    operator = "stringEquals"
    value    = ibm_resource_instance.cloud_logs.guid
  }
}

resource "random_string" "random_tenant_suffix" {
  length  = 4
  numeric = true
  upper   = false
  lower   = false
  special = false
}

# Lookup supported regions (Cloud Logs support the same as VPC regions)
# data "ibm_is_regions" "regions" {} # uncomment when region support comes in https://github.com/IBM-Cloud/terraform-provider-ibm/pull/5634

# Lookup current provider region
data "ibm_is_region" "provider_region" {}

locals {
  log_sink_host = var.use_private_endpoint_logs_routing ? "${ibm_resource_instance.cloud_logs.guid}.ingress.private.${var.region}.logs.cloud.ibm.com" : "${ibm_resource_instance.cloud_logs.guid}.ingress.${var.region}.logs.cloud.ibm.com"

  # Temporary validation to ensure the provider region matches the region passed in the var.logs_routing_tenant_regions
  region_validate_condition = length(var.logs_routing_tenant_regions) != 0 ? data.ibm_is_region.provider_region.name != var.logs_routing_tenant_regions[0] : false
  region_validate_msg       = "The provider region defined in the provider config, and the region passed in the 'logs_routing_tenant_regions' list currently must match. If not region has been defined in the provider config, it defaults to us-south."
  # tflint-ignore: terraform_unused_declarations
  region_validate_check = regex("^${local.region_validate_msg}$", (!local.region_validate_condition ? local.region_validate_msg : ""))
}

resource "ibm_logs_router_tenant" "logs_router_tenant_instances" {
  # until provider supports passing region to this resource (coming in https://github.com/IBM-Cloud/terraform-provider-ibm/pull/5634),
  # the for_each will only ever include the provider region

  # for_each = contains(var.logs_routing_tenant_regions, "*") ? toset(data.ibm_is_regions.regions.regions[*].name) : var.logs_routing_tenant_regions
  for_each = contains(var.logs_routing_tenant_regions, "*") ? toset([data.ibm_is_region.provider_region.name]) : toset(var.logs_routing_tenant_regions)
  name     = "${each.key}-${random_string.random_tenant_suffix.result}"
  # region = each.key
  targets {
    log_sink_crn = ibm_resource_instance.cloud_logs.crn
    name         = local.instance_name
    parameters {
      host = local.log_sink_host
      port = 443
    }
  }
}
