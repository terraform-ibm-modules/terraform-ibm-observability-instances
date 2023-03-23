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

# COS Target
variable "cos_target" {
  type = object({
    cos_endpoint = object({
      endpoint                   = string
      bucket_name                = string
      target_crn                 = string
      api_key                    = optional(string)
      service_to_service_enabled = optional(bool, false)
    })
    target_name           = string
    route_name            = string
    target_region         = optional(string)
    regions_targeting_cos = list(string)
  })
  default     = null
  description = <<EOT
    cos_target = {
      cos_endpoint: "(Object) Property values for COS Endpoint"
      target_name: "(String) The name of the COS target."
      route_name: "(String) The name of the COS route."
      target_region: "(String) Region where is COS target is created, include this field if you want to create a target in a different region other than the one you are connected"
      regions_targeting_logdna: (List) Route the events generated in these regions to COS target"
    }
  EOT

  validation {
    condition     = var.cos_target == null ? true : var.cos_target.cos_endpoint.service_to_service_enabled == false && var.cos_target.cos_endpoint.api_key != null
    error_message = "Api key is required if service_to_service authorization is not enabled"
  }

  validation {
    condition = anytrue([
      var.cos_target == null,
      alltrue([
        can(length(var.cos_target.target_name) >= 1),
        can(length(var.cos_target.target_name) <= 1000),
        can(regex("^[a-zA-Z0-9 -._:]+$", var.cos_target.target_name))
      ])
    ])
    error_message = "The target name must be 1000 characters or less, and cannot include any special characters other than (space) - . _ :."
  }

  validation {
    condition = anytrue([
      var.cos_target == null,
      alltrue([
        can(length(var.cos_target.route_name) >= 1),
        can(length(var.cos_target.route_name) <= 1000),
        can(regex("^[a-zA-Z0-9 -._:]+$", var.cos_target.route_name))
      ])
    ])
    error_message = "The route name must be 1000 characters or less, and cannot include any special characters other than (space) - . _ :."
  }

  validation {
    condition = var.cos_target == null ? true : anytrue([
      var.cos_target.target_region == null,
      alltrue([
        can(length(var.cos_target.target_region) >= 3),
        can(length(var.cos_target.target_region) <= 1000),
        can(regex("^[a-zA-Z0-9 -._:]+$", var.cos_target.target_region))
      ])
    ])
    error_message = "The target region must be between 3 and 1000 characters, and cannot include any special characters other than (space) - . _ :."
  }
}

# Event Streams Target
variable "eventstreams_target" {
  type = object({
    eventstreams_endpoint = object({
      target_crn = string
      brokers    = list(string)
      topic      = string
      api_key    = string
    })
    target_name                    = string
    route_name                     = string
    target_region                  = optional(string)
    regions_targeting_eventstreams = list(string)
  })
  default     = null
  description = <<EOT
    eventstreams_target = {
      eventstreams_endpoint: "(Object) Property values for event streams Endpoint"
      target_name: "(String) The name of the event streams target."
      route_name: "(String) The name of the event streams route."
      target_region: "(String) Region where is event streams target is created, include this field if you want to create a target in a different region other than the one you are connected"
      regions_targeting_logdna: (List) Route the events generated in these regions to event streams target"
    }
  EOT

  validation {
    condition = anytrue([
      var.eventstreams_target == null,
      alltrue([
        can(length(var.eventstreams_target.target_name) >= 1),
        can(length(var.eventstreams_target.target_name) <= 1000),
        can(regex("^[a-zA-Z0-9 -._:]+$", var.eventstreams_target.target_name))
      ])
    ])
    error_message = "The target name must be 1000 characters or less, and cannot include any special characters other than (space) - . _ :."
  }

  validation {
    condition = anytrue([
      var.eventstreams_target == null,
      alltrue([
        can(length(var.eventstreams_target.route_name) >= 1),
        can(length(var.eventstreams_target.route_name) <= 1000),
        can(regex("^[a-zA-Z0-9 -._:]+$", var.eventstreams_target.route_name))
      ])
    ])
    error_message = "The route name must be 1000 characters or less, and cannot include any special characters other than (space) - . _ :."
  }

  validation {
    condition = var.eventstreams_target == null ? true : anytrue([
      var.eventstreams_target.target_region == null,
      alltrue([
        can(length(var.eventstreams_target.target_region) >= 3),
        can(length(var.eventstreams_target.target_region) <= 1000),
        can(regex("^[a-zA-Z0-9 -._:]+$", var.eventstreams_target.target_region))
      ])
    ])
    error_message = "The target region must be between 3 and 1000 characters, and cannot include any special characters other than (space) - . _ :."
  }
}

# logDNA Target
variable "logdna_target" {
  type = object({
    logdna_endpoint = object({
      target_crn    = string
      ingestion_key = string
    })
    target_name              = string
    route_name               = string
    target_region            = optional(string)
    regions_targeting_logdna = list(string)
  })
  default     = null
  description = <<EOT
    logdna_target = {
      logdna_endpoint: "(Object) Property values for LogDNA Endpoint"
      target_name: "(String) The name of the logDNA target."
      route_name: "(String) The name of the LogDNA route."
      target_region: "(String) Region where is LogDNA target is created, include this field if you want to create a target in a different region other than the one you are connected"
      regions_targeting_logdna: (List) Route the events generated in these regions to LogDNA target"
    }
  EOT

  validation {
    condition = anytrue([
      var.logdna_target == null,
      alltrue([
        can(length(var.logdna_target.target_name) >= 1),
        can(length(var.logdna_target.target_name) <= 1000),
        can(regex("^[a-zA-Z0-9 -._:]+$", var.logdna_target.target_name))
      ])
    ])
    error_message = "The target name must be 1000 characters or less, and cannot include any special characters other than (space) - . _ :."
  }

  validation {
    condition = anytrue([
      var.logdna_target == null,
      alltrue([
        can(length(var.logdna_target.route_name) >= 1),
        can(length(var.logdna_target.route_name) <= 1000),
        can(regex("^[a-zA-Z0-9 -._:]+$", var.logdna_target.route_name))
      ])
    ])
    error_message = "The route name must be 1000 characters or less, and cannot include any special characters other than (space) - . _ :."
  }

  validation {
    condition = var.logdna_target == null ? true : anytrue([
      var.logdna_target.target_region == null,
      alltrue([
        can(length(var.logdna_target.target_region) >= 3),
        can(length(var.logdna_target.target_region) <= 1000),
        can(regex("^[a-zA-Z0-9 -._:]+$", var.logdna_target.target_region))
      ])
    ])
    error_message = "The target region must be between 3 and 1000 characters, and cannot include any special characters other than (space) - . _ :."
  }
}

# Event Routing Setting
variable "default_targets" {
  type        = list(string)
  description = "The target ID List. In the event that no routing rule causes the event to be sent to a target, these targets will receive the event"
  default     = []
}

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
