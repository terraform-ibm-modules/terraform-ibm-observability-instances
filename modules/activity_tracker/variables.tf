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
  description = "Enable archive on Activity Tracker instances"
  default     = false
}

variable "ibmcloud_api_key" {
  type        = string
  description = "Only required to archive. The IBM Cloud API Key."
  default     = null
  sensitive   = true
}

variable "activity_tracker_provision" {
  description = "Provision an Activity Tracker instance?"
  type        = bool
  default     = true
}

variable "instance_name" {
  type        = string
  description = "The name of the Activity Tracker instance to create. Defaults to 'activity-tracker-<region>'"
  default     = null
}

variable "plan" {
  type        = string
  description = "The Activity Tracker plan to provision. Available: lite, 7-day, 14-day, 30-day, hipaa-30-day"
  default     = "lite"

  validation {
    condition     = can(regex("^lite$|^7-day$|^14-day$|^30-day$|^hipaa-30-day$", var.plan))
    error_message = "The plan value must be one of the following: lite, 7-day, 14-day, 30-day, hipaa-30-day."
  }
}

variable "manager_key_name" {
  type        = string
  description = "The name to give the Activity Tracker manager key."
  default     = "AtManagerKey"
}

variable "manager_key_tags" {
  type        = list(string)
  description = "Tags associated with the Activity Tracker manager key."
  default     = []
}

variable "tags" {
  type        = list(string)
  description = "Tags associated with the Activity Tracker instance (Optional, array of strings)."
  default     = []
}

variable "access_tags" {
  type        = list(string)
  description = "Access Management Tags associated with the Activity Tracker instance (Optional, array of strings)."
  default     = []
}

variable "service_endpoints" {
  description = "The type of the service endpoint that will be set for the activity tracker instance."
  type        = string
  default     = "public-and-private"
  validation {
    condition     = contains(["public", "private", "public-and-private"], var.service_endpoints)
    error_message = "The specified service_endpoints is not a valid selection"
  }
}

variable "cos_instance_id" {
  type        = string
  description = "The ID of the cloud object storage instance containing the archive bucket (Only required when var.enable_archive and var.activity_tracker_provision are true)."
  default     = null
}

variable "cos_bucket_name" {
  type        = string
  description = "The name of an existing COS bucket to be used for the archive (Only required when var.enable_archive and var.activity_tracker_provision are true)."
  default     = null
}

variable "cos_bucket_endpoint" {
  type        = string
  description = "An endpoint for the COS bucket for the archive. Pass either the public or private endpoint (Only required when var.enable_archive and var.activity_tracker_provision are true)"
  default     = null
}

########################################################################
# Activity Tracker Event Routing
#########################################################################

# COS Targets
variable "cos_targets" {
  type = list(object({
    endpoint                          = string
    bucket_name                       = string
    instance_id                       = string
    api_key                           = optional(string)
    service_to_service_enabled        = optional(bool, true)
    target_region                     = optional(string)
    target_name                       = string
    skip_atracker_cos_iam_auth_policy = optional(bool, false)
  }))
  default     = []
  description = "List of cos target to be created"
  sensitive   = true

  validation {
    condition     = alltrue([for cos_target in var.cos_targets : (cos_target.service_to_service_enabled == true && cos_target.api_key == null) || (cos_target.service_to_service_enabled == false && cos_target.api_key != null)])
    error_message = "If 'service_to_service_enabled' is true, 'api_key' value should not be passed. If you wish to use 'api_key', set 'service_to_service_enabled' to false."
  }
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

# log Analysis Targets
variable "log_analysis_targets" {
  type = list(object({
    instance_id   = string
    ingestion_key = string
    target_region = optional(string)
    target_name   = string
  }))
  default     = []
  description = "List of log analysis target to be created"
  sensitive   = true
}

# Routes
variable "activity_tracker_routes" {
  type = list(object({
    locations  = list(string)
    target_ids = list(string)
    route_name = string
  }))
  description = "List of routes to be created, maximum four routes are allowed"
  default     = []

  validation {
    condition     = length(var.activity_tracker_routes) <= 4
    error_message = "Number of routes should be less than or equal to 4"
  }

  validation {
    condition     = alltrue([for activity_tracker_route in var.activity_tracker_routes : length(activity_tracker_route.locations) > 0])
    error_message = "Length of locations can not be zero"
  }

  validation {
    condition     = alltrue([for activity_tracker_route in var.activity_tracker_routes : length(activity_tracker_route.target_ids) > 0])
    error_message = "Length of target_ids can not be zero"
  }
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

  # https://cloud.ibm.com/docs/atracker?topic=atracker-regions#regions-atracker
  validation {
    error_message = "Valid regions for permitted_target_regions are: [eu-gb eu-de au-syd us-east us-south eu-es]"
    condition = (var.global_event_routing_settings == null ?
      true :
      alltrue([
        for region in var.global_event_routing_settings.permitted_target_regions :
        contains(["eu-gb", "eu-de", "au-syd", "us-east", "us-south", "eu-es"], region)
      ])
    )
  }
}
