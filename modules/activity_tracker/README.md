# Activity Tracker module

This module supports provisioning the following:

* **IBM Cloud Activity Tracker Event Routing**
  * Use IBM Cloud® Activity Tracker Event Routing to configure how to route auditing events, both global and location-based event data, in your IBM Cloud. Supports routing to the following target types: `IBM Cloud Object Storage (COS)`, `IBM Cloud Logs`, and `IBM® Event Streams for IBM Cloud®`.

## Usage

```hcl
# Locals
locals {
  region      = "us-south"
}

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      version = "X.Y.Z" # lock into a supported provider version
    }
  }
}
provider "ibm" {
  ibmcloud_api_key = XXXXXXXXXXXX
  region           = local.region
}

# Create Activity Tracker target and route for Cloud Logs
module "activity_tracker" {
  source    = "terraform-ibm-modules/observability-instances/ibm//modules/activity_tracker"
  version   = "X.Y.Z" # Replace "X.Y.Z" with a release version to lock into a specific release
  # Create Cloud Logs target
  cloud_logs_targets = [
    {
      # ID of the Cloud logs instance
      instance_id   = "crn:v1:bluemix:public:logs:us-south:a/xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX:xxxxxx-XXXX-XXXX-XXXX-xxxxxx::"
      target_region = "us-south"
      target_name   = "my-icl-target"
    }
  ]
  activity_tracker_routes = [
    {
      locations  = ["*", "global"]
      target_ids = [module.activity_tracker.activity_tracker_targets["my-icl-target"].id]
      route_name = "my-icl-route"
    }
  ]
}
```

### Required IAM access policies

You need the following permissions to run this module.

* Service
  * **Activity Tracker Event Routing** (Required if creating AT routes and targets)
    * `Editor` platform access
    * `Manager` service access

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.70.0, < 2.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.1, < 1.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cbr_rule"></a> [cbr\_rule](#module\_cbr\_rule) | terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module | 1.29.0 |

### Resources

| Name | Type |
|------|------|
| [ibm_atracker_route.atracker_routes](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/atracker_route) | resource |
| [ibm_atracker_settings.atracker_settings](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/atracker_settings) | resource |
| [ibm_atracker_target.atracker_cloud_logs_targets](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/atracker_target) | resource |
| [ibm_atracker_target.atracker_cos_targets](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/atracker_target) | resource |
| [ibm_atracker_target.atracker_eventstreams_targets](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/atracker_target) | resource |
| [ibm_iam_authorization_policy.atracker_cloud_logs](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_iam_authorization_policy.atracker_cos](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_iam_authorization_policy.atracker_es](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [time_sleep.wait_for_authorization_policy](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.wait_for_cloud_logs_auth_policy](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.wait_for_event_stream_auth_policy](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_activity_tracker_routes"></a> [activity\_tracker\_routes](#input\_activity\_tracker\_routes) | List of routes to be created, maximum four routes are allowed | <pre>list(object({<br/>    locations  = list(string)<br/>    target_ids = list(string)<br/>    route_name = string<br/>  }))</pre> | `[]` | no |
| <a name="input_cbr_rules_at"></a> [cbr\_rules\_at](#input\_cbr\_rules\_at) | (Optional, list) List of context-based restrictions rules to create | <pre>list(object({<br/>    description = string<br/>    account_id  = string<br/>    rule_contexts = list(object({<br/>      attributes = optional(list(object({<br/>        name  = string<br/>        value = string<br/>    }))) }))<br/>    enforcement_mode = string<br/>  }))</pre> | `[]` | no |
| <a name="input_cloud_logs_targets"></a> [cloud\_logs\_targets](#input\_cloud\_logs\_targets) | List of Cloud Logs targets to be created | <pre>list(object({<br/>    instance_id                              = string<br/>    target_region                            = optional(string)<br/>    target_name                              = string<br/>    skip_atracker_cloud_logs_iam_auth_policy = optional(bool, false)<br/>  }))</pre> | `[]` | no |
| <a name="input_cos_targets"></a> [cos\_targets](#input\_cos\_targets) | List of cos target to be created | <pre>list(object({<br/>    endpoint                          = string<br/>    bucket_name                       = string<br/>    instance_id                       = string<br/>    api_key                           = optional(string)<br/>    service_to_service_enabled        = optional(bool, true)<br/>    target_region                     = optional(string)<br/>    target_name                       = string<br/>    skip_atracker_cos_iam_auth_policy = optional(bool, false)<br/>  }))</pre> | `[]` | no |
| <a name="input_eventstreams_targets"></a> [eventstreams\_targets](#input\_eventstreams\_targets) | List of event streams target to be created | <pre>list(object({<br/>    instance_id                      = string<br/>    brokers                          = list(string)<br/>    topic                            = string<br/>    api_key                          = optional(string)<br/>    service_to_service_enabled       = optional(bool, true)<br/>    target_region                    = optional(string)<br/>    target_name                      = string<br/>    skip_atracker_es_iam_auth_policy = optional(bool, false)<br/>  }))</pre> | `[]` | no |
| <a name="input_global_event_routing_settings"></a> [global\_event\_routing\_settings](#input\_global\_event\_routing\_settings) | Global settings for event routing | <pre>object({<br/>    default_targets           = optional(list(string), [])<br/>    metadata_region_primary   = string<br/>    metadata_region_backup    = optional(string)<br/>    permitted_target_regions  = list(string)<br/>    private_api_endpoint_only = optional(bool, false)<br/>  })</pre> | `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_activity_tracker_routes"></a> [activity\_tracker\_routes](#output\_activity\_tracker\_routes) | The map of created routes |
| <a name="output_activity_tracker_targets"></a> [activity\_tracker\_targets](#output\_activity\_tracker\_targets) | The map of created targets |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
