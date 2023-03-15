# Sysdig instance sub-module

This sub-module supports provisioning the following observability instances:

* **IBM Cloud Monitoring with SysDig**
  * Monitor the health of services and applications in IBM Cloud.

:information_source: This sub-module also creates a manager key.

## Usage

To provision Sysdig instance
```hcl
module "sysdig" {
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-observability-instances//submodules/sysdig?ref=main"
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
    - **IBM Cloud Monitoring** service
        - `Editor` platform access
        - `Manager` service access

<!-- BEGIN EXAMPLES HOOK -->
## Examples

- [ Provision Sysdig and LogDNA + AT with archiving enabled using encrypted COS bucket](examples/observability_archive)
- [ Provision basic observability instances (LogDNA, Sysdig, AT)](examples/observability_basic)
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
| [ibm_resource_instance.sysdig](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [ibm_resource_key.sysdig_resource_key](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_platform_metrics"></a> [enable\_platform\_metrics](#input\_enable\_platform\_metrics) | Receive platform metrics in the provisioned IBM Cloud Monitoring instance. | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | The IBM Cloud region where instances will be created. | `string` | `"us-south"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The id of the IBM Cloud resource group where the instance(s) will be created. | `string` | `null` | no |
| <a name="input_sysdig_instance_name"></a> [sysdig\_instance\_name](#input\_sysdig\_instance\_name) | The name of the IBM Cloud Monitoring instance to create. Defaults to 'sysdig-<region>' | `string` | `null` | no |
| <a name="input_sysdig_manager_key_name"></a> [sysdig\_manager\_key\_name](#input\_sysdig\_manager\_key\_name) | The name to give the IBM Cloud Monitoring manager key. | `string` | `"SysdigManagerKey"` | no |
| <a name="input_sysdig_manager_key_tags"></a> [sysdig\_manager\_key\_tags](#input\_sysdig\_manager\_key\_tags) | Tags associated with the IBM Cloud Monitoring manager key. | `list(string)` | `[]` | no |
| <a name="input_sysdig_plan"></a> [sysdig\_plan](#input\_sysdig\_plan) | The IBM Cloud Monitoring plan to provision. Available: lite, graduated-tier, graduated-tier-sysdig-secure-plus-monitor | `string` | `"lite"` | no |
| <a name="input_sysdig_provision"></a> [sysdig\_provision](#input\_sysdig\_provision) | Provision a Sysdig instance? | `bool` | `true` | no |
| <a name="input_sysdig_service_endpoints"></a> [sysdig\_service\_endpoints](#input\_sysdig\_service\_endpoints) | The type of the service endpoint that will be set for the Sisdig instance. | `string` | `"public-and-private"` | no |
| <a name="input_sysdig_tags"></a> [sysdig\_tags](#input\_sysdig\_tags) | Tags associated with the IBM Cloud Monitoring instance (Optional, array of strings). | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_sysdig_access_key"></a> [sysdig\_access\_key](#output\_sysdig\_access\_key) | Sysdig access key for agents to use |
| <a name="output_sysdig_crn"></a> [sysdig\_crn](#output\_sysdig\_crn) | The id of the provisioned Sysdig instance. |
| <a name="output_sysdig_guid"></a> [sysdig\_guid](#output\_sysdig\_guid) | The guid of the provisioned Sysdig instance. |
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
