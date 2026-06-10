# Day 6 - June 9, 2026

## Today's Goals
- [x] Optimize RAG with similarity threshold filtering
- [x] Improve prompt for better instruction following
- [x] Understand embedding distance and similarity scores
- [x] Understand embedding dimension (384) and why it matters
- [x] Understand attention heads in Transformer models
- [x] Compare Qwen2-1.5B vs Phi-3-mini for RAG
- [x] Learn the difference between embedding model and LLM

## RAG Optimization

### Problem Identified
The 1.5B model (Qwen2) didn't strictly follow the "answer only from context" instruction. When asked "What is the capital of France?", it answered "Paris" first, then said it couldn't answer.

### Solution 1: Similarity Threshold Filtering
Filter retrieved documents by distance score before sending to LLM.

```python
SIMILARITY_THRESHOLD = 1.2  # Chroma default
# Only use chunks with distance < threshold
relevant_chunks = [chunk for chunk, dist in zip(chunks, distances) if dist < THRESHOLD]
Solution 2: Improved Prompt
prompt = f"""You are a strict assistant that answers ONLY based on the provided context.

Rules:
- If the context contains the answer, answer based ONLY on the context.
- If the context does NOT contain the answer, reply EXACTLY: "I cannot answer this question based on the provided documents."
- Do not use any external knowledge.

Context: {context}
Question: {query}
Answer:"""
Solution 3: Model Upgrade
Phi-3-mini (3.8B) has much better instruction following than Qwen2-1.5B.

Performance Comparison: Qwen2-1.5B vs Phi-3-mini
Query	Qwen2-1.5B-AWQ	Phi-3-mini
"What is RTX 5060 Ti?"	✅ Correct	✅ Correct
"What is the capital of France?"	❌ "Paris... cannot answer"	✅ "I cannot answer"
"What is a GPU?"	✅ Used own knowledge	✅ "Cannot answer" (correct rejection)
Conclusion: Phi-3-mini is better for RAG due to superior instruction following.

Understanding Vector Distance
What is "distance"?
In Chroma (default L2 distance), it measures how similar two vectors are. Smaller distance = more similar.

Distance values (with all-MiniLM-L6-v2)
Range	Meaning	Example
0.0 - 0.5	Highly relevant	"RTX 5060 Ti" ↔ document about RTX 5060 Ti
0.5 - 1.0	Partially relevant	"GPU" ↔ document about RTX 5060 Ti
> 1.0	Weakly or unrelated	"Capital of France" ↔ document about graphics cards
How distance is calculated
Not hardcoded! Chroma computes it at query time:

Convert query text to vector (384-dim float array)

Convert each document chunk to vector

Compute L2 distance: √(Σ(query_i - doc_i)²)

Return chunks with smallest distances

Why 384 dimensions?
all-MiniLM-L6-v2 uses 384-dimensional vectors because:

Component	Value
Hidden dimension	384
Attention heads	12
Dimension per head	32
384 = 12 × 32

Why 12 attention heads?
The model is distilled from a teacher model (BERT-base) which has 12 heads

Preserving 12 heads maintains expressive power even with fewer layers

Each head learns to focus on different relationships in text (syntax, semantics, coreference, etc.)

Each dimension represents?
Individual dimensions don't have meaningful interpretations. The vector space as a whole represents semantic meaning. Similar texts cluster together in this 384-dimensional space.

The Two Models in Your RAG System
Component	Model	Role
Embedding (Retrieval)	all-MiniLM-L6-v2	Converts text to 384-dim vectors; Chroma calculates distances
LLM (Generation)	Phi-3-mini	Generates answers based on retrieved context
They serve different purposes and cannot be swapped arbitrarily.

Similarity Threshold Decision
Threshold	Effect	Recommendation
1.2 (loose)	Most queries enter generation phase	Depends on model's rejection ability
0.9 (strict)	Edge queries rejected early	Good for precision
0.7 (very strict)	Only highly relevant queries pass	May miss useful inference
With Phi-3-mini's good instruction following, a loose threshold works fine.

Key Takeaways
Small models (1.5B) struggle with instruction following → use larger models (3B+) for RAG

Similarity threshold pre-filters irrelevant content before generation

Distance is computed at query time, not hardcoded

384 dimensions = 12 attention heads × 32 dimensions per head

Embedding model ≠ LLM: they serve different purposes in RAG

Updated RAG Scripts
code/scripts/rag_optimized.py - With similarity threshold and improved prompt

code/scripts/rag_strict.py - With post-processing rejection

code/scripts/rag_demo.py - Original version

Commands to Run Optimized RAG

cd ~/ai_infra_learning
source venv310/bin/activate
export VLLM_USE_FLASHINFER_SAMPLER=0
python -m vllm.entrypoints.openai.api_server --model ./phi3-mini --trust-remote-code --gpu-memory-utilization 0.7

# In another terminal
python code/scripts/rag_optimized.py
Next Steps (Day 7)
Set up monitoring (Prometheus + Grafana)

Containerize the RAG pipeline (Docker)

Or continue with RAG enhancements (different vector DB, reranking)
