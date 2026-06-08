# Day 5 - June 8, 2026

## Today's Goal
- [x] Build a simple RAG (Retrieval-Augmented Generation) pipeline
- [x] Integrate ChromaDB, sentence-transformers, and vLLM
- [x] Test retrieval and generation with sample documents
- [x] Understand limitations and trade-offs of RAG systems

## Environment
- GPU: NVIDIA GeForce RTX 5060 Ti (16GB)
- vLLM: 0.22.0 (serving Qwen2-1.5B-AWQ)
- Vector DB: Chroma (in-memory)
- Embedding: sentence-transformers/all-MiniLM-L6-v2
- Framework: LangChain (text splitters)

## What is RAG?

RAG combines **information retrieval** with **LLM generation** to answer questions based on a custom knowledge base.
User Question → Retrieve relevant documents → Build context prompt → LLM generates answer


Benefits:
- Reduces hallucinations (answers grounded in provided documents)
- Enables domain-specific Q&A without retraining
- Easy to update knowledge base (just add documents)

## Implementation Details

### Components

| Component | Choice | Why |
|-----------|--------|-----|
| Vector DB | Chroma | Lightweight, in-memory, no extra service |
| Embedding | all-MiniLM-L6-v2 | Small (80MB), fast, local |
| Text splitter | RecursiveCharacterTextSplitter | Industry standard |
| LLM | Qwen2-1.5B-AWQ | Already deployed via vLLM |

### Chunking Strategy
- Chunk size: 200 characters
- Overlap: 50 characters
- Preserves semantic boundaries (paragraphs, sentences)

## Test Results

### Sample Documents Indexed
- RTX 5060 Ti specifications
- vLLM description
- Quantization explanation
- AWQ vs GPTQ comparison
- RAG definition
- Chroma introduction

### Query Results

| Question | Retrieved? | Answer quality |
|----------|------------|----------------|
| "What is RTX 5060 Ti?" | ✅ | Accurate, based on context |
| "How does quantization work?" | ✅ | Good, combined multiple chunks |
| "What is AWQ?" | ✅ | Accurate |
| "What is Chroma?" | ✅ | Accurate |
| "What is the capital of France?" | ❌ (no relevant docs) | Model answered correctly from its own knowledge (undesired behavior) |

## Observed Limitation

The model did **not** strictly follow the instruction to answer only from context. When asked about Paris (outside document scope), it used its internal knowledge instead of saying "I don't know."

**Root causes**:
- Small model (1.5B) has weaker instruction following
- Prompt engineering could be improved
- No retrieval confidence threshold

**Potential fixes**:
1. Strengthen prompt: "ONLY use context. If not found, reply 'I cannot answer from given documents.'"
2. Add similarity score threshold (skip low-confidence retrievals)
3. Use a larger model with better instruction following (e.g., Phi-3, Llama-3)

## RAG Script

Location: `code/scripts/rag_demo.py`

```bash
# Run RAG demo
cd ~/ai_infra_learning
source venv310/bin/activate
python code/scripts/rag_demo.py

Key Takeaways
RAG is powerful: Grounds LLM responses in custom documents.

Retrieval matters: Chroma + sentence-transformers worked seamlessly.

Models don't automatically follow "only from context": Need explicit prompting or post-processing.

Production RAG needs: Confidence thresholds, better chunking, and possibly reranking.

Next Steps (Day 6)
Improve RAG with similarity score filtering

Test with larger model (Phi-3-mini)

Set up monitoring (Prometheus + Grafana)

Explore advanced RAG: HyDE, self-query, multi-vector

References
LangChain RAG: https://python.langchain.com/docs/tutorials/rag/

ChromaDB: https://docs.trychroma.com/

RAG paper: Lewis et al. (2020) "Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks"
