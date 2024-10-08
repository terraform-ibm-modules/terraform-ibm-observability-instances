##############################################################################
# Input Variables
##############################################################################

# Common
variable "region" {
  type        = string
  description = "The IBM Cloud region where instances will be created."
  default     = "us-south"
}

variable "resource_group_id" {
  type        = string
  description = "The id of the IBM Cloud resource group where the instance(s) will be created."
  default     = null
}

##############################################################################

# IBM Cloud Monitoring
variable "cloud_monitoring_provision" {
  description = "Provision a IBM cloud monitoring instance?"
  type        = bool
  default     = true
}

variable "cloud_monitoring_instance_name" {
  type        = string
  description = "The name of the IBM Cloud Monitoring instance to create. Defaults to 'cloud_monitoring-<region>'"
  default     = null
}

variable "cloud_monitoring_plan" {
  type        = string
  description = "The IBM Cloud Monitoring plan to provision. Available: lite, graduated-tier"
  default     = "lite"

  validation {
    condition     = can(regex("^lite$|^graduated-tier$", var.cloud_monitoring_plan))
    error_message = "The cloud_monitoring_plan value must be one of the following: lite, graduated-tier."
  }
}

variable "cloud_monitoring_manager_key_name" {
  type        = string
  description = "The name to give the IBM Cloud Monitoring manager key."
  default     = "SysdigManagerKey"
}

variable "cloud_monitoring_manager_key_tags" {
  type        = list(string)
  description = "Tags associated with the IBM Cloud Monitoring manager key."
  default     = []
}

variable "cloud_monitoring_tags" {
  type        = list(string)
  description = "Tags associated with the IBM Cloud Monitoring instance (Optional, array of strings)."
  default     = []
}

variable "cloud_monitoring_access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the Cloud Monitoring instance created by the module. For more information, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial."
  default     = []

  validation {
    condition = alltrue([
      for tag in var.cloud_monitoring_access_tags : can(regex("[\\w\\-_\\.]+:[\\w\\-_\\.]+", tag)) && length(tag) <= 128
    ])
    error_message = "Tags must match the regular expression \"[\\w\\-_\\.]+:[\\w\\-_\\.]+\". For more information, see https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#limits."
  }
}

variable "enable_platform_metrics" {
  type        = bool
  description = "Receive platform metrics in the provisioned IBM Cloud Monitoring instance."
  default     = true
}

variable "cloud_monitoring_service_endpoints" {
  description = "The type of the service endpoint that will be set for the IBM Cloud Monitoring instance. Allowed values: public-and-private"
  type        = string
  default     = "public-and-private"
  validation {
    condition     = contains(["public-and-private"], var.cloud_monitoring_service_endpoints)
    error_message = "The specified service_endpoints is not a valid selection. Allowed values: public-and-private"
  }
}

########################################################################
# Activity Tracker Event Routing
#########################################################################
# COS Targets
variable "at_cos_targets" {
  type = list(object({
    endpoint                          = string
    bucket_name                       = string
    instance_id                       = string
    api_key                           = optional(string)
    service_to_service_enabled        = optional(bool, true)
    target_region                     = optional(string)
    target_name                       = string
    skip_atracker_cos_iam_auth_policy = optional(bool, false)
  }))
  default     = []
  description = "List of cos target to be created"
  sensitive   = true
}

# Event Streams Targets
variable "at_eventstreams_targets" {
  type = list(object({
    instance_id   = string
    brokers       = list(string)
    topic         = string
    api_key       = string
    target_region = optional(string)
    target_name   = string
  }))
  default     = []
  description = "List of event streams target to be created"
  sensitive   = true
}

# Cloud Logs Targets
variable "at_cloud_logs_targets" {
  type = list(object({
    instance_id                              = string
    target_region                            = optional(string)
    target_name                              = string
    skip_atracker_cloud_logs_iam_auth_policy = optional(bool, false)
  }))
  default     = []
  description = "List of Cloud Logs targets to be created"
}

