# Day 18: Prometheus Deep Dive, Grafana Dashboards, and vLLM Monitoring

## Date: 2026-06-24

## Learning Objectives
- [x] Prometheus architecture and components
- [x] Custom metrics and alerting rules
- [x] Grafana dashboards for Kubernetes monitoring
- [x] vLLM metrics collection and visualization

## 1. Prometheus Deep Dive

### Core Components

| Component | Purpose |
|-----------|---------|
| **Prometheus Server** | Scrapes and stores metrics data |
| **Node Exporter** | Collects node-level metrics (CPU, memory, disk) |
| **kube-state-metrics** | Collects Kubernetes object metrics (pods, deployments, services) |
| **Alertmanager** | Handles alerts and notifications |

### Key Metrics Types

| Type | Description | Example |
|------|-------------|---------|
| **Counter** | Only increases | `http_requests_total` |
| **Gauge** | Goes up and down | `cpu_usage` |
| **Histogram** | Buckets observations | `request_duration_seconds` |
| **Summary** | Percentiles | `request_latency_seconds` |

### Example Alert Rule

```yaml
groups:
- name: pod-alerts
  rules:
  - alert: PodCrashLooping
    expr: increase(kube_pod_container_status_restarts_total[5m]) > 5
    for: 2m
    labels:
      severity: warning
    annotations:
      summary: "Pod {{ $labels.pod }} is crash looping"
2. Grafana Dashboards
Key Dashboards
Dashboard	Usage
Kubernetes / Compute Resources / Cluster	Cluster-level CPU/memory
Kubernetes / Compute Resources / Namespace	Namespace-level resource usage
Kubernetes / Networking	Network traffic
Kubernetes / Persistent Volumes	Storage usage
Adding a Dashboard
bash
# Port forward Grafana
kubectl port-forward svc/grafana -n monitoring 3000:80

# Access at http://localhost:3000
# Default credentials: admin/admin
3. vLLM Monitoring
vLLM Exposed Metrics
Metric	Description
vllm:request_successful	Successful inference requests
vllm:request_failed	Failed inference requests
vllm:request_latency	Request latency in seconds
vllm:kv_cache_usage	KV cache usage percentage
vllm:gpu_cache_usage	GPU cache usage
Accessing vLLM Metrics
bash
# Get vLLM Pod
VLLM_POD=$(kubectl get pods -n ai-inference -l app=vllm -o jsonpath='{.items[0].metadata.name}')

# Port forward metrics endpoint
kubectl port-forward pod/$VLLM_POD -n ai-inference 8000:8000

# View metrics
curl http://localhost:8000/metrics | grep vllm
Key Commands
bash
# Check Prometheus targets
kubectl port-forward svc/prometheus -n monitoring 9090:9090
# http://localhost:9090/targets

# Query Prometheus
kubectl port-forward svc/prometheus -n monitoring 9090:9090
# http://localhost:9090/graph

# Check Grafana dashboards
kubectl port-forward svc/grafana -n monitoring 3000:80
# http://localhost:3000
References
Prometheus Documentation

Grafana Documentation

vLLM Metrics
