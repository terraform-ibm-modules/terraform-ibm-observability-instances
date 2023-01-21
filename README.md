<!-- BEGIN MODULE HOOK -->

<!-- Update the title to match the module name and add a description -->

# Terraform IBM Observability instances module

<!-- UPDATE BADGE: Update the link for the following badge-->

[![Stable (With quality checks)](<https://img.shields.io/badge/Status-Stable%20(With%20quality%20checks)-green?style=plastic>)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![Build status](https://github.com/terraform-ibm-modules/terraform-ibm-observability-instances/actions/workflows/ci.yml/badge.svg)](https://github.com/terraform-ibm-modules/terraform-ibm-observability-instances/actions/workflows/ci.yml)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-observability-instances?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-observability-instances/releases/latest)

This module supports provisioning the following observability instances:

- **IBM Cloud Activity Tracker**
  - Records events, compliant with CADF standard, triggered by user-initiated activities that change the state of a service in the cloud.
- **IBM Cloud Logging with LogDNA**
  - Manage operating system logs, application logs, and platform logs in IBM Cloud.
- **IBM Cloud Monitoring with SysDig**
  - Monitor the health of services and applications in IBM Cloud.

:information_source: The module also creates a manager key for each instance.

## Usage

```hcl
# Replace "main" with a GIT release version to lock into a specific release
module "observability_instances" {
  source                             = "git::https://github.com/terraform-ibm-modules/terraform-ibm-observability-instances?ref=main"
  logdna_resource_group_id           = var.resource_group.id
  sysdig_resource_group_id           = var.resource_group.id
  activity_tracker_resource_group_id = var.resource_group.id
  logdna_region                      = var.ibm_region
  sysdig_region                      = var.ibm_region
  activity_tracker_region            = var.ibm_region
  logdna_plan                        = "7-day"
  sysdig_plan                        = "graduated-tier"
  activity_tracker_plan              = "7-day"
}
```

## Required IAM access policies

You need the following permissions to run this module.

- Account Management
  - **Resource Group** service
    - `Viewer` platform access
- IAM Services
  - **IBM Cloud Activity Tracker** service
    - `Editor` platform access
    - `Manager` service access
  - **IBM Cloud Monitoring** service
    - `Editor` platform access
    - `Manager` service access
  - **IBM Log Analysis** service
    - `Editor` platform access
    - `Manager` service access

<!-- BEGIN EXAMPLES HOOK -->
## Examples

- [ Provision Activity Tracker only](examples/observability_at)
- [ Provision observability instance with default config (LogDNA, Sysdig, AT)](examples/observability_default)
- [ Provision LogDNA only](examples/observability_logdna)
- [ Provision SysDig only](examples/observability_sysdig)
<!-- END EXAMPLES HOOK -->
  <!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.49.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [ibm_atracker_route.atracker_route_cos](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/atracker_route) | resource |
| [ibm_atracker_route.atracker_route_eventstreams](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/atracker_route) | resource |
| [ibm_atracker_route.atracker_route_logdna](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/atracker_route) | resource |
| [ibm_atracker_settings.atracker_settings](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/atracker_settings) | resource |
| [ibm_atracker_target.atracker_cos_target](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/atracker_target) | resource |
| [ibm_atracker_target.atracker_eventstreams_target](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/atracker_target) | resource |
| [ibm_atracker_target.atracker_logdna_target](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/atracker_target) | resource |
| [ibm_resource_instance.activity_tracker](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [ibm_resource_instance.logdna](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [ibm_resource_instance.sysdig](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [ibm_resource_key.at_resource_key](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_key) | resource |
| [ibm_resource_key.log_dna_resource_key](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_key) | resource |
| [ibm_resource_key.sysdig_resource_key](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_activity_tracker_instance_name"></a> [activity\_tracker\_instance\_name](#input\_activity\_tracker\_instance\_name) | The name of the Activity Tracker instance to create. Defaults to 'activity-tracker-<region>' | `string` | `null` | no |
| <a name="input_activity_tracker_manager_key_name"></a> [activity\_tracker\_manager\_key\_name](#input\_activity\_tracker\_manager\_key\_name) | The name to give the Activity Tracker manager key. | `string` | `"AtManagerKey"` | no |
| <a name="input_activity_tracker_plan"></a> [activity\_tracker\_plan](#input\_activity\_tracker\_plan) | The Activity Tracker plan to provision. Available: lite, 7-day, 14-day, 30-day, hipaa-30-day | `string` | `"lite"` | no |
| <a name="input_activity_tracker_provision"></a> [activity\_tracker\_provision](#input\_activity\_tracker\_provision) | Provision an Activity Tracker instance? | `bool` | `true` | no |
| <a name="input_activity_tracker_tags"></a> [activity\_tracker\_tags](#input\_activity\_tracker\_tags) | Tags associated with the Activity Tracker instance (Optional, array of strings). | `list(string)` | `[]` | no |
| <a name="input_cos_endpoint"></a> [cos\_endpoint](#input\_cos\_endpoint) | (Optional, List) Property values for a Cloud Object Storage Endpoint. | <pre>list(object({<br>    endpoint                   = string<br>    bucket_name                = string<br>    target_crn                 = string<br>    api_key                    = string<br>    service_to_service_enabled = bool<br>  }))</pre> | `[]` | no |
| <a name="input_cos_route_name"></a> [cos\_route\_name](#input\_cos\_route\_name) | (Required, String) The name of the COS route. | `string` | `null` | no |
| <a name="input_cos_target_name"></a> [cos\_target\_name](#input\_cos\_target\_name) | (Optional, String) The name of the COS target. | `string` | `null` | no |
| <a name="input_cos_target_region"></a> [cos\_target\_region](#input\_cos\_target\_region) | (Optional, String) Region where is COS target is created | `string` | `null` | no |
| <a name="input_default_targets"></a> [default\_targets](#input\_default\_targets) | (Optional, List) The target ID List. In the event that no routing rule causes the event to be sent to a target, these targets will receive the event. | `list(string)` | `[]` | no |
| <a name="input_enable_platform_logs"></a> [enable\_platform\_logs](#input\_enable\_platform\_logs) | Receive platform logs in the provisioned IBM Cloud Logging instance. | `bool` | `true` | no |
| <a name="input_enable_platform_metrics"></a> [enable\_platform\_metrics](#input\_enable\_platform\_metrics) | Receive platform metrics in the provisioned IBM Cloud Monitoring instance. | `bool` | `true` | no |
| <a name="input_eventstreams_endpoint"></a> [eventstreams\_endpoint](#input\_eventstreams\_endpoint) | (Required, List) Property values for Event streams Endpoint | <pre>list(object({<br>    target_crn = string<br>    brokers    = list(string)<br>    topic      = string<br>    api_key    = string<br>  }))</pre> | `[]` | no |
| <a name="input_eventstreams_route_name"></a> [eventstreams\_route\_name](#input\_eventstreams\_route\_name) | (Required, String) The name of the Event Streams route. | `string` | `null` | no |
| <a name="input_eventstreams_target_name"></a> [eventstreams\_target\_name](#input\_eventstreams\_target\_name) | (Optional, String) The name of the logDNA target. | `string` | `null` | no |
| <a name="input_eventstreams_target_region"></a> [eventstreams\_target\_region](#input\_eventstreams\_target\_region) | Region where is Event streams target is created | `string` | `null` | no |
| <a name="input_logdna_endpoint"></a> [logdna\_endpoint](#input\_logdna\_endpoint) | (Optional, List) Property values for a LogDNA Endpoint. | <pre>list(object({<br>    target_crn    = string<br>    ingestion_key = string<br>  }))</pre> | `[]` | no |
| <a name="input_logdna_instance_name"></a> [logdna\_instance\_name](#input\_logdna\_instance\_name) | The name of the IBM Cloud Logging instance to create. Defaults to 'logdna-<region>' | `string` | `null` | no |
| <a name="input_logdna_manager_key_name"></a> [logdna\_manager\_key\_name](#input\_logdna\_manager\_key\_name) | The name to give the IBM Cloud Logging manager key. | `string` | `"LogDnaManagerKey"` | no |
| <a name="input_logdna_plan"></a> [logdna\_plan](#input\_logdna\_plan) | The IBM Cloud Logging plan to provision. Available: lite, 7-day, 14-day, 30-day, hipaa-30-day | `string` | `"lite"` | no |
| <a name="input_logdna_provision"></a> [logdna\_provision](#input\_logdna\_provision) | Provision an IBM Cloud Logging instance? | `bool` | `true` | no |
| <a name="input_logdna_route_name"></a> [logdna\_route\_name](#input\_logdna\_route\_name) | (Required, String) The name of the LogDNA route. | `string` | `null` | no |
| <a name="input_logdna_tags"></a> [logdna\_tags](#input\_logdna\_tags) | Tags associated with the IBM Cloud Logging instance (Optional, array of strings). | `list(string)` | `[]` | no |
| <a name="input_logdna_target_name"></a> [logdna\_target\_name](#input\_logdna\_target\_name) | (Optional, String) The name of the logDNA target. | `string` | `null` | no |
| <a name="input_logdna_target_region"></a> [logdna\_target\_region](#input\_logdna\_target\_region) | (Optional, List) Region where is LogDNA target is created | `string` | `null` | no |
| <a name="input_metadata_region_backup"></a> [metadata\_region\_backup](#input\_metadata\_region\_backup) | (Optional, String) To store all your meta data in a backup region. | `string` | `"us-east"` | no |
| <a name="input_metadata_region_primary"></a> [metadata\_region\_primary](#input\_metadata\_region\_primary) | (Required, String) To store all your meta data in a single region. | `string` | `"us-south"` | no |
| <a name="input_permitted_target_regions"></a> [permitted\_target\_regions](#input\_permitted\_target\_regions) | (Optional, List) If present then only these regions may be used to define a target. | `list(string)` | <pre>[<br>  "us-south",<br>  "eu-de",<br>  "us-east",<br>  "eu-gb",<br>  "jp-tok",<br>  "au-syd"<br>]</pre> | no |
| <a name="input_private_api_endpoint_only"></a> [private\_api\_endpoint\_only](#input\_private\_api\_endpoint\_only) | (Required, Boolean) If you set this true then you cannot access api through public network. | `bool` | `false` | no |
| <a name="input_region"></a> [region](#input\_region) | The IBM Cloud region where instances will be created. | `string` | `"us-south"` | no |
| <a name="input_regions_targeting_cos"></a> [regions\_targeting\_cos](#input\_regions\_targeting\_cos) | (Optional, List) Route the events generated in these regions to COS target | `list(string)` | <pre>[<br>  "*",<br>  "global"<br>]</pre> | no |
| <a name="input_regions_targeting_eventstreams"></a> [regions\_targeting\_eventstreams](#input\_regions\_targeting\_eventstreams) | (Optional, String) Route the events generated in these regions to Event Streams target | `list(string)` | <pre>[<br>  "*",<br>  "global"<br>]</pre> | no |
| <a name="input_regions_targeting_logdna"></a> [regions\_targeting\_logdna](#input\_regions\_targeting\_logdna) | (Optional, List) Route the events generated in these regions to LogDNA target | `list(string)` | <pre>[<br>  "*",<br>  "global"<br>]</pre> | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The id of the IBM Cloud resource group where the instance(s) will be created. | `string` | `null` | no |
| <a name="input_sysdig_instance_name"></a> [sysdig\_instance\_name](#input\_sysdig\_instance\_name) | The name of the IBM Cloud Monitoring instance to create. Defaults to 'sysdig-<region>' | `string` | `null` | no |
| <a name="input_sysdig_manager_key_name"></a> [sysdig\_manager\_key\_name](#input\_sysdig\_manager\_key\_name) | The name to give the IBM Cloud Monitoring manager key. | `string` | `"SysdigManagerKey"` | no |
| <a name="input_sysdig_plan"></a> [sysdig\_plan](#input\_sysdig\_plan) | The IBM Cloud Monitoring plan to provision. Available: lite, graduated-tier, graduated-tier-sysdig-secure-plus-monitor | `string` | `"lite"` | no |
| <a name="input_sysdig_provision"></a> [sysdig\_provision](#input\_sysdig\_provision) | Provision a Sysdig instance? | `bool` | `true` | no |
| <a name="input_sysdig_tags"></a> [sysdig\_tags](#input\_sysdig\_tags) | Tags associated with the IBM Cloud Monitoring instance (Optional, array of strings). | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_activity_tracker_crn"></a> [activity\_tracker\_crn](#output\_activity\_tracker\_crn) | The id of the provisioned Activity Tracker instance. |
| <a name="output_activity_tracker_guid"></a> [activity\_tracker\_guid](#output\_activity\_tracker\_guid) | The guid of the provisioned Activity Tracker instance. |
| <a name="output_activity_tracker_manager_key_name"></a> [activity\_tracker\_manager\_key\_name](#output\_activity\_tracker\_manager\_key\_name) | The Activity Tracker manager key name |
| <a name="output_activity_tracker_name"></a> [activity\_tracker\_name](#output\_activity\_tracker\_name) | The name of the provisioned Activity Tracker instance. |
| <a name="output_activity_tracker_resource_group_id"></a> [activity\_tracker\_resource\_group\_id](#output\_activity\_tracker\_resource\_group\_id) | The resource group where Activity Tracker instance resides |
| <a name="output_activity_tracker_resource_key"></a> [activity\_tracker\_resource\_key](#output\_activity\_tracker\_resource\_key) | The resource/service key for agents to use |
| <a name="output_logdna_crn"></a> [logdna\_crn](#output\_logdna\_crn) | The id of the provisioned LogDNA instance. |
| <a name="output_logdna_guid"></a> [logdna\_guid](#output\_logdna\_guid) | The guid of the provisioned LogDNA instance. |
| <a name="output_logdna_ingestion_key"></a> [logdna\_ingestion\_key](#output\_logdna\_ingestion\_key) | LogDNA ingest key for agents to use |
| <a name="output_logdna_manager_key_name"></a> [logdna\_manager\_key\_name](#output\_logdna\_manager\_key\_name) | The LogDNA manager key name |
| <a name="output_logdna_name"></a> [logdna\_name](#output\_logdna\_name) | The name of the provisioned LogDNA instance. |
| <a name="output_logdna_resource_group_id"></a> [logdna\_resource\_group\_id](#output\_logdna\_resource\_group\_id) | The resource group where LogDNA instance resides |
| <a name="output_logdna_resource_key"></a> [logdna\_resource\_key](#output\_logdna\_resource\_key) | LogDNA service key for agents to use |
| <a name="output_region"></a> [region](#output\_region) | Region that instance(s) are provisioned to. |
| <a name="output_sysdig_access_key"></a> [sysdig\_access\_key](#output\_sysdig\_access\_key) | Sysdig access key for agents to use |
| <a name="output_sysdig_crn"></a> [sysdig\_crn](#output\_sysdig\_crn) | The id of the provisioned Sysdig instance. |
| <a name="output_sysdig_guid"></a> [sysdig\_guid](#output\_sysdig\_guid) | The guid of the provisioned Sisdig instance. |
| <a name="output_sysdig_manager_key_name"></a> [sysdig\_manager\_key\_name](#output\_sysdig\_manager\_key\_name) | The Sysdig manager key name |
| <a name="output_sysdig_name"></a> [sysdig\_name](#output\_sysdig\_name) | The name of the provisioned Sysdig instance. |
| <a name="output_sysdig_resource_group_id"></a> [sysdig\_resource\_group\_id](#output\_sysdig\_resource\_group\_id) | The resource group where Sysdig monitor instance resides |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- BEGIN CONTRIBUTING HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->

## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.

<!-- Source for this readme file: https://github.com/terraform-ibm-modules/common-dev-assets/tree/main/module-assets/ci/module-template-automation -->
<!-- END CONTRIBUTING HOOK -->
