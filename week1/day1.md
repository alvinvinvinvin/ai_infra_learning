
Day 1 - 2026-06-02
✅ 今日成果
在 WSL2 中配置 Python 3.10 环境

安装支持 RTX 5060 Ti 的 PyTorch Nightly (CUDA 13.0)

成功运行 vLLM 0.22.0 API 服务

本地和跨节点（通过 Tailscale）推理成功

🐛 遇到的问题
C compiler missing → sudo apt install build-essential

Python.h not found → sudo apt install python3.10-dev

Python 3.14 太新 → 降级到 Python 3.10

PyTorch 不支持 sm_120 → 安装 Nightly (CUDA 13.0)

FlashInfer 不支持 sm_120 → 升级 vLLM 到 0.22.0

📝 测试输出
json
{"text":["Hello, who are you? I'm from the Netherlands..."]}
🎯 明日计划
学习 vLLM OpenAI 兼容 API

运行吞吐量基准测试
