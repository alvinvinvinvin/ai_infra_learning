#!/bin/bash
cd ~/ai_infra_learning
source venv310/bin/activate
export VLLM_USE_FLASHINFER_SAMPLER=0
python -m vllm.entrypoints.openai.api_server \
  --model /home/cheer/qwen2 \
  --gpu-memory-utilization 0.7 \
  --port 8000
