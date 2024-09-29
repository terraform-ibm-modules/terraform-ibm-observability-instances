# Activity Tracker module

This module supports provisioning the following:

* **IBM Cloud Activity Tracker Event Routing**
  * Use IBM Cloud® Activity Tracker Event Routing to configure how to route auditing events, both global and location-based event data, in your IBM Cloud. Supports routing to the following target types: `IBM Cloud Object Storage (COS)`, `IBM Cloud Logs`, `IBM® Event Streams for IBM Cloud®` and `(DEPRECATED) Activity Tracker hosted event search`.
- **(DEPRECATED) IBM Cloud Activity Tracker instance**
  - Records events, compliant with CADF standard, triggered by user-initiated activities that change the state of a service in the cloud.

## Usage

```hcl
# Locals
locals {
  region      = "us-south"
  at_endpoint = "https://api.${local.region}.logging.cloud.ibm.com"
}

# Required providers
# NOTE: It is required to configure the logdna provider, even if not
# provisioning an Activity Tracker instance. Once the deprecated Activity
# Tracker support is removed from the module, the logdna provider will no
# longer be a requirement

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      version = "X.Y.Z" # lock into a supported provider version
    }
    logdna = {
      source  = "logdna/logdna"
      version = "X.Y.Z" # lock into a supported provider version
    }
  }
}
provider "ibm" {
  ibmcloud_api_key = XXXXXXXXXXXX
  region           = local.region
}

provider "logdna" {
  alias      = "at"
  servicekey = module.activity_tracker.resource_key != null ? module.activity_tracker.resource_key : ""
  url        = local.at_endpoint
}

# Create Activity Tracker target and route for Cloud Logs
module "activity_tracker" {
  source    = "terraform-ibm-modules/observability-instances/ibm//modules/activity_tracker"
  version   = "X.Y.Z" # Replace "X.Y.Z" with a release version to lock into a specific release
  providers = {
    logdna.at = logdna.at
  }
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

- Service
    - **Resource group only**
        - `Viewer` access on the specific resource group
    - **Activity Tracker Event Routing** (Required if creating AT routes and targets)
        - `Editor` platform access
        - `Manager` service access
    - **Cloud Activity Tracker** (Required if creating AT instance)
        - `Editor` platform access
        - `Manager` service access
    - **Tagging service** (Required if attaching access tags to the AT instance)
        - `Editor` platform access

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.69.2, < 2.0.0 |
| <a name="requirement_logdna"></a> [logdna](#requirement\_logdna) | >= 1.14.2, < 2.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.1, < 1.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_atracker_route.atracker_routes](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/atracker_route) | resource |
| [ibm_atracker_settings.atracker_settings](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/atracker_settings) | resource |
| [ibm_atracker_target.atracker_cloud_logs_targets](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/atracker_target) | resource |
| [ibm_atracker_target.atracker_cos_targets](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/atracker_target) | resource |
| [ibm_atracker_target.atracker_eventstreams_targets](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/atracker_target) | resource |
| [ibm_atracker_target.atracker_log_analysis_targets](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/atracker_target) | resource |
| [ibm_iam_authorization_policy.atracker_cloud_logs](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_iam_authorization_policy.atracker_cos](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_resource_instance.activity_tracker](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [ibm_resource_key.resource_key](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_key) | resource |
| [ibm_resource_tag.activity_tracker_tag](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_tag) | resource |
| [logdna_archive.archive_config](https://registry.terraform.io/providers/logdna/logdna/latest/docs/resources/archive) | resource |
| [time_sleep.wait_for_authorization_policy](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.wait_for_cloud_logs_auth_policy](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tags"></a> [access\_tags](#input\_access\_tags) | DEPRECATED: Access Management Tags associated with the Activity Tracker instance (Optional, array of strings). | `list(string)` | `[]` | no |
| <a name="input_activity_tracker_enable_archive"></a> [activity\_tracker\_enable\_archive](#input\_activity\_tracker\_enable\_archive) | DEPRECATED: Enable archive on Activity Tracker instances | `bool` | `false` | no |
| <a name="input_activity_tracker_provision"></a> [activity\_tracker\_provision](#input\_activity\_tracker\_provision) | DEPRECATED: Provision an Activity Tracker instance? | `bool` | `false` | no |
| <a name="input_activity_tracker_routes"></a> [activity\_tracker\_routes](#input\_activity\_tracker\_routes) | List of routes to be created, maximum four routes are allowed | <pre>list(object({<br>    locations  = list(string)<br>    target_ids = list(string)<br>    route_name = string<br>  }))</pre> | `[]` | no |
| <a name="input_cloud_logs_targets"></a> [cloud\_logs\_targets](#input\_cloud\_logs\_targets) | List of Cloud Logs targets to be created | <pre>list(object({<br>    instance_id                              = string<br>    target_region                            = optional(string)<br>    target_name                              = string<br>    skip_atracker_cloud_logs_iam_auth_policy = optional(bool, false)<br>  }))</pre> | `[]` | no |
| <a name="input_cos_bucket_endpoint"></a> [cos\_bucket\_endpoint](#input\_cos\_bucket\_endpoint) | DEPRECATED: An endpoint for the COS bucket for the archive. Pass either the public or private endpoint (Only required when var.activity\_tracker\_enable\_archive and var.activity\_tracker\_provision are true) | `string` | `null` | no |
| <a name="input_cos_bucket_name"></a> [cos\_bucket\_name](#input\_cos\_bucket\_name) | DEPRECATED: The name of an existing COS bucket to be used for the archive (Only required when var.activity\_tracker\_enable\_archive and var.activity\_tracker\_provision are true). | `string` | `null` | no |
| <a name="input_cos_instance_id"></a> [cos\_instance\_id](#input\_cos\_instance\_id) | DEPRECATED: The ID of the cloud object storage instance containing the archive bucket (Only required when var.activity\_tracker\_enable\_archive and var.activity\_tracker\_provision are true). | `string` | `null` | no |
| <a name="input_cos_targets"></a> [cos\_targets](#input\_cos\_targets) | List of cos target to be created | <pre>list(object({<br>    endpoint                          = string<br>    bucket_name                       = string<br>    instance_id                       = string<br>    api_key                           = optional(string)<br>    service_to_service_enabled        = optional(bool, true)<br>    target_region                     = optional(string)<br>    target_name                       = string<br>    skip_atracker_cos_iam_auth_policy = optional(bool, false)<br>  }))</pre> | `[]` | no |
| <a name="input_eventstreams_targets"></a> [eventstreams\_targets](#input\_eventstreams\_targets) | List of event streams target to be created | <pre>list(object({<br>    instance_id   = string<br>    brokers       = list(string)<br>    topic         = string<br>    api_key       = string<br>    target_region = optional(string)<br>    target_name   = string<br>  }))</pre> | `[]` | no |
| <a name="input_global_event_routing_settings"></a> [global\_event\_routing\_settings](#input\_global\_event\_routing\_settings) | Global settings for event routing | <pre>object({<br>    default_targets           = optional(list(string), [])<br>    metadata_region_primary   = string<br>    metadata_region_backup    = optional(string)<br>    permitted_target_regions  = list(string)<br>    private_api_endpoint_only = optional(bool, false)<br>  })</pre> | `null` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | DEPRECATED: The IBM Cloud API Key to use Activity Tracking archiving. Only required if `activity_tracker_enable_archive` is true. | `string` | `null` | no |
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | DEPRECATED: The name of the Activity Tracker instance to create. Defaults to 'activity-tracker-<region>' | `string` | `null` | no |
| <a name="input_log_analysis_targets"></a> [log\_analysis\_targets](#input\_log\_analysis\_targets) | List of log analysis target to be created | <pre>list(object({<br>    instance_id   = string<br>    ingestion_key = string<br>    target_region = optional(string)<br>    target_name   = string<br>  }))</pre> | `[]` | no |
| <a name="input_manager_key_name"></a> [manager\_key\_name](#input\_manager\_key\_name) | DEPRECATED: The name to give the Activity Tracker manager key. | `string` | `"AtManagerKey"` | no |
| <a name="input_manager_key_tags"></a> [manager\_key\_tags](#input\_manager\_key\_tags) | DEPRECATED: Tags associated with the Activity Tracker manager key. | `list(string)` | `[]` | no |
| <a name="input_plan"></a> [plan](#input\_plan) | DEPRECATED: The Activity Tracker plan to provision. Available: lite, 7-day, 14-day, 30-day, hipaa-30-day | `string` | `"lite"` | no |
| <a name="input_region"></a> [region](#input\_region) | DEPRECATED: The IBM Cloud region where the Activity Tracker instance will be created. | `string` | `"us-south"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | DEPRECATED: The id of the IBM Cloud resource group where the instance will be created. | `string` | `null` | no |
| <a name="input_service_endpoints"></a> [service\_endpoints](#input\_service\_endpoints) | DEPRECATED: The type of the service endpoint that will be set for the activity tracker instance. | `string` | `"public-and-private"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | DEPRECATED: Tags associated with the Activity Tracker instance (Optional, array of strings). | `list(string)` | `[]` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_activity_tracker_routes"></a> [activity\_tracker\_routes](#output\_activity\_tracker\_routes) | The map of created routes |
| <a name="output_activity_tracker_targets"></a> [activity\_tracker\_targets](#output\_activity\_tracker\_targets) | The map of created targets |
| <a name="output_crn"></a> [crn](#output\_crn) | The id of the provisioned Activity Tracker instance. |
| <a name="output_guid"></a> [guid](#output\_guid) | The guid of the provisioned Activity Tracker instance. |
| <a name="output_manager_key_name"></a> [manager\_key\_name](#output\_manager\_key\_name) | The Activity Tracker manager key name |
| <a name="output_name"></a> [name](#output\_name) | The name of the provisioned Activity Tracker instance. |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | The resource group where Activity Tracker instance resides |
| <a name="output_resource_key"></a> [resource\_key](#output\_resource\_key) | The resource/service key for agents to use |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
