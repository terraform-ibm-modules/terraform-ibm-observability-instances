variable "metrics_router_targets" {
  type = list(object({
    destination_crn                     = string
    target_name                         = string
    target_region                       = string
    skip_mrouter_sysdig_iam_auth_policy = optional(bool, false)
  }))
  default     = []
  description = "List of Metrics Router targets to be created."
}

variable "metrics_router_routes" {
  type = list(object({
    name = string
    rules = list(object({
      action = string
      targets = optional(list(object({
        id = optional(string)
      })), [])
      inclusion_filters = list(object({
        operand  = string
        operator = string
        values   = list(string)
      }))
    }))
  }))
  default     = []
  description = "List of routes for IBM Metrics Router"

  validation {
    condition     = length(var.metrics_router_routes) == 0 || alltrue([for route in var.metrics_router_routes : length(route.rules) <= 4])
    error_message = "The metrics_router_routes list can be empty or each route can have a maximum of 4 rules."
  }
}

variable "metrics_router_settings" {
  type = object({
    permitted_target_regions  = list(string)
    primary_metadata_region   = string
    backup_metadata_region    = string
    private_api_endpoint_only = bool
    default_targets = optional(list(object({
      id = string
    })), [])
  })
  description = "Global settings for Metrics Routing"
  default     = null
}
