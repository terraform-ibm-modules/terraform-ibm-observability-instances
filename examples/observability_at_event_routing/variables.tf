variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Token"
  sensitive   = true
}

variable "prefix" {
  type        = string
  description = "Prefix for name of all resource created by this example"
  default     = "test-observability-at-instance"
}

variable "region" {
  description = "Region where resources will be created"
  type        = string
  default     = "eu-gb"
}

variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example, if unset a new resource group will be created"
  default     = null
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
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

##############################################################################

#Event Routing Setting
variable "metadata_region_primary" {
  type        = string
  description = "Primary region to store all your meta data."
  default     = "us-south"
}

variable "metadata_region_backup" {
  type        = string
  description = "Backup region to store all your meta data in a ."
  default     = "us-east"
}

variable "permitted_target_regions" {
  type        = list(string)
  description = "List of regions where target can be defined."
  default     = ["us-south", "eu-de", "us-east", "eu-gb", "au-syd"]
}

variable "private_api_endpoint_only" {
  type        = bool
  description = "Set this true to restrict access only to private api endpoint."
  default     = false
}
