module "resource_group" {
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git?ref=v1.0.5"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}


#target
module "cos_bucket" {
  source             = "git::https://github.com/terraform-ibm-modules/terraform-ibm-cos?ref=v5.0.0"
  resource_group_id  = module.resource_group.resource_group_id
  region             = var.region
  cos_instance_name  = "${var.prefix}-cos-test"
  cos_tags           = var.resource_tags
  bucket_name        = "${var.prefix}-cos-bucket"
  encryption_enabled = false
  retention_enabled  = false
}

# LogDNA
resource "ibm_resource_instance" "logdna" {

  name              = "lodDNA-test-target"
  resource_group_id = module.resource_group.resource_group_id
  service           = "logdna"
  plan              = "7-day"
  location          = var.region

  parameters = {
    "default_receiver" = true
  }
}

resource "ibm_resource_key" "log_dna_resource_key" {
  name                 = "logdna_manager_key_name"
  resource_instance_id = ibm_resource_instance.logdna.id
  role                 = "Manager"
}

resource "ibm_resource_instance" "es_instance_1" {
  name              = "terraform-integration-soaib"
  service           = "messagehub"
  plan              = "lite"
  location          = var.region # "us-east", "eu-gb", "eu-de", "jp-tok", "au-syd"
  resource_group_id = module.resource_group.resource_group_id
}

resource "ibm_event_streams_topic" "es_topic_1" {
  resource_instance_id = ibm_resource_instance.es_instance_1.id
  name                 = "my-es-topic"
  partitions           = 1
  config = {
    "cleanup.policy"  = "compact,delete"
    "retention.ms"    = "86400000"
    "retention.bytes" = "10485760"
    "segment.bytes"   = "536870912"
  }
}



provider "logdna" {
  servicekey = ibm_resource_key.ingestion.credentials["service_key"]
}


module "test_observability_instance_creation" {
  depends_on = [
    ibm_event_streams_topic.es_topic_1,
    ibm_resource_instance.es_instance_1
  ]
  source                         = "../../"
  resource_group_id              = module.resource_group.resource_group_id
  region                         = var.region
  logdna_provision               = false
  sysdig_provision               = false
  activity_tracker_instance_name = var.prefix
  activity_tracker_plan          = "7-day"
  logdna_tags                    = var.resource_tags
  sysdig_tags                    = var.resource_tags
  activity_tracker_tags          = var.resource_tags

  cos_endpoint = [
    {
      api_key : var.ibmcloud_api_key,
      bucket_name : module.cos_bucket.bucket_name[0],
      endpoint : module.cos_bucket.s3_endpoint_private[0],
      target_crn : module.cos_bucket.cos_instance_id,
      service_to_service_enabled = false,
  }]

  eventstreams_endpoint = [
    {
      api_key : var.ibmcloud_api_key
      target_crn : ibm_resource_instance.es_instance_1.id
      # target_crn: ibm_event_streams_topic.es_topic_1.resource_instance_id
      brokers : ibm_event_streams_topic.es_topic_1.kafka_brokers_sasl
      topic : ibm_event_streams_topic.es_topic_1.name
    }
  ]

  logdna_endpoint = [
    {
      target_crn : ibm_resource_instance.logdna.target_crn
      ingestion_key : ibm_resource_key.log_dna_resource_key.credentials.ingestion_key
    }
  ]

  regions_target_cos          = ["*", "global"] # review later
  regions_target_logdna       = ["*", "global"] # review later
  regions_target_eventstreams = ["*", "global"] # review later

}
