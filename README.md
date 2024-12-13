# Terraform IBM Observability instances module

[![Graduated (Supported)](https://img.shields.io/badge/Status-Graduated%20(Supported)-brightgreen)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-observability-instances?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-observability-instances/releases/latest)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)

> [!IMPORTANT]
> The IBM Log Analysis and IBM Cloud Activity Tracker services are deprecated and no longer supported in this module. [IBM Cloud Logs](https://www.ibm.com/products/cloud-logs) is the replacement service and is now the default service created with this module.

This module supports provisioning the following observability services:

* **IBM Cloud Logs**
  * IBM® Cloud Logs is a scalable logging service that persists logs and provides users with capabilities for querying, tailing, and visualizing logs.
* **IBM Cloud Activity Tracker Event Routing**
  * Use IBM Cloud® Activity Tracker Event Routing to configure how to route auditing events, both global and location-based event data, in your IBM Cloud. Supports routing to the following target types: `IBM Cloud Object Storage (COS)`, `IBM Cloud Logs`, and `IBM® Event Streams for IBM Cloud®`.
* **IBM Cloud Monitoring with Cloud Monitoring**
  * Monitor the health of services and applications in IBM Cloud.
* **IBM Cloud Metrics Routing**
  * Use IBM Cloud® Metrics Routing to configure the routing of platform metrics generated in your IBM Cloud account. Supports routing to `IBM Cloud Monitoring` target.

<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-observability-instances](#terraform-ibm-observability-instances)
* [Submodules](./modules)
    * [activity_tracker](./modules/activity_tracker)
    * [cloud_logs](./modules/cloud_logs)
    * [cloud_monitoring](./modules/cloud_monitoring)
    * [metrics_routing](./modules/metrics_routing)
* [Examples](./examples)
    * [Advanced Examples configuring Cloud Logs, Monitoring, Activity Tracker routing with multiple target types](./examples/advanced)
    * [Basic example (Cloud Logs, Monitoring, Activity Tracker route with Cloud Logs target)](./examples/basic)
* [Contributing](#contributing)
<!-- END OVERVIEW HOOK -->

## terraform-ibm-observability-instances

### Usage

```hcl
# Locals
locals {
  region      = "us-south"
}

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      version = "X.Y.Z" # lock into a supported provider version
    }
  }
}

provider "ibm" {
  ibmcloud_api_key = XXXXXXXXXXXX
  region           = local.region
}

# Below config will provision:
# - Cloud Logs instance
# - Monitoring instance
# - Activity Tracker route to the Cloud Logs target
# - Metrics Routing to Cloud Monitoring target
module "observability_instances" {
  source    = "terraform-ibm-modules/observability-instances/ibm"
  version   = "X.Y.Z" # Replace "X.X.X" with a release version to lock into a specific release
  resource_group_id     = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
  region                = local.region
  cloud_logs_data_storage = {
    # logs and metrics buckets must be different
    logs_data = {
      enabled         = true
      bucket_crn      = "crn:v1:bluemix:public:cloud-object-storage:global:a/......"
      bucket_endpoint = "s3.direct.us-south.cloud-object-storage.appdomain.cloud"
    },
    metrics_data = {
      enabled         = true
      bucket_crn      = "crn:v1:bluemix:public:cloud-object-storage:global:a/......"
      bucket_endpoint = "s3.direct.us-south.cloud-object-storage.appdomain.cloud"
    }
  }
  at_cloud_logs_targets = [
    {
      instance_id   = module.observability_instances.cloud_logs_crn
      target_region = local.region
      target_name   = "my-icl-target"
    }
  ]
  activity_tracker_routes = [
    {
      locations  = ["*", "global"]
      target_ids = [module.observability_instances.activity_tracker_targets["my-icl-target"].id]
      route_name = "my-icl-route"
    }
  ]
  metric_router_targets = [
    {
      # ID of the Cloud logs instance
      destination_crn   = module.observability_instances.cloud_monitoring_crn
      target_region = "us-south"
      target_name   = "my-mr-target"
    }
  ]
  metric_router_routes = [
    {
        name = "my-mr-route"
        rules = [
            {
                action = "send"
                targets = [{
                    id = module.observability_instances.metrics_router_targets["my-mr-target"].id
                }]
                inclusion_filters = [{
                    operand = "location"
                    operator = "is"
                    values = ["us-south"]
                }]
            }
        ]
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
    - **Cloud Logs**
        - `Editor` platform access
        - `Manager` service access
    - **IBM Cloud Logs Routing** (Required if creating tenants, which are required to enable platform logs)
        - `Editor` platform access
        - `Manager` service access
    - **Cloud Monitoring**
        - `Editor` platform access
        - `Manager` service access
    - **Tagging service** (Required if attaching access tags)
        - `Editor` platform access

<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.70.0, < 2.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_activity_tracker"></a> [activity\_tracker](#module\_activity\_tracker) | ./modules/activity_tracker | n/a |
| <a name="module_cloud_logs"></a> [cloud\_logs](#module\_cloud\_logs) | ./modules/cloud_logs | n/a |
| <a name="module_cloud_monitoring"></a> [cloud\_monitoring](#module\_cloud\_monitoring) | ./modules/cloud_monitoring | n/a |
| <a name="module_metric_routing"></a> [metric\_routing](#module\_metric\_routing) | ./modules/metrics_routing | n/a |

### Resources

No resources.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_activity_tracker_routes"></a> [activity\_tracker\_routes](#input\_activity\_tracker\_routes) | List of routes to be created, maximum four routes are allowed | <pre>list(object({<br/>    locations  = list(string)<br/>    target_ids = list(string)<br/>    route_name = string<br/>  }))</pre> | `[]` | no |
| <a name="input_at_cloud_logs_targets"></a> [at\_cloud\_logs\_targets](#input\_at\_cloud\_logs\_targets) | List of Cloud Logs targets to be created | <pre>list(object({<br/>    instance_id                              = string<br/>    target_region                            = optional(string)<br/>    target_name                              = string<br/>    skip_atracker_cloud_logs_iam_auth_policy = optional(bool, false)<br/>  }))</pre> | `[]` | no |
| <a name="input_at_cos_targets"></a> [at\_cos\_targets](#input\_at\_cos\_targets) | List of cos target to be created | <pre>list(object({<br/>    endpoint                          = string<br/>    bucket_name                       = string<br/>    instance_id                       = string<br/>    api_key                           = optional(string)<br/>    service_to_service_enabled        = optional(bool, true)<br/>    target_region                     = optional(string)<br/>    target_name                       = string<br/>    skip_atracker_cos_iam_auth_policy = optional(bool, false)<br/>  }))</pre> | `[]` | no |
| <a name="input_at_eventstreams_targets"></a> [at\_eventstreams\_targets](#input\_at\_eventstreams\_targets) | List of event streams target to be created | <pre>list(object({<br/>    instance_id                      = string<br/>    brokers                          = list(string)<br/>    topic                            = string<br/>    api_key                          = optional(string)<br/>    service_to_service_enabled       = optional(bool, true)<br/>    skip_atracker_es_iam_auth_policy = optional(bool, false)<br/>    target_region                    = optional(string)<br/>    target_name                      = string<br/>  }))</pre> | `[]` | no |
| <a name="input_cloud_logs_access_tags"></a> [cloud\_logs\_access\_tags](#input\_cloud\_logs\_access\_tags) | A list of access tags to apply to the IBM Cloud Logs instance created by the module. For more information, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial. | `list(string)` | `[]` | no |
| <a name="input_cloud_logs_data_storage"></a> [cloud\_logs\_data\_storage](#input\_cloud\_logs\_data\_storage) | A logs data bucket and a metrics bucket in IBM Cloud Object Storage to store your IBM Cloud Logs data for long term storage, search, analysis and alerting. | <pre>object({<br/>    logs_data = optional(object({<br/>      enabled              = optional(bool, false)<br/>      bucket_crn           = optional(string)<br/>      bucket_endpoint      = optional(string)<br/>      skip_cos_auth_policy = optional(bool, false)<br/>    }), {})<br/>    metrics_data = optional(object({<br/>      enabled              = optional(bool, false)<br/>      bucket_crn           = optional(string)<br/>      bucket_endpoint      = optional(string)<br/>      skip_cos_auth_policy = optional(bool, false)<br/>    }), {})<br/>    }<br/>  )</pre> | <pre>{<br/>  "logs_data": null,<br/>  "metrics_data": null<br/>}</pre> | no |
| <a name="input_cloud_logs_existing_en_instances"></a> [cloud\_logs\_existing\_en\_instances](#input\_cloud\_logs\_existing\_en\_instances) | List of Event Notifications instance details for routing critical events that occur in your IBM Cloud Logs. | <pre>list(object({<br/>    en_instance_id      = string<br/>    en_region           = string<br/>    en_integration_name = optional(string)<br/>    skip_en_auth_policy = optional(bool, false)<br/>  }))</pre> | `[]` | no |
| <a name="input_cloud_logs_instance_name"></a> [cloud\_logs\_instance\_name](#input\_cloud\_logs\_instance\_name) | The name of the IBM Cloud Logs instance to create. Defaults to 'cloud\_logs-<region>' | `string` | `null` | no |
| <a name="input_cloud_logs_plan"></a> [cloud\_logs\_plan](#input\_cloud\_logs\_plan) | The IBM Cloud Logs plan to provision. Available: standard | `string` | `"standard"` | no |
| <a name="input_cloud_logs_policies"></a> [cloud\_logs\_policies](#input\_cloud\_logs\_policies) | Configuration of Cloud Logs policies. | <pre>list(object({<br/>    logs_policy_name        = string<br/>    logs_policy_description = optional(string, null)<br/>    logs_policy_priority    = string<br/>    application_rule = optional(list(object({<br/>      name         = string<br/>      rule_type_id = optional(string, "unspecified")<br/>    })))<br/>    subsystem_rule = optional(list(object({<br/>      name         = string<br/>      rule_type_id = optional(string, "unspecified")<br/>    })))<br/>    log_rules = optional(list(object({<br/>      severities = list(string)<br/>    })))<br/>    archive_retention = optional(list(object({<br/>      id = string<br/>    })))<br/>  }))</pre> | `[]` | no |
| <a name="input_cloud_logs_provision"></a> [cloud\_logs\_provision](#input\_cloud\_logs\_provision) | Provision an IBM Cloud Logs instance? | `bool` | `true` | no |
| <a name="input_cloud_logs_retention_period"></a> [cloud\_logs\_retention\_period](#input\_cloud\_logs\_retention\_period) | The number of days IBM Cloud Logs will retain the logs data in Priority insights. Allowed values: 7, 14, 30, 60, 90. | `number` | `7` | no |
| <a name="input_cloud_logs_service_endpoints"></a> [cloud\_logs\_service\_endpoints](#input\_cloud\_logs\_service\_endpoints) | The type of the service endpoint that will be set for the IBM Cloud Logs instance. | `string` | `"public-and-private"` | no |
| <a name="input_cloud_logs_tags"></a> [cloud\_logs\_tags](#input\_cloud\_logs\_tags) | Tags associated with the IBM Cloud Logs instance (Optional, array of strings). | `list(string)` | `[]` | no |
| <a name="input_cloud_monitoring_access_tags"></a> [cloud\_monitoring\_access\_tags](#input\_cloud\_monitoring\_access\_tags) | A list of access tags to apply to the Cloud Monitoring instance created by the module. For more information, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial. | `list(string)` | `[]` | no |
| <a name="input_cloud_monitoring_instance_name"></a> [cloud\_monitoring\_instance\_name](#input\_cloud\_monitoring\_instance\_name) | The name of the IBM Cloud Monitoring instance to create. Defaults to 'cloud\_monitoring-<region>' | `string` | `null` | no |
| <a name="input_cloud_monitoring_manager_key_name"></a> [cloud\_monitoring\_manager\_key\_name](#input\_cloud\_monitoring\_manager\_key\_name) | The name to give the IBM Cloud Monitoring manager key. | `string` | `"SysdigManagerKey"` | no |
| <a name="input_cloud_monitoring_manager_key_tags"></a> [cloud\_monitoring\_manager\_key\_tags](#input\_cloud\_monitoring\_manager\_key\_tags) | Tags associated with the IBM Cloud Monitoring manager key. | `list(string)` | `[]` | no |
| <a name="input_cloud_monitoring_plan"></a> [cloud\_monitoring\_plan](#input\_cloud\_monitoring\_plan) | The IBM Cloud Monitoring plan to provision. Available: lite, graduated-tier | `string` | `"lite"` | no |
| <a name="input_cloud_monitoring_provision"></a> [cloud\_monitoring\_provision](#input\_cloud\_monitoring\_provision) | Provision a IBM cloud monitoring instance? | `bool` | `true` | no |
| <a name="input_cloud_monitoring_service_endpoints"></a> [cloud\_monitoring\_service\_endpoints](#input\_cloud\_monitoring\_service\_endpoints) | The type of the service endpoint that will be set for the IBM Cloud Monitoring instance. Allowed values: public-and-private | `string` | `"public-and-private"` | no |
| <a name="input_cloud_monitoring_tags"></a> [cloud\_monitoring\_tags](#input\_cloud\_monitoring\_tags) | Tags associated with the IBM Cloud Monitoring instance (Optional, array of strings). | `list(string)` | `[]` | no |
| <a name="input_enable_platform_logs"></a> [enable\_platform\_logs](#input\_enable\_platform\_logs) | Setting this to true will create a tenant in the same region that the Cloud Logs instance is provisioned to enable platform logs for that region. To send platform logs from other regions, you can explicitially specify a list of regions using the `logs_routing_tenant_regions` input. NOTE: You can only have 1 tenant per region in an account. | `bool` | `true` | no |
| <a name="input_enable_platform_metrics"></a> [enable\_platform\_metrics](#input\_enable\_platform\_metrics) | Receive platform metrics in the provisioned IBM Cloud Monitoring instance. | `bool` | `true` | no |
| <a name="input_global_event_routing_settings"></a> [global\_event\_routing\_settings](#input\_global\_event\_routing\_settings) | Global settings for event routing | <pre>object({<br/>    default_targets           = optional(list(string), [])<br/>    metadata_region_primary   = string<br/>    metadata_region_backup    = optional(string)<br/>    permitted_target_regions  = list(string)<br/>    private_api_endpoint_only = optional(bool, false)<br/>  })</pre> | `null` | no |
| <a name="input_logs_routing_tenant_regions"></a> [logs\_routing\_tenant\_regions](#input\_logs\_routing\_tenant\_regions) | Pass a list of regions to create a tenant for that is targetted to the Cloud Logs instance created by this module. To manage platform logs that are generated by IBM Cloud® services in a region of IBM Cloud, you must create a tenant in each region that you operate. Leave the list empty if you don't want to create any tenants. | `list(any)` | `[]` | no |
| <a name="input_metrics_router_routes"></a> [metrics\_router\_routes](#input\_metrics\_router\_routes) | List of routes for IBM Metrics Router. | <pre>list(object({<br/>    name = string<br/>    rules = list(object({<br/>      action = optional(string, "send")<br/>      targets = optional(list(object({<br/>        id = string<br/>      })))<br/>      inclusion_filters = list(object({<br/>        operand  = string<br/>        operator = string<br/>        values   = list(string)<br/>      }))<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_metrics_router_settings"></a> [metrics\_router\_settings](#input\_metrics\_router\_settings) | Global settings for Metrics Routing. | <pre>object({<br/>    default_targets = optional(list(object({<br/>      id = string<br/>    })))<br/>    permitted_target_regions  = optional(list(string))<br/>    primary_metadata_region   = optional(string)<br/>    backup_metadata_region    = optional(string)<br/>    private_api_endpoint_only = optional(bool, false)<br/>  })</pre> | `null` | no |
| <a name="input_metrics_router_targets"></a> [metrics\_router\_targets](#input\_metrics\_router\_targets) | List of Metrics Router targets to be created. | <pre>list(object({<br/>    destination_crn                     = string<br/>    target_name                         = string<br/>    target_region                       = optional(string)<br/>    skip_mrouter_sysdig_iam_auth_policy = optional(bool, false)<br/>  }))</pre> | `[]` | no |
| <a name="input_region"></a> [region](#input\_region) | The IBM Cloud region where instances will be created. | `string` | `"us-south"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The id of the IBM Cloud resource group where the instance(s) will be created. | `string` | `null` | no |
| <a name="input_skip_logs_routing_auth_policy"></a> [skip\_logs\_routing\_auth\_policy](#input\_skip\_logs\_routing\_auth\_policy) | Whether to create an IAM authorization policy that permits Logs Routing Sender access to the IBM Cloud Logs. | `bool` | `false` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_activity_tracker_routes"></a> [activity\_tracker\_routes](#output\_activity\_tracker\_routes) | The map of created routes |
| <a name="output_activity_tracker_targets"></a> [activity\_tracker\_targets](#output\_activity\_tracker\_targets) | The map of created targets |
| <a name="output_cloud_logs_crn"></a> [cloud\_logs\_crn](#output\_cloud\_logs\_crn) | The id of the provisioned Cloud Logs instance. |
| <a name="output_cloud_logs_guid"></a> [cloud\_logs\_guid](#output\_cloud\_logs\_guid) | The guid of the provisioned Cloud Logs instance. |
| <a name="output_cloud_logs_ingress_endpoint"></a> [cloud\_logs\_ingress\_endpoint](#output\_cloud\_logs\_ingress\_endpoint) | The public ingress endpoint of the provisioned Cloud Logs instance. |
| <a name="output_cloud_logs_ingress_private_endpoint"></a> [cloud\_logs\_ingress\_private\_endpoint](#output\_cloud\_logs\_ingress\_private\_endpoint) | The private ingress endpoint of the provisioned Cloud Logs instance. |
| <a name="output_cloud_logs_name"></a> [cloud\_logs\_name](#output\_cloud\_logs\_name) | The name of the provisioned Cloud Logs instance. |
| <a name="output_cloud_logs_resource_group_id"></a> [cloud\_logs\_resource\_group\_id](#output\_cloud\_logs\_resource\_group\_id) | The resource group where Cloud Logs instance resides. |
| <a name="output_cloud_monitoring_access_key"></a> [cloud\_monitoring\_access\_key](#output\_cloud\_monitoring\_access\_key) | IBM cloud monitoring access key for agents to use |
| <a name="output_cloud_monitoring_crn"></a> [cloud\_monitoring\_crn](#output\_cloud\_monitoring\_crn) | The id of the provisioned IBM cloud monitoring instance. |
| <a name="output_cloud_monitoring_guid"></a> [cloud\_monitoring\_guid](#output\_cloud\_monitoring\_guid) | The guid of the provisioned IBM cloud monitoring instance. |
| <a name="output_cloud_monitoring_manager_key_name"></a> [cloud\_monitoring\_manager\_key\_name](#output\_cloud\_monitoring\_manager\_key\_name) | The IBM cloud monitoring manager key name |
| <a name="output_cloud_monitoring_name"></a> [cloud\_monitoring\_name](#output\_cloud\_monitoring\_name) | The name of the provisioned IBM cloud monitoring instance. |
| <a name="output_cloud_monitoring_resource_group_id"></a> [cloud\_monitoring\_resource\_group\_id](#output\_cloud\_monitoring\_resource\_group\_id) | The resource group where IBM cloud monitoring monitor instance resides |
| <a name="output_logs_policies_details"></a> [logs\_policies\_details](#output\_logs\_policies\_details) | The details of the Cloud logs policies created. |
| <a name="output_metrics_router_routes"></a> [metrics\_router\_routes](#output\_metrics\_router\_routes) | The created metrics routing routes. |
| <a name="output_metrics_router_settings"></a> [metrics\_router\_settings](#output\_metrics\_router\_settings) | The global metrics routing settings. |
| <a name="output_metrics_router_targets"></a> [metrics\_router\_targets](#output\_metrics\_router\_targets) | The created metrics routing targets. |
| <a name="output_region"></a> [region](#output\_region) | Region that instance(s) are provisioned to. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
