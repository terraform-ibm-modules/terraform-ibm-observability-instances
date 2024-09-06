# Cloud Logs instance sub-module

This sub-module supports provisioning the following observability instances:

- **IBM Cloud Logging with Cloud Logs**
  - View, analyze, and alert on activity tracking events and logging activity.

:information_source: This sub-module also supports passing COS bucket details to store your IBM Cloud Logs data for long term storage, search, analysis and alerting.

## Usage

To provision Cloud Logs instance

```hcl
# required ibm provider config
provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key #pragma: allowlist secret
}

# IBM cloud logs
module "cloud_logs" {
  source  = "terraform-ibm-modules/observability-instances/ibm//modules/cloud_logs"
  version = "X.X.X" # Replace "X.X.X" with a release version to lock into a specific release
  resource_group_id = module.resource_group.resource_group_id
  region = var.region
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.67.1, < 2.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.1, < 1.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_iam_authorization_policy.cos_policy](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_iam_authorization_policy.en_policy](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_logs_outgoing_webhook.en_integration](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/logs_outgoing_webhook) | resource |
| [ibm_resource_instance.cloud_logs](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [ibm_resource_tag.cloud_logs_tag](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_tag) | resource |
| [time_sleep.wait_for_en_authorization_policy](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [ibm_iam_account_settings.iam_account_settings](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/data-sources/iam_account_settings) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tags"></a> [access\_tags](#input\_access\_tags) | A list of access tags to apply to the IBM Cloud Logs instance created by the module. For more information, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial. | `list(string)` | `[]` | no |
| <a name="input_data_storage"></a> [data\_storage](#input\_data\_storage) | A logs data bucket and a metrics bucket in IBM Cloud Object Storage to store your IBM Cloud Logs data for long term storage, search, analysis and alerting. | <pre>object({<br>    logs_data = optional(object({<br>      enabled              = optional(bool, false)<br>      bucket_crn           = optional(string)<br>      bucket_endpoint      = optional(string)<br>      skip_cos_auth_policy = optional(bool, false)<br>    }), {})<br>    metrics_data = optional(object({<br>      enabled              = optional(bool, false)<br>      bucket_crn           = optional(string)<br>      bucket_endpoint      = optional(string)<br>      skip_cos_auth_policy = optional(bool, false)<br>    }), {})<br>    }<br>  )</pre> | <pre>{<br>  "logs_data": null,<br>  "metrics_data": null<br>}</pre> | no |
| <a name="input_existing_en_instances"></a> [existing\_en\_instances](#input\_existing\_en\_instances) | List of Event Notifications instance details for routing critical events that occur in your IBM Cloud Logs | <pre>list(object({<br>    en_instance_id      = string<br>    en_region           = string<br>    en_instance_name    = optional(string)<br>    skip_en_auth_policy = optional(bool, false)<br>  }))</pre> | `[]` | no |
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | The name of the IBM Cloud Logs instance to create. Defaults to 'cloud-logs-<region>' | `string` | `null` | no |
| <a name="input_plan"></a> [plan](#input\_plan) | The IBM Cloud Logs plan to provision. Available: standard | `string` | `"standard"` | no |
| <a name="input_region"></a> [region](#input\_region) | The region where observability resources are created. | `string` | `"eu-es"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The id of the IBM Cloud resource group where the instance(s) will be created. | `string` | `null` | no |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | Tags associated with the IBM Cloud Logs instance (Optional, array of strings). | `list(string)` | `[]` | no |
| <a name="input_retention_period"></a> [retention\_period](#input\_retention\_period) | The number of days IBM Cloud Logs will retain the logs data in Priority insights. | `number` | `7` | no |
| <a name="input_service_endpoints"></a> [service\_endpoints](#input\_service\_endpoints) | The type of the service endpoint that will be set for the IBM Cloud Logs instance. | `string` | `"public-and-private"` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_crn"></a> [crn](#output\_crn) | The id of the provisioned Cloud Logs instance. |
| <a name="output_guid"></a> [guid](#output\_guid) | The guid of the provisioned Cloud Logs instance. |
| <a name="output_name"></a> [name](#output\_name) | The name of the provisioned Cloud Logs instance. |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | The resource group where Cloud Logs instance resides |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
