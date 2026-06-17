# K8s vs K3s 的区别

## 1. 是什么？

| 名称 | 全称 | 说明 |
|------|------|------|
| **K8s** | Kubernetes | 开源的容器编排平台，**K8s** 是 "Kubernetes" 的缩写（K + 8 个字母 + s） |
| **K3s** | K3s（无全称） | **轻量级 Kubernetes 发行版**，由 Rancher 开发，兼容 K8s API |

---

## 2. 两者的关系

**K3s 是 K8s 的一个"精简版"发行版，并非不同的东西。**

K3s 是一个**完全兼容 Kubernetes API** 的发行版，只是做了以下裁剪：

| 特性 | K8s（完整版） | K3s（轻量版） |
|------|---------------|---------------|
| **内存占用** | 较大（~1-2GB） | 较小（~500MB） |
| **存储后端** | etcd（默认） | SQLite（默认），也支持 etcd |
| **组件数量** | 多个独立组件 | 单个二进制文件包含所有组件 |
| **CNI 默认** | 通常用 Calico、Cilium | Flannel（轻量、简单） |
| **适用场景** | 大规模生产环境 | 边缘计算、开发测试、IoT、资源受限环境 |

---

## 3. 兼容性

**K3s 是经过认证的 Kubernetes 发行版**，这意味着：

- 所有 K8s 的 YAML 文件在 K3s 中都可以正常工作
- 所有 `kubectl` 命令完全一样
- 所有 Helm Charts 都可以在 K3s 中部署
- K8s 的 API 资源（Deployment、Service、Ingress、ConfigMap 等）完全兼容

---

## 4. 为什么会有时说 K8s、有时说 K3s？

| 上下文 | 用词 | 原因 |
|--------|------|------|
| **通用概念** | K8s | 在讨论 Kubernetes 通用功能（如 NetworkPolicy、RBAC、Helm）时使用 |
| **具体环境** | K3s | 在你的集群上执行具体命令时，使用 K3s 因为你的集群是 K3s |
| **特性差异** | K3s | 当涉及 K3s 特有的行为时（如默认 Flannel 不支持 NetworkPolicy、默认 `system:authenticated` 权限） |

---

## 5. 类比理解
K8s = 标准 Linux 发行版（如 Ubuntu Server）
K3s = 精简版 Linux（如 Alpine Linux）

两者都是 Linux，但 K3s 更小、更快、更适合特定场景。---

## 6. 对学习的影响

| 学习内容 | 在 K8s 中的表现 | 在 K3s 中的表现 |
|----------|-----------------|-----------------|
| **SecurityContext** | ✅ 完全支持 | ✅ 完全支持 |
| **PodSecurity Standards** | ✅ 完全支持 | ✅ 完全支持 |
| **NetworkPolicy** | ✅ 支持（CNI 默认支持） | ⚠️ 需要额外安装（Flannel 不支持） |
| **ResourceQuota/LimitRange** | ✅ 完全支持 | ✅ 完全支持 |
| **RBAC** | ✅ 完全支持 | ✅ 完全支持（但有默认权限差异） |
| **Ingress** | ✅ 完全支持 | ✅ 完全支持 |
| **HPA** | ✅ 完全支持 | ✅ 完全支持（需要 metrics-server） |
| **PV/PVC** | ✅ 完全支持 | ✅ 完全支持（自带 local-path-provisioner） |

---

## 7. 一句话总结

**K3s 就是 K8s，只是更轻量。** 你学到的所有 Kubernetes 知识都适用于 K3s，但 K3s 有一些默认配置差异（如 CNI 插件）需要注意。
