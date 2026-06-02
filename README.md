# AI Infrastructure Engineer Learning Journey

## 项目概述
这个仓库记录了我从零开始学习 AI Infrastructure 的完整过程。

## 学习路线
- [x] Week 1: 跑通第一个 LLM 推理
- [ ] Week 2-3: 性能测试与优化
- [ ] Week 4-5: 封装为可部署服务
- [ ] Week 6-8: 生产化与监控

## 环境配置
- OS: WSL2 (Ubuntu)
- GPU: NVIDIA GeForce RTX 5060 Ti (16GB)
- CUDA: 13.0
- PyTorch: 2.13.0.dev
- vLLM: 0.22.0

## 快速启动
```bash
source venv310/bin/activate
python -m vllm.entrypoints.api_server --model /home/cheer/qwen2 --gpu-memory-utilization 0.7
