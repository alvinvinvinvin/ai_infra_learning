# Day 15: Troubleshooting and Debugging

## Date: 2026-06-22

## Learning Objectives
- [x] kubectl debug for troubleshooting pods
- [x] Pod startup failure diagnosis (CrashLoopBackOff, ImagePullBackOff)
- [x] Cluster events and auditing

## Key Commands Learned

```bash
# Debug pod with temp container
kubectl debug -it <pod> --image=busybox --target=<container>

# View cluster events
kubectl get events --all-namespaces --sort-by='.lastTimestamp'

# Check pod status and events
kubectl describe pod <name>
kubectl logs <name>
kubectl exec -it <name> -- /bin/sh
Common Failure Scenarios
Scenario	Command to Diagnose
ImagePullBackOff	kubectl describe pod → Events
CrashLoopBackOff	kubectl logs + kubectl describe
Liveness probe failure	kubectl describe pod → Events
Network issue	kubectl exec → test connectivity
Production Takeaway
Kubernetes doesn't validate image existence at API level

Always set proper initialDelaySeconds for livenessProbe

Use kubectl debug when production images lack debug tools
