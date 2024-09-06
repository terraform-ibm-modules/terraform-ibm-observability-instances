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
}

variable "log_analysis_enable_archive" {
  type        = bool
  description = "Enable archive on log analysis instances"
  default     = false
}

variable "activity_tracker_enable_archive" {
  type        = bool
  description = "Enable archive on activity tracker instances"
  default     = false
}
variable "ibmcloud_api_key" {
  type        = string
  description = "Restricted IBM Cloud API Key used only for writing Log Analysis archives to Cloud Object Storage"
  default     = null
  sensitive   = true
}

##############################################################################

# Log Analysis
variable "log_analysis_provision" {
  description = "Provision an IBM Cloud Logging instance?"
  type        = bool
  default     = true
}

variable "log_analysis_instance_name" {
  type        = string
  description = "The name of the IBM Cloud Logging instance to create. Defaults to 'log-analysis-<region>'"
  default     = null
}

variable "log_analysis_plan" {
  type        = string
  description = "The IBM Cloud Logging plan to provision. Available: lite, 7-day, 14-day, 30-day, hipaa-30-day"
  default     = "lite"

  validation {
    condition     = can(regex("^lite$|^7-day$|^14-day$|^30-day$|^hipaa-30-day$", var.log_analysis_plan))
    error_message = "The log_analysis_plan value must be one of the following: lite, 7-day, 14-day, 30-day, hipaa-30-day."
  }
}

variable "log_analysis_manager_key_name" {
  type        = string
  description = "The name to give the IBM Cloud Logging manager key."
  default     = "LogDnaManagerKey"
}

variable "log_analysis_resource_key_role" {
  type        = string
  description = "Role assigned to provide the IBM Cloud Logging key."
  default     = "Manager"

  validation {
    condition     = contains(["Manager", "Reader", "Standard Member"], var.log_analysis_resource_key_role)
    error_message = "Allowed roles can be Manager, Reader or Standard Member."
  }
}

variable "log_analysis_manager_key_tags" {
  type        = list(string)
  description = "Tags associated with the IBM Cloud Logging manager key."
  default     = []
}

variable "log_analysis_tags" {
  type        = list(string)
  description = "Tags associated with the IBM Cloud Logging instance (Optional, array of strings)."
  default     = []
}

variable "log_analysis_access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the Log Analysis instance created by the module. For more information, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial."
  default     = []

  validation {
    condition = alltrue([
      for tag in var.log_analysis_access_tags : can(regex("[\\w\\-_\\.]+:[\\w\\-_\\.]+", tag)) && length(tag) <= 128
    ])
    error_message = "Tags must match the regular expression \"[\\w\\-_\\.]+:[\\w\\-_\\.]+\". For more information, see https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#limits."
  }
}

variable "enable_platform_logs" {
  type        = bool
  description = "Receive platform logs in the provisioned IBM Cloud Logging instance."
  default     = true
}

variable "log_analysis_service_endpoints" {
  description = "The type of the service endpoint that will be set for the Log Analysis instance."
  type        = string
  default     = "public-and-private"
  validation {
    condition     = contains(["public", "private", "public-and-private"], var.log_analysis_service_endpoints)
    error_message = "The specified service_endpoints is not a valid selection"
  }
}

variable "log_analysis_cos_instance_id" {
  type        = string
  description = "The ID of the cloud object storage instance containing the Log Analysis archive bucket. (Only required when var.log_analysis_enable_archive and var.log_analysis_provision are true)."
  default     = null
}

variable "log_analysis_cos_bucket_name" {
  type        = string
  description = "The name of an existing COS bucket to be used for the Log Analysis archive. (Only required when var.log_analysis_enable_archive and var.log_analysis_provision are true)."
  default     = null
}

variable "log_analysis_cos_bucket_endpoint" {
  type        = string
  description = "An endpoint for the COS bucket for the Log Analysis archive. Pass either the public or private endpoint. (Only required when var.log_analysis_enable_archive and var.log_analysis_provision are true)."
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
  description = "The type of the service endpoint that will be set for the IBM cloud monitoring instance."
  type        = string
  default     = "public-and-private"
  validation {
    condition     = contains(["public", "private", "public-and-private"], var.cloud_monitoring_service_endpoints)
    error_message = "The specified service_endpoints is not a valid selection"
  }
}

