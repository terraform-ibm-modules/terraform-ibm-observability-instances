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
  description = "Provision a LogDNA instance?"
  type        = bool
  default     = true
}

variable "logdna_instance_name" {
  type        = string
  description = "The name of the LogDNA instance to create. Defaults to 'logdna-<region>'"
  default     = null
}

variable "logdna_plan" {
  type        = string
  description = "The LogDNA plan to provision. Available: lite, 7-day, 14-day, 30-day, hipaa-30-day"
  default     = "lite"

  validation {
    condition     = can(regex("^lite$|^7-day$|^14-day$|^30-day$|^hipaa-30-day$", var.logdna_plan))
    error_message = "The logdna_plan value must be one of the following: lite, 7-day, 14-day, 30-day, hipaa-30-day."
  }
}

variable "logdna_manager_key_name" {
  type        = string
  description = "The name to give the LogDNA manager key."
  default     = "LogDnaManagerKey"
}

variable "logdna_tags" {
  type        = list(string)
  description = "Tags associated with the LogDNA instance (Optional, array of strings)."
  default     = []
}

variable "enable_platform_logs" {
  type        = bool
  description = "Receive platform logs in LogDNA"
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
  description = "The name of the Sysdig instance to create. Defaults to 'sysdig-<region>'"
  default     = null
}

variable "sysdig_plan" {
  type        = string
  description = "The Sysdig plan to provision. Available: lite, graduated-tier, graduated-tier-sysdig-secure-plus-monitor"
  default     = "lite"

  validation {
    condition     = can(regex("^lite$|^graduated-tier$|^graduated-tier-sysdig-secure-plus-monitor$", var.sysdig_plan))
    error_message = "The sysdig_plan value must be one of the following: lite, graduated-tier, graduated-tier-sysdig-secure-plus-monitor."
  }
}

variable "sysdig_manager_key_name" {
  type        = string
  description = "The name to give the Sysdig manager key."
  default     = "SysdigManagerKey"
}

variable "sysdig_tags" {
  type        = list(string)
  description = "Tags associated with the Sysdig instance (Optional, array of strings)."
  default     = []
}

variable "enable_platform_metrics" {
  type        = bool
  description = "Receive platform metrics in Sysdig"
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
