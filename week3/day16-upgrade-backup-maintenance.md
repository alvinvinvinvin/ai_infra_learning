# Day 16: K3s Upgrade, Backup, and Node Maintenance

## Date: 2026-06-23

## Learning Objectives
- [x] K3s version management
- [x] Certificate management
- [x] SQLite backup and recovery
- [x] Node maintenance (cordon, drain, uncordon)

## Key Commands

### Version Check
```bash
sudo kubectl version
sudo k3s --version
Certificate Management
bash
# Check certificate expiry
sudo openssl x509 -in /var/lib/rancher/k3s/server/tls/server-ca.crt -noout -enddate
Backup
bash
sudo cp /var/lib/rancher/k3s/server/db/state.db ~/backups/k3s-state.db.$(date +%Y%m%d)
Node Maintenance
bash
kubectl cordon <node>      # Mark unschedulable
kubectl drain <node>       # Evict pods (with caution)
kubectl uncordon <node>    # Mark schedulable
Production Maintenance Flow
Notify team

Check cluster status

cordon node

drain node

Perform maintenance

uncordon node

Verify recovery
