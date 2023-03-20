# LogDNA instance sub-module

This sub-module supports provisioning the following observability instances:

- **IBM Cloud Logging with LogDNA**
  - Manage operating system logs, application logs, and platform logs in IBM Cloud.

:information_source: This sub-module also creates a manager key, and supports passing COS bucket details to enable archiving for LogDNA.

## Usage

To provision LogDNA instance

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
  alias      = "ld"
  servicekey = module.logdna.resource_key
  url        = local.at_endpoint
}

module "logdna" {
  # Replace "main" with a GIT release version to lock into a specific release
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-observability-instances//submodules/logdna?ref=main"
  providers = {
    logdna.ld = logdna.ld
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
  - **IBM Log Analysis** service
    - `Editor` platform access
    - `Manager` service access

<!-- BEGIN EXAMPLES HOOK -->

## Examples

<!-- END EXAMPLES HOOK -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

| Name                                                                     | Version   |
| ------------------------------------------------------------------------ | --------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.0.0  |
| <a name="requirement_ibm"></a> [ibm](#requirement_ibm)                   | >= 1.49.0 |
| <a name="requirement_logdna"></a> [logdna](#requirement_logdna)          | >= 1.14.2 |

## Modules

No modules.

## Resources

| Name                                                                                                                          | Type     |
| ----------------------------------------------------------------------------------------------------------------------------- | -------- |
| [ibm_resource_instance.logdna](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [ibm_resource_key.resource_key](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_key)     | resource |
| [logdna_archive.config](https://registry.terraform.io/providers/logdna/logdna/latest/docs/resources/archive)                  | resource |

## Inputs

| Name                                                                                          | Description                                                                                                                                                                   | Type           | Default                | Required |
| --------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ---------------------- | :------: |
| <a name="input_cos_bucket_endpoint"></a> [cos_bucket_endpoint](#input_cos_bucket_endpoint)    | An endpoint for the COS bucket for the LogDNA archive. Pass either the public or private endpoint. (Only required when var.enable_archive and var.logdna_provision are true). | `string`       | `null`                 |    no    |
| <a name="input_cos_bucket_name"></a> [cos_bucket_name](#input_cos_bucket_name)                | The name of an existing COS bucket to be used for the LogDNA archive. (Only required when var.enable_archive and var.logdna_provision are true).                              | `string`       | `null`                 |    no    |
| <a name="input_cos_instance_id"></a> [cos_instance_id](#input_cos_instance_id)                | The ID of the cloud object storage instance containing the LogDNA archive bucket. (Only required when var.enable_archive and var.logdna_provision are true).                  | `string`       | `null`                 |    no    |
| <a name="input_enable_archive"></a> [enable_archive](#input_enable_archive)                   | Enable archive on logDNA and Activity Tracker instances                                                                                                                       | `bool`         | `false`                |    no    |
| <a name="input_enable_platform_logs"></a> [enable_platform_logs](#input_enable_platform_logs) | Receive platform logs in the provisioned IBM Cloud Logging instance.                                                                                                          | `bool`         | `true`                 |    no    |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud_api_key](#input_ibmcloud_api_key)             | Only required to archive. The IBM Cloud API Key.                                                                                                                              | `string`       | `null`                 |    no    |
| <a name="input_instance_name"></a> [instance_name](#input_instance_name)                      | The name of the IBM Cloud Logging instance to create. Defaults to 'logdna-<region>'                                                                                           | `string`       | `null`                 |    no    |
| <a name="input_logdna_provision"></a> [logdna_provision](#input_logdna_provision)             | Provision an IBM Cloud Logging instance?                                                                                                                                      | `bool`         | `true`                 |    no    |
| <a name="input_manager_key_name"></a> [manager_key_name](#input_manager_key_name)             | The name to give the IBM Cloud Logging manager key.                                                                                                                           | `string`       | `"LogDnaManagerKey"`   |    no    |
| <a name="input_manager_key_tags"></a> [manager_key_tags](#input_manager_key_tags)             | Tags associated with the IBM Cloud Logging manager key.                                                                                                                       | `list(string)` | `[]`                   |    no    |
| <a name="input_plan"></a> [plan](#input_plan)                                                 | The IBM Cloud Logging plan to provision. Available: lite, 7-day, 14-day, 30-day, hipaa-30-day                                                                                 | `string`       | `"lite"`               |    no    |
| <a name="input_region"></a> [region](#input_region)                                           | The IBM Cloud region where instances will be created.                                                                                                                         | `string`       | `"us-south"`           |    no    |
| <a name="input_resource_group_id"></a> [resource_group_id](#input_resource_group_id)          | The id of the IBM Cloud resource group where the instance(s) will be created.                                                                                                 | `string`       | `null`                 |    no    |
| <a name="input_resource_key_role"></a> [resource_key_role](#input_resource_key_role)          | Role assigned to provide the IBM Cloud Logging key.                                                                                                                           | `string`       | `"Manager"`            |    no    |
| <a name="input_service_endpoints"></a> [service_endpoints](#input_service_endpoints)          | The type of the service endpoint that will be set for the LogDNA instance.                                                                                                    | `string`       | `"public-and-private"` |    no    |
| <a name="input_tags"></a> [tags](#input_tags)                                                 | Tags associated with the IBM Cloud Logging instance (Optional, array of strings).                                                                                             | `list(string)` | `[]`                   |    no    |

## Outputs

| Name                                                                                   | Description                                      |
| -------------------------------------------------------------------------------------- | ------------------------------------------------ |
| <a name="output_crn"></a> [crn](#output_crn)                                           | The id of the provisioned LogDNA instance.       |
| <a name="output_guid"></a> [guid](#output_guid)                                        | The guid of the provisioned LogDNA instance.     |
| <a name="output_ingestion_key"></a> [ingestion_key](#output_ingestion_key)             | LogDNA ingest key for agents to use              |
| <a name="output_manager_key_name"></a> [manager_key_name](#output_manager_key_name)    | The LogDNA manager key name                      |
| <a name="output_name"></a> [name](#output_name)                                        | The name of the provisioned LogDNA instance.     |
| <a name="output_resource_group_id"></a> [resource_group_id](#output_resource_group_id) | The resource group where LogDNA instance resides |
| <a name="output_resource_key"></a> [resource_key](#output_resource_key)                | LogDNA service key for agents to use             |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- BEGIN CONTRIBUTING HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->

## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.

<!-- Source for this readme file: https://github.com/terraform-ibm-modules/common-dev-assets/tree/main/module-assets/ci/module-template-automation -->
<!-- END CONTRIBUTING HOOK -->
