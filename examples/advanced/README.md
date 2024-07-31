# Provision IBM Cloud Monitoring, Log Analysis, Cloud Logs and Activity Tracker with archiving and event routing

Example that deploys:

- Log Analysis, Cloud Monitoring, and Activity Tracker instances
- Key Protect instance and root key
- COS instance and COS bucket for archiving Log Analysis and Activity Tracker logs into an encrypted bucket.
- Additional logs data bucket and a metrics bucket in COS instance to store IBM Cloud Logs data
- Activity Tracker instance with event routing to COS bucket, Event Streams, and Log Analysis
- Cloud Logs instance with Event Notification integration.
