# AI Infrastructure Engineer 学习路线图（12周）

> 目标：从零基础到能够独立部署、优化、封装 LLM 推理服务，拥有可展示的项目作品，为求职 AI Infra 相关岗位做准备。

## 总体路线图

| 阶段 | 主题 | 目标 | 时长 |
|------|------|------|------|
| 1 | 跑通第一个 LLM 推理 | 能在自己机器上运行一个开源模型并调用 API | 2 周 |
| 2 | 性能测试与优化 | 学会测量吞吐、延迟，并使用关键优化技术 | 3 周 |
| 3 | 封装为可部署服务 | 制作 Docker 镜像、提供 REST API、压力测试 | 3 周 |
| 4 | 项目整合与求职准备 | 完善 GitHub、写技术博客、模拟面试 | 4 周 |

---

## 阶段 1：跑通第一个 LLM 推理（第 1-2 周）

**目标**：在你的 WSL2 + RTX 5060（或任何 NVIDIA GPU）上，用 vLLM 跑起一个 7B 模型，能通过 HTTP 请求得到回复。

### 第 1 周：环境准备与首次运行

**周任务**：
- 安装 Python 虚拟环境、vLLM、Hugging Face CLI
- 下载一个小模型（如 Qwen2-1.5B-Instruct，显存占用低）
- 成功启动 vLLM API 服务器并发送第一个请求

**每天任务**：

- **Day 1**：创建 Python 3.10+ 虚拟环境
- **Day 2**：安装 vLLM 和 Hugging Face Hub
- **Day 3**：下载 Qwen2-1.5B-Instruct 模型
- **Day 4**：启动 vLLM API 服务器
- **Day 5**：用 curl 发送第一个请求
- **Day 6**：用 Python 脚本调用 API
- **Day 7**：整理本周笔记，写 README.md

### 第 2 周：理解基本概念，换一个模型

**周任务**：
- 跑通 Llama 2 7B 或 Mistral 7B
- 学会用 nvidia-smi 观察显存占用和 GPU 利用率
- 尝试调整 vLLM 参数（--max-model-len, --gpu-memory-utilization）

**每天任务**：

- **Day 8**：下载 Llama 2 7B（需要 Hugging Face 授权）
- **Day 9**：启动 Llama 2 7B，观察显存
- **Day 10**：显存不足时，学习使用 GPTQ 量化模型
- **Day 11**：用 GPTQ 模型启动 vLLM（--quantization gptq）
- **Day 12**：对比 FP16 和 GPTQ 的性能差异
- **Day 13**：学习 vLLM 核心参数，尝试修改
- **Day 14**：整理对比报告，发到 GitHub 仓库

---

## 阶段 2：性能测试与优化（第 3-5 周）

**目标**：学会使用基准测试工具，应用关键优化技术，理解 batching 和量化。

### 第 3 周：基准测试基础

- **Day 15**：安装压测工具（locust 或 hey）
- **Day 16**：学习 vLLM 内置的 benchmark_throughput.py
- **Day 17**：测试不同并发数（1, 4, 8, 16）
- **Day 18**：画图表，理解并发与吞吐的关系
- **Day 19**：尝试开启 --enable-prefix-caching
- **Day 20**：尝试调整 --block-size 参数
- **Day 21**：写笔记《如何对 LLM 推理进行基准测试》

### 第 4 周：优化技术实践

- **Day 22**：对比 vLLM 与 Hugging Face pipeline 的吞吐差异
- **Day 23**：学习量化原理，使用 bitsandbytes 加载 4-bit 模型
- **Day 24**：尝试 AWQ 量化模型（--quantization awq）
- **Day 25**：测试投机解码（speculative decoding）
- **Day 26**：了解张量并行原理
- **Day 27**：测试系统提示的影响
- **Day 28**：整理《LLM 推理优化技巧清单》

### 第 5 周：真实场景模拟

- **Day 29**：设计随机负载模式
- **Day 30**：运行 10 分钟压测，记录 P50/P99 延迟
- **Day 31**：用 Docker Compose 启动两个 vLLM 服务
- **Day 32**：用 nvidia-smi --query-gpu 记录显存/功耗
- **Day 33**：用 nvidia-smi dmon 持续监控 GPU
- **Day 34**：给出硬件最佳配置建议
- **Day 35**：写博客《如何在单张 RTX 5060 Ti 上榨干 Llama 2 7B 的推理性能》

---

## 阶段 3：封装为可部署服务（第 6-8 周）

**目标**：将优化后的模型打包成 Docker 镜像，提供生产可用的 REST API，并有压力测试报告。

### 第 6 周：容器化

- **Day 36**：编写 Dockerfile（基于 nvidia/cuda）
- **Day 37**：构建镜像，本地测试 GPU
- **Day 38**：修改启动命令，使容器外可访问
- **Day 39**：编写 docker-compose.yml
- **Day 40**：实现优雅关闭（graceful shutdown）
- **Day 41**：添加健康检查端点 /health
- **Day 42**：推送到 Docker Hub，写 README

### 第 7 周：API 增强与可观测性

- **Day 43**：用 FastAPI 添加 /tokenize 端点
- **Day 44**：添加流式响应（SSE）
- **Day 45**：集成 Prometheus 指标
- **Day 46**：配置 Grafana 监控面板
- **Day 47**：设置日志轮转
- **Day 48**：实现 API 密钥认证
- **Day 49**：整理《生产化 LLM 服务的检查清单》

### 第 8 周：压力测试与调优报告

- **Day 50**：用 locust 编写场景
- **Day 51**：压测，找到系统瓶颈
- **Day 52**：调整 --num-scheduler-steps 重新压测
- **Day 53**：测试 Nginx 反向代理的影响
- **Day 54**：写压测报告
- **Day 55**：录制 3 分钟演示视频
- **Day 56**：上传 GitHub，完善 README

---

## 阶段 4：项目整合与求职准备（第 9-12 周）

**目标**：将项目转化为简历亮点，开始面试和接单。

### 第 9 周：文档与社区

- **Day 57-58**：整理博客发到 Medium/知乎
- **Day 59-60**：中文版本发到掘金
- **Day 61**：给开源项目提 PR
- **Day 62**：参与社区讨论
- **Day 63**：更新 LinkedIn

### 第 10 周：模拟面试与简历

- **Day 64**：总结 3 个 STAR 故事
- **Day 65**：整理常见面试问题
- **Day 66**：模拟面试
- **Day 67**：写 AI Infra 岗位简历
- **Day 68**：搜索职位，了解要求
- **Day 69**：筛选 10 家目标公司
- **Day 70**：准备作品集

### 第 11 周：开始投递与接单

- **Day 71-72**：修改简历并投递
- **Day 73**：准备中文自我介绍
- **Day 74**：准备英文自我介绍
- **Day 75**：针对性准备面试
- **Day 76**：开始 Upwork 小单
- **Day 77**：总结经验教训

### 第 12 周：总结与迭代

- **Day 78-80**：根据反馈补强短板
- **Day 81-83**：学习一个额外框架（如 Triton）
- **Day 84**：规划下一个 12 周

---

## 当前进度

**当前位置**：阶段 1 之前（准备开始）

**已完成前置学习**：
- Kubernetes 基础 (K3s)
- Istio 服务网格
- 容器化基础

**下一步**：开始 Day 1 - 创建 Python 虚拟环境
