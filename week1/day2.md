# Day 2 - June 3, 2026

## Today's Goals
- [x] Resolve FlashInfer compatibility issue with RTX 5060 Ti (SM 12.0)
- [x] Launch vLLM with OpenAI-compatible API server
- [x] Test `/v1/completions` and `/v1/chat/completions` endpoints
- [x] Understand sampling parameters: Temperature, Top P, Frequency Penalty
- [x] Run basic performance benchmarks

## Environment
- GPU: NVIDIA GeForce RTX 5060 Ti (16GB, SM 12.0)
- PyTorch: 2.13.0.dev20260601+cu130 (CUDA 13.0)
- vLLM: 0.22.0
- Model: Qwen2-1.5B-Instruct

## Problems Solved

### FlashInfer Still Not Compatible with SM 12.0
Even with `VLLM_USE_FLASHINFER_SAMPLER=0` set, the default API server still used FlashInfer.

**Solution**: Use the OpenAI-compatible entrypoint instead:

```bash
python -m vllm.entrypoints.openai.api_server \
  --model /home/cheer/qwen2 \
  --gpu-memory-utilization 0.7

Key Concepts Learned
Temperature
Controls randomness in generation. Higher temperature = more creative/random.

Temperature	Behavior	Use Case
0.1-0.3	Deterministic	Code, facts
0.7-1.0	Balanced	Conversation
1.2-1.5	Creative	Brainstorming
Top P (Nucleus Sampling)
Limits sampling to tokens whose cumulative probability reaches P.

Top P	Effect
0.5	Only obvious choices
0.9-1.0	Standard range
Frequency Penalty
Penalizes repeated tokens to reduce repetition.

Test Results
Temperature Comparison
temperature=0.1: " blue. This is because when light from the" (conservative)

temperature=1.5: More varied/creative output

Performance Benchmark
Average latency: ~1.0s for 50 output tokens

Throughput: ~50 tokens/s

Useful Commands

# Start OpenAI-compatible server
export VLLM_USE_FLASHINFER_SAMPLER=0
python -m vllm.entrypoints.openai.api_server --model /home/cheer/qwen2 --gpu-memory-utilization 0.7

# Test completions endpoint
curl -s http://localhost:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"/home/cheer/qwen2","prompt":"Hello","max_tokens":50}'

# Test chat endpoint
curl -s http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"/home/cheer/qwen2","messages":[{"role":"user","content":"Hello"}],"max_tokens":50}'

