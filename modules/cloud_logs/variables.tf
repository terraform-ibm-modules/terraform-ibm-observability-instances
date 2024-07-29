variable "region" {
  description = "The region where observability resources are created."
  type        = string
  default     = "eu-es"
}

variable "resource_group_id" {
  type        = string
  description = "The id of the IBM Cloud resource group where the instance(s) will be created."
  default     = null
}

variable "cloud_logs_provision" {
  description = "Provision an IBM Cloud Logs instance?"
  type        = bool
  default     = true
}

variable "instance_name" {
  type        = string
  description = "The name of the IBM Cloud Logs instance to create. Defaults to 'cloud_logs-<region>'"
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
    error_message = "The cloud_logs_plan value must be one of the following: standard."
  }
}

variable "tags" {
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
  description = "The number of days IBM Cloud Logs will retain the logs data in Priority insights."
  default     = 7
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
  description = "The type of the service endpoint that will be set for the IBM Cloud Logs instance."
  type        = string
  default     = "public-and-private"
  validation {
    condition     = contains(["public", "private", "public-and-private"], var.service_endpoints)
    error_message = "The specified service_endpoints is not a valid selection"
  }
}

##############################################################################
# Event Notification
##############################################################################

variable "existing_en_instances" {
  type = list(object({
    en_instance_id      = string
    en_region           = string
    en_instance_name    = optional(string)
    source_id           = optional(string)
    source_name         = optional(string)
    skip_en_auth_policy = optional(bool, false)
  }))
  default     = []
  description = "List of Event Notifications instance details for routing critical events that occur in your IBM Cloud Logs"
}
