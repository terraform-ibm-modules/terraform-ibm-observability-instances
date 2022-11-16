##############################################################################
# observability-instances-module
#
# Deploy the observability instances - LogDNA, Sysdig and Activity Tracker
##############################################################################

locals {
  logdna_instance_name           = var.logdna_instance_name != null ? var.logdna_instance_name : "logdna-${var.region}"
  sysdig_instance_name           = var.sysdig_instance_name != null ? var.sysdig_instance_name : "sysdig-${var.region}"
  activity_tracker_instance_name = var.activity_tracker_instance_name != null ? var.activity_tracker_instance_name : "activity-tracker-${var.region}"
}

# LogDNA
resource "ibm_resource_instance" "logdna" {
  count = var.logdna_provision ? 1 : 0

  name              = local.logdna_instance_name
  resource_group_id = var.resource_group_id
  service           = "logdna"
  plan              = var.logdna_plan
  location          = var.region
  tags              = var.logdna_tags

  parameters = {
    "default_receiver" = var.enable_platform_logs
  }
}

resource "ibm_resource_key" "log_dna_resource_key" {
  count = var.logdna_provision ? 1 : 0

  name                 = var.logdna_manager_key_name
  resource_instance_id = ibm_resource_instance.logdna[0].id
  role                 = "Manager"
}

# Sysdig
resource "ibm_resource_instance" "sysdig" {
  count = var.sysdig_provision ? 1 : 0

  name              = local.sysdig_instance_name
  resource_group_id = var.resource_group_id
  service           = "sysdig-monitor"
  plan              = var.sysdig_plan
  location          = var.region
  tags              = var.sysdig_tags

  parameters = {
    "default_receiver" = var.enable_platform_metrics
  }
}

resource "ibm_resource_key" "sysdig_resource_key" {
  count = var.sysdig_provision ? 1 : 0

  name                 = var.sysdig_manager_key_name
  resource_instance_id = ibm_resource_instance.sysdig[0].id
  role                 = "Manager"
}

# Activity Tracker
resource "ibm_resource_instance" "activity_tracker" {
  count = var.activity_tracker_provision ? 1 : 0

  name              = local.activity_tracker_instance_name
  resource_group_id = var.resource_group_id
  service           = "logdnaat"
  plan              = var.activity_tracker_plan
  location          = var.region
  tags              = var.activity_tracker_tags
}

resource "ibm_resource_key" "at_resource_key" {
  count = var.activity_tracker_provision ? 1 : 0

  name                 = var.activity_tracker_manager_key_name
  resource_instance_id = ibm_resource_instance.activity_tracker[0].id
  role                 = "Manager"
}
