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
  description = "Restricted IBM Cloud API Key used only for writing Log Analysis archives to Cloud Object Storage"
  default     = null
  sensitive   = true
}

##############################################################################

# LogDNA
variable "logdna_provision" {
  description = "Provision an IBM Cloud Logging instance?"
  type        = bool
  default     = true
}

variable "logdna_instance_name" {
  type        = string
  description = "The name of the IBM Cloud Logging instance to create. Defaults to 'logdna-<region>'"
  default     = null
}

variable "logdna_plan" {
  type        = string
  description = "The IBM Cloud Logging plan to provision. Available: lite, 7-day, 14-day, 30-day, hipaa-30-day"
  default     = "lite"

  validation {
    condition     = can(regex("^lite$|^7-day$|^14-day$|^30-day$|^hipaa-30-day$", var.logdna_plan))
    error_message = "The logdna_plan value must be one of the following: lite, 7-day, 14-day, 30-day, hipaa-30-day."
  }
}

variable "logdna_manager_key_name" {
  type        = string
  description = "The name to give the IBM Cloud Logging manager key."
  default     = "LogDnaManagerKey"
}

variable "logdna_resource_key_role" {
  type        = string
  description = "Role assigned to provide the IBM Cloud Logging key."
  default     = "Manager"

  validation {
    condition     = contains(["Manager", "Reader", "Standard Member"], var.logdna_resource_key_role)
    error_message = "Allowed roles can be Manager, Reader or Standard Member."
  }
}

variable "logdna_manager_key_tags" {
  type        = list(string)
  description = "Tags associated with the IBM Cloud Logging manager key."
  default     = []
}

variable "logdna_tags" {
  type        = list(string)
  description = "Tags associated with the IBM Cloud Logging instance (Optional, array of strings)."
  default     = []
}

variable "logdna_access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the LogDNA instance created by the module. For more information, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial."
  default     = []

  validation {
    condition = alltrue([
      for tag in var.logdna_access_tags : can(regex("[\\w\\-_\\.]+:[\\w\\-_\\.]+", tag)) && length(tag) <= 128
    ])
    error_message = "Tags must match the regular expression \"[\\w\\-_\\.]+:[\\w\\-_\\.]+\". For more information, see https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#limits."
  }
}

variable "enable_platform_logs" {
  type        = bool
  description = "Receive platform logs in the provisioned IBM Cloud Logging instance."
  default     = true
}

variable "logdna_service_endpoints" {
  description = "The type of the service endpoint that will be set for the LogDNA instance."
  type        = string
  default     = "public-and-private"
  validation {
    condition     = contains(["public", "private", "public-and-private"], var.logdna_service_endpoints)
    error_message = "The specified service_endpoints is not a valid selection"
  }
}

variable "logdna_cos_instance_id" {
  type        = string
  description = "The ID of the cloud object storage instance containing the LogDNA archive bucket. (Only required when var.enable_archive and var.logdna_provision are true)."
  default     = null
}

variable "logdna_cos_bucket_name" {
  type        = string
  description = "The name of an existing COS bucket to be used for the LogDNA archive. (Only required when var.enable_archive and var.logdna_provision are true)."
  default     = null
}

variable "logdna_cos_bucket_endpoint" {
  type        = string
  description = "An endpoint for the COS bucket for the LogDNA archive. Pass either the public or private endpoint. (Only required when var.enable_archive and var.logdna_provision are true)."
  default     = null
}

##############################################################################

# Sysdig
variable "sysdig_provision" {
  description = "Provision a Sysdig instance?"
  type        = bool
  default     = true
}

variable "sysdig_instance_name" {
  type        = string
  description = "The name of the IBM Cloud Monitoring instance to create. Defaults to 'sysdig-<region>'"
  default     = null
}

variable "sysdig_plan" {
  type        = string
  description = "The IBM Cloud Monitoring plan to provision. Available: lite, graduated-tier, graduated-tier-sysdig-secure-plus-monitor"
  default     = "lite"

  validation {
    condition     = can(regex("^lite$|^graduated-tier$|^graduated-tier-sysdig-secure-plus-monitor$", var.sysdig_plan))
    error_message = "The sysdig_plan value must be one of the following: lite, graduated-tier, graduated-tier-sysdig-secure-plus-monitor."
  }
}

variable "sysdig_manager_key_name" {
  type        = string
  description = "The name to give the IBM Cloud Monitoring manager key."
  default     = "SysdigManagerKey"
}

variable "sysdig_manager_key_tags" {
  type        = list(string)
  description = "Tags associated with the IBM Cloud Monitoring manager key."
  default     = []
}

variable "sysdig_tags" {
  type        = list(string)
  description = "Tags associated with the IBM Cloud Monitoring instance (Optional, array of strings)."
  default     = []
}

variable "sysdig_access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the Sysdig instance created by the module. For more information, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial."
  default     = []

  validation {
    condition = alltrue([
      for tag in var.sysdig_access_tags : can(regex("[\\w\\-_\\.]+:[\\w\\-_\\.]+", tag)) && length(tag) <= 128
    ])
    error_message = "Tags must match the regular expression \"[\\w\\-_\\.]+:[\\w\\-_\\.]+\". For more information, see https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#limits."
  }
}

variable "enable_platform_metrics" {
  type        = bool
  description = "Receive platform metrics in the provisioned IBM Cloud Monitoring instance."
  default     = true
}

variable "sysdig_service_endpoints" {
  description = "The type of the service endpoint that will be set for the Sisdig instance."
  type        = string
  default     = "public-and-private"
  validation {
    condition     = contains(["public", "private", "public-and-private"], var.sysdig_service_endpoints)
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
  sensitive   = true
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
  sensitive   = true
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
