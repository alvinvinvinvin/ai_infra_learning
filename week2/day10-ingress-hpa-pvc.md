
Day 10: Ingress, HPA, Persistent Storage
Date: 2026-06-15
Learning Objectives
Install and configure Ingress Controller

Set up HPA with CPU-based auto-scaling

Use PVC for persistent storage

Environment
K3s cluster: nzxtamd (master only, worker removed due to connectivity issues)

Namespace: k8s-learning

Tasks Completed
1. Ingress Controller

# Installed nginx-ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/cloud/deploy.yaml

# Created test apps
kubectl create deployment app-a --image=nginx --replicas=2 -n k8s-learning
kubectl expose deployment app-a --port=80 -n k8s-learning
kubectl create deployment app-b --image=httpd --replicas=2 -n k8s-learning
kubectl expose deployment app-b --port=80 -n k8s-learning

# Created Ingress rule (host-based routing)
# app-a.example.com → app-a service
# app-b.example.com → app-b service

# Tested via NodePort 30849
2. HPA Auto-scaling

# Created CPU-intensive deployment with stress container
kubectl create deployment hpa-demo --image=polinux/stress --replicas=1 -n k8s-learning
kubectl set resources deployment hpa-demo -n k8s-learning --requests=cpu=100m --limits=cpu=200m

# Created HPA rule
kubectl autoscale deployment hpa-demo -n k8s-learning --cpu=70% --min=1 --max=5

# Result: Scaled from 1 → 5 pods (CPU was 200%+)
3. Persistent Storage (PVC)

# Created PVC
kubectl create pvc test-pvc --storage=1Gi --storage-class=local-path -n k8s-learning

# Created test pod with PVC mount
kubectl run pv-test-pod --image=busybox --restart=Never -n k8s-learning -- sh -c "echo 'Day 10' > /data/message.txt && sleep 3600"

# Verified persistence
kubectl exec pv-test-pod -n k8s-learning -- cat /data/message.txt
# Output: Day 10
Issues Encountered & Solutions
Issue	Solution
HPA showed <unknown> for CPU	Worker node was NotReady; removed worker, restarted metrics-server
Metrics-server timeout errors	K3s needs --kubelet-insecure-tls flag; also removed unhealthy worker
PVC showed Pending briefly	Local-path-provisioner bound it automatically within seconds
Commands Learned Today

# Ingress
kubectl get ingress -A
kubectl describe ingress <name>

# HPA  
kubectl get hpa -n <namespace>
kubectl describe hpa <name>

# PVC
kubectl get pvc
kubectl get pv
kubectl describe pvc <name>
Next Steps
Day 11: Helm package manager

RBAC authorization

Service Mesh basics

Notes Reference
See notes/pvc.md for detailed PVC explanation

See notes/hpa.md (to be created) for HPA deep dive

See notes/ingress.md (to be created) for Ingress patterns
