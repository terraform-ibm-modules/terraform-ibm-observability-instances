
moved {
  from = ibm_resource_instance.sysdig
  to   = module.sysdig.ibm_resource_instance.sysdig
}

moved {
  from = module.sysdig.ibm_resource_instance.sysdig
  to   = module.cloud_monitoring.ibm_resource_instance.cloud_monitoring
}

moved {
  from = ibm_resource_key.sysdig_resource_key
  to   = module.sysdig.ibm_resource_key.resource_key
}

moved {
  from = module.sysdig.ibm_resource_key.resource_key
  to   = module.cloud_monitoring.ibm_resource_key.resource_key
}

moved {
  from = module.activity_tracker.ibm_atracker_target.atracker_logdna_targets
  to   = module.activity_tracker.ibm_atracker_target.atracker_log_analysis_targets
}

moved {
  from = module.cloud_monitoring
  to   = module.cloud_monitoring[0]
}
