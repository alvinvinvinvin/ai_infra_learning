
Session Recovery Info
Last Updated
June 10, 2026 - End of Day 7

Current Status
vLLM 0.22.0 serving Phi-3-mini on port 8000

Prometheus scraping metrics every 15s (port 9090)

Grafana dashboard available at http://localhost:3000

Dashboard ID 19195 imported and showing real-time metrics

Completed
Day 1: vLLM deployment, environment setup

Day 2: OpenAI API, sampling parameters

Day 3: AWQ quantization

Day 4: GPTQ quantization comparison

Day 5: RAG pipeline (Chroma + embeddings)

Day 6: RAG optimization (threshold, Phi-3-mini, embedding dimensions)

Day 7: Monitoring with Prometheus + Grafana

Quick Recovery

# Start vLLM
cd ~/ai_infra_learning
source venv310/bin/activate
export VLLM_USE_FLASHINFER_SAMPLER=0
python -m vllm.entrypoints.openai.api_server \
  --model ./phi3-mini \
  --trust-remote-code \
  --gpu-memory-utilization 0.7 \
  --port 8000

# Start Prometheus (if not running)
cd /opt/prometheus
nohup ./prometheus --config.file=prometheus.yml --web.listen-address=:9090 > prometheus.log 2>&1 &

# Grafana should auto-start; if not:
# sudo systemctl start grafana-server
Next (Day 8)
Containerization with Docker

Kubernetes deployment (K3s)

Grafana alerting setup
