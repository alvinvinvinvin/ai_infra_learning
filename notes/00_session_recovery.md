# Session Recovery Info

## Last Updated
June 4, 2026 - End of Day 3

## Current Status
- vLLM 0.22.0 running with AWQ quantized Qwen2-1.5B (awq_marlin backend)
- Model: ./qwen2-awq, quantization: awq_marlin
- Port: 8000, VLLM_USE_FLASHINFER_SAMPLER=0
- RTX 5060 Ti (SM 12.0) with PyTorch CUDA 13.0

## Completed
- [x] Day 1: Environment setup, vLLM deployment, local + cross-node inference
- [x] Day 2: OpenAI API, sampling parameters, performance benchmarks
- [x] Day 3: Quantization (AWQ), model comparison, latency and memory gains

## Key Metrics (AWQ vs FP16)
- Memory: 9.5 GB vs 12.9 GB (26% reduction)
- Latency (50 tokens): 0.23 s vs 1.0 s (4.3x faster)

## Next (Day 4)
- [ ] Try GPTQ quantization
- [ ] Experiment with other models (Phi-3, Mistral)
- [ ] Build a simple RAG pipeline

## Quick Recovery
```bash
cd ~/ai_infra_learning
source venv310/bin/activate
export VLLM_USE_FLASHINFER_SAMPLER=0
python -m vllm.entrypoints.openai.api_server \
  --model ./qwen2-awq \
  --quantization awq_marlin \
  --gpu-memory-utilization 0.5
