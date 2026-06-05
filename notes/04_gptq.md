
GPTQ Quantization
Overview
GPTQ (Generative Pre-trained Transformer Quantization) is a post-training quantization method that compresses LLM weights to 4-bit or lower while maintaining accuracy. It was introduced in the paper "GPTQ: Accurate Post-Training Quantization for Generative Pre-trained Transformers" (2023).

How GPTQ Works
Layer-wise quantization: Each layer is quantized independently.

Hessian information: Uses second-order derivatives to estimate the importance of each weight.

Error compensation: After quantizing a weight, GPTQ updates the remaining unquantized weights to compensate for the error.

Batch processing: Processes weights in batches (e.g., 128 at a time) for efficiency.

Strengths and Weaknesses
Aspect	Assessment
Accuracy	Very good, often near FP16
Speed	Fast quantization (minutes for 7B models)
Calibration	Requires calibration data (typically 128-2048 samples)
Hardware support	Supported by vLLM, TGI, AutoGPTQ, ExLlama
Memory reduction	~75% for INT4 (e.g., 3GB → 0.75GB weights)
GPTQ vs AWQ vs FP16
Method	Weight size (7B)	Inference speed	Accuracy	Calibration data
FP16	14 GB	baseline	100%	N/A
AWQ INT4	~3.5 GB	~2-3x faster	~99%	Optional (default uses random data)
GPTQ INT4	~3.5 GB	~2-3x faster	~99%	Required (often 128 samples)
Using GPTQ with vLLM
python -m vllm.entrypoints.openai.api_server \
  --model path/to/gptq-model \
  --quantization gptq \
  --gpu-memory-utilization 0.5
For faster inference with Marlin kernel (if supported):
# vLLM automatically uses marlin backend when available
# No special flag needed, just ensure the model is GPTQ format
Popular GPTQ models
TheBloke/Llama-2-7B-Chat-GPTQ

TheBloke/Mistral-7B-Instruct-v0.2-GPTQ

Qwen/Qwen2-1.5B-Instruct-GPTQ-Int4

References
Original paper: GPTQ: Accurate Post-Training Quantization for Generative Pre-trained Transformers

vLLM documentation on quantization: https://docs.vllm.ai/en/latest/quantization/

## Real‑world Industrial Use Cases & Selection Guide

### When to Prefer AWQ

AWQ is ideal when you need **fast deployment without calibration data** or when the target use case involves **unpredictable, diverse prompts** (e.g., chatbots, code completion, creative writing). Because AWQ doesn’t rely on a fixed calibration set, it generalizes better to out‑of‑distribution inputs.

**Industrial examples**:
- **Customer support chatbot** – user queries vary widely; recalibration impractical.
- **Code completion** (GitHub Copilot style) – the prompt distribution changes continuously.
- **Real‑time translation** – low latency and adaptability are key.
- **Voice assistants** – short, diverse utterances.

### When to Prefer GPTQ

GPTQ shines when you have **a representative calibration dataset** and care about **theoretical accuracy bounds** – for instance, offline batch processing, document summarization, or tasks where the input distribution is stable.

**Industrial examples**:
- **Document summarization (RAG backend)** – you can sample real documents for calibration.
- **Data labelling / entity extraction** – the input format is fixed (e.g., legal contracts, medical records).
- **Batch inference pipelines** (e.g., nightly user review classification) – you can run calibration once.
- **Academic / research comparisons** – GPTQ's error‑compensation math is well understood.

### How an AI Infrastructure Engineer Chooses

Use this decision flow:

1. **Do you have a representative calibration dataset?**  
   - No → **AWQ** (simpler, no risk of overfitting).  
   - Yes → continue.

2. **Is the model >7B or the context length >8k?**  
   - Yes → both will show similar performance; pick the one with better kernel support (e.g., `awq_marlin` if available).  
   - No → continue.

3. **Run a small A/B test with your actual workload** (like you did today).  
   - If latency or memory differs significantly → use the better one.  
   - If they are tied → use the **format that is more widely supported** by the community (often GPTQ because of AutoGPTQ and ExLlama) or the one that is **already provided by the model author**.

4. **Production consideration**: Monitor GPU memory usage and preemption events. If you see frequent preemption, lower `--max-num-seqs` regardless of the quantization method.

### Summary Table

| Condition | Recommended method |
|-----------|--------------------|
| No calibration data | AWQ |
| Stable input distribution + strict accuracy requirements | GPTQ |
| Both produce same performance in your test | Either – tie‑break by ecosystem support |
| Marlin‑compatible GPU (Ampere/Turing/Ada/Blackwell) | Both benefit equally; use `awq_marlin` or marlin‑aware GPTQ |

**Key takeaway**: For many real‑world scenarios (like your RTX 5060 Ti + short prompts), AWQ and GPTQ are **functionally equivalent**. The decision then reduces to **availability** (which quantized version of the model is already released) and **operational simplicity** (AWQ needs no calibration). As an AI Infra Engineer, your job is to **measure, not guess** – exactly what you did today.
