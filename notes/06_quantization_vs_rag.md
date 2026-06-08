# Quantization (GPTQ/AWQ) vs RAG: What's the Difference?

You've now learned two powerful techniques. This note clarifies the difference and shows how they work together.

## The Short Answer

| Technique | Goal | Layer |
|-----------|------|-------|
| **Quantization (GPTQ/AWQ)** | Compress the model to use less memory and run faster | Model weights |
| **RAG** | Give the model access to external knowledge to reduce hallucinations | Application pipeline |

**They are orthogonal** – you can use one without the other, but they work great together.

## Detailed Comparison

| Aspect | GPTQ / AWQ (Quantization) | RAG (Retrieval-Augmented Generation) |
|--------|---------------------------|----------------------------------------|
| **Problem it solves** | Model too big for GPU; inference too slow | Model hallucinates; lacks up-to-date or private knowledge |
| **How it works** | Reduces precision of weights (FP16 → INT4) | Retrieves relevant documents and adds them to prompt |
| **Effect on model** | Changes the model itself (compressed) | Leaves model unchanged; changes input |
| **Impact on accuracy** | Slight loss (usually 1-2%) | Can greatly improve factual accuracy |
| **Impact on speed** | 2-4x faster | Adds retrieval latency (typically 0.1-0.5s) |
| **Impact on memory** | 50-75% reduction | Adds vector DB memory (minimal) |
| **Setup complexity** | Find/download quantized model | Set up vector DB and embedding pipeline |

## Visual Analogy

Quantization = JPEG compression for images

Same image, smaller file, slightly lower quality

Works on the file itself

RAG = Allowing open-book exam

Student (LLM) can look up information during test

Changes how student answers, not the student


## How They Work Together

In your RAG demo (`rag_demo.py`), you are using BOTH:

```python
MODEL_NAME = "./qwen2-awq"  # ← Quantized model (smaller, faster)

Then RAG adds context retrieval on top:

User Question → Retrieve documents → Add to prompt → Quantized LLM → Answer

Why combine them?

If you use...	You get...
Only RAG	Accurate answers, but model still slow and memory-heavy
Only Quantization	Fast, small model, but still hallucinates
Both (your setup)	Fast, small, AND accurate with external knowledge ✅
Common Confusion
Q: "GPTQ" sounds similar to "RAG" – are they related?
A: No. GPTQ is a quantization method (Day 4). RAG is an application architecture (Day 5). Similar naming, completely different concepts.

Q: Can I use RAG with a non-quantized model?
A: Yes. RAG works with any LLM, quantized or not.

Q: Can I use quantization without RAG?
A: Yes. Quantization is purely about model size/speed.

When to Use Which (Decision Guide)
Scenario	Recommendation
Model doesn't fit on GPU	Quantization first
Model fits but hallucinates	RAG first
Model too slow	Quantization first
Need private/up-to-date knowledge	RAG first
Model barely fits AND needs external knowledge	Both (your current setup)

Summary

Quantization (GPTQ/AWQ) = Make the model smaller and faster
RAG = Make the model smarter with external knowledge

You can (and often should) do both.
Your Experiment Status
Day	Technique	Status
Day 3	AWQ Quantization	✅ Completed
Day 4	GPTQ Quantization	✅ Completed
Day 5	RAG Pipeline	✅ Completed
Day 5+	AWQ + RAG	✅ Working together
References
Quantization notes: notes/03_quantization.md, notes/04_gptq.md

RAG notes: notes/05_rag_basics.md

Your working demo: code/scripts/rag_demo.py
