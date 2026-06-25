# Day 19 补充笔记：Kubernetes 安全措施对比与生产应用

**日期**: 2026-06-25

## 概述

本文档详细对比了 Kubernetes 安全体系中的各种安全措施，包括它们的作用层次、检查时机、控制粒度和生产应用场景。

---

## 1. Pod Security Admission (PSA) vs Gatekeeper/OPA

### Pod Security Admission (PSA)
- **是什么**: Kubernetes 内置的 Pod 安全策略执行器（1.22+ 稳定）
- **策略定义**: 3 个预定义级别（privileged、baseline、restricted）
- **策略粒度**: 仅针对 Pod 安全（特权容器、卷类型、用户等）
- **灵活性**: 低 - 只能选择 3 个级别
- **部署复杂度**: 低 - Kubernetes 内置
- **适用场景**: 快速实施基础 Pod 安全标准

### Gatekeeper/OPA
- **是什么**: 基于 OPA 的外部策略引擎（CNCF 项目）
- **策略定义**: Rego 语言编写的任意策略
- **策略粒度**: 所有 Kubernetes 资源（Pod、Service、Ingress、CRD 等）
- **灵活性**: 极高 - 可以定义任何逻辑
- **部署复杂度**: 高 - 需要部署 Gatekeeper 控制器
- **适用场景**: 复杂业务规则、多资源类型、自定义策略

