# AI Infrastructure Engineer 学习路线图（12周）- 修订版 v2

> 基于当前进度调整：已完成 LLM 推理入门 + K8s/Istio 平台层，现在进入 **模型服务性能优化与生产化部署**。

## 当前状态（Day 19 结束）

| 维度 | 状态 |
|------|------|
| Python + vLLM + RAG | ✅ 已完成 |
| K3s 集群部署 | ✅ 已完成 |
| Istio 服务网格 | ✅ 已完成 |
| K8s 安全加固（Gatekeeper, kube-bench, Trivy）| ✅ 已完成 |
| NetworkPolicy, RBAC, 审计日志 | ✅ 已完成 |
| **LLM 推理性能压测与优化** | ❌ 未开始 |
| **vLLM 容器化与 K8s 部署** | ❌ 未开始 |
| **生产级服务封装** | ❌ 未开始 |

---

## 修订后的阶段划分

| 阶段 | 主题 | 目标 | 时长 |
|------|------|------|------|
| 1 | LLM 推理入门 | 已在 Day 1-7 完成 | ~1 周 |
| 2 | **平台基础设施** | 已在 Day 8-19 完成 | ~2 周 |
| **3** | **模型服务性能优化** | 在 K3s 上压测并调优 vLLM 推理性能 | **3 周（Day 20-40）** |
| **4** | **生产级服务封装** | 容器化、API 增强、可观测性、灰度发布 | **2 周（Day 41-54）** |
| **5** | **项目整合与求职准备** | 完善 GitHub、技术博客、模拟面试 | **2 周（Day 55-70）** |

---

## 阶段 3：模型服务性能优化（Day 20-40）

**目标**：在 K3s 集群中部署 vLLM，进行系统性的性能压测，理解并发、量化、调度参数对吞吐和延迟的影响。

### 第 1 周：在 K3s 上部署 vLLM（Day 20-26）

| Day | 任务 | 产出 |
|-----|------|------|
| **Day 20** | 将 vLLM 环境打包为 Docker 镜像，推送到本地镜像仓库 | Dockerfile, 镜像 |
| **Day 21** | 编写 K8s Deployment + Service，在 K3s 上部署 vLLM | vLLM Deployment, Service |
| **Day 22** | 通过 Istio Gateway 暴露 vLLM 服务，外部访问测试 | Istio Gateway + VirtualService |
| **Day 23** | 对比 K3s 内外 vLLM 的延迟差异（首次请求 vs 后续请求）| 延迟对比数据 |
| **Day 24** | 配置 ConfigMap 管理 vLLM 参数（--max-model-len, --gpu-memory-utilization）| ConfigMap + 滚动更新测试 |
| **Day 25** | 使用 K8s HPA 基于 CPU/自定义指标自动扩缩容 | HPA 配置 + 测试记录 |
| **Day 26** | 总结：在 K3s 上运行 vLLM 的注意事项 | 笔记《K3s + vLLM 部署指南》|

### 第 2 周：性能压测与基准（Day 27-33）

| Day | 任务 | 产出 |
|-----|------|------|
| **Day 27** | 在 K3s 集群内部署 Locust，编写压测脚本 | Locust Deployment + 脚本 |
| **Day 28** | 测试并发数 1/4/8/16/32 的吞吐量和 P50/P95/P99 延迟 | 压测原始数据 |
| **Day 29** | 调整 vLLM 的 --max-num-seqs 参数，观察性能变化 | 参数调优对比报告 |
| **Day 30** | 开启 --enable-prefix-caching，对比缓存命中率对性能的影响 | Prefix Caching 测试结果 |
| **Day 31** | 调整 --block-size 参数（原计划 Day 20），记录差异 | Block Size 调优记录 |
| **Day 32** | 用 Grafana + Prometheus 可视化性能指标 | Grafana 仪表板截图 |
| **Day 33** | 撰写《在 K3s 上运行 vLLM 的压测报告》| 完整压测报告 |

### 第 3 周：优化技术实践（Day 34-40）

| Day | 任务 | 产出 |
|-----|------|------|
| **Day 34** | 部署 GPTQ 4-bit 模型，对比 FP16 的显存和吞吐差异 | GPTQ vs FP16 对比数据 |
| **Day 35** | 部署 AWQ 模型，对比 GPTQ 与 AWQ 的性能差异 | AWQ vs GPTQ 对比 |
| **Day 36** | 测试投机解码（Speculative Decoding），记录加速比 | 投机解码实验结果 |
| **Day 37** | 测试张量并行（Tensor Parallelism）在单卡上的效果 | TP 测试结果 |
| **Day 38** | 用 K8s 的 ResourceQuota 限制 vLLM Pod 资源，观察 QoS 影响 | ResourceQuota 配置 + 结果 |
| **Day 39** | 综合对比：所有优化手段的效果汇总表 | 优化效果汇总 |
| **Day 40** | 撰写《LLM 推理优化技巧在 K8s 上的实践》| 技术博客素材 |

---

## 阶段 4：生产级服务封装（Day 41-54）

**目标**：将优化后的服务封装为生产可用的 API 服务，具备认证、流式响应、可观测性。

