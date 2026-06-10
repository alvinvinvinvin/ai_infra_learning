
Session Recovery Info
Last Updated
June 9, 2026 - End of Day 6

Current Status
vLLM 0.22.0 serving Phi-3-mini (3.8B) on port 8000

RAG pipeline optimized with similarity threshold + improved prompt

Embedding model: all-MiniLM-L6-v2 (384-dim)

Similarity threshold: 1.2

Completed
Day 1: vLLM deployment, environment setup

Day 2: OpenAI API, sampling parameters

Day 3: AWQ quantization

Day 4: GPTQ quantization comparison

Day 5: RAG pipeline (Chroma + embeddings + vLLM)

Day 6: RAG optimization (threshold, prompt, Phi-3-mini, understanding embedding distance & dimensions)

Key Learnings
Phi-3-mini follows instructions much better than Qwen2-1.5B

L2 distance measures semantic similarity (smaller = more similar)

384-dim vectors come from 12 attention heads × 32 dim/head

Embedding model and LLM serve different roles in RAG

Next (Day 7)
Set up monitoring (Prometheus + Grafana)

Containerization (Docker)

Or continue RAG enhancements

Quick Recovery

cd ~/ai_infra_learning
source venv310/bin/activate
export VLLM_USE_FLASHINFER_SAMPLER=0
python -m vllm.entrypoints.openai.api_server \
  --model ./phi3-mini \
  --trust-remote-code \
  --gpu-memory-utilization 0.7
