# Metric Router module

This module supports provisioning the following:

* **IBM Cloud Metric Routing**
  * Use IBM Cloud® Metrics Routing to configure the routing of platform metrics generated in your IBM Cloud account. IBM Cloud Metrics Routing is a platform service, to manage platform metrics at the account-level by configuring targets and routes that define where data points are routed.

## Usage

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
  ibmcloud_api_key = XXXXXXXXXXXX #pragma: allowlist secret
  region           = local.region
}

# Create Metric Router target and route
module "metric_router" {
  source    = "terraform-ibm-modules/observability-instances/ibm//modules/metrics_routing"
  version   = "X.Y.Z" # Replace "X.Y.Z" with a release version to lock into a specific release
  # Create Metric Router target
  metric_router_targets = [
    {
      # ID of the Cloud logs instance
      destination_crn   = "crn:v1:bluemix:public:sysdig-monitor:eu-de:a/xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX:xxxxxx-XXXX-XXXX-XXXX-xxxxxx::"
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
                    id = module.observability_instances.metrics_router_targets["my-mr-target].id
                }]
                inclusion_filters = [{
                    operand = "location"
                    operator = "is"
                    values = ["us-east"]
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
    - **Metric Routing** (Required if creating Metric routes and targets)
        - `Editor` platform access
        - `Manager` service access

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.69.2, < 2.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_iam_authorization_policy.metrics_router_cloud_monitoring](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_metrics_router_route.metrics_router_routes](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/metrics_router_route) | resource |
| [ibm_metrics_router_settings.metrics_router_settings](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/metrics_router_settings) | resource |
| [ibm_metrics_router_target.metrics_router_targets](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/metrics_router_target) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_metrics_router_routes"></a> [metrics\_router\_routes](#input\_metrics\_router\_routes) | List of routes for IBM Metrics Router | <pre>list(object({<br/>    name = string<br/>    rules = list(object({<br/>      action = string<br/>      targets = optional(list(object({<br/>        id = optional(string)<br/>      })), [])<br/>      inclusion_filters = list(object({<br/>        operand  = string<br/>        operator = string<br/>        values   = list(string)<br/>      }))<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_metrics_router_settings"></a> [metrics\_router\_settings](#input\_metrics\_router\_settings) | Global settings for Metrics Routing | <pre>object({<br/>    permitted_target_regions  = list(string)<br/>    primary_metadata_region   = string<br/>    backup_metadata_region    = string<br/>    private_api_endpoint_only = bool<br/>    default_targets = optional(list(object({<br/>      id = string<br/>    })), [])<br/>  })</pre> | `null` | no |
| <a name="input_metrics_router_targets"></a> [metrics\_router\_targets](#input\_metrics\_router\_targets) | List of Metrics Router targets to be created. | <pre>list(object({<br/>    destination_crn                     = string<br/>    target_name                         = string<br/>    target_region                       = string<br/>    skip_mrouter_sysdig_iam_auth_policy = optional(bool, false)<br/>  }))</pre> | `[]` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_metrics_router_routes"></a> [metrics\_router\_routes](#output\_metrics\_router\_routes) | The created metrics routing routes. |
| <a name="output_metrics_router_settings"></a> [metrics\_router\_settings](#output\_metrics\_router\_settings) | The global metrics routing settings. |
| <a name="output_metrics_router_targets"></a> [metrics\_router\_targets](#output\_metrics\_router\_targets) | The created metrics routing targets. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
