# Day 14: Authentication, Logging, GitOps, and Week 2 Summary

## Date: 2026-06-19

## Learning Objectives
- [x] ServiceAccount and OIDC authentication
- [x] EFK/ELK logging stack (theory)
- [x] GitOps with ArgoCD/FluxCD (theory)
- [x] Week 2 summary and review

---

## 1. ServiceAccount and OIDC

### ServiceAccount
- Identity for Pods to authenticate with API Server
- Can be assigned RBAC permissions via RoleBinding/ClusterRoleBinding

### OIDC (OpenID Connect)
- External identity provider (Google, GitLab, Okta)
- Users authenticate with SSO, API Server validates token

### Practice Commands
```bash
# Create ServiceAccount
kubectl create sa demo-sa -n day14-auth

# Generate token (K8s 1.24+)
kubectl create token demo-sa -n day14-auth

# Check permissions
kubectl auth can-i get pods --as=system:serviceaccount:day14-auth:demo-sa

# Grant permissions
kubectl create clusterrolebinding demo-sa-view --clusterrole=view --serviceaccount=day14-auth:demo-sa
2. Logging (EFK/ELK)
Components
Component	Role
Fluentd/Filebeat	Log collector (DaemonSet)
Elasticsearch	Store and index logs
Kibana	Visualize and search logs
EFK Architecture
App → stdout → Fluentd (DaemonSet) → Elasticsearch → Kibana
3. GitOps (ArgoCD)
What is GitOps?
Declarative CD using Git as the single source of truth.

ArgoCD vs FluxCD
Feature	ArgoCD	FluxCD
UI	Rich	Limited
Multi-cluster	Yes	Yes
Learning Curve	Medium	Steep
ArgoCD Workflow
Git Repo → ArgoCD detects changes → Auto-sync to cluster
4. Week 2 Summary
Day	Topic
8	Docker containerization, K8s deployment
9	Rolling updates, ConfigMap, Secret
10	Ingress, HPA, PV/PVC
11	Helm, RBAC, Istio
12	SecurityContext, PodSecurity Standards, NetworkPolicy, ResourceQuota, LimitRange
13	Scheduling (nodeSelector, nodeAffinity, taints/tolerations), Cluster API, Velero
14	Auth, Logging, GitOps
References
Kubernetes ServiceAccount

EFK on Kubernetes

ArgoCD Documentation
