# Activity Tracker instance sub-module

This sub-module supports provisioning the following observability instance:

- **IBM Cloud Activity Tracker**
  - Records events, compliant with CADF standard, triggered by user-initiated activities that change the state of a service in the cloud.

:information_source: This sub-module also creates a manager key, and supports passing COS bucket details to enable archiving for Activity Tracker, it also supports event routing to COS, LogDNA and Event Streams.

## Usage

To provision Activity Tracker instance

```hcl
# required ibm provider config
provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
}

# required logdna provider config
locals {
  at_endpoint = "https://api.${var.region}.logging.cloud.ibm.com"
}

provider "logdna" {
  alias      = "at"
  servicekey = module.activity_tracker.resource_key
  url        = local.at_endpoint
}

module "activity_tracker" {
  # Replace "main" with a GIT release version to lock into a specific release
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-observability-instances//modules/activity_tracker?ref=main"
  providers = {
    logdna.at = logdna.at
  }
  resource_group_id = module.resource_group.resource_group_id
  region = var.region
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.49.0 |
| <a name="requirement_logdna"></a> [logdna](#requirement\_logdna) | >= 1.14.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [ibm_atracker_route.atracker_routes](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/atracker_route) | resource |
| [ibm_atracker_settings.atracker_settings](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/atracker_settings) | resource |
| [ibm_atracker_target.atracker_cos_targets](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/atracker_target) | resource |
| [ibm_atracker_target.atracker_eventstreams_targets](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/atracker_target) | resource |
| [ibm_atracker_target.atracker_logdna_targets](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/atracker_target) | resource |
| [ibm_resource_instance.activity_tracker](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [ibm_resource_key.resource_key](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_key) | resource |
| [logdna_archive.archive_config](https://registry.terraform.io/providers/logdna/logdna/latest/docs/resources/archive) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_activity_tracker_provision"></a> [activity\_tracker\_provision](#input\_activity\_tracker\_provision) | Provision an Activity Tracker instance? | `bool` | `true` | no |
| <a name="input_activity_tracker_routes"></a> [activity\_tracker\_routes](#input\_activity\_tracker\_routes) | List of routes to be created, maximum four routes are allowed | <pre>list(object({<br>    locations  = list(string)<br>    target_ids = list(string)<br>    route_name = string<br>  }))</pre> | `[]` | no |
| <a name="input_cos_bucket_endpoint"></a> [cos\_bucket\_endpoint](#input\_cos\_bucket\_endpoint) | An endpoint for the COS bucket for the archive. Pass either the public or private endpoint (Only required when var.enable\_archive and var.activity\_tracker\_provision are true) | `string` | `null` | no |
| <a name="input_cos_bucket_name"></a> [cos\_bucket\_name](#input\_cos\_bucket\_name) | The name of an existing COS bucket to be used for the archive (Only required when var.enable\_archive and var.activity\_tracker\_provision are true). | `string` | `null` | no |
| <a name="input_cos_instance_id"></a> [cos\_instance\_id](#input\_cos\_instance\_id) | The ID of the cloud object storage instance containing the archive bucket (Only required when var.enable\_archive and var.activity\_tracker\_provision are true). | `string` | `null` | no |
| <a name="input_cos_targets"></a> [cos\_targets](#input\_cos\_targets) | List of cos target to be created | <pre>list(object({<br>    endpoint                   = string<br>    bucket_name                = string<br>    instance_id                = string<br>    api_key                    = optional(string)<br>    service_to_service_enabled = optional(bool, false)<br>    target_region              = optional(string)<br>    target_name                = string<br>  }))</pre> | `[]` | no |
| <a name="input_enable_archive"></a> [enable\_archive](#input\_enable\_archive) | Enable archive on Activity Tracker instances | `bool` | `false` | no |
| <a name="input_eventstreams_targets"></a> [eventstreams\_targets](#input\_eventstreams\_targets) | List of event streams target to be created | <pre>list(object({<br>    instance_id   = string<br>    brokers       = list(string)<br>    topic         = string<br>    api_key       = string<br>    target_region = optional(string)<br>    target_name   = string<br>  }))</pre> | `[]` | no |
| <a name="input_global_event_routing_settings"></a> [global\_event\_routing\_settings](#input\_global\_event\_routing\_settings) | Global settings for event routing | <pre>object({<br>    default_targets           = optional(list(string), [])<br>    metadata_region_primary   = string<br>    metadata_region_backup    = optional(string)<br>    permitted_target_regions  = list(string)<br>    private_api_endpoint_only = optional(bool, false)<br>  })</pre> | `null` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | Only required to archive. The IBM Cloud API Key. | `string` | `null` | no |
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | The name of the Activity Tracker instance to create. Defaults to 'activity-tracker-<region>' | `string` | `null` | no |
| <a name="input_logdna_targets"></a> [logdna\_targets](#input\_logdna\_targets) | List of logdna target to be created | <pre>list(object({<br>    instance_id   = string<br>    ingestion_key = string<br>    target_region = optional(string)<br>    target_name   = string<br>  }))</pre> | `[]` | no |
| <a name="input_manager_key_name"></a> [manager\_key\_name](#input\_manager\_key\_name) | The name to give the Activity Tracker manager key. | `string` | `"AtManagerKey"` | no |
| <a name="input_manager_key_tags"></a> [manager\_key\_tags](#input\_manager\_key\_tags) | Tags associated with the Activity Tracker manager key. | `list(string)` | `[]` | no |
| <a name="input_plan"></a> [plan](#input\_plan) | The Activity Tracker plan to provision. Available: lite, 7-day, 14-day, 30-day, hipaa-30-day | `string` | `"lite"` | no |
| <a name="input_region"></a> [region](#input\_region) | The IBM Cloud region where instances will be created. | `string` | `"us-south"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The id of the IBM Cloud resource group where the instance(s) will be created. | `string` | `null` | no |
| <a name="input_service_endpoints"></a> [service\_endpoints](#input\_service\_endpoints) | The type of the service endpoint that will be set for the activity tracker instance. | `string` | `"public-and-private"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags associated with the Activity Tracker instance (Optional, array of strings). | `list(string)` | `[]` | no |

## Outputs

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
<!-- BEGIN CONTRIBUTING HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->

## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.

<!-- Source for this readme file: https://github.com/terraform-ibm-modules/common-dev-assets/tree/main/module-assets/ci/module-template-automation -->
<!-- END CONTRIBUTING HOOK -->
