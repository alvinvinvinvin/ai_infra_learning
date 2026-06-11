
Session Recovery Info
Last Updated
June 11, 2026 - End of Day 8

Current Status
Docker image alvinchen8611/ai-infra-learning:cpu built and pushed

K3s cluster running with ai-inference namespace

nginx test deployment verified working

vLLM not running due to CPU mode compatibility issue

Completed
Day 1: vLLM deployment, environment setup

Day 2: OpenAI API, sampling parameters

Day 3: AWQ quantization

Day 4: GPTQ quantization comparison

Day 5: RAG pipeline with Chroma

Day 6: RAG optimization, embedding dimensions

Day 7: Prometheus + Grafana monitoring

Day 8: Docker containerization + K8s deployment

Key Skills Acquired
Dockerfile authoring and image building

Docker Hub image registry operations

Kubernetes Deployment and Service management

K8s troubleshooting (logs, describe, events)

Node selection and environment configuration

Next (Day 9)
K8s rolling updates

ConfigMaps and Secrets

Ingress controllers

Persistent volumes

Quick Recovery

# Check K3s cluster
kubectl get nodes
kubectl get pods -n ai-inference

# Test with nginx (works)
kubectl port-forward -n ai-inference svc/nginx-service 8080:80
curl http://localhost:8080
