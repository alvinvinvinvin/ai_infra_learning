# Quantization Techniques for LLMs

## Why Quantize?
- Reduce memory footprint → run larger models on limited GPU
- Speed up inference → less data movement, specialized kernels
- Lower cost → use cheaper GPUs or serve more users

## Common Bit-Widths

| Format | Bits per param | Size reduction | Typical use |
|--------|----------------|----------------|--------------|
| FP32 | 32 | 0% | Training, high precision |
| FP16 | 16 | 50% | Default for inference |
| INT8 | 8 | 75% | Good balance |
| INT4 | 4 | 87.5% | Aggressive, popular |
| INT2 | 2 | 93.75% | Extreme, often inaccurate |

## Main Quantization Methods

### GPTQ (GPT Quantization)
- **Based on**: Optimal Brain Quantization (OBQ)
- **How**: Quantize weights layer by layer, compensate error with Hessian
- **Strengths**: Fast, good accuracy for many models
- **Weaknesses**: Requires calibration data, may not be optimal for all architectures

### AWQ (Activation-aware Weight Quantization)
- **Based on**: Observation that not all weights are equally important
- **How**: Protect important weights (based on activation distribution) from quantization
- **Strengths**: Better accuracy than GPTQ for generation tasks, no calibration needed
- **Weaknesses**: Slightly slower than GPTQ in some backends

### Others
- **GGUF** (GGML Universal Format): Popular for CPU inference
- **bitsandbytes (bnb)**: Easy to use in transformers, supports 4-bit and 8-bit
- **QLoRA**: Fine-tune quantized models (4-bit base + adapters)

## vLLM Support
| Method | vLLM argument | Backend |
|--------|---------------|---------|
| AWQ | `--quantization awq` or `awq_marlin` | AWQ / Marlin |
| GPTQ | `--quantization gptq` | GPTQ / Marlin |
| Marlin | `--quantization marlin` | Specialized for GPTQ/AWQ |

- **Marlin** is a faster kernel for quantized models. If detected, vLLM suggests using `awq_marlin` for better performance.

## Practical Tips
- Always benchmark accuracy and speed yourself; numbers vary per model/task
- Use `awq_marlin` when possible (faster than plain `awq`)
- For very large models, consider using `--gpu-memory-utilization` lower than 0.9 to leave room for KV cache
- Calibration data matters for GPTQ; AWQ is more robust without it

## Quick Reference
FP16 → AWQ INT4: ~75% weight size reduction, 4-5x speedup possible
Memory: Model weights + KV cache + overhead
Latency: First request warmup, then steady
Best for: Production deployments, cost-sensitive inferenceEOF

echo "✅ notes/03_quantization.md created"
