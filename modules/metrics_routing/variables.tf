variable "metrics_router_targets" {
  type = list(object({
    destination_crn                     = string
    target_name                         = string
    target_region                       = optional(string)
    skip_mrouter_sysdig_iam_auth_policy = optional(bool, false)
  }))
  default     = []
  description = "List of Metrics Router targets to be created."
}

variable "metrics_router_routes" {
  type = list(object({
    name = string
    rules = list(object({
      action = optional(string)
      targets = optional(list(object({
        id = optional(string)
      })), [])
      inclusion_filters = optional(list(object({
        operand  = string
        operator = string
        values   = list(string)
      })))
    }))
  }))
  default     = []
  description = "List of routes for IBM Metrics Router"

  validation {
    condition = length(var.metrics_router_routes) == 0 || alltrue([
      for route in var.metrics_router_routes : (
        length(route.rules) <= 4 &&
        alltrue([
          for rule in route.rules : (
            (rule.action == "send" || rule.action == "drop") &&
            length(rule.targets) <= 3 &&
            length(rule.inclusion_filters) <= 5
          )
        ])
      )
    ])
    error_message = "Each metric router route's can contain up to 4 rules, each rule's action must be either 'send' or 'drop', targets list must have a maximum of 3 items, and each rule's inclusion_filters can have up to 5 items."
  }

  # Validation for operator, operand, and values
  validation {
    condition = length(var.metrics_router_routes) == 0 || alltrue([
      for route in var.metrics_router_routes : alltrue([
        for rule in route.rules : (
          length(rule.inclusion_filters) == 0 || alltrue([
            for filter in rule.inclusion_filters : (
              filter.operator == "is" || filter.operator == "in"
              ) && (
              filter.operand == "location" ||
              filter.operand == "service_name" ||
              filter.operand == "service_instance" ||
              filter.operand == "resource_type" ||
              filter.operand == "resource"
              ) && (
              length(filter.values) >= 1 && length(filter.values) <= 20
            )
          ])
        )
      ])
    ])
    error_message = "Each inclusion_filter must have an operator of 'is' or 'in', an operand of 'location', 'service_name', 'service_instance', 'resource_type', or 'resource', and values must have between 1 and 20 items."
  }
}

variable "metrics_router_settings" {
  type = object({
    permitted_target_regions  = optional(list(string))
    primary_metadata_region   = optional(string)
    backup_metadata_region    = optional(string)
    private_api_endpoint_only = optional(bool)
    default_targets = optional(list(object({
      id = string
    })), [])
  })
  description = "Global settings for Metrics Routing"
  default     = null
}
