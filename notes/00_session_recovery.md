# Session Recovery Info

## Last Updated
June 3, 2026 - End of Day 2

## Current Status
- vLLM 0.22.0 OpenAI-compatible server running on port 8000
- Model: Qwen2-1.5B-Instruct
- VLLM_USE_FLASHINFER_SAMPLER=0 (PyTorch-native sampler)
- RTX 5060 Ti (SM 12.0) with PyTorch CUDA 13.0

## Completed
- [x] Day 1: Environment setup, vLLM deployment, local + cross-node inference
- [x] Day 2: OpenAI API, sampling parameters, performance benchmarks

## Next (Day 3)
- [ ] Try different model (Phi-3-mini / Mistral-7B)
- [ ] Learn about quantization (AWQ, GPTQ)
- [ ] Basic RAG implementation

## Quick Recovery
```bash
cd ~/ai_infra_learning
source venv310/bin/activate
export VLLM_USE_FLASHINFER_SAMPLER=0
python -m vllm.entrypoints.openai.api_server --model /home/cheer/qwen2 --gpu-memory-utilization 0.7
