# Velero - Kubernetes 备份与恢复

## 是什么？
Velero 是 Kubernetes 集群的备份、迁移和恢复工具。

## 核心功能
- **备份**：备份集群资源（Deployment、Service、ConfigMap 等）和 PV 数据
- **恢复**：从备份恢复集群
- **迁移**：将资源从一个集群迁移到另一个集群
- **调度**：定期自动备份

## 工作原理
1. Velero 运行在目标集群中
2. 备份资源存储在对象存储中（AWS S3、MinIO、Azure Blob 等）
3. 备份时调用 CSI 快照或文件备份插件来备份 PV 数据

## 常用命令
```bash
# 安装 Velero
velero install --provider aws --bucket my-backup --secret-file credentials

# 备份整个命名空间
velero backup create my-backup --include-namespaces myapp

# 查看备份
velero backup get

# 恢复
velero restore create --from-backup my-backup

# 调度备份
velero schedule create daily-backup --schedule="0 2 * * *" --include-namespaces myapp
生产场景
灾难恢复（DR）

集群迁移（从 K3s 到 EKS）

开发/测试环境克隆