### 示例对比
```yaml
# PSA: 只能使用预定义级别
kubectl label ns prod pod-security.kubernetes.io/enforce=restricted

# Gatekeeper: 可以定义任意策略
# 例如：禁止 :latest 标签、要求 Pod 有特定标签、禁止修改 Ingress
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredTags
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
  parameters:
    tags: ["latest"]
生产选择建议
PSA: 快速开启基础保护，适合资源有限的集群

Gatekeeper: 大型企业需要细粒度策略（如要求每个 Pod 必须有团队标签、环境标签、成本中心标签等）

2. NetworkPolicy vs Service Mesh (Istio) 安全策略
NetworkPolicy
是什么: Kubernetes 原生网络隔离（L3/L4）

控制粒度: IP + Port

认证: 不支持

授权: 基于 IP/端口

策略范围: Pod 之间网络通信

部署复杂度: 低 - 只需 CNI 支持

Service Mesh (Istio) 安全策略
是什么: 服务网格安全功能（L7）

控制粒度: 应用层（HTTP 方法、Header、路径、JWT 等）

认证: 支持 mTLS、JWT 认证

授权: 基于身份（SPIFFE）、JWT claims

策略范围: 服务间通信 + 外部流量

部署复杂度: 高 - 需要部署 Istio 控制面和 Sidecar

示例对比
yaml
# NetworkPolicy: 只控制网络层
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend
spec:
  podSelector:
    matchLabels:
      app: frontend
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: backend
    ports:
    - port: 8080

# Istio AuthorizationPolicy: 控制应用层
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: require-jwt
spec:
  rules:
  - from:
    - source:
        requestPrincipals: ["user@example.com"]
    to:
    - operation:
        methods: ["GET", "POST"]
        paths: ["/api/*"]
生产选择建议
NetworkPolicy: 基础安全（防止 Pod 被横向移动攻击）

Service Mesh: 微服务间的认证、授权、加密通信（零信任架构）

3. RBAC vs OPA/Gatekeeper
RBAC
控制对象: 用户/ServiceAccount 对资源的操作权限

检查时机: API Server 认证后、授权阶段

策略类型: "谁可以做什么"（访问控制）

灵活性: 中等 - 基于 API Group/Resource/Verb

作用范围: 整个集群/命名空间

OPA/Gatekeeper
控制对象: 资源本身的合规性（配置是否符合规范）

检查时机: 准入控制阶段（资源创建/更新时）

策略类型: "资源应该是什么样子"（合规控制）

灵活性: 极高 - 可以检查资源的任何字段

作用范围: 可以限制到特定资源或字段

示例对比
yaml
# RBAC: 控制权限
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]   # 只能查看，不能创建/删除

# Gatekeeper: 控制配置合规
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredResources
spec:
  # 即使有权限创建 Pod，如果没有资源限制也会被拒绝
  match:
    kinds: ["Pod"]
生产场景
RBAC: DevOps 团队可以部署应用，但不能修改节点

Gatekeeper: 即使 DevOps 有部署权限，如果镜像使用 :latest 或没有资源限制，也会被拒绝

4. 镜像扫描 (Trivy) vs 准入控制 (Gatekeeper/PSA)
Trivy 镜像扫描
阶段: 镜像构建/部署前扫描

检查内容: 操作系统漏洞、语言包漏洞、密文

动作: 生成报告、标记漏洞

集成方式: CI/CD 流水线

准入控制 (Gatekeeper/PSA)
阶段: 资源创建时的实时拦截

检查内容: 资源配置合规性（标签、限制、安全上下文）

动作: 阻止/允许资源创建

集成方式: Kubernetes API Server 准入控制

生产流程结合
text
开发提交代码
    ↓
CI 构建镜像
    ↓
Trivy 扫描镜像 ← 如果有 CRITICAL 漏洞，构建失败
    ↓
推送到镜像仓库（版本标签）
    ↓
Kubernetes 部署
    ↓
Gatekeeper 检查 ← 如果镜像用了 :latest，拒绝部署
    ↓
Pod 运行
    ↓
NetworkPolicy 限制通信 ← 只能访问允许的服务
    ↓
Istio mTLS 加密通信 ← 服务间通信加密
5. 完整对比总结表
安全措施	防护层次	检查时机	控制粒度	部署成本
Trivy	镜像安全	CI/CD 阶段	漏洞级别	低
PSA	Pod 配置	准入控制	3 个预定义级别	低
Gatekeeper	资源配置	准入控制	自定义（任意资源）	高
RBAC	操作权限	授权阶段	API 操作级别	中
NetworkPolicy	网络访问	运行时	L3/L4（IP+Port）	中
Istio	服务通信	运行时	L7（应用层）	高
kube-bench	集群配置	检查工具	集群配置项	低
6. 生产环境完整安全体系
text
┌─────────────────────────────────────────────────────────────┐
│                    CI/CD 流水线                            │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐   │
│  │ SAST/DAST   │ →  │ Trivy 扫描  │ →  │ Snyk/其他   │   │
│  │ (代码安全)   │    │ (镜像漏洞)   │    │ (依赖检查)   │   │
│  └─────────────┘    └─────────────┘    └─────────────┘   │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│                Kubernetes 部署阶段                          │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐   │
│  │ RBAC        │ →  │ Gatekeeper  │ →  │ Pod 创建    │   │
│  │ (权限检查)   │    │ (合规检查)   │    │ (准入)      │   │
│  └─────────────┘    └─────────────┘    └─────────────┘   │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│                Pod 运行时阶段                              │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐   │
│  │NetworkPolicy│ →  │ Istio mTLS  │ →  │ Falco       │   │
│  │(网络隔离)    │    │(加密通信)    │    │(运行时安全)  │   │
│  └─────────────┘    └─────────────┘    └─────────────┘   │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│                    持续监控层                               │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐   │
│  │ kube-bench  │ →  │ Prometheus  │ →  │ 审计日志    │   │
│  │ (合规检查)   │    │ (监控告警)   │    │ (审计)      │   │
│  └─────────────┘    └─────────────┘    └─────────────┘   │
└─────────────────────────────────────────────────────────────┘
7. 实际生产场景：金融科技公司示例
开发环境
RBAC: 开发者账号允许在 dev 命名空间部署

PSA: dev 命名空间使用 baseline 级别（允许特权容器）

NetworkPolicy: 允许所有通信（方便调试）

Trivy: 在 CI 阶段扫描，有漏洞允许继续但生成报告

预发布环境
RBAC: 只有 CI/CD ServiceAccount 有部署权限

Gatekeeper: 禁止 :latest 标签、要求资源限制、禁止特权容器

NetworkPolicy: 只允许必要的服务通信

Istio: 启用 mTLS 和 JWT 认证

Trivy: 如果有 CRITICAL 漏洞，阻止部署

生产环境
RBAC: 严格限制，只有审批通过的部署账号可用

Gatekeeper: 更严格（还要求镜像来自受信仓库）

NetworkPolicy: 拒绝所有外部流量，只允许 Ingress 入口

Istio: 强制 mTLS，严格授权策略

Trivy: 所有漏洞都必须修复才能部署

kube-bench: 定期运行检查集群配置

审计日志: 所有操作都记录

8. 关键 Takeaways
分层防御: 安全需要在多层实施，任何单层都不足够

最小权限: 永远只授予完成任务所需的最低权限

纵深防御: 即使一个安全措施被绕过，其他措施仍能提供保护

左移安全: 在 CI/CD 早期发现问题（Trivy），成本更低

持续合规: 定期检查（kube-bench），防止配置漂移

运行时防护: NetworkPolicy + Service Mesh + Falco 确保运行安全

9. 相关命令速查
bash
# PSA
kubectl label ns <namespace> pod-security.kubernetes.io/enforce=restricted

# Gatekeeper
kubectl apply -f constraint-template.yaml
kubectl apply -f constraint.yaml
kubectl get constraints

# RBAC
kubectl apply -f role.yaml
kubectl apply -f rolebinding.yaml

# NetworkPolicy
kubectl apply -f networkpolicy.yaml

# Trivy
trivy image --severity HIGH,CRITICAL <image>

# kube-bench
kube-bench run --targets master --benchmark cis-1.24

# Istio AuthorizationPolicy
kubectl apply -f authorizationpolicy.yaml -n <namespace>
10. 参考链接
Pod Security Standards

Gatekeeper Documentation

CIS Kubernetes Benchmark

Trivy Documentation

Istio Security
