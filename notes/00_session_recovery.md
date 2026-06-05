
Session Recovery Info
Last Updated
June 5, 2026 - End of Day 4

Current Status
vLLM 0.22.0 currently serving GPTQ model (or can switch)

Models available: Qwen2-1.5B (FP16, AWQ, GPTQ)

RTX 5060 Ti (SM 12.0) with PyTorch CUDA 13.0

Completed
Day 1: Environment setup, vLLM deployment, cross-node inference

Day 2: OpenAI API, sampling parameters, performance benchmarks

Day 3: Quantization with AWQ, 4.3x speedup, 26% memory reduction

Day 4: GPTQ quantization, comparison with AWQ (similar performance)

Performance Summary
Model	Latency (50 tokens)	Memory	Notes
FP16	~1.0 s	12.9 GB	Baseline
AWQ	~0.23 s	9.5 GB	4.3x faster
GPTQ	~0.23 s	9.6 GB	Similar to AWQ
Next (Day 5)
RAG pipeline (document loading, vector store, retrieval)

Or try larger model (e.g., Phi-3-mini)

Set up monitoring (Prometheus + Grafana)

Quick Recovery (GPTQ)

cd ~/ai_infra_learning
source venv310/bin/activate
export VLLM_USE_FLASHINFER_SAMPLER=0
python -m vllm.entrypoints.openai.api_server \
  --model ./qwen2-gptq \
  --quantization gptq \
  --gpu-memory-utilization 0.5

Quick Recovery (AWQ)

python -m vllm.entrypoints.openai.api_server \
  --model ./qwen2-awq \
  --quantization awq_marlin \
  --gpu-memory-utilization 0.5
