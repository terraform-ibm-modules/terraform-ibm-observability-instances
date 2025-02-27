variable "region" {
  description = "The IBM Cloud region where Cloud logs instance will be created."
  type        = string
  default     = "us-south"
}

variable "resource_group_id" {
  type        = string
  description = "The id of the IBM Cloud resource group where the instance will be created."
  default     = null
}

variable "instance_name" {
  type        = string
  description = "The name of the IBM Cloud Logs instance to create. Defaults to 'cloud-logs-<region>'"
  default     = null
}

variable "plan" {
  type        = string
  description = "The IBM Cloud Logs plan to provision. Available: standard"
  default     = "standard"

  validation {
    condition = anytrue([
      var.plan == "standard",
    ])
    error_message = "The plan value must be one of the following: standard."
  }
}

variable "resource_tags" {
  type        = list(string)
  description = "Tags associated with the IBM Cloud Logs instance (Optional, array of strings)."
  default     = []
}

variable "access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the IBM Cloud Logs instance created by the module. For more information, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial."
  default     = []
}

variable "retention_period" {
  type        = number
  description = "The number of days IBM Cloud Logs will retain the logs data in Priority insights. Allowed values: 7, 14, 30, 60, 90."
  default     = 7

  validation {
    condition     = contains([7, 14, 30, 60, 90], var.retention_period)
    error_message = "Valid values 'retention_period' are: 7, 14, 30, 60, 90"
  }
}

variable "data_storage" {
  type = object({
    logs_data = optional(object({
      enabled              = optional(bool, false)
      bucket_crn           = optional(string)
      bucket_endpoint      = optional(string)
      skip_cos_auth_policy = optional(bool, false)
    }), {})
    metrics_data = optional(object({
      enabled              = optional(bool, false)
      bucket_crn           = optional(string)
      bucket_endpoint      = optional(string)
      skip_cos_auth_policy = optional(bool, false)
    }), {})
    }
  )
  default = {
    logs_data    = null,
    metrics_data = null
  }
  validation {
    condition     = (var.data_storage.logs_data.bucket_crn == null && var.data_storage.metrics_data.bucket_crn == null) || (var.data_storage.logs_data.bucket_crn != var.data_storage.metrics_data.bucket_crn)
    error_message = "The same bucket cannot be used as both your data bucket and your metrics bucket."
  }
  validation {
    error_message = "`bucket_crn` and `bucket_endpoint` must be included if logs_data `enabled` is true."
    condition = (
      lookup(var.data_storage.logs_data, "enabled", null) == null
      ) || (
      lookup(var.data_storage.logs_data, "enabled", false) == false
      ) || (
      lookup(var.data_storage.logs_data, "bucket_crn", null) != null &&
      lookup(var.data_storage.logs_data, "bucket_endpoint", null) != null &&
      lookup(var.data_storage.logs_data, "enabled", false) == true
    )
  }
  validation {
    error_message = "`bucket_crn` and `bucket_endpoint` must be included if metrics_data `enabled` is true."
    condition = (
      lookup(var.data_storage.metrics_data, "enabled", null) == null
      ) || (
      lookup(var.data_storage.metrics_data, "enabled", false) == false
      ) || (
      lookup(var.data_storage.metrics_data, "bucket_crn", null) != null &&
      lookup(var.data_storage.metrics_data, "bucket_endpoint", null) != null &&
      lookup(var.data_storage.metrics_data, "enabled", false) == true
    )
  }
  description = "A logs data bucket and a metrics bucket in IBM Cloud Object Storage to store your IBM Cloud Logs data for long term storage, search, analysis and alerting."
}

variable "service_endpoints" {
  description = "The type of the service endpoint that will be set for the IBM Cloud Logs instance. Allowed values: public-and-private."
  type        = string
  default     = "public-and-private"
  validation {
    condition     = contains(["public-and-private"], var.service_endpoints)
    error_message = "The specified service_endpoints is not a valid selection. Allowed values: public-and-private."
  }
}

##############################################################################
# Event Notification
##############################################################################

variable "existing_en_instances" {
  type = list(object({
    en_instance_id      = string
    en_region           = string
    en_integration_name = optional(string)
    skip_en_auth_policy = optional(bool, false)
  }))
  default     = []
  description = "List of Event Notifications instance details for routing critical events that occur in your IBM Cloud Logs."
}

##############################################################################
# Logs Routing
##############################################################################

variable "logs_routing_tenant_regions" {
  type        = list(any)
  default     = []
  description = "Pass a list of regions to create a tenant for that is targetted to the Cloud Logs instance created by this module. To manage platform logs that are generated by IBM Cloud® services in a region of IBM Cloud, you must create a tenant in each region that you operate. Leave the list empty if you don't want to create any tenants. NOTE: You can only have 1 tenant per region in an account."
  nullable    = false
}

