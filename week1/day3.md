# Day 3 - June 4, 2026

## Today's Goals
- [x] Learn about quantization: AWQ, GPTQ
- [x] Download and run AWQ quantized Qwen2-1.5B
- [x] Compare performance (latency & memory) with FP16 baseline
- [x] Understand trade-offs between quantization methods

## Environment
- GPU: NVIDIA GeForce RTX 5060 Ti (16GB, SM 12.0)
- PyTorch: 2.13.0.dev20260601+cu130 (CUDA 13.0)
- vLLM: 0.22.0
- Models: Qwen2-1.5B-Instruct (FP16) vs AWQ (INT4)

## What is Quantization?

Quantization reduces model precision from FP16 (16-bit) to lower bit-widths like INT8 (8-bit) or INT4 (4-bit). Benefits:
- **Smaller memory footprint** (e.g., 75% reduction for INT4)
- **Faster inference** (less memory bandwidth, possible kernel optimizations)
- **Lower energy consumption**

Trade-off: slight accuracy loss (often negligible for many tasks).

## AWQ (Activation-aware Weight Quantization)

AWQ protects important weights based on activation distribution:
- **Key idea**: Not all weights are equally important
- **Method**: Observe activation magnitudes to decide which weights to keep at higher precision
- **Result**: Better accuracy than GPTQ for same bit-width, especially for generation tasks

## Performance Comparison

### FP16 Baseline (from Day 2)
- Memory used: ~12.9 GB
- Latency (50 tokens): ~1.0 s

### AWQ INT4 (today)
- Model size: 1.5 GB (vs 2.98 GB)
- Memory used: **9.5 GB** (26% less than FP16)
- Latency (50 tokens, after warmup): **0.23 s** (4.3x faster!)

### Key Observations
- First request took ~0.93s due to JIT compilation / CUDA graph capture
- Subsequent requests are consistently fast
- vLLM automatically handles KV cache, which still consumes memory but benefits from quantization

## Useful Commands

```bash
# Download AWQ model
hf download Qwen/Qwen2-1.5B-Instruct-AWQ --local-dir ./qwen2-awq

# Run with AWQ (using awq_marlin backend for best performance)
export VLLM_USE_FLASHINFER_SAMPLER=0
python -m vllm.entrypoints.openai.api_server \
  --model ./qwen2-awq \
  --quantization awq_marlin \
  --gpu-memory-utilization 0.5

# Quick benchmark
for i in {1..5}; do
  curl -s -o /dev/null -w "%{time_total}\n" \
    http://localhost:8000/v1/completions \
    -H "Content-Type: application/json" \
    -d '{"model":"./qwen2-awq","prompt":"What is AI?","max_tokens":50}'
done
Next Steps (Day 4)
Try GPTQ quantization for comparison

Explore other model families (Phi-3, Mistral)

Set up simple RAG pipeline
