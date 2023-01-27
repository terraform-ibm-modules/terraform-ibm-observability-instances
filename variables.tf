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

variable "logdna_service_endpoints" {
  description = "The type of the service endpoint that will be set for the LogDNA instance."
  type        = string
  default     = "public-and-private"
  validation {
    condition     = contains(["public", "private", "public-and-private"], var.logdna_service_endpoints)
    error_message = "The specified service_endpoints is not a valid selection"
  }
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

##############################################################################
# Archive options, access key and information about COS bucket
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

variable "logdna_cos_instance_id" {
  type        = string
  description = "Only required to archive. The ID of the cloud object storage instance containing the bucket"
  default     = null
}

variable "logdna_cos_bucket_name" {
  type        = string
  description = "Only required to archive. The name of an existing COS bucket to be used for the LogDNA archive"
  default     = null
}

variable "logdna_cos_bucket_endpoint" {
  type        = string
  description = "Only required to archive. An endpoint for the COS bucket for the LogDNA archive. Pass either the public or private endpoint"
  default     = null
}

variable "at_cos_instance_id" {
  type        = string
  description = "Only required to archive. The ID of the cloud object storage instance containing the bucket"
  default     = null
}

variable "at_cos_bucket_name" {
  type        = string
  description = "Only required to archive. The name of an existing COS bucket to be used for the Activity Tracker archive"
  default     = null
}

variable "at_cos_bucket_endpoint" {
  type        = string
  description = "Only required to archive. An endpoint for the COS bucket for the Activity Tracker archive. Pass either the public or private endpoint"
  default     = null
}
