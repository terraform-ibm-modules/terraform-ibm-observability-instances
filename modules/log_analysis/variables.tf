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
  description = "Enable archive on Log Analysis and Activity Tracker instances"
  default     = false
}

variable "ibmcloud_api_key" {
  type        = string
  description = "Only required to archive. The IBM Cloud API Key."
  default     = null
  sensitive   = true
}

variable "log_analysis_provision" {
  description = "Provision an IBM Cloud Logging instance?"
  type        = bool
  default     = true
}

variable "instance_name" {
  type        = string
  description = "The name of the IBM Cloud Logging instance to create. Defaults to 'log-analysis-<region>'"
  default     = null
}

variable "plan" {
  type        = string
  description = "The IBM Cloud Logging plan to provision. Available: lite, 7-day, 14-day, 30-day, hipaa-30-day"
  default     = "lite"

  validation {
    condition     = can(regex("^lite$|^7-day$|^14-day$|^30-day$|^hipaa-30-day$", var.plan))
    error_message = "The plan value must be one of the following: lite, 7-day, 14-day, 30-day, hipaa-30-day."
  }
}

variable "manager_key_name" {
  type        = string
  description = "The name to give the IBM Cloud Logging manager key."
  default     = "LogDnaManagerKey"
}

variable "manager_key_tags" {
  type        = list(string)
  description = "Tags associated with the IBM Cloud Logging manager key."
  default     = []
}

variable "tags" {
  type        = list(string)
  description = "Tags associated with the IBM Cloud Logging instance (Optional, array of strings)."
  default     = []
}

variable "enable_platform_logs" {
  type        = bool
  description = "Receive platform logs in the provisioned IBM Cloud Logging instance."
  default     = true
}

variable "service_endpoints" {
  description = "The type of the service endpoint that will be set for the LogDNA instance."
  type        = string
  default     = "public-and-private"
  validation {
    condition     = contains(["public", "private", "public-and-private"], var.service_endpoints)
    error_message = "The specified service_endpoints is not a valid selection"
  }
}

variable "resource_key_role" {
  type        = string
  description = "Role assigned to provide the IBM Cloud Logging key."
  default     = "Manager"

  validation {
    condition     = contains(["Manager", "Reader", "Standard Member"], var.resource_key_role)
    error_message = "Allowed roles can be Manager, Reader or Standard Member."
  }
}

variable "cos_instance_id" {
  type        = string
  description = "The ID of the cloud object storage instance containing the LogDNA archive bucket. (Only required when var.enable_archive and var.logdna_provision are true)."
  default     = null
}

variable "cos_bucket_name" {
  type        = string
  description = "The name of an existing COS bucket to be used for the LogDNA archive. (Only required when var.enable_archive and var.logdna_provision are true)."
  default     = null
}

variable "cos_bucket_endpoint" {
  type        = string
  description = "An endpoint for the COS bucket for the LogDNA archive. Pass either the public or private endpoint. (Only required when var.enable_archive and var.logdna_provision are true)."
  default     = null
}
