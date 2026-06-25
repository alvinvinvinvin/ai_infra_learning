# AI Infra 学习快速参考

## 核心工具链
- **推理引擎**: vLLM
- **模型格式**: Hugging Face, GPTQ, AWQ
- **容器**: Docker, NVIDIA Container Toolkit
- **监控**: Prometheus, Grafana
- **压测**: Locust, hey

## 关键命令速查

### vLLM 启动
```bash
python -m vllm.entrypoints.openai.api_server \
    --model <model-name> \
    --port 8000 \
    --max-model-len 4096 \
    --gpu-memory-utilization 0.9
发送请求
bash
curl http://localhost:8000/v1/completions \
    -H "Content-Type: application/json" \
    -d '{"model": "<model-name>", "prompt": "Hello", "max_tokens": 100}'
GPU 监控
bash
nvidia-smi
nvidia-smi dmon
nvidia-smi --query-gpu=utilization.gpu,memory.used --format=csv
常用模型
模型	参数量	显存需求(FP16)	推荐量化
Qwen2-1.5B	1.5B	~3GB	-
Llama 2 7B	7B	~14GB	GPTQ 4-bit
Mistral 7B	7B	~14GB	GPTQ 4-bit
Llama 3 8B	8B	~16GB	GPTQ 4-bit
