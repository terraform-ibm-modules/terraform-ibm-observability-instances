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