variable "skip_logs_routing_auth_policy" {
  description = "Whether to create an IAM authorization policy that permits the Logs Routing server 'Sender' access to the IBM Cloud Logs instance created by this module."
  type        = bool
  default     = false
}

#############################################################################################################
# Logs Policies Configuration
#
# logs_policy_name -The name of the IBM Cloud Logs policy to create.
# logs_policy_description - Description of the IBM Cloud Logs policy to create.
# logs_policy_priority - Select priority to determine the pipeline for the logs. High (priority value) sent to 'Priority insights' (TCO pipleine), Medium to 'Analyze and alert', Low to 'Store and search', Blocked are not sent to any pipeline.
# application_rule - Define rules for matching applications to include in the policy configuration.
# subsystem_rule - Define subsystem rules for matching applications to include in the policy configuration.
# log_rules - Define the log severities to include in the policy configuration.
# archive_retention - Define archive retention.
##############################################################################################################

variable "policies" {
  type = list(object({
    logs_policy_name        = string
    logs_policy_description = optional(string, null)
    logs_policy_priority    = string
    application_rule = optional(list(object({
      name         = string
      rule_type_id = string
    })))
    subsystem_rule = optional(list(object({
      name         = string
      rule_type_id = string
    })))
    log_rules = optional(list(object({
      severities = list(string)
    })))
    archive_retention = optional(list(object({
      id = string
    })))
  }))
  description = "Configuration of Cloud Logs policies."
  default     = []

  validation {
    condition     = alltrue([for config in var.policies : (length(config.logs_policy_name) <= 4096 ? true : false)])
    error_message = "Maximum length of logs_policy_name allowed is 4096 chars."
  }

  validation {
    condition     = alltrue([for config in var.policies : contains(["type_unspecified", "type_block", "type_low", "type_medium", "type_high"], config.logs_policy_priority)])
    error_message = "The specified priority for logs policy is not a valid selection. Allowed values are: type_unspecified, type_block, type_low, type_medium, type_high."
  }

  validation {
    condition = alltrue(
      [for config in var.policies :
        (config.application_rule != null ?
          (alltrue([for rule in config.application_rule :
          contains(["unspecified", "is", "is_not", "start_with", "includes"], rule.rule_type_id)]))
        : true)
    ])
    error_message = "Identifier of application_rule 'rule_type_id' is not a valid selection. Allowed values are: unspecified, is, is_not, start_with, includes."
  }

  validation {
    condition = alltrue(
      [for config in var.policies :
        (config.application_rule != null ?
          (alltrue([for rule in config.application_rule :
          can(regex("^[\\p{L}\\p{N}\\p{P}\\p{Z}\\p{S}\\p{M}]+$", rule.name)) && length(rule.name) <= 4096 && length(rule.name) > 1]))
        : true)
    ])
    error_message = "The name of the application_rule does not meet the required criteria."
  }

  validation {
    condition = alltrue(
      [for config in var.policies :
        (config.log_rules != null && length(config.log_rules) > 0 ? true : false)
    ])
    error_message = "The log_rules can not be empty and must contain at least 1 item."
  }

  validation {
    condition = alltrue(
      [for config in var.policies :
        (config.log_rules != null ?
          (alltrue([for rule in config.log_rules :
            alltrue([for severity in rule["severities"] :
          contains(["unspecified", "debug", "verbose", "info", "warning", "error", "critical"], severity)])]))
          : true
    )])
    error_message = "The 'severities' of log_rules is not a valid selection. Allowed values are: unspecified, debug, verbose, info, warning, error, critical."
  }

  validation {
    condition = alltrue(
      [for config in var.policies :
        (config.subsystem_rule != null ?
          (alltrue([for rule in config.subsystem_rule :
          contains(["unspecified", "is", "is_not", "start_with", "includes"], rule.rule_type_id)]))
          : true
    )])
    error_message = "Identifier of subsystem_rule 'rule_type_id' is not a valid selection. Allowed values are: unspecified, is, is_not, start_with, includes."
  }

  validation {
    condition = alltrue(
      [for config in var.policies :
        (config.subsystem_rule != null ?
          (alltrue([for rule in config.subsystem_rule :
          can(regex("^[\\p{L}\\p{N}\\p{P}\\p{Z}\\p{S}\\p{M}]+$", rule.name)) && length(rule.name) <= 4096 && length(rule.name) > 1]))
        : true)
    ])
    error_message = "The name of the subsytem_rule does not meet the required criteria."
  }

  validation {
    condition = alltrue(
      [for config in var.policies :
        (config.archive_retention != null ?
          (alltrue(
            [for rule in config.archive_retention : can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", rule.id))]
          )) : true
    )])
    error_message = "The id of the archive_retention does not meet the required criteria."
  }
}
