# Day 13: Scheduler, Cluster Management, and Backup

## Date: 2026-06-18

## Learning Objectives
- [x] nodeSelector (hard requirement)
- [x] nodeAffinity (required + preferred)
- [x] taints and tolerations
- [x] Cluster API (theory)
- [x] Velero backup/restore (theory)

---

## 1. nodeSelector

Simple label matching: Pod only schedules on nodes with matching labels. Hard requirement - no fallback if labels don't match.

### Practice Commands

```bash
# Add label to node
kubectl label node nzxtamd gpu=true

# Pod with matching label - schedules successfully
kubectl run gpu-pod --image=nginx --overrides='{"spec":{"nodeSelector":{"gpu":"true"}}}'

# Pod with non-matching label - stays Pending
kubectl run no-match-pod --image=nginx --overrides='{"spec":{"nodeSelector":{"gpu":"false"}}}'
Key Observation
gpu-pod: Scheduled successfully to nzxtamd

no-match-pod: Pending with message "0/1 nodes are available: 1 node(s) didn't match Pod's node affinity/selector"

2. nodeAffinity
More flexible than nodeSelector. Supports complex expressions: In, NotIn, Exists, DoesNotExist.

Two Types
requiredDuringSchedulingIgnoredDuringExecution: Hard requirement

preferredDuringSchedulingIgnoredDuringExecution: Soft preference

Practice Commands

# Hard affinity - must match
kubectl apply -f - << 'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: affinity-hard-pod
  namespace: day13-scheduler
spec:
  containers:
  - name: nginx
    image: nginx
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: gpu
            operator: In
            values:
            - "true"
YAML

# Soft affinity - prefer but not required
kubectl apply -f - << 'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: affinity-soft-pod
  namespace: day13-scheduler
spec:
  containers:
  - name: nginx
    image: nginx
  affinity:
    nodeAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        preference:
          matchExpressions:
          - key: gpu
            operator: In
            values:
            - "true"
YAML
3. Taints and Tolerations
Taint: Node repels pods (unless tolerated)

Toleration: Pod tolerates a specific taint

Practice Commands

# Add taint to node
kubectl taint node nzxtamd dedicated=ai:NoSchedule

# Pod without toleration - stays Pending
kubectl run no-toleration-pod --image=nginx

# Pod with toleration - schedules successfully
kubectl apply -f - << 'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: with-toleration-pod
  namespace: day13-scheduler
spec:
  containers:
  - name: nginx
    image: nginx
  tolerations:
  - key: dedicated
    operator: Equal
    value: ai
    effect: NoSchedule
YAML

# Remove taint
kubectl taint node nzxtamd dedicated=ai:NoSchedule-
Key Observation
no-toleration-pod: Pending with message "0/1 nodes are available: 1 node(s) had untolerated taint(s)"

with-toleration-pod: Running successfully on nzxtamd

4. Cluster API (Theory)
Kubernetes-native way to manage Kubernetes clusters. Uses CRDs: Cluster, Machine, MachineSet, MachineDeployment.

Core Concept: Management cluster creates workload clusters via providers (AWS, Azure, vSphere).

Analogy: "Using Kubernetes to manage Kubernetes" - like Terraform for infrastructure, but fully driven by K8s API and CRDs.

Key Benefits:

Declarative management

Cloud provider agnostic

GitOps friendly

Community driven

5. Velero (Theory)
Backup and restore tool for Kubernetes clusters.

Core Features:

Backup cluster resources (Deployment, Service, ConfigMap, etc.)

Backup persistent volume data (via CSI snapshots or file backup)

Scheduled automatic backups

Migration between clusters

Disaster recovery

Common Commands:

# Install Velero
velero install --provider aws --bucket my-backup --secret-file credentials

# Backup a namespace
velero backup create my-backup --include-namespaces myapp

# List backups
velero backup get

# Restore from backup
velero restore create --from-backup my-backup

# Scheduled backup
velero schedule create daily-backup --schedule="0 2 * * *" --include-namespaces myapp
6. Summary
Mechanism	Purpose	Example
nodeSelector	Hard label matching	Pod must run on node with gpu=true
nodeAffinity (required)	Hard with complex expressions	Pod must run on node with gpu in [true]
nodeAffinity (preferred)	Soft preference	Pod should run on node with gpu=true if possible
Taints	Node repels pods	Node has dedicated=ai:NoSchedule
Tolerations	Pod tolerates taint	Pod can run on tainted node
Issues Encountered & Solutions
Issue	Solution
Pod stays Pending with no-match nodeSelector	Check node labels; verify selector matches
Pod stays Pending with no toleration	Add matching toleration or remove taint
Taint prevents all pods	Remove taint with - suffix
References
Kubernetes Scheduling

Cluster API

Velero Documentation
