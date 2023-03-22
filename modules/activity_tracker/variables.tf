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

##############################################################################

#COS Target
variable "cos_target" {
  type = object({
    cos_endpoint = object({
      endpoint                   = string
      bucket_name                = string
      target_crn                 = string
      api_key                    = string
      service_to_service_enabled = bool
    })
    target_name           = string
    route_name            = string
    target_region         = string
    regions_targeting_cos = list(string)
  })
  default = {
    cos_endpoint          = null
    target_name           = null
    route_name            = null
    target_region         = null
    regions_targeting_cos = null
  }
  description = <<EOT
    cos_target = {
      cos_endpoint: "(Object) Property values for COS Endpoint"
      target_name: "(String) The name of the COS target."
      route_name: "(String) The name of the COS route."
      target_region: "(String) Region where is COS target is created"
      regions_targeting_logdna: (List) Route the events generated in these regions to COS target"
    }
  EOT

  validation {
    condition = anytrue([
      var.cos_target.target_name == null,
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
      var.cos_target.route_name == null,
      alltrue([
        can(length(var.cos_target.route_name) >= 1),
        can(length(var.cos_target.route_name) <= 1000),
        can(regex("^[a-zA-Z0-9 -._:]+$", var.cos_target.route_name))
      ])
    ])
    error_message = "The route name must be 1000 characters or less, and cannot include any special characters other than (space) - . _ :."
  }
}

#Event Streams Target
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
    target_region                  = string
    regions_targeting_eventstreams = list(string)
  })
  default = {
    eventstreams_endpoint          = null
    target_name                    = null
    route_name                     = null
    target_region                  = null
    regions_targeting_eventstreams = null
  }
  description = <<EOT
    eventstreams_target = {
      eventstreams_endpoint: "(Object) Property values for event streams Endpoint"
      target_name: "(String) The name of the event streams target."
      route_name: "(String) The name of the event streams route."
      target_region: "(String) Region where is event streams target is created"
      regions_targeting_logdna: (List) Route the events generated in these regions to event streams target"
    }
  EOT

  validation {
    condition = anytrue([
      var.eventstreams_target.target_name == null,
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
      var.eventstreams_target.route_name == null,
      alltrue([
        can(length(var.eventstreams_target.route_name) >= 1),
        can(length(var.eventstreams_target.route_name) <= 1000),
        can(regex("^[a-zA-Z0-9 -._:]+$", var.eventstreams_target.route_name))
      ])
    ])
    error_message = "The route name must be 1000 characters or less, and cannot include any special characters other than (space) - . _ :."
  }
}

#logDNA Target
variable "logdna_target" {
  type = object({
    logdna_endpoint = object({
      target_crn    = string
      ingestion_key = string
    })
    target_name              = string
    route_name               = string
    target_region            = string
    regions_targeting_logdna = list(string)
  })
  default = {
    logdna_endpoint          = null
    target_name              = null
    route_name               = null
    target_region            = null
    regions_targeting_logdna = null
  }
  description = <<EOT
    logdna_target = {
      logdna_endpoint: "(Object) Property values for LogDNA Endpoint"
      target_name: "(String) The name of the logDNA target."
      route_name: "(String) The name of the LogDNA route."
      target_region: "(String) Region where is LogDNA target is created"
      regions_targeting_logdna: (List) Route the events generated in these regions to LogDNA target"
    }
  EOT

  validation {
    condition = anytrue([
      var.logdna_target.target_name == null,
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
      var.logdna_target.route_name == null,
      alltrue([
        can(length(var.logdna_target.route_name) >= 1),
        can(length(var.logdna_target.route_name) <= 1000),
        can(regex("^[a-zA-Z0-9 -._:]+$", var.logdna_target.route_name))
      ])
    ])
    error_message = "The route name must be 1000 characters or less, and cannot include any special characters other than (space) - . _ :."
  }
}
