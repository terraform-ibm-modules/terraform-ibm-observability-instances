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

variable "metric_router_routes" {
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
  description = "List of routes for IBM metrics router"

  validation {
    condition     = length(var.metric_router_routes) <= 4
    error_message = "Number of routes should be less than or equal to 4"
  }
}

variable "metric_router_settings" {
  type = object({
    permitted_target_regions  = list(string)
    primary_metadata_region   = string
    backup_metadata_region    = string
    private_api_endpoint_only = bool
    default_targets            = optional(list(object({
      id = string
    })), [])
  })
  description = "Global settings for metrics routing"
  default     = null
}
