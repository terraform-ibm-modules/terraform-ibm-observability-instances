# Terraform IBM Observability instances module

[![Graduated (Supported)](https://img.shields.io/badge/Status-Graduated%20(Supported)-brightgreen)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-observability-instances?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-observability-instances/releases/latest)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)

> [!IMPORTANT]
> The IBM Log Analysis and IBM Cloud Activity Tracker services are deprecated. IBM Cloud Logs is the replacement service. This module will be updated to provision the new services before the end of support in March 2025.

This module supports provisioning the following observability instances:

* **IBM Cloud Activity Tracker**
  * Records events, compliant with CADF standard, triggered by user-initiated activities that change the state of a service in the cloud.
* **IBM Cloud Logging with Log Analysis**
  * Manage operating system logs, application logs, and platform logs in IBM Cloud.
* **IBM Cloud Monitoring with Cloud Monitoring**
  * Monitor the health of services and applications in IBM Cloud.

:information_source: The module also creates a manager key for each instance, and supports passing COS bucket details to enable archiving for Log Analysis and Activity Tracker, it also supports activity tracker event routing to COS, Log Analysis and Event Streams.

<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-observability-instances](#terraform-ibm-observability-instances)
* [Submodules](./modules)
    * [activity_tracker](./modules/activity_tracker)
    * [cloud_logs](./modules/cloud_logs)
    * [cloud_monitoring](./modules/cloud_monitoring)
    * [log_analysis](./modules/log_analysis)
* [Examples](./examples)
    * [Provision IBM Cloud Monitoring, Log Analysis, Cloud Logs and Activity Tracker with archiving and event routing](./examples/advanced)
    * [Provision basic observability instances (Log Analysis, Cloud Monitoring, Activity Tracker, Cloud Logs)](./examples/basic)
* [Contributing](#contributing)
<!-- END OVERVIEW HOOK -->

## terraform-ibm-observability-instances

### Usage

To provision Activity Tracker, Log Analysis and IBM Cloud Monitoring

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
  servicekey = module.observability_instances.log_analysis_resource_key != null ? module.observability_instances.log_analysis_resource_key : ""
  url        = local.at_endpoint
}

module "observability_instances" {
  source  = "terraform-ibm-modules/observability-instances/ibm"
  version = "X.X.X" # Replace "X.X.X" with a release version to lock into a specific release
  providers = {
    logdna.at  = logdna.at
    logdna.ld  = logdna.ld
  }
  resource_group_id  = var.resource_group.id
  region             = var.ibm_region
}
```

To provision Log Analysis only

```hcl
# required ibm provider config
provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
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
  version = "X.X.X" # Replace "X.X.X" with a release version to lock into a specific release
  providers = {
    logdna.ld = logdna.ld
  }
  resource_group_id = module.resource_group.resource_group_id
  region = var.region
}
```

To provision Activity Tracker only

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
  source  = "terraform-ibm-modules/observability-instances/ibm//modules/activity_tracker"
  version = "X.X.X" # Replace "X.X.X" with a release version to lock into a specific release
  providers = {
    logdna.at = logdna.at
  }
  resource_group_id = module.resource_group.resource_group_id
  region = var.region
}
```

To provision IBM Cloud Monitoring only

```hcl
module "cloud_monitoring" {
  source  = "terraform-ibm-modules/observability-instances/ibm//modules/cloud_monitoring"
  version = "X.X.X" # Replace "X.X.X" with a release version to lock into a specific release
  resource_group_id = module.resource_group.resource_group_id
  region = var.region
}
```

To provision IBM Cloud Logs only

```hcl
module "cloud_logs" {
  source  = "terraform-ibm-modules/observability-instances/ibm//modules/cloud_logs"
  version = "X.X.X" # Replace "X.X.X" with a release version to lock into a specific release
  resource_group_id = module.resource_group.resource_group_id
  region = var.region
}
```

### Required IAM access policies

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
    - **IBM Cloud Logs** service
        - `Editor` platform access
        - `Manager` service access

To attach access management tags to resources in this module, you need the following permissions.

- IAM Services
    - **Tagging** service
        - `Administrator` platform access

<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.67.1, < 2.0.0 |
| <a name="requirement_logdna"></a> [logdna](#requirement\_logdna) | >= 1.14.2, < 2.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_activity_tracker"></a> [activity\_tracker](#module\_activity\_tracker) | ./modules/activity_tracker | n/a |
| <a name="module_cloud_logs"></a> [cloud\_logs](#module\_cloud\_logs) | ./modules/cloud_logs | n/a |
| <a name="module_cloud_monitoring"></a> [cloud\_monitoring](#module\_cloud\_monitoring) | ./modules/cloud_monitoring | n/a |
| <a name="module_log_analysis"></a> [log\_analysis](#module\_log\_analysis) | ./modules/log_analysis | n/a |

### Resources

No resources.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_activity_tracker_access_tags"></a> [activity\_tracker\_access\_tags](#input\_activity\_tracker\_access\_tags) | A list of access tags to apply to the Activity Tracker instance created by the module. For more information, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial. | `list(string)` | `[]` | no |
| <a name="input_activity_tracker_enable_archive"></a> [activity\_tracker\_enable\_archive](#input\_activity\_tracker\_enable\_archive) | Enable archive on activity tracker instances | `bool` | `false` | no |
| <a name="input_activity_tracker_instance_name"></a> [activity\_tracker\_instance\_name](#input\_activity\_tracker\_instance\_name) | The name of the Activity Tracker instance to create. Defaults to 'activity-tracker-<region>' | `string` | `null` | no |
| <a name="input_activity_tracker_manager_key_name"></a> [activity\_tracker\_manager\_key\_name](#input\_activity\_tracker\_manager\_key\_name) | The name to give the Activity Tracker manager key. | `string` | `"AtManagerKey"` | no |
| <a name="input_activity_tracker_manager_key_tags"></a> [activity\_tracker\_manager\_key\_tags](#input\_activity\_tracker\_manager\_key\_tags) | Tags associated with the Activity Tracker manager key. | `list(string)` | `[]` | no |
| <a name="input_activity_tracker_plan"></a> [activity\_tracker\_plan](#input\_activity\_tracker\_plan) | The Activity Tracker plan to provision. Available: lite, 7-day, 14-day, 30-day, hipaa-30-day | `string` | `"lite"` | no |
| <a name="input_activity_tracker_provision"></a> [activity\_tracker\_provision](#input\_activity\_tracker\_provision) | Provision an Activity Tracker instance? | `bool` | `true` | no |
| <a name="input_activity_tracker_routes"></a> [activity\_tracker\_routes](#input\_activity\_tracker\_routes) | List of routes to be created, maximum four routes are allowed | <pre>list(object({<br>    locations  = list(string)<br>    target_ids = list(string)<br>    route_name = string<br>  }))</pre> | `[]` | no |
| <a name="input_activity_tracker_service_endpoints"></a> [activity\_tracker\_service\_endpoints](#input\_activity\_tracker\_service\_endpoints) | The type of the service endpoint that will be set for the activity tracker instance. | `string` | `"public-and-private"` | no |
| <a name="input_activity_tracker_tags"></a> [activity\_tracker\_tags](#input\_activity\_tracker\_tags) | Tags associated with the Activity Tracker instance (Optional, array of strings). | `list(string)` | `[]` | no |
| <a name="input_at_cos_bucket_endpoint"></a> [at\_cos\_bucket\_endpoint](#input\_at\_cos\_bucket\_endpoint) | An endpoint for the COS bucket for the Activity Tracker archive. Pass either the public or private endpoint (Only required when var.activity\_tracker\_enable\_archive and var.activity\_tracker\_provision are true) | `string` | `null` | no |
| <a name="input_at_cos_bucket_name"></a> [at\_cos\_bucket\_name](#input\_at\_cos\_bucket\_name) | The name of an existing COS bucket to be used for the Activity Tracker archive (Only required when var.activity\_tracker\_enable\_archive and var.activity\_tracker\_provision are true). | `string` | `null` | no |
| <a name="input_at_cos_instance_id"></a> [at\_cos\_instance\_id](#input\_at\_cos\_instance\_id) | The ID of the cloud object storage instance containing the Activity Tracker archive bucket (Only required when var.activity\_tracker\_enable\_archive and var.activity\_tracker\_provision are true). | `string` | `null` | no |
| <a name="input_cloud_logs_access_tags"></a> [cloud\_logs\_access\_tags](#input\_cloud\_logs\_access\_tags) | A list of access tags to apply to the IBM Cloud Logs instance created by the module. For more information, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial. | `list(string)` | `[]` | no |
| <a name="input_cloud_logs_data_storage"></a> [cloud\_logs\_data\_storage](#input\_cloud\_logs\_data\_storage) | A logs data bucket and a metrics bucket in IBM Cloud Object Storage to store your IBM Cloud Logs data for long term storage, search, analysis and alerting. | <pre>object({<br>    logs_data = optional(object({<br>      enabled              = optional(bool, false)<br>      bucket_crn           = optional(string)<br>      bucket_endpoint      = optional(string)<br>      skip_cos_auth_policy = optional(bool, false)<br>    }), {})<br>    metrics_data = optional(object({<br>      enabled              = optional(bool, false)<br>      bucket_crn           = optional(string)<br>      bucket_endpoint      = optional(string)<br>      skip_cos_auth_policy = optional(bool, false)<br>    }), {})<br>    }<br>  )</pre> | <pre>{<br>  "logs_data": null,<br>  "metrics_data": null<br>}</pre> | no |
| <a name="input_cloud_logs_existing_en_instances"></a> [cloud\_logs\_existing\_en\_instances](#input\_cloud\_logs\_existing\_en\_instances) | List of Event Notifications instance details for routing critical events that occur in your IBM Cloud Logs. | <pre>list(object({<br>    en_instance_id      = string<br>    en_region           = string<br>    en_instance_name    = optional(string)<br>    source_id           = optional(string)<br>    source_name         = optional(string)<br>    skip_en_auth_policy = optional(bool, false)<br>  }))</pre> | `[]` | no |
| <a name="input_cloud_logs_instance_name"></a> [cloud\_logs\_instance\_name](#input\_cloud\_logs\_instance\_name) | The name of the IBM Cloud Logs instance to create. Defaults to 'cloud\_logs-<region>' | `string` | `null` | no |
| <a name="input_cloud_logs_plan"></a> [cloud\_logs\_plan](#input\_cloud\_logs\_plan) | The IBM Cloud Logs plan to provision. Available: standard | `string` | `"standard"` | no |
| <a name="input_cloud_logs_provision"></a> [cloud\_logs\_provision](#input\_cloud\_logs\_provision) | Provision a IBM Cloud Logs instance? | `bool` | `true` | no |
| <a name="input_cloud_logs_region"></a> [cloud\_logs\_region](#input\_cloud\_logs\_region) | The IBM Cloud region where Cloud Logs instances will be created. | `string` | `null` | no |
| <a name="input_cloud_logs_retention_period"></a> [cloud\_logs\_retention\_period](#input\_cloud\_logs\_retention\_period) | The number of days IBM Cloud Logs will retain the logs data in Priority insights. | `number` | `7` | no |
| <a name="input_cloud_logs_service_endpoints"></a> [cloud\_logs\_service\_endpoints](#input\_cloud\_logs\_service\_endpoints) | The type of the service endpoint that will be set for the IBM Cloud Logs instance. | `string` | `"public-and-private"` | no |
| <a name="input_cloud_logs_tags"></a> [cloud\_logs\_tags](#input\_cloud\_logs\_tags) | Tags associated with the IBM Cloud Logs instance (Optional, array of strings). | `list(string)` | `[]` | no |
| <a name="input_cloud_monitoring_access_tags"></a> [cloud\_monitoring\_access\_tags](#input\_cloud\_monitoring\_access\_tags) | A list of access tags to apply to the Cloud Monitoring instance created by the module. For more information, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial. | `list(string)` | `[]` | no |
| <a name="input_cloud_monitoring_instance_name"></a> [cloud\_monitoring\_instance\_name](#input\_cloud\_monitoring\_instance\_name) | The name of the IBM Cloud Monitoring instance to create. Defaults to 'cloud\_monitoring-<region>' | `string` | `null` | no |
| <a name="input_cloud_monitoring_manager_key_name"></a> [cloud\_monitoring\_manager\_key\_name](#input\_cloud\_monitoring\_manager\_key\_name) | The name to give the IBM Cloud Monitoring manager key. | `string` | `"SysdigManagerKey"` | no |
| <a name="input_cloud_monitoring_manager_key_tags"></a> [cloud\_monitoring\_manager\_key\_tags](#input\_cloud\_monitoring\_manager\_key\_tags) | Tags associated with the IBM Cloud Monitoring manager key. | `list(string)` | `[]` | no |
| <a name="input_cloud_monitoring_plan"></a> [cloud\_monitoring\_plan](#input\_cloud\_monitoring\_plan) | The IBM Cloud Monitoring plan to provision. Available: lite, graduated-tier | `string` | `"lite"` | no |
| <a name="input_cloud_monitoring_provision"></a> [cloud\_monitoring\_provision](#input\_cloud\_monitoring\_provision) | Provision a IBM cloud monitoring instance? | `bool` | `true` | no |
| <a name="input_cloud_monitoring_service_endpoints"></a> [cloud\_monitoring\_service\_endpoints](#input\_cloud\_monitoring\_service\_endpoints) | The type of the service endpoint that will be set for the IBM cloud monitoring instance. | `string` | `"public-and-private"` | no |
| <a name="input_cloud_monitoring_tags"></a> [cloud\_monitoring\_tags](#input\_cloud\_monitoring\_tags) | Tags associated with the IBM Cloud Monitoring instance (Optional, array of strings). | `list(string)` | `[]` | no |
| <a name="input_cos_targets"></a> [cos\_targets](#input\_cos\_targets) | List of cos target to be created | <pre>list(object({<br>    endpoint                          = string<br>    bucket_name                       = string<br>    instance_id                       = string<br>    api_key                           = optional(string)<br>    service_to_service_enabled        = optional(bool, true)<br>    target_region                     = optional(string)<br>    target_name                       = string<br>    skip_atracker_cos_iam_auth_policy = optional(bool, false)<br>  }))</pre> | `[]` | no |
| <a name="input_enable_platform_logs"></a> [enable\_platform\_logs](#input\_enable\_platform\_logs) | Receive platform logs in the provisioned IBM Cloud Logging instance. | `bool` | `true` | no |
| <a name="input_enable_platform_metrics"></a> [enable\_platform\_metrics](#input\_enable\_platform\_metrics) | Receive platform metrics in the provisioned IBM Cloud Monitoring instance. | `bool` | `true` | no |
| <a name="input_eventstreams_targets"></a> [eventstreams\_targets](#input\_eventstreams\_targets) | List of event streams target to be created | <pre>list(object({<br>    instance_id   = string<br>    brokers       = list(string)<br>    topic         = string<br>    api_key       = string<br>    target_region = optional(string)<br>    target_name   = string<br>  }))</pre> | `[]` | no |
| <a name="input_global_event_routing_settings"></a> [global\_event\_routing\_settings](#input\_global\_event\_routing\_settings) | Global settings for event routing | <pre>object({<br>    default_targets           = optional(list(string), [])<br>    metadata_region_primary   = string<br>    metadata_region_backup    = optional(string)<br>    permitted_target_regions  = list(string)<br>    private_api_endpoint_only = optional(bool, false)<br>  })</pre> | `null` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | Restricted IBM Cloud API Key used only for writing Log Analysis archives to Cloud Object Storage | `string` | `null` | no |
| <a name="input_log_analysis_access_tags"></a> [log\_analysis\_access\_tags](#input\_log\_analysis\_access\_tags) | A list of access tags to apply to the Log Analysis instance created by the module. For more information, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial. | `list(string)` | `[]` | no |
| <a name="input_log_analysis_cos_bucket_endpoint"></a> [log\_analysis\_cos\_bucket\_endpoint](#input\_log\_analysis\_cos\_bucket\_endpoint) | An endpoint for the COS bucket for the Log Analysis archive. Pass either the public or private endpoint. (Only required when var.log\_analysis\_enable\_archive and var.log\_analysis\_provision are true). | `string` | `null` | no |
| <a name="input_log_analysis_cos_bucket_name"></a> [log\_analysis\_cos\_bucket\_name](#input\_log\_analysis\_cos\_bucket\_name) | The name of an existing COS bucket to be used for the Log Analysis archive. (Only required when var.log\_analysis\_enable\_archive and var.log\_analysis\_provision are true). | `string` | `null` | no |
| <a name="input_log_analysis_cos_instance_id"></a> [log\_analysis\_cos\_instance\_id](#input\_log\_analysis\_cos\_instance\_id) | The ID of the cloud object storage instance containing the Log Analysis archive bucket. (Only required when var.log\_analysis\_enable\_archive and var.log\_analysis\_provision are true). | `string` | `null` | no |
| <a name="input_log_analysis_enable_archive"></a> [log\_analysis\_enable\_archive](#input\_log\_analysis\_enable\_archive) | Enable archive on log analysis instances | `bool` | `false` | no |
| <a name="input_log_analysis_instance_name"></a> [log\_analysis\_instance\_name](#input\_log\_analysis\_instance\_name) | The name of the IBM Cloud Logging instance to create. Defaults to 'log-analysis-<region>' | `string` | `null` | no |
| <a name="input_log_analysis_manager_key_name"></a> [log\_analysis\_manager\_key\_name](#input\_log\_analysis\_manager\_key\_name) | The name to give the IBM Cloud Logging manager key. | `string` | `"LogDnaManagerKey"` | no |
| <a name="input_log_analysis_manager_key_tags"></a> [log\_analysis\_manager\_key\_tags](#input\_log\_analysis\_manager\_key\_tags) | Tags associated with the IBM Cloud Logging manager key. | `list(string)` | `[]` | no |
| <a name="input_log_analysis_plan"></a> [log\_analysis\_plan](#input\_log\_analysis\_plan) | The IBM Cloud Logging plan to provision. Available: lite, 7-day, 14-day, 30-day, hipaa-30-day | `string` | `"lite"` | no |
| <a name="input_log_analysis_provision"></a> [log\_analysis\_provision](#input\_log\_analysis\_provision) | Provision an IBM Cloud Logging instance? | `bool` | `true` | no |
| <a name="input_log_analysis_resource_key_role"></a> [log\_analysis\_resource\_key\_role](#input\_log\_analysis\_resource\_key\_role) | Role assigned to provide the IBM Cloud Logging key. | `string` | `"Manager"` | no |
| <a name="input_log_analysis_service_endpoints"></a> [log\_analysis\_service\_endpoints](#input\_log\_analysis\_service\_endpoints) | The type of the service endpoint that will be set for the Log Analysis instance. | `string` | `"public-and-private"` | no |
| <a name="input_log_analysis_tags"></a> [log\_analysis\_tags](#input\_log\_analysis\_tags) | Tags associated with the IBM Cloud Logging instance (Optional, array of strings). | `list(string)` | `[]` | no |
| <a name="input_log_analysis_targets"></a> [log\_analysis\_targets](#input\_log\_analysis\_targets) | List of log analysis target to be created | <pre>list(object({<br>    instance_id   = string<br>    ingestion_key = string<br>    target_region = optional(string)<br>    target_name   = string<br>  }))</pre> | `[]` | no |
| <a name="input_region"></a> [region](#input\_region) | The IBM Cloud region where instances will be created. | `string` | `"us-south"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The id of the IBM Cloud resource group where the instance(s) will be created. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_activity_tracker_crn"></a> [activity\_tracker\_crn](#output\_activity\_tracker\_crn) | The id of the provisioned Activity Tracker instance. |
| <a name="output_activity_tracker_guid"></a> [activity\_tracker\_guid](#output\_activity\_tracker\_guid) | The guid of the provisioned Activity Tracker instance. |
| <a name="output_activity_tracker_manager_key_name"></a> [activity\_tracker\_manager\_key\_name](#output\_activity\_tracker\_manager\_key\_name) | The Activity Tracker manager key name |
| <a name="output_activity_tracker_name"></a> [activity\_tracker\_name](#output\_activity\_tracker\_name) | The name of the provisioned Activity Tracker instance. |
| <a name="output_activity_tracker_resource_group_id"></a> [activity\_tracker\_resource\_group\_id](#output\_activity\_tracker\_resource\_group\_id) | The resource group where Activity Tracker instance resides |
| <a name="output_activity_tracker_resource_key"></a> [activity\_tracker\_resource\_key](#output\_activity\_tracker\_resource\_key) | The resource/service key for agents to use |
| <a name="output_activity_tracker_routes"></a> [activity\_tracker\_routes](#output\_activity\_tracker\_routes) | The map of created routes |
| <a name="output_activity_tracker_targets"></a> [activity\_tracker\_targets](#output\_activity\_tracker\_targets) | The map of created targets |
| <a name="output_cloud_logs_crn"></a> [cloud\_logs\_crn](#output\_cloud\_logs\_crn) | The id of the provisioned Cloud Logs instance. |
| <a name="output_cloud_logs_guid"></a> [cloud\_logs\_guid](#output\_cloud\_logs\_guid) | The guid of the provisioned Cloud Logs instance. |
| <a name="output_cloud_logs_name"></a> [cloud\_logs\_name](#output\_cloud\_logs\_name) | The name of the provisioned Cloud Logs instance. |
| <a name="output_cloud_logs_resource_group_id"></a> [cloud\_logs\_resource\_group\_id](#output\_cloud\_logs\_resource\_group\_id) | The resource group where Cloud Logs instance resides. |
| <a name="output_cloud_monitoring_access_key"></a> [cloud\_monitoring\_access\_key](#output\_cloud\_monitoring\_access\_key) | IBM cloud monitoring access key for agents to use |
| <a name="output_cloud_monitoring_crn"></a> [cloud\_monitoring\_crn](#output\_cloud\_monitoring\_crn) | The id of the provisioned IBM cloud monitoring instance. |
| <a name="output_cloud_monitoring_guid"></a> [cloud\_monitoring\_guid](#output\_cloud\_monitoring\_guid) | The guid of the provisioned IBM cloud monitoring instance. |
| <a name="output_cloud_monitoring_manager_key_name"></a> [cloud\_monitoring\_manager\_key\_name](#output\_cloud\_monitoring\_manager\_key\_name) | The IBM cloud monitoring manager key name |
| <a name="output_cloud_monitoring_name"></a> [cloud\_monitoring\_name](#output\_cloud\_monitoring\_name) | The name of the provisioned IBM cloud monitoring instance. |
| <a name="output_cloud_monitoring_resource_group_id"></a> [cloud\_monitoring\_resource\_group\_id](#output\_cloud\_monitoring\_resource\_group\_id) | The resource group where IBM cloud monitoring monitor instance resides |
| <a name="output_ingress_endpoint"></a> [ingress\_endpoint](#output\_ingress\_endpoint) | The public ingress endpoint of the provisioned Cloud Logs instance. |
| <a name="output_ingress_private_endpoint"></a> [ingress\_private\_endpoint](#output\_ingress\_private\_endpoint) | The private ingress endpoint of the provisioned Cloud Logs instance. |
| <a name="output_log_analysis_crn"></a> [log\_analysis\_crn](#output\_log\_analysis\_crn) | The id of the provisioned Log Analysis instance. |
| <a name="output_log_analysis_guid"></a> [log\_analysis\_guid](#output\_log\_analysis\_guid) | The guid of the provisioned Log Analysis instance. |
| <a name="output_log_analysis_ingestion_key"></a> [log\_analysis\_ingestion\_key](#output\_log\_analysis\_ingestion\_key) | Log Analysis ingest key for agents to use |
| <a name="output_log_analysis_manager_key_name"></a> [log\_analysis\_manager\_key\_name](#output\_log\_analysis\_manager\_key\_name) | The Log Analysis manager key name |
| <a name="output_log_analysis_name"></a> [log\_analysis\_name](#output\_log\_analysis\_name) | The name of the provisioned Log Analysis instance. |
| <a name="output_log_analysis_resource_group_id"></a> [log\_analysis\_resource\_group\_id](#output\_log\_analysis\_resource\_group\_id) | The resource group where Log Analysis instance resides |
| <a name="output_log_analysis_resource_key"></a> [log\_analysis\_resource\_key](#output\_log\_analysis\_resource\_key) | Log Analysis service key for agents to use |
| <a name="output_region"></a> [region](#output\_region) | Region that instance(s) are provisioned to. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
