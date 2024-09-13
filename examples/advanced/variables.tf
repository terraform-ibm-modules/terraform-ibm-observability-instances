variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Token"
  sensitive   = true
}

variable "archive_api_key" {
  type        = string
  description = "Limited IBM Cloud API Token for Log Analysis archiving to COS"
  sensitive   = true
  default     = null
}

variable "prefix" {
  type        = string
  description = "Prefix for name of all resource created by this example"
}

variable "region" {
  description = "Region where resources will be created"
  type        = string
  default     = "us-south"
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

variable "access_tags" {
  type        = list(string)
  description = "Optional list of access management tags to add to resources that are created"
  default     = []
}

# Activity Tracker Event Routing
variable "atracker_target_region" {
  type        = string
  description = "Region where Event Streams, COS, Log Analysis & Cloud Log targets will be created"
  default     = null
}

# Event Routing Global Setting
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
  default     = ["us-south", "eu-de", "us-east", "eu-es", "eu-gb", "au-syd"]
}

variable "private_api_endpoint_only" {
  type        = bool
  description = "Set this true to restrict access only to private api endpoint."
  default     = false
}

variable "en_region" {
  type        = string
  description = "Region where event notification will be created"
  default     = "au-syd"
}
