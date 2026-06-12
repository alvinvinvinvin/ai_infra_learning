# Day 9 - June 12, 2026

## Today's Goals
- [x] Rolling update and rollback in Kubernetes
- [x] ConfigMap configuration management
- [x] Secret management
- [x] Multi-replica high availability

## 1. Rolling Update

### What is Rolling Update?
Kubernetes Deployment gradually replaces old Pods with new ones, ensuring zero downtime.

### Key Observation
With 3 replicas, Pods were replaced one by one:
- New Pod created and health-checked
- Old Pod terminated only after new is running
- Service never interrupted

### Commands
```bash
# Update image
kubectl set image deployment/nginx-rollout nginx=nginx:1.26 -n k8s-learning

# Watch process
kubectl get pods -l app=nginx-rollout -w

# Rollback
kubectl rollout undo deployment/nginx-rollout -n k8s-learning

# View history
kubectl rollout history deployment/nginx-rollout -n k8s-learning
2. ConfigMap
Create
kubectl create configmap app-config --from-literal=APP_COLOR=blue
Use as Env Var
env:
- name: APP_COLOR
  valueFrom:
    configMapKeyRef:
      name: app-config
      key: APP_COLOR
Update Behavior
Env vars: Pod restart required

File mount: Auto-update with delay (~60s)

3. Secret
Create
kubectl create secret generic db-secret --from-literal=password=secret
View (base64 encoded)
kubectl get secret db-secret -o yaml
echo "base64_value" | base64 -d
Key Takeaways
Rolling update enables zero-downtime deployment

ConfigMap separates config from code

Secret protects sensitive data

3+ replicas provide high availability
