# Migrating to replacement modules

The [terraform-ibm-observability-instances](https://github.com/terraform-ibm-modules/terraform-ibm-observability-instances) module is no longer maintained and has been replaced by the following 3 modules:

- [terraform-ibm-cloud-logs](https://github.com/terraform-ibm-modules/terraform-ibm-cloud-logs)
- [terraform-ibm-cloud-monitoring](https://github.com/terraform-ibm-modules/terraform-ibm-cloud-monitoring)
- [terraform-ibm-activity-tracker](https://github.com/terraform-ibm-modules/terraform-ibm-activity-tracker)

In order to migrate to the new modules, you need to update your terraform code to now call each of the new modules individually. For example, your current code will look something like this:

```hcl
module "observability_instances" {
  source  = "terraform-ibm-modules/observability-instances/ibm"
  version = "3.5.2"
  ...
  ...
}
```

And your new code will look like this:
```hcl
module "cloud_logs" {
  source  = "terraform-ibm-modules/cloud-logs/ibm"
  version = "1.3.1"
  ...
  ...
}

module "cloud_monitoring" {
  source            = "terraform-ibm-modules/cloud-monitoring/ibm"
  version           = "1.2.2"
  ...
  ...
}

module "metrics_router" {
  source    = "terraform-ibm-modules/cloud-monitoring/ibm//modules/metrics_routing"
  version   = "1.2.2"
  ...
  ...
}

module "activity_tracker" {
  source            = "terraform-ibm-modules/activity-tracker/ibm"
  version           = "1.0.0"
  ...
  ...
}
```

In order to prevent infrastructure from being recreated when migrating, you can use terraform [moved block references](https://developer.hashicorp.com/terraform/language/moved). Below are a full list of required moved blocks:

```hcl
# Cloud Logs
moved {
  from = module.observability_instance.module.cloud_logs[0]
  to   = module.cloud_logs[0]
}

# Cloud Monitoring
moved {
  from = module.observability_instance.module.cloud_monitoring[0].ibm_resource_instance.cloud_monitoring[0]
  to   = module.cloud_monitoring[0].ibm_resource_instance.cloud_monitoring
}

moved {
  from = module.observability_instance.module.cloud_monitoring[0].ibm_resource_key.resource_key[0]
  to   = module.cloud_monitoring[0].ibm_resource_key.resource_key
}

moved {
  from = module.observability_instance.module.cloud_monitoring[0].ibm_resource_tag.cloud_monitoring_tag
  to   = module.cloud_monitoring[0].ibm_resource_tag.cloud_monitoring_tag
}

# Metrics Routing
moved {
  from = module.observability_instance.module.metric_routing
  to   = module.metrics_router
}

# Activity Tracker
moved {
  from = module.observability_instance.module.activity_tracker
  to   = module.activity_tracker
}
```

After upgrading your code and running a terraform plan, you may see the following expected change:
- Destroy and re-create of the Activity Tracker / COS service to service authorization policy.
  - In the new Activity Tracker module, the authorization policy has been updated so that it is now scoped the exact Object storage bucket, where previously it was scoped to the full Object Storage instance.
  - The new logic has been implemented in such a way that the new authorization policy will be created before the old one is deleted, meaning there will be no disruption to every day services.
  - The plan output will look something like this:
    ```
    # module.activity_tracker.ibm_iam_authorization_policy.atracker_cos["con-cos-target"] must be replaced
    # (moved from module.observability_instance.module.activity_tracker.ibm_iam_authorization_policy.atracker_cos["con-cos-target"])
    +/- resource "ibm_iam_authorization_policy" "atracker_cos" {
        ~ id                          = "1da3880a-b623-46fa-a8f3-362dc51c4774" -> (known after apply)
        + source_resource_group_id    = (known after apply)
        + source_resource_instance_id = (known after apply)
        + source_resource_type        = (known after apply)
        ~ source_service_account      = "abac0df06b644a9cabc6e44f55b3880e" -> (known after apply)
        + target_resource_group_id    = (known after apply)
        ~ target_resource_instance_id = "7fa80cb2-2771-460a-bcdd-b52dfbf959e5" -> (known after apply)
        + target_resource_type        = (known after apply)
        ~ target_service_name         = "cloud-object-storage" -> (known after apply)
        ~ transaction_id              = "184970857dde438f9e05d298a55711ea" -> (known after apply)
        + version                     = (known after apply)
            # (3 unchanged attributes hidden)

        + resource_attributes { # forces replacement
            + name     = "resource"
            + operator = "stringEquals"
            + value    = "con-at-events-cos-bucket-jm90"
            }
        + resource_attributes { # forces replacement
            + name     = "resourceType"
            + operator = "stringEquals"
            + value    = "bucket"
            }

        ~ subject_attributes (known after apply)

            # (3 unchanged blocks hidden)
        }
    ```