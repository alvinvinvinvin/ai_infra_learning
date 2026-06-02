#!/bin/bash
cd ~/ai_infra_learning
source venv310/bin/activate
python -m vllm.entrypoints.api_server
--model /home/cheer/qwen2
--gpu-memory-utilization 0.7
