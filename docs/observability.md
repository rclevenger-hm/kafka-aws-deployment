# Observability

## Collect Kafka metrics

Deploy Prometheus on a private host with routing and DNS to all nodes. Add its narrow private network to `metrics_cidrs`. Adapt [prometheus.yml.example](../monitoring/prometheus.yml.example), load [alerts.yml](../monitoring/alerts.yml), and import [Grafana dashboard](../monitoring/grafana-dashboard.json). The repository provisions exporters and rules; it does not provision Prometheus or Grafana.

The checksum-pinned JMX exporter runs on port 9404 in each Kafka JVM. Confirm its `up` series and the expected broker/controller labels before relying on alerts. Keep the endpoint private; it uses HTTP and exposes operational metadata.

