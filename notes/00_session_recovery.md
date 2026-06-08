# Session Recovery Info

## Last Updated
June 8, 2026 - End of Day 5

## Current Status
- vLLM 0.22.0 serving AWQ quantized Qwen2-1.5B
- RAG pipeline working with ChromaDB + sentence-transformers
- Models available: FP16, AWQ, GPTQ (Qwen2-1.5B)

## Completed
- [x] Day 1: Environment setup, vLLM deployment, cross-node inference
- [x] Day 2: OpenAI API, sampling parameters, performance benchmarks
- [x] Day 3: AWQ quantization, 4.3x speedup, 26% memory reduction
- [x] Day 4: GPTQ quantization, comparison with AWQ
- [x] Day 5: RAG pipeline (Chroma + embeddings + vLLM)

## RAG Demo
```bash
cd ~/ai_infra_learning
source venv310/bin/activate
python code/scripts/rag_demo.py

Known Limitations
Model doesn't strictly follow "answer only from context" instruction

Small model (1.5B) has weaker instruction following

No retrieval confidence threshold yet

Next (Day 6)
Improve RAG: confidence filtering, better prompts

Test with larger model (Phi-3-mini)

Set up monitoring (Prometheus + Grafana)

Quick Recovery

cd ~/ai_infra_learning
source venv310/bin/activate
export VLLM_USE_FLASHINFER_SAMPLER=0
python -m vllm.entrypoints.openai.api_server \
  --model ./qwen2-awq \
  --quantization awq_marlin \
  --gpu-memory-utilization 0.5

