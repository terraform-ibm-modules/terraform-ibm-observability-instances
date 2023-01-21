variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Token"
  sensitive   = true
}

variable "prefix" {
  type        = string
  description = "Prefix for name of all resource created by this example"
  default     = "test-all-observability-instances"
}

variable "enable_platform_metrics" {
  type        = bool
  description = "Enable platform metrics"
  default     = true
}

variable "enable_platform_logs" {
  type        = bool
  description = "Enable platform logs"
  default     = true
}

variable "region" {
  description = "Region where resources will be created"
  type        = string
  default     = "us-east"
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
}

variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example, if unset a new resource group will be created"
  default     = null
}

variable "logdna_plan" {
  type        = string
  description = "The LogDNA plan to provision. Available: lite, 7-day, 14-day, 30-day, hipaa-30-day"
  default     = "lite"
}

variable "sysdig_plan" {
  type        = string
  description = "The Sysdig plan to provision. Available: lite, graduated-tier, graduated-tier-sysdig-secure-plus-monitor"
  default     = "lite"
}

variable "activity_tracker_plan" {
  type        = string
  description = "The Activity Tracker plan to provision. Available: lite, 7-day, 14-day, 30-day, hipaa-30-day"
  default     = "lite"
}

#Activity Tracker Event Routing
variable "cos_target_region" {
  type        = string
  description = "The region cos target is to be created on"
  default     = null
}

variable "logdna_target_region" {
  type        = string
  description = "The region logDNA target is to be created on"
  default     = null
}

variable "eventstreams_target_region" {
  type        = string
  description = "The region event streams target is to be created on"
  default     = null
}