### 第 4 周：API 增强与服务封装（Day 41-47）

| Day | 任务 | 产出 |
|-----|------|------|
| **Day 41** | 用 FastAPI 封装 vLLM，添加 /health, /metrics 端点 | FastAPI 封装代码 |
| **Day 42** | 实现流式响应（SSE）和 /tokenize 端点 | SSE + Tokenize 实现 |
| **Day 43** | 添加 API Key 认证（Header 验证）| 认证中间件 |
| **Day 44** | 集成 Prometheus 客户端，暴露自定义指标 | Prometheus 指标代码 |
| **Day 45** | 在 K3s 上部署封装后的服务，替换原生 vLLM | 新服务 Deployment |
| **Day 46** | 配置 Grafana 仪表板，监控请求量、错误率、延迟 | Grafana Dashboard |
| **Day 47** | 实现日志轮转和结构化日志（JSON 格式）| 日志配置 |

### 第 5 周：灰度发布与生产就绪（Day 48-54）

| Day | 任务 | 产出 |
|-----|------|------|
| **Day 48** | 用 Istio 实现金丝雀发布（v1/v2 流量切分 90/10）| 金丝雀发布配置 |
| **Day 49** | 测试 Istio 故障注入（延迟 + HTTP 错误）| 故障注入测试 |
| **Day 50** | 配置 HPA 基于 QPS 自动扩缩容 | QPS-based HPA |
| **Day 51** | 实施 PodDisruptionBudget 保障可用性 | PDB 配置 |
| **Day 52** | 用 Velero 备份 vLLM 服务的 PVC 和配置 | 备份演练 |
| **Day 53** | 编写 docker-compose 本地开发环境 | docker-compose.yml |
| **Day 54** | 撰写《生产级 LLM 服务部署检查清单》| 检查清单文档 |

---

## 阶段 5：项目整合与求职准备（Day 55-70）

### 第 6 周：项目展示与文档（Day 55-62）

| Day | 任务 | 产出 |
|-----|------|------|
| **Day 55** | 整理所有代码，添加 README 和架构图 | 完善 GitHub 仓库 |
| **Day 56** | 录制 3 分钟项目演示视频 | 演示视频 + 链接 |
| **Day 57-58** | 写技术博客：《如何在 K3s 上部署和优化 LLM 推理服务》| Medium/知乎 文章 |
| **Day 59-60** | 中文版本发到掘金 | 掘金文章 |
| **Day 61** | 整理压测报告和优化报告 | PDF 报告 |
| **Day 62** | 创建项目演示网站（GitHub Pages）| 项目主页 |

### 第 7 周：简历与面试准备（Day 63-70）

| Day | 任务 | 产出 |
|-----|------|------|
| **Day 63** | 总结 3 个 STAR 故事（部署/优化/排障）| STAR 故事卡 |
| **Day 64** | 整理 AI Infra 常见面试题 | 面试题库 |
| **Day 65** | 更新简历，突出项目经历 | 简历 v1 |
| **Day 66** | 模拟面试（LLM 推理 + K8s 场景）| 面试练习 |
| **Day 67** | 筛选 10 家目标公司，了解岗位要求 | 目标公司列表 |
| **Day 68** | 准备中文自我介绍和项目介绍 | 中文话术 |
| **Day 69** | 准备英文自我介绍和项目介绍 | 英文话术 |
| **Day 70** | 投递第一批简历 | 投递记录 |

---

## 附录：关键产出物清单

| 类型 | 文件 | 说明 |
|------|------|------|
| 代码 | `llm-service/Dockerfile` | vLLM 容器镜像 |
| 代码 | `llm-service/deployment.yaml` | K8s 部署清单 |
| 代码 | `llm-service/fastapi-wrapper/` | FastAPI 封装代码 |
| 文档 | `docs/k3s-vllm-deployment-guide.md` | 部署指南 |
| 文档 | `docs/benchmark-report.md` | 压测报告 |
| 文档 | `docs/optimization-summary.md` | 优化总结 |
| 文档 | `docs/production-checklist.md` | 生产检查清单 |
| 博客 | `blog/k3s-vllm-optimization.md` | 技术博客 |
| 演示 | `demo/` | 演示视频 + 截图 |

---

## 关键区别：v2 与原计划

| 维度 | 原计划 | v2 修订版 |
|------|--------|-----------|
| 侧重点 | 通用 LLM 推理优化 | **K8s + LLM 深度融合** |
| 部署 | 本地运行 | **K3s 集群部署 + Istio** |
| 压测 | 本地压测 | **集群内压测 + 可观测性** |
| 优化 | 仅模型参数 | **模型参数 + K8s 资源调度** |
| 最终交付 | 本地服务 | **生产级 K8s 服务 + 文档** |

---

## 里程碑检查点

- **Day 26**：vLLM 在 K3s 上成功运行并通过 Istio 对外访问
- **Day 33**：完成首轮压测，拿到基线数据
- **Day 40**：完成 4 种优化技术的对比
- **Day 54**：服务完成封装，具备认证、监控、灰度能力
- **Day 62**：项目完整展示，可对外宣讲
- **Day 70**：简历投递，开始面试流程
