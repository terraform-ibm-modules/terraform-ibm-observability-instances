# IBM Observability Activity Tracker instance sub-module

This sub-module supports provisioning the following observability instance:

* **IBM Cloud Activity Tracker**
  * Records events, compliant with CADF standard, triggered by user-initiated activities that change the state of a service in the cloud.

:information_source: This sub-module also creates a manager key, and supports passing COS bucket details to enable archiving for Activity Tracker.

## Usage

Provisioning Activity Tracker instance
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
  servicekey = module.activity_tracker.at_resource_key
  url        = local.at_endpoint
}

module "activity_tracker" {
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-observability-instances//modules/activity_tracker?ref=main"
  providers = {
    logdna.at = logdna.at
  }
  resource_group_id = module.resource_group.resource_group_id
  region = var.region
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

<!-- BEGIN EXAMPLES HOOK -->
## Examples
<!-- END EXAMPLES HOOK -->
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
| [ibm_resource_instance.activity_tracker](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [ibm_resource_key.at_resource_key](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_key) | resource |
| [logdna_archive.activity_tracker_config](https://registry.terraform.io/providers/logdna/logdna/latest/docs/resources/archive) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_activity_tracker_instance_name"></a> [activity\_tracker\_instance\_name](#input\_activity\_tracker\_instance\_name) | The name of the Activity Tracker instance to create. Defaults to 'activity-tracker-<region>' | `string` | `null` | no |
| <a name="input_activity_tracker_manager_key_name"></a> [activity\_tracker\_manager\_key\_name](#input\_activity\_tracker\_manager\_key\_name) | The name to give the Activity Tracker manager key. | `string` | `"AtManagerKey"` | no |
| <a name="input_activity_tracker_manager_key_tags"></a> [activity\_tracker\_manager\_key\_tags](#input\_activity\_tracker\_manager\_key\_tags) | Tags associated with the Activity Tracker manager key. | `list(string)` | `[]` | no |
| <a name="input_activity_tracker_plan"></a> [activity\_tracker\_plan](#input\_activity\_tracker\_plan) | The Activity Tracker plan to provision. Available: lite, 7-day, 14-day, 30-day, hipaa-30-day | `string` | `"lite"` | no |
| <a name="input_activity_tracker_provision"></a> [activity\_tracker\_provision](#input\_activity\_tracker\_provision) | Provision an Activity Tracker instance? | `bool` | `true` | no |
| <a name="input_activity_tracker_service_endpoints"></a> [activity\_tracker\_service\_endpoints](#input\_activity\_tracker\_service\_endpoints) | The type of the service endpoint that will be set for the activity tracker instance. | `string` | `"public-and-private"` | no |
| <a name="input_activity_tracker_tags"></a> [activity\_tracker\_tags](#input\_activity\_tracker\_tags) | Tags associated with the Activity Tracker instance (Optional, array of strings). | `list(string)` | `[]` | no |
| <a name="input_at_cos_bucket_endpoint"></a> [at\_cos\_bucket\_endpoint](#input\_at\_cos\_bucket\_endpoint) | An endpoint for the COS bucket for the Activity Tracker archive. Pass either the public or private endpoint (Only required when var.enable\_archive and var.activity\_tracker\_provision are true) | `string` | `null` | no |
| <a name="input_at_cos_bucket_name"></a> [at\_cos\_bucket\_name](#input\_at\_cos\_bucket\_name) | The name of an existing COS bucket to be used for the Activity Tracker archive (Only required when var.enable\_archive and var.activity\_tracker\_provision are true). | `string` | `null` | no |
| <a name="input_at_cos_instance_id"></a> [at\_cos\_instance\_id](#input\_at\_cos\_instance\_id) | The ID of the cloud object storage instance containing the Activity Tracker archive bucket (Only required when var.enable\_archive and var.activity\_tracker\_provision are true). | `string` | `null` | no |
| <a name="input_enable_archive"></a> [enable\_archive](#input\_enable\_archive) | Enable archive on logDNA and Activity Tracker instances | `bool` | `false` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | Only required to archive. The IBM Cloud API Key. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | The IBM Cloud region where instances will be created. | `string` | `"us-south"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The id of the IBM Cloud resource group where the instance(s) will be created. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_activity_tracker_crn"></a> [activity\_tracker\_crn](#output\_activity\_tracker\_crn) | The id of the provisioned Activity Tracker instance. |
| <a name="output_activity_tracker_guid"></a> [activity\_tracker\_guid](#output\_activity\_tracker\_guid) | The guid of the provisioned Activity Tracker instance. |
| <a name="output_activity_tracker_manager_key_name"></a> [activity\_tracker\_manager\_key\_name](#output\_activity\_tracker\_manager\_key\_name) | The Activity Tracker manager key name |
| <a name="output_activity_tracker_name"></a> [activity\_tracker\_name](#output\_activity\_tracker\_name) | The name of the provisioned Activity Tracker instance. |
| <a name="output_activity_tracker_resource_group_id"></a> [activity\_tracker\_resource\_group\_id](#output\_activity\_tracker\_resource\_group\_id) | The resource group where Activity Tracker instance resides |
| <a name="output_activity_tracker_resource_key"></a> [activity\_tracker\_resource\_key](#output\_activity\_tracker\_resource\_key) | The resource/service key for agents to use |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- BEGIN CONTRIBUTING HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
<!-- Source for this readme file: https://github.com/terraform-ibm-modules/common-dev-assets/tree/main/module-assets/ci/module-template-automation -->
<!-- END CONTRIBUTING HOOK -->
