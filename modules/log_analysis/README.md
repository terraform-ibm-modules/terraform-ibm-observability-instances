# Log Analysis instance sub-module

This sub-module supports provisioning the following observability instances:

- **IBM Cloud Logging with Log Analysis**
  - Manage operating system logs, application logs, and platform logs in IBM Cloud.

:information_source: This sub-module also creates a manager key, and supports passing COS bucket details to enable archiving for Log Analysis.

## Usage

To provision Log Analysis instance

```hcl
# required ibm provider config
provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key #pragma: allowlist secret
}

# required log analysis provider config
locals {
  at_endpoint = "https://api.${var.region}.logging.cloud.ibm.com"
}

provider "logdna" {
  alias      = "ld"
  servicekey = module.log_analysis.resource_key
  url        = local.at_endpoint
}

module "log_analysis" {
  source  = "terraform-ibm-modules/observability-instances/ibm//modules/log_analysis"
  version = "latest" # Replace "latest" with a release version to lock into a specific release
  providers = {
    logdna.ld = logdna.ld
  }
  resource_group_id = module.resource_group.resource_group_id
  region = var.region
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0, < 1.7.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.56.1, < 2.0.0 |
| <a name="requirement_logdna"></a> [logdna](#requirement\_logdna) | >= 1.14.2, < 2.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_resource_instance.log_analysis](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [ibm_resource_key.resource_key](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_key) | resource |
| [ibm_resource_tag.log_analysis_tag](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_tag) | resource |
| [logdna_archive.archive_config](https://registry.terraform.io/providers/logdna/logdna/latest/docs/resources/archive) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tags"></a> [access\_tags](#input\_access\_tags) | Access Management Tags associated with the IBM Cloud Logging instance (Optional, array of strings). | `list(string)` | `[]` | no |
| <a name="input_cos_bucket_endpoint"></a> [cos\_bucket\_endpoint](#input\_cos\_bucket\_endpoint) | An endpoint for the COS bucket for the Log Analysis archive. Pass either the public or private endpoint. (Only required when var.log\_analysis\_enable\_archive and var.log\_analysis\_provision are true). | `string` | `null` | no |
| <a name="input_cos_bucket_name"></a> [cos\_bucket\_name](#input\_cos\_bucket\_name) | The name of an existing COS bucket to be used for the Log Analysis archive. (Only required when var.log\_analysis\_enable\_archive and var.log\_analysis\_provision are true). | `string` | `null` | no |
| <a name="input_cos_instance_id"></a> [cos\_instance\_id](#input\_cos\_instance\_id) | The ID of the cloud object storage instance containing the Log Analysis archive bucket. (Only required when var.log\_analysis\_enable\_archive and var.log\_analysis\_provision are true). | `string` | `null` | no |
| <a name="input_enable_platform_logs"></a> [enable\_platform\_logs](#input\_enable\_platform\_logs) | Receive platform logs in the provisioned IBM Cloud Logging instance. | `bool` | `true` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | Only required to archive. The IBM Cloud API Key. | `string` | `null` | no |
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | The name of the IBM Cloud Logging instance to create. Defaults to 'log-analysis-<region>' | `string` | `null` | no |
| <a name="input_log_analysis_enable_archive"></a> [log\_analysis\_enable\_archive](#input\_log\_analysis\_enable\_archive) | Enable archive on Log Analysis instances | `bool` | `false` | no |
| <a name="input_log_analysis_provision"></a> [log\_analysis\_provision](#input\_log\_analysis\_provision) | Provision an IBM Cloud Logging instance? | `bool` | `true` | no |
| <a name="input_manager_key_name"></a> [manager\_key\_name](#input\_manager\_key\_name) | The name to give the IBM Cloud Logging manager key. | `string` | `"LogDnaManagerKey"` | no |
| <a name="input_manager_key_tags"></a> [manager\_key\_tags](#input\_manager\_key\_tags) | Tags associated with the IBM Cloud Logging manager key. | `list(string)` | `[]` | no |
| <a name="input_plan"></a> [plan](#input\_plan) | The IBM Cloud Logging plan to provision. Available: lite, 7-day, 14-day, 30-day, hipaa-30-day | `string` | `"lite"` | no |
| <a name="input_region"></a> [region](#input\_region) | The IBM Cloud region where instances will be created. | `string` | `"us-south"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The id of the IBM Cloud resource group where the instance(s) will be created. | `string` | `null` | no |
| <a name="input_resource_key_role"></a> [resource\_key\_role](#input\_resource\_key\_role) | Role assigned to provide the IBM Cloud Logging key. | `string` | `"Manager"` | no |
| <a name="input_service_endpoints"></a> [service\_endpoints](#input\_service\_endpoints) | The type of the service endpoint that will be set for the Log Analysis instance. | `string` | `"public-and-private"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags associated with the IBM Cloud Logging instance (Optional, array of strings). | `list(string)` | `[]` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_crn"></a> [crn](#output\_crn) | The id of the provisioned Log Analysis instance. |
| <a name="output_guid"></a> [guid](#output\_guid) | The guid of the provisioned Log Analysis instance. |
| <a name="output_ingestion_key"></a> [ingestion\_key](#output\_ingestion\_key) | Log Analysis ingest key for agents to use |
| <a name="output_manager_key_name"></a> [manager\_key\_name](#output\_manager\_key\_name) | The Log Analysis manager key name |
| <a name="output_name"></a> [name](#output\_name) | The name of the provisioned Log Analysis instance. |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | The resource group where Log Analysis instance resides |
| <a name="output_resource_key"></a> [resource\_key](#output\_resource\_key) | Log Analysis service key for agents to use |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
