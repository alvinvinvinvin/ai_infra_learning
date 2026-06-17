# 为什么 NetworkPolicy 需要 CNI 插件支持？

## 问题
NetworkPolicy 是 Kubernetes 的网络防火墙，控制 Pod 之间、Pod 与外部之间的网络流量。但为什么它需要 CNI 插件支持？K3s 默认的 Flannel 为什么不支持？

## 简短回答
**NetworkPolicy 不是 K8s 自己执行的，而是通过 CNI 插件实现的。** K8s 只定义了 API 规范（YAML 格式），实际执行交给 CNI 插件。

---

## 1. Kubernetes 网络的职责分工

| 组件 | 职责 | 比喻 |
|------|------|------|
| **CNI 插件** | 实际网络通信：创建网络接口、路由、转发数据包 | "修路 + 铺路" |
| **NetworkPolicy** | 流量控制规则：定义谁可以访问谁 | "红绿灯 + 交警" |

Kubernetes 本身只定义了 NetworkPolicy 的 API 规范，但并不负责执行它。执行规则的任务交给了 CNI 插件——因为只有 CNI 插件真正控制着数据包的流向。

---

## 2. 各 CNI 插件的支持情况

| CNI 插件 | 是否支持 NetworkPolicy | 原因 |
|----------|------------------------|------|
| **Flannel** | ❌ 不支持 | 只负责简单的网络连接（Overlay），没有内置防火墙/过滤功能 |
| **Calico** | ✅ 支持 | 内置 Linux 内核的 iptables/eBPF 规则引擎，可以拦截和过滤数据包 |
| **Cilium** | ✅ 支持 | 基于 eBPF 技术，在内核层进行高效的流量过滤 |
| **Weave** | ✅ 支持 | 内置网络策略控制器 |

**Flannel 的设计哲学是"简单"**：它只负责让 Pod 之间能互相通信，不关心"谁不能访问谁"。

---

## 3. 技术层面：如何实现 NetworkPolicy

当你在 YAML 中定义 NetworkPolicy 时，CNI 插件会做以下事情：

1. 你：`kubectl apply -f networkpolicy.yaml`
2. K8s API Server：存储这个 Policy（只是存起来，不执行）
3. CNI 插件（如 Calico）：Watch 到新的 Policy 事件
4. CNI 插件：将规则翻译成 Linux iptables 或 eBPF 规则
5. Linux 内核：实际拦截/放行数据包

**Flannel 没有第 3-5 步**，所以它完全不理会 NetworkPolicy 资源。

---

## 4. 类比帮助理解

| 场景 | 类比 |
|------|------|
| **Flannel** | 给你一台能上网的电脑（网络通了），但没有防火墙 |
| **Calico/Cilium** | 给你一台能上网的电脑，还带一个防火墙软件，你可以配置规则 |
| **NetworkPolicy API** | 防火墙软件的配置界面（K8s 提供界面，但实际的防火墙软件必须支持） |

---

## 5. K3s 为什么默认用 Flannel？

K3s 的目标是**轻量级、简单、快速**。对于很多开发/测试场景，只需要网络连通即可，不需要复杂的网络策略。Flannel 足够满足这些场景。

如果需要 NetworkPolicy，K3s 可以：
- 启动时通过 `--flannel-backend=none` 禁用 Flannel
- 安装 Calico 或 Cilium 作为替代 CNI

---

## 6. 总结

| 问题 | 答案 |
|------|------|
| **NetworkPolicy 是 K8s 的防火墙吗？** | 是 K8s 定义的 API 规范，但不是 K8s 自己执行的 |
| **为什么需要 CNI 支持？** | 因为只有 CNI 插件能实际控制数据包流向 |
| **Flannel 为什么不支持？** | Flannel 的设计目标是简单网络连通，不包含防火墙功能 |
| **生产环境怎么办？** | 使用 Calico、Cilium 等支持 NetworkPolicy 的 CNI 插件 |

---

## 一句话总结

**Kubernetes 定义了"防火墙规则"的格式，但真正的"防火墙软件"是 CNI 插件。没有防火墙软件，规则就是一张废纸。**
