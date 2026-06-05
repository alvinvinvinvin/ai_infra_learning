# Day 4 - June 5, 2026

## Today's Goal
- [x] Download and run GPTQ quantized Qwen2-1.5B
- [x] Compare performance (latency & memory) with AWQ baseline
- [x] Understand differences between AWQ and GPTQ quantization methods

## Environment
- GPU: NVIDIA GeForce RTX 5060 Ti (16GB, SM 12.0)
- vLLM: 0.22.0
- Models: Qwen2-1.5B-Instruct-AWQ vs GPTQ-Int4

## GPTQ Quantization

**GPTQ (Generative Pre-trained Transformer Quantization)** is another popular post-training quantization method.

### How it works
- Uses second-order error compensation (Hessian information)
- Quantizes weights layer by layer
- Adjusts remaining weights to minimize reconstruction error

### Key differences from AWQ

| Aspect | AWQ | GPTQ |
|--------|-----|------|
| Principle | Protect important weights via activation observation | Layer-wise error compensation using Hessian |
| Calibration data | Not required | Typically needs ~128 samples |
| Accuracy on generation tasks | Very good | Good, sometimes slightly lower |
| vLLM backend | awq / awq_marlin | gptq / marlin |

## Performance Comparison: AWQ vs GPTQ

| Model | Stable Latency (50 tokens) | Memory Usage | First request latency |
|-------|----------------------------|--------------|----------------------|
| AWQ (awq_marlin) | ~0.223 s | 9.5 GB | 0.93 s |
| GPTQ (gptq) | ~0.223 s | 9.6 GB | 0.97 s |

### Observations
- Both achieve nearly identical performance on this model/hardware
- Memory difference is negligible (9.5 vs 9.6 GB)
- First request latency similar (both include JIT compilation overhead)
- For Qwen2-1.5B, AWQ and GPTQ are equally viable

## Commands used

```bash
# Download GPTQ model
hf download Qwen/Qwen2-1.5B-Instruct-GPTQ-Int4 --local-dir ./qwen2-gptq

# Run GPTQ service
export VLLM_USE_FLASHINFER_SAMPLER=0
python -m vllm.entrypoints.openai.api_server \
  --model ./qwen2-gptq \
  --quantization gptq \
  --gpu-memory-utilization 0.5

# Benchmark
for i in {1..5}; do
  curl -s -o /dev/null -w "%{time_total}\n" \
    http://localhost:8000/v1/completions \
    -H "Content-Type: application/json" \
    -d '{"model":"./qwen2-gptq","prompt":"What is AI?","max_tokens":50}'
done
Conclusion
Both AWQ and GPTQ provide similar speed and memory benefits. The choice between them may depend on model availability, calibration data requirements, or specific hardware optimizations (e.g., Marlin kernel supports both). For this setup, either works perfectly.

Next Steps (Day 5)
Explore other model families (Phi-3, Mistral)

Set up RAG pipeline (retrieval + generation)

Monitor production metrics (Prometheus + Grafana)
