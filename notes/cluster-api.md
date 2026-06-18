# Cluster API - Kubernetes 多集群管理

## 是什么？
Cluster API 是 Kubernetes 官方项目，用 K8s 的方式来管理 K8s 集群。

## 核心概念
- **Cluster**: 定义整个集群（控制平面 + 工作节点）
- **Machine**: 定义单个节点
- **MachineSet**: 管理一组节点（类似 ReplicaSet）
- **MachineDeployment**: 管理 MachineSet 的滚动更新

## 工作原理
1. 一个"管理集群"（Management Cluster）运行 Cluster API 控制器
2. 控制器通过 Provider（如 AWS、Azure、vSphere）创建"工作集群"（Workload Clusters）
3. 所有集群管理通过 K8s API 完成

## 类比
Cluster API = "用 Kubernetes 来管理 Kubernetes"
就像用 Terraform 管理基础设施，但 Cluster API 完全通过 K8s API 和 CRD 驱动。

## 优势
- 声明式管理
- 与云平台解耦
- GitOps 友好
- 社区驱动

## 常用命令
```bash
# 安装 Cluster API
clusterctl init --infrastructure aws

# 创建集群
kubectl apply -f cluster.yaml

# 查看集群
kubectl get cluster
kubectl get machine