# Routes
variable "activity_tracker_routes" {
  type = list(object({
    locations  = list(string)
    target_ids = list(string)
    route_name = string
  }))
  default     = []
  description = "List of routes to be created, maximum four routes are allowed"
}

# Event Routing Setting
variable "global_event_routing_settings" {
  type = object({
    default_targets           = optional(list(string), [])
    metadata_region_primary   = string
    metadata_region_backup    = optional(string)
    permitted_target_regions  = list(string)
    private_api_endpoint_only = optional(bool, false)
  })
  description = "Global settings for event routing"
  default     = null
}

##############################################################################

# IBM Cloud Logs
variable "cloud_logs_provision" {
  description = "Provision an IBM Cloud Logs instance?"
  type        = bool
  default     = true
}

variable "cloud_logs_instance_name" {
  type        = string
  description = "The name of the IBM Cloud Logs instance to create. Defaults to 'cloud_logs-<region>'"
  default     = null
}

variable "cloud_logs_plan" {
  type        = string
  description = "The IBM Cloud Logs plan to provision. Available: standard"
  default     = "standard"
}

variable "cloud_logs_tags" {
  type        = list(string)
  description = "Tags associated with the IBM Cloud Logs instance (Optional, array of strings)."
  default     = []
}

variable "cloud_logs_access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the IBM Cloud Logs instance created by the module. For more information, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial."
  default     = []

  validation {
    condition = alltrue([
      for tag in var.cloud_logs_access_tags : can(regex("[\\w\\-_\\.]+:[\\w\\-_\\.]+", tag)) && length(tag) <= 128
    ])
    error_message = "Tags must match the regular expression \"[\\w\\-_\\.]+:[\\w\\-_\\.]+\". For more information, see https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#limits."
  }
}

variable "cloud_logs_service_endpoints" {
  description = "The type of the service endpoint that will be set for the IBM Cloud Logs instance."
  type        = string
  default     = "public-and-private"
  validation {
    condition     = contains(["public-and-private"], var.cloud_logs_service_endpoints)
    error_message = "The specified service_endpoints is not a valid selection"
  }
}

variable "cloud_logs_retention_period" {
  type        = number
  description = "The number of days IBM Cloud Logs will retain the logs data in Priority insights. Allowed values: 7, 14, 30, 60, 90."
  default     = 7

  validation {
    condition     = contains([7, 14, 30, 60, 90], var.cloud_logs_retention_period)
    error_message = "Valid values 'cloud_logs_retention_period' are: 7, 14, 30, 60, 90"
  }
}

variable "cloud_logs_existing_en_instances" {
  type = list(object({
    en_instance_id      = string
    en_region           = string
    en_integration_name = optional(string)
    skip_en_auth_policy = optional(bool, false)
  }))
  default     = []
  description = "List of Event Notifications instance details for routing critical events that occur in your IBM Cloud Logs."
}

variable "cloud_logs_data_storage" {
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
  description = "A logs data bucket and a metrics bucket in IBM Cloud Object Storage to store your IBM Cloud Logs data for long term storage, search, analysis and alerting."
}

variable "skip_logs_routing_auth_policy" {
  description = "Whether to create an IAM authorization policy that permits Logs Routing Sender access to the IBM Cloud Logs."
  type        = bool
  default     = false
}

variable "enable_platform_logs" {
  type        = bool
  description = "Setting this to true will create a tenant in the same region that the Cloud Logs instance is provisioned to enable platform logs for that region. To send platform logs from other regions, you can explicitially specify a list of regions using the `logs_routing_tenant_regions` input. NOTE: You can only have 1 tenant per region in an account."
  default     = true
}

variable "logs_routing_tenant_regions" {
  type        = list(any)
  default     = []
  description = "Pass a list of regions to create a tenant for that is targetted to the Cloud Logs instance created by this module. To manage platform logs that are generated by IBM Cloud® services in a region of IBM Cloud, you must create a tenant in each region that you operate. Leave the list empty if you don't want to create any tenants."
  nullable    = false
}

##############################################################################
