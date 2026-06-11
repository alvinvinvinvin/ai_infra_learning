# Day 7 - June 10, 2026

## Today's Goals
- [x] Understand Prometheus and Grafana for monitoring
- [x] Install and configure Prometheus to scrape vLLM metrics
- [x] Install and configure Grafana for visualization
- [x] Import vLLM dashboard and verify real-time metrics
- [x] Learn about production monitoring for AI inference services

## What are Prometheus and Grafana?

| Tool | Role | Analogy |
|------|------|---------|
| **Prometheus** | Time-series database + metrics scraper | Like a data collector that regularly checks `/metrics` |
| **Grafana** | Visualization and dashboard | Like a charting tool that reads from Prometheus |

**How they work together**:
vLLM → exposes /metrics endpoint → Prometheus scrapes every 15s → stores data → Grafana queries and displays

## Why Go Programs Like Prometheus Don't Need Virtual Environment

- **vLLM** (Python): Needs specific Python packages → requires virtual environment
- **Prometheus/Grafana** (Go): Compiled into standalone binaries → no external dependencies

## Installation Steps

### 1. Start vLLM with Metrics Endpoint

```bash
cd ~/ai_infra_learning
source venv310/bin/activate
export VLLM_USE_FLASHINFER_SAMPLER=0
python -m vllm.entrypoints.openai.api_server \
  --model ./phi3-mini \
  --trust-remote-code \
  --gpu-memory-utilization 0.7 \
  --port 8000

Note: /metrics endpoint is enabled by default with openai.api_server. No special flag needed.

2. Install Prometheus

# Download
cd ~
wget https://github.com/prometheus/prometheus/releases/download/v2.53.0/prometheus-2.53.0.linux-amd64.tar.gz
tar xvf prometheus-2.53.0.linux-amd64.tar.gz
sudo mv prometheus-2.53.0.linux-amd64 /opt/prometheus

# Configuration
sudo cat > /opt/prometheus/prometheus.yml << 'PROMEOF'
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'vllm'
    static_configs:
      - targets: ['localhost:8000']
    metrics_path: '/metrics'
PROMEOF

# Start Prometheus
cd /opt/prometheus
nohup ./prometheus --config.file=prometheus.yml --web.listen-address=:9090 > prometheus.log 2>&1 &

# Verify
curl http://localhost:9090/-/healthy
# Expected: "Prometheus Server is Healthy"
3. Install Grafana
On modern Ubuntu/WSL2, apt-key is deprecated. Use the new method:

# Add GPG key using gpg (replaces apt-key)
wget -q -O - https://packages.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/grafana.gpg > /dev/null

# Add repository
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list

# Install
sudo apt-get update
sudo apt-get install -y grafana

# Start service
sudo systemctl start grafana-server
sudo systemctl enable grafana-server

# Check status
sudo systemctl status grafana-server
4. Configure Grafana
Open browser: http://localhost:3000

Login: admin / admin (set new password)

Add Prometheus data source:

Connections → Data sources → Add data source → Prometheus

URL: http://localhost:9090

Click Save & test

Import vLLM dashboard:

Click + (top of left sidebar) → Import

Or use URL: http://localhost:3000/dashboard/import

Enter dashboard ID: 19195

Select Prometheus data source

Click Import

Verify Monitoring Works
Generate load to see metrics

# Continuous load for 30 seconds
end=$((SECONDS+30))
while [ $SECONDS -lt $end ]; do
  curl -s http://localhost:8000/v1/completions \
    -H "Content-Type: application/json" \
    -d '{"model":"./phi3-mini","prompt":"Hello","max_tokens":20}' \
    -o /dev/null &
  sleep 0.1
done
wait
Check Prometheus targets

curl http://localhost:9090/api/v1/targets | python3 -m json.tool | grep -A5 "vllm"
Expected output shows:

"job": "vllm"

"lastError": "" (no errors)

"health": "up"

Grafana Dashboard Features
Panel	Metric	Purpose
Running Requests	vllm:num_requests_running	Current concurrency
Request Rate	rate(vllm:num_requests_total[1m])	QPS
Latency P50/P90/P99	histogram_quantile	Performance
GPU Cache Usage	vllm:gpu_cache_usage_perc	Memory pressure
Adjusting Time Range in Grafana
Click time range picker (top right corner)

Choose Last 5 minutes or Last 15 minutes

Set auto-refresh: 5s for real-time view

Troubleshooting
"connection refused" when adding data source
Prometheus not running. Check:

ps aux | grep prometheus
curl http://localhost:9090/-/healthy
No data showing in dashboard
Check Prometheus targets: curl http://localhost:9090/api/v1/targets

Verify vLLM metrics endpoint: curl http://localhost:8000/metrics | head

Generate some load with the continuous load script

Refresh the dashboard and set time range to Last 5 minutes

apt-key: command not found during Grafana install
Use the gpg --dearmor method shown above (modern Ubuntu/WSL2).

Key Takeaways
Prometheus + Grafana is the standard monitoring stack for production AI services

Metrics endpoint is auto-enabled when using openai.api_server

Go binaries don't need virtual environments or Python dependencies

15-second scrape interval means short-lived spikes may be missed

Production best practices include:

Setting up alerts for high latency or OOM

Longer retention for historical analysis

TLS/authentication for endpoints

Multiple Prometheus instances for high availability

Next Steps (Day 8)
Containerize the RAG pipeline with Docker

Deploy to Kubernetes (K3s) with GPU support

Set up alerting in Grafana

Explore DCGM for GPU hardware metrics