##############################################################################

# Activity Tracker
variable "activity_tracker_provision" {
  description = "Provision an Activity Tracker instance?"
  type        = bool
  default     = true
}

variable "activity_tracker_instance_name" {
  type        = string
  description = "The name of the Activity Tracker instance to create. Defaults to 'activity-tracker-<region>'"
  default     = null
}

variable "activity_tracker_plan" {
  type        = string
  description = "The Activity Tracker plan to provision. Available: lite, 7-day, 14-day, 30-day, hipaa-30-day"
  default     = "lite"

  validation {
    condition     = can(regex("^lite$|^7-day$|^14-day$|^30-day$|^hipaa-30-day$", var.activity_tracker_plan))
    error_message = "The activity_tracker_plan value must be one of the following: lite, 7-day, 14-day, 30-day, hipaa-30-day."
  }
}

variable "activity_tracker_manager_key_name" {
  type        = string
  description = "The name to give the Activity Tracker manager key."
  default     = "AtManagerKey"
}

variable "activity_tracker_manager_key_tags" {
  type        = list(string)
  description = "Tags associated with the Activity Tracker manager key."
  default     = []
}

variable "activity_tracker_tags" {
  type        = list(string)
  description = "Tags associated with the Activity Tracker instance (Optional, array of strings)."
  default     = []
}

variable "activity_tracker_access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the Activity Tracker instance created by the module. For more information, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial."
  default     = []

  validation {
    condition = alltrue([
      for tag in var.activity_tracker_access_tags : can(regex("[\\w\\-_\\.]+:[\\w\\-_\\.]+", tag)) && length(tag) <= 128
    ])
    error_message = "Tags must match the regular expression \"[\\w\\-_\\.]+:[\\w\\-_\\.]+\". For more information, see https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#limits."
  }
}

variable "activity_tracker_service_endpoints" {
  description = "The type of the service endpoint that will be set for the activity tracker instance."
  type        = string
  default     = "public-and-private"
  validation {
    condition     = contains(["public", "private", "public-and-private"], var.activity_tracker_service_endpoints)
    error_message = "The specified service_endpoints is not a valid selection"
  }
}

variable "at_cos_instance_id" {
  type        = string
  description = "The ID of the cloud object storage instance containing the Activity Tracker archive bucket (Only required when var.activity_tracker_enable_archive and var.activity_tracker_provision are true)."
  default     = null
}

variable "at_cos_bucket_name" {
  type        = string
  description = "The name of an existing COS bucket to be used for the Activity Tracker archive (Only required when var.activity_tracker_enable_archive and var.activity_tracker_provision are true)."
  default     = null
}

variable "at_cos_bucket_endpoint" {
  type        = string
  description = "An endpoint for the COS bucket for the Activity Tracker archive. Pass either the public or private endpoint (Only required when var.activity_tracker_enable_archive and var.activity_tracker_provision are true)"
  default     = null
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

# Log Analysis Targets
variable "at_log_analysis_targets" {
  type = list(object({
    instance_id   = string
    ingestion_key = string
    target_region = optional(string)
    target_name   = string
  }))
  default     = []
  description = "List of log analysis target to be created"
  sensitive   = true
}

# Cloud Logs Targets
variable "at_cloud_logs_targets" {
  type = list(object({
    instance_id   = string
    target_region = optional(string)
    target_name   = string
  }))
  default     = []
  description = "List of cloud logs target to be created"
  sensitive   = true
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
  description = "Provision a IBM Cloud Logs instance?"
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

variable "cloud_logs_region" {
  description = "The IBM Cloud region where Cloud Logs instances will be created."
  type        = string
  default     = null
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
    condition     = contains(["public", "private", "public-and-private"], var.cloud_logs_service_endpoints)
    error_message = "The specified service_endpoints is not a valid selection"
  }
}

variable "cloud_logs_retention_period" {
  type        = number
  description = "The number of days IBM Cloud Logs will retain the logs data in Priority insights."
  default     = 7
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
##############################################################################
