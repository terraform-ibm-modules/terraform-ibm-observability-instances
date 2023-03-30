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

variable "enable_archive" {
  type        = bool
  description = "Enable archive on logDNA and Activity Tracker instances"
  default     = false
}

variable "ibmcloud_api_key" {
  type        = string
  description = "Only required to archive. The IBM Cloud API Key."
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
  description = "The name of the IBM Cloud Logging instance to create. Defaults to 'logdna-<region>'"
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
  default     = "LogAnalysisManagerKey"
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
  description = "The ID of the cloud object storage instance containing the Log Analysis archive bucket. (Only required when var.enable_archive and var.log_analysis_provision are true)."
  default     = null
}

variable "log_analysis_cos_bucket_name" {
  type        = string
  description = "The name of an existing COS bucket to be used for the Log Analysis archive. (Only required when var.enable_archive and var.log_analysis_provision are true)."
  default     = null
}

variable "log_analysis_cos_bucket_endpoint" {
  type        = string
  description = "An endpoint for the COS bucket for the Log Analysis archive. Pass either the public or private endpoint. (Only required when var.enable_archive and var.log_analysis_provision are true)."
  default     = null
}

##############################################################################

# IBM Cloud Monitoring
variable "cloud_monitoring_provision" {
  description = "Provision a Sysdig instance?"
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
  description = "The IBM Cloud Monitoring plan to provision. Available: lite, graduated-tier, graduated-tier-sysdig-secure-plus-monitor"
  default     = "lite"

  validation {
    condition     = can(regex("^lite$|^graduated-tier$|^graduated-tier-sysdig-secure-plus-monitor$", var.cloud_monitoring_plan))
    error_message = "The cloud_monitoring_plan value must be one of the following: lite, graduated-tier, graduated-tier-sysdig-secure-plus-monitor."
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

variable "enable_platform_metrics" {
  type        = bool
  description = "Receive platform metrics in the provisioned IBM Cloud Monitoring instance."
  default     = true
}

variable "cloud_monitoring_service_endpoints" {
  description = "The type of the service endpoint that will be set for the Sisdig instance."
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
  description = "The ID of the cloud object storage instance containing the Activity Tracker archive bucket (Only required when var.enable_archive and var.activity_tracker_provision are true)."
  default     = null
}

variable "at_cos_bucket_name" {
  type        = string
  description = "The name of an existing COS bucket to be used for the Activity Tracker archive (Only required when var.enable_archive and var.activity_tracker_provision are true)."
  default     = null
}

variable "at_cos_bucket_endpoint" {
  type        = string
  description = "An endpoint for the COS bucket for the Activity Tracker archive. Pass either the public or private endpoint (Only required when var.enable_archive and var.activity_tracker_provision are true)"
  default     = null
}

########################################################################
# Activity Tracker Event Routing
#########################################################################
# COS Targets
variable "cos_targets" {
  type = list(object({
    endpoint                   = string
    bucket_name                = string
    instance_id                = string
    api_key                    = optional(string)
    service_to_service_enabled = optional(bool, false)
    target_region              = optional(string)
    target_name                = string
  }))
  default     = []
  description = "List of cos target to be created"
}

# Event Streams Targets
variable "eventstreams_targets" {
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
}

# logDNA Targets
variable "logdna_targets" {
  type = list(object({
    instance_id   = string
    ingestion_key = string
    target_region = optional(string)
    target_name   = string
  }))
  default     = []
  description = "List of logdna target to be created"
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
