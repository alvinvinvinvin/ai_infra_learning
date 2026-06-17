# Day 12: Security, NetworkPolicy, and Resource Management

## Date: 2026-06-17

## Learning Objectives
- [x] SecurityContext (runAsUser, runAsGroup, fsGroup)
- [x] PodSecurity Standards (baseline, restricted)
- [x] NetworkPolicy (theory + YAML syntax)
- [x] ResourceQuota (namespace-level limits)
- [x] LimitRange (pod/container defaults)

## SecurityContext
- `runAsUser`: sets container user ID
- `runAsGroup`: sets container group ID
- `fsGroup`: sets file system group ownership
- Non-root containers may need `NET_BIND_SERVICE` capability or writable volumes

## PodSecurity Standards
- **Privileged**: unrestricted, for system components
- **Baseline**: limited restrictions (blocks privileged containers)
- **Restricted**: strict restrictions (requires runAsNonRoot, drop ALL capabilities, seccomp)

## NetworkPolicy
- Requires CNI support (Calico, Cilium; Flannel does NOT support it)
- Controls ingress/egress traffic between pods
- Default behavior: allow all → deny all once policy is applied

## ResourceQuota vs LimitRange
- **LimitRange**: sets defaults and ranges per pod/container
- **ResourceQuota**: sets total limits per namespace

## Commands
```bash
# SecurityContext
kubectl run pod --overrides='{"spec":{"securityContext":{"runAsUser":1000}}}'

# PodSecurity Standards
kubectl label namespace <ns> pod-security.kubernetes.io/enforce=baseline

# ResourceQuota
kubectl create quota <name> --hard=pods=5,cpu=2,memory=2Gi -n <ns>

# LimitRange
kubectl apply -f limitrange.yaml
