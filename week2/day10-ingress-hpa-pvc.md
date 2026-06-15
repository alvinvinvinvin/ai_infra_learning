# Day 10: Ingress, HPA, and Persistent Storage

## 1. Ingress Controller
An entry controller that routes external traffic to internal cluster services.

### What We Did
- Installed nginx-ingress controller
- Created host-based routing rules (`app-a.example.com` → app-a service)
- Tested routing via NodePort (30849)

## 2. Horizontal Pod Autoscaler (HPA)
Automatically adjusts the number of pod replicas based on CPU/memory metrics.

### What We Did
- Fixed metrics-server configuration issues in K3s
- Created a CPU-intensive test application (stress container)
- HPA scaled from 1 to 5 pods (200% CPU > 50% target)

## 3. Persistent Volume & Persistent Volume Claim (PVC)

### What is PVC?
**PVC (Persistent Volume Claim)** is a user's "request form" or "lease application" for storage resources. It allows applications to request storage without needing to understand the underlying storage implementation details.

### Kubernetes Storage Abstraction Layers
Pod → PVC → PV → Actual Storage (Local Disk/NFS/Cloud Disk)

| Component | Created By | Purpose | Analogy |
|-----------|------------|---------|---------|
| **PV** (Persistent Volume) | Administrator | Cluster storage resource pool | Physical hard drive or cloud disk |
| **PVC** (Persistent Volume Claim) | User/Application | Request storage resources | Lease application form |
| **StorageClass** | Administrator | Template for dynamic PV creation | Disk specification catalog |

### Differences Between PVC and Pod

| Aspect | Pod | PVC |
|--------|-----|-----|
| **Lifecycle** | Temporary, can be deleted/recreated anytime | Independent of Pod, persists after Pod deletion by default |
| **Data Persistence** | Data lost on container restart | Data persists even if Pod is deleted |
| **Creation Method** | `kubectl run` or Deployment | `kubectl create pvc` or YAML |
| **Primary Use** | Run application containers | Provide persistent storage for Pods |
| **Binding** | Multiple Pods can share storage (depends on accessMode) | A PVC is typically used by one Pod (ReadWriteOnce) |

### Real-World Production Scenarios

#### Scenario 1: Database Persistence
```yaml
# MySQL Pod needs data persistence to prevent data loss on restart
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-data
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: mysql
spec:
  containers:
    - name: mysql
      image: mysql:8.0
      volumeMounts:
        - mountPath: /var/lib/mysql
          name: data
  volumes:
    - name: data
      persistentVolumeClaim:
        claimName: mysql-data
Scenario 2: AI Model Storage (Relevant to Your Project)

# Store downloaded model files to avoid re-downloading each time
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: model-storage
spec:
  accessModes:
    - ReadOnlyMany  # Multiple Pods can read models simultaneously
  resources:
    requests:
      storage: 100Gi
---
# vLLM Deployment using shared model storage
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vllm
spec:
  replicas: 2
  template:
    spec:
      containers:
        - name: vllm
          image: vllm/vllm-openai:latest
          volumeMounts:
            - mountPath: /models
              name: models
      volumes:
        - name: models
          persistentVolumeClaim:
            claimName: model-storage
Scenario 3: Log Persistence

# Persist application logs for troubleshooting and auditing
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-logs
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: fast-ssd  # Use high-performance storage class
  resources:
    requests:
      storage: 50Gi
Scenario 4: Dynamic Configuration (When ConfigMap Isn't Suitable)

# When config files need dynamic updates and persistence across Pod restarts
# ConfigMap is for static config, PVC for dynamic data
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nginx-config
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
Storage Access Modes
Mode	Description	Use Case
ReadWriteOnce (RWO)	Read/write by a single node	Databases, most applications
ReadOnlyMany (ROX)	Read-only by many nodes	Shared model files, static assets
ReadWriteMany (RWX)	Read/write by many nodes	Distributed file systems, shared workspaces
Common Commands

# View storage classes
kubectl get storageclass

# Create PVC
kubectl create pvc my-pvc --storage=1Gi --storage-class=local-path

# Check PVC status (Bound means successfully bound to PV)
kubectl get pvc

# View PVs
kubectl get pv

# Delete PVC (behavior of associated PV depends on reclaimPolicy)
kubectl delete pvc my-pvc
Special Notes for K3s
K3s comes with local-path-provisioner by default. When you create a PVC, it automatically creates a corresponding PV with local storage — no need to manually create PVs.

4. Summary
Ingress: Controls how traffic enters the cluster

HPA: Automatically scales compute resources (number of Pods)

PVC: Declares storage needs for data persistence

Together, these three form production-ready infrastructure:

Ingress (Access) → Service (Routing) → Pod (Compute) + PVC (Storage) → HPA (Elasticity)
Reference Commands

# Ingress
kubectl get ingress -n k8s-learning
kubectl describe ingress demo-ingress -n k8s-learning

# HPA
kubectl get hpa -n k8s-learning
kubectl describe hpa hpa-demo -n k8s-learning

# PVC
kubectl get pvc -n k8s-learning
kubectl get pv
kubectl describe pvc test-pvc -n k8s-learning
