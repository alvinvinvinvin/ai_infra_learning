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

## Understanding `--max-num-seqs` and the "Maximum Concurrency" Log

While tuning today, we saw this log line:
Maximum concurrency for 32,768 tokens per request: 6.77x

This caused confusion: does it mean we should set `--max-num-seqs` to ≤ 6? No.

### What does the log value mean?

It represents a **worst‑case theoretical limit** assuming **every request uses the full context length** (`max_model_len=32768`). In that extreme scenario, the KV cache can hold only ~6.77 requests simultaneously.

### Why can we set `--max-num-seqs` much higher (e.g., 128 or 256)?

Because real requests are usually **short**. For example:
- A typical prompt + completion uses only ~100 tokens.
- Per‑request KV cache consumption is ~100/32768 ≈ 0.3% of the worst‑case size.
- Therefore, the same GPU memory can comfortably handle hundreds of concurrent short requests.

### What determines the maximum concurrency calculation?

vLLM computes it as:
KV Cache total size (allocated from GPU memory by gpu_memory_utilization)
──────────────────────────────────────────────────────────────────────────
KV Cache per request (based on max_model_len and model architecture)

This is a **static safety estimate**, not a runtime limit.

### How should you set `--max-num-seqs` for real workloads?

1. **Start high** (e.g., 128 or 256) – the default is fine.
2. **Run your real workload** while monitoring GPU memory (`nvidia-smi`) and vLLM logs.
3. **If you see OOM or preemption warnings**, reduce `--max-num-seqs`.
4. **If memory is under‑utilized**, increase `--max-num-seqs` to boost throughput.

For short‑text experiments like ours, a high value (128‑256) is safe and provides good throughput. The log's "6.77x" is a **worst‑case reference**, not a hard cap.

### Summary

| Concept | Meaning | Practical use |
|---------|---------|----------------|
| `Maximum concurrency` (log) | Worst‑case concurrency if every request fills `max_model_len` | Reference for extreme upper bound |
| `--max-num-seqs` (CLI) | User‑defined limit on concurrently processing sequences | Tune based on actual request lengths and GPU memory |

**Key takeaway**: Don't be misled by the low log value. For short requests you can safely set `--max-num-seqs` to 128 or higher.
