# NetworkPolicy - Kubernetes 网络策略

## 概述
NetworkPolicy 是 Kubernetes 的网络防火墙，控制 Pod 间的网络通信。需要 CNI 插件支持（Calico、Cilium、Weave）。

## 核心概念
- **Ingress**: 入站流量规则
- **Egress**: 出站流量规则  
- **podSelector**: 选择目标 Pod
- **policyTypes**: Ingress / Egress / Both

## 默认行为
- 无策略：允许所有通信
- 有策略：拒绝所有通信（除非明确允许）

## 常用示例
1. 拒绝所有入站流量
2. 基于标签允许特定 Pod 访问
3. 允许同命名空间内所有 Pod 访问
4. 跨命名空间访问控制
5. 限制出站流量（Egress）
6. 基于 IP 段（ipBlock）控制

## 生产场景
- 数据库隔离（只允许应用层访问）
- 前端 → API → 数据库 分层限制
- 监控系统采集指标
- 多租户命名空间隔离

## 常用命令
```bash
kubectl get networkpolicy -n <ns>
kubectl describe networkpolicy <name> -n <ns>
kubectl apply -f networkpolicy.yaml
kubectl delete networkpolicy <name> -n <ns>
