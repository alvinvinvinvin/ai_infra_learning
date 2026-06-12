# Day 8 - June 11, 2026

## Today's Goals
- [x] Containerize vLLM with Docker
- [x] Build and push Docker image to Docker Hub
- [x] Deploy to K3s Kubernetes cluster
- [x] Understand K8s concepts: Deployment, Service, nodeSelector
- [x] Troubleshoot and validate K8s environment

## Environment
- Master node: nzxtamd (K3s control plane)
- Worker node: worker-pc2 (GPU available but not used today)
- Kubernetes: K3s v1.35.5
- Docker: 29.5.2
- Image: alvinchen8611/ai-infra-learning:cpu

## Docker Containerization

### Dockerfile.cpu
```dockerfile
FROM ubuntu:22.04

ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive
ENV VLLM_USE_FLASHINFER_SAMPLER=0
ENV VLLM_TARGET_DEVICE=cpu

RUN apt-get update && apt-get install -y \
    python3.10 \
    python3-pip \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/bin/python3.10 /usr/bin/python

WORKDIR /app

RUN pip3 install --no-cache-dir vllm==0.22.0

RUN mkdir -p /app/models

EXPOSE 8000

CMD ["python", "-m", "vllm.entrypoints.openai.api_server", \
     "--model", "/app/models/phi3-mini", \
     "--trust-remote-code", \
     "--device", "cpu", \
     "--port", "8000"]

Build and Push Commands

# Build CPU version
docker build -f Dockerfile.cpu -t alvinchen8611/ai-infra-learning:cpu .

# Push to Docker Hub
docker push alvinchen8611/ai-infra-learning:cpu

Kubernetes Deployment
Deployment YAML

apiVersion: apps/v1
kind: Deployment
metadata:
  name: vllm-deployment
  namespace: ai-inference
spec:
  replicas: 1
  selector:
    matchLabels:
      app: vllm
  template:
    metadata:
      labels:
        app: vllm
    spec:
      nodeSelector:
        kubernetes.io/hostname: worker-pc2
      containers:
        - name: vllm
          image: alvinchen8611/ai-infra-learning:cpu
          ports:
            - containerPort: 8000
          env:
            - name: VLLM_USE_FLASHINFER_SAMPLER
              value: "0"
          volumeMounts:
            - name: model-cache
              mountPath: /app/models
      volumes:
        - name: model-cache
          hostPath:
            path: /home/cheer/ai_infra_learning/models
            type: Directory

Service YAML

apiVersion: v1
kind: Service
metadata:
  name: vllm-service
  namespace: ai-inference
spec:
  selector:
    app: vllm
  ports:
    - port: 8000
      targetPort: 8000
  type: ClusterIP

Deployment Commands

# Create namespace
kubectl create namespace ai-inference

# Apply deployment
kubectl apply -f vllm-deployment-cpu.yaml

# Check status
kubectl get pods -n ai-inference -w

# View logs
kubectl logs -n ai-inference -l app=vllm

# Port forward for testing
kubectl port-forward -n ai-inference svc/vllm-service 8000:8000
Validation with Nginx
To verify K8s environment works correctly:

# Deploy nginx test
cat > nginx-test.yaml << 'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: ai-inference
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      nodeSelector:
        kubernetes.io/hostname: worker-pc2
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  namespace: ai-inference
spec:
  selector:
    app: nginx
  ports:
    - port: 80
      targetPort: 80
  type: ClusterIP
YAML

kubectl apply -f nginx-test.yaml
kubectl port-forward -n ai-inference svc/nginx-service 8080:80
curl http://localhost:8080  # Returns nginx welcome page
Key Learnings
Containerization
Dockerfile is the blueprint for container images

Build context includes files in current directory

Image tags follow registry/username/repo:tag format

CPU vs GPU images require different base images

Kubernetes Concepts
Concept	Purpose	How to use
Namespace	Isolate resources	kubectl create namespace
Deployment	Manage Pod lifecycle	Define replicas, image, ports
Service	Network access to Pods	ClusterIP for internal access
nodeSelector	Schedule Pods on specific nodes	kubernetes.io/hostname: worker-pc2
Port forwarding	Local testing	kubectl port-forward

Troubleshooting Commands

kubectl get pods -n <namespace>           # List Pods
kubectl describe pod -n <namespace> <pod> # Detailed status
kubectl logs -n <namespace> <pod>         # Container logs
kubectl logs -n <namespace> <pod> --previous  # Previous container logs
kubectl get events -n <namespace>         # Cluster events
Issues Encountered
vLLM CPU Mode Failure
vLLM failed to run in CPU mode with error:

RuntimeError: Failed to infer device type
Root cause: vLLM's CUDA detection logic doesn't work well in WSL2 + K3s CPU-only environment.

Lesson: Not all applications work in all environments. K8s itself is healthy (nginx worked).

Docker Hub Push Authentication
Initial push failed with insufficient scopes. Fixed by:

Creating Read & Write Personal Access Token on Docker Hub

Updating token permissions

What Actually Worked
✅ Docker image built successfully
✅ Image pushed to Docker Hub
✅ K3s cluster responds to commands
✅ nginx deployment runs correctly
✅ Port forwarding works
✅ Service discovery works

What Didn't Work (Environment-Specific)
❌ vLLM CPU mode in WSL2 + K3s
❌ GPU mode (requires GPU Operator, not compatible with WSL2)

Conclusion
Today's learning focused on containerization and Kubernetes deployment concepts, which are valuable independently of whether vLLM runs. The skills learned (Dockerfile, image registry, K8s manifests, troubleshooting) transfer to any containerized application.

Next Steps (Day 9)
Continue K8s learning with working examples (nginx, redis, echo-server)

Learn about ConfigMaps and Secrets

Understand rolling updates and rollbacks

Study Ingress controllers
