# Terraform IBM Observability instances module

[![Stable (With quality checks)](https://img.shields.io/badge/Status-Stable%20(With%20quality%20checks)-green?style=plastic)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![Build status](https://github.com/terraform-ibm-modules/terraform-ibm-observability-instances/actions/workflows/ci.yml/badge.svg)](https://github.com/terraform-ibm-modules/terraform-ibm-observability-instances/actions/workflows/ci.yml)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-observability-instances?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-observability-instances/releases/latest)

This module supports provisioning the following observability instances:

* **IBM Cloud Activity Tracker**
  * Records events, compliant with CADF standard, triggered by user-initiated activities that change the state of a service in the cloud.
* **IBM Cloud Logging with LogDNA**
  * Manage operating system logs, application logs, and platform logs in IBM Cloud.
* **IBM Cloud Monitoring with SysDig**
  * Monitor the health of services and applications in IBM Cloud.

:information_source: The module also creates a manager key for each instance, and supports passing COS bucket details to enable archiving for LogDNA and Activity Tracker.

## Usage

Provisioning Activity Tracker, LogDNA and Sysdig
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
  servicekey = module.observability_instances.activity_tracker_resource_key != null ? module.observability_instances.activity_tracker_resource_key : ""
  url        = local.at_endpoint
}

provider "logdna" {
  alias      = "ld"
  servicekey = module.observability_instances.logdna_resource_key != null ? module.observability_instances.logdna_resource_key : ""
  url        = local.at_endpoint
}

module "observability_instances" {
  # Replace "main" with a GIT release version to lock into a specific release
  source                             = "git::https://github.com/terraform-ibm-modules/terraform-ibm-observability-instances?ref=main"
  providers = {
    logdna.at  = logdna.at
    logdna.ld  = logdna.ld
  }
  resource_group_id  = var.resource_group.id
  region             = var.ibm_region
}
```

Provisioning LogDNA only
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
  servicekey = module.logdna.logdna_resource_key
  url        = local.at_endpoint
}

module "logdna" {
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-observability-instances//modules/logdna?ref=main"
  providers = {
    logdna.ld = logdna.ld
  }
  resource_group_id = module.resource_group.resource_group_id
  region = var.region
}
```

Provisioning Activity Tracker only
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

Provisioning Sysdig only
```hcl
moRule "sysdig" {
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-observability-instances//modules/sysdig?ref=main"
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
    - **IBM Cloud Monitoring** service
        - `Editor` platform access
        - `Manager` service access
    - **IBM Log Analysis** service
        - `Editor` platform access
        - `Manager` service access

<!-- BEGIN EXAMPLES HOOK -->
## Examples

- [ Provision Sysdig and LogDNA + Activity Tracker with archiving enabled using encrypted COS bucket](examples/observability_archive)
- [ Provision basic observability instances (LogDNA, Sysdig, Activity Tracker)](examples/observability_basic)
<!-- END EXAMPLES HOOK -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_logdna"></a> [logdna](#requirement\_logdna) | >= 1.14.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_activity_tracker"></a> [activity\_tracker](#module\_activity\_tracker) | ./modules/activity_tracker | n/a |
| <a name="module_logdna"></a> [logdna](#module\_logdna) | ./modules/logdna | n/a |
| <a name="module_sysdig"></a> [sysdig](#module\_sysdig) | ./modules/sysdig | n/a |

## Resources

No resources.

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
| <a name="input_enable_platform_logs"></a> [enable\_platform\_logs](#input\_enable\_platform\_logs) | Receive platform logs in the provisioned IBM Cloud Logging instance. | `bool` | `true` | no |
| <a name="input_enable_platform_metrics"></a> [enable\_platform\_metrics](#input\_enable\_platform\_metrics) | Receive platform metrics in the provisioned IBM Cloud Monitoring instance. | `bool` | `true` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | Only required to archive. The IBM Cloud API Key. | `string` | `null` | no |
| <a name="input_logdna_cos_bucket_endpoint"></a> [logdna\_cos\_bucket\_endpoint](#input\_logdna\_cos\_bucket\_endpoint) | An endpoint for the COS bucket for the LogDNA archive. Pass either the public or private endpoint. (Only required when var.enable\_archive and var.logdna\_provision are true). | `string` | `null` | no |
| <a name="input_logdna_cos_bucket_name"></a> [logdna\_cos\_bucket\_name](#input\_logdna\_cos\_bucket\_name) | The name of an existing COS bucket to be used for the LogDNA archive. (Only required when var.enable\_archive and var.logdna\_provision are true). | `string` | `null` | no |
| <a name="input_logdna_cos_instance_id"></a> [logdna\_cos\_instance\_id](#input\_logdna\_cos\_instance\_id) | The ID of the cloud object storage instance containing the LogDNA archive bucket. (Only required when var.enable\_archive and var.logdna\_provision are true). | `string` | `null` | no |
| <a name="input_logdna_instance_name"></a> [logdna\_instance\_name](#input\_logdna\_instance\_name) | The name of the IBM Cloud Logging instance to create. Defaults to 'logdna-<region>' | `string` | `null` | no |
| <a name="input_logdna_manager_key_name"></a> [logdna\_manager\_key\_name](#input\_logdna\_manager\_key\_name) | The name to give the IBM Cloud Logging manager key. | `string` | `"LogDnaManagerKey"` | no |
| <a name="input_logdna_manager_key_tags"></a> [logdna\_manager\_key\_tags](#input\_logdna\_manager\_key\_tags) | Tags associated with the IBM Cloud Logging manager key. | `list(string)` | `[]` | no |
| <a name="input_logdna_plan"></a> [logdna\_plan](#input\_logdna\_plan) | The IBM Cloud Logging plan to provision. Available: lite, 7-day, 14-day, 30-day, hipaa-30-day | `string` | `"lite"` | no |
| <a name="input_logdna_provision"></a> [logdna\_provision](#input\_logdna\_provision) | Provision an IBM Cloud Logging instance? | `bool` | `true` | no |
| <a name="input_logdna_service_endpoints"></a> [logdna\_service\_endpoints](#input\_logdna\_service\_endpoints) | The type of the service endpoint that will be set for the LogDNA instance. | `string` | `"public-and-private"` | no |
| <a name="input_logdna_tags"></a> [logdna\_tags](#input\_logdna\_tags) | Tags associated with the IBM Cloud Logging instance (Optional, array of strings). | `list(string)` | `[]` | no |
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
