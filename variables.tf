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

variable "logdna_tags" {
  type        = list(string)
  description = "Tags associated with the IBM Cloud Logging instance (Optional, array of strings)."
  default     = []
}

variable "enable_platform_logs" {
  type        = bool
  description = "Receive platform logs in the provisioned IBM Cloud Logging instance."
  default     = true
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

variable "sysdig_tags" {
  type        = list(string)
  description = "Tags associated with the IBM Cloud Monitoring instance (Optional, array of strings)."
  default     = []
}

variable "enable_platform_metrics" {
  type        = bool
  description = "Receive platform metrics in the provisioned IBM Cloud Monitoring instance."
  default     = true
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

variable "activity_tracker_tags" {
  type        = list(string)
  description = "Tags associated with the Activity Tracker instance (Optional, array of strings)."
  default     = []
}

##############################################################################

#Event Routing Setting
variable "default_targets" {
  type        = list(string)
  description = "(Optional, List) The target ID List. In the event that no routing rule causes the event to be sent to a target, these targets will receive the event."
  default     = []
}

variable "metadata_region_primary" {
  type        = string
  description = "(Required, String) To store all your meta data in a single region."
  default     = "us-south" #review later
}

variable "metadata_region_backup" {
  type        = string
  description = "(Optional, String) To store all your meta data in a backup region."
  default     = "us-east" #review later
}

variable "permitted_target_regions" {
  type        = list(string)
  description = "(Optional, List) If present then only these regions may be used to define a target."
  default     = ["us-south", "eu-de"] #remove later
}

variable "private_api_endpoint_only" {
  type        = bool
  description = "(Required, Boolean) If you set this true then you cannot access api through public network."
  default     = false
}

##############################################################################

#Event Routing Route
variable "cos_route_name" {
  type        = string
  description = "(Required, String) The name of the COS route."
  default     = null
}

variable "logdna_route_name" {
  type        = string
  description = "(Required, String) The name of the LogDNA route."
  default     = null
}

variable "eventstreams_route_name" {
  type        = string
  description = "(Required, String) The name of the Event Streams route."
  default     = null
}



##############################################################################

#COS Target
variable "cos_endpoint" {
  type = list(object({
    endpoint                   = string
    bucket_name                = string
    target_crn                 = string
    api_key                    = string
    service_to_service_enabled = bool
  }))
  description = "(Optional, List) Property values for a Cloud Object Storage Endpoint."
  default     = []
}


variable "cos_target_name" {
  type        = string
  description = "(Required, String) The name of the COS target."
  default     = null
}


variable "regions_target_cos" { # review later
  type        = list(string)
  description = "Route the events generated in regions to COS"
  default     = []
}

##############################################################################

#logDNA Target
variable "logdna_endpoint" {
  type = list(object({
    target_crn    = string
    ingestion_key = string
  }))
  description = "(Optional, List) Property values for a LogDNA Endpoint."
  default     = []
}


variable "logdna_target_name" {
  type        = string
  description = "(Required, String) The name of the logDNA target."
  default     = null
}

variable "regions_target_logdna" { # review later
  type        = list(string)
  description = "Route the events generated in regions to LogDNA"
  default     = []
}


##############################################################################

#Event Streams Target
variable "eventstreams_endpoint" {
  type = list(object({
    target_crn = string
    brokers    = list(string)
    topic      = string
    api_key    = string
  }))
  description = "(List) Property values for Event streams Endpoint"
  default     = [] ## Remove later
}

variable "eventstreams_target_name" {
  type        = string
  description = "(Required, String) The name of the logDNA target."
  default     = null
}

variable "regions_target_eventstreams" { # review later
  type        = list(string)
  description = "Route the events generated in regions to Event Streams"
  default     = []
}
