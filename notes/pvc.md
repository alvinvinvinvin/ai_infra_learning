# Persistent Volume Claim (PVC)

## What is PVC?
A PVC is a user's request for storage resources in Kubernetes. It abstracts away storage implementation details.

## Storage Abstraction
Pod → PVC → PV → Actual Storage

## Access Modes
- **RWO**: ReadWriteOnce
- **ROX**: ReadOnlyMany  
- **RWX**: ReadWriteMany

## Production Scenarios
- Database persistence (MySQL, PostgreSQL)
- AI model storage (vLLM, HuggingFace models)
- Log persistence for auditing
- Shared configuration that needs updates

## Difference from Pod
| Aspect | Pod | PVC |
|--------|-----|-----|
| Lifecycle | Temporary | Persistent |
| Purpose | Run containers | Store data |
| Deletion | Data lost | Data retained |

## Common Commands
```bash
kubectl get pvc
kubectl get pv
kubectl create pvc my-pvc --storage=1Gi
kubectl delete pvc my-pvc
K3s Notes
K3s includes local-path-provisioner by default.
