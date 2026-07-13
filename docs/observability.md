# Observability

## Collect Kafka metrics

Deploy Prometheus on a private host with routing and DNS to all nodes. Add its narrow private network to `metrics_cidrs`. Adapt [prometheus.yml.example](../monitoring/prometheus.yml.example), load [alerts.yml](../monitoring/alerts.yml), and import [Grafana dashboard](../monitoring/grafana-dashboard.json). The repository provisions exporters and rules; it does not provision Prometheus or Grafana.

The checksum-pinned JMX exporter runs on port 9404 in each Kafka JVM. Confirm its `up` series and the expected broker/controller labels before relying on alerts. Keep the endpoint private; it uses HTTP and exposes operational metadata.

## Alerts and response

Watch unavailable partitions, under-replicated partitions, ISR loss, active controller count, exporter loss and request behavior. Correlate failures with deployment events, EC2 status, EBS latency and client p99. Rule unit tests exercise alert expressions; tune hold times and thresholds to measured workload behavior.

Terraform creates one EC2 status alarm per node. Set `alarm_topic_arns` to existing same-region SNS topics with confirmed subscriptions; otherwise alarms appear in CloudWatch without delivering notifications. VPC flow logs record accepted/rejected traffic metadata to CloudWatch with a configurable retention window.

## Host and certificate coverage

Add your standard host collector for filesystem free space/inodes, disk latency/queue depth, CPU, memory pressure, network drops and certificate expiration. Kafka/JMX alone does not expose filesystem capacity or every host failure. Use CloudWatch EBS metrics alongside Linux observations and benchmark baselines.

