# RAG (Retrieval-Augmented Generation) Basics

## What is RAG?

RAG is an architecture that enhances LLM responses by first retrieving relevant information from a knowledge base, then feeding that information as context to the LLM.

## Why RAG?

| Problem | RAG Solution |
|---------|---------------|
| Hallucination | Ground responses in retrieved documents |
| Outdated knowledge | Update documents, not the model |
| Private data | Keep documents local, query securely |
| Costly retraining | No training needed, just indexing |

## Core Components

### 1. Document Loading
Load from various sources: PDF, HTML, Markdown, databases, APIs.

### 2. Chunking (Text Splitting)
Split long documents into smaller chunks for embedding.

| Strategy | Description | Best for |
|----------|-------------|----------|
| Recursive | Splits by separators (paragraphs, sentences) | General text |
| Semantic | Splits by semantic similarity | Technical docs |
| Fixed size | Simple character/token count | Logs, code |

### 3. Embedding
Convert text chunks to vector representations.

Popular embedding models:
- `all-MiniLM-L6-v2` (384 dim, 80MB) - Fast, local
- `text-embedding-3-small` (1536 dim) - OpenAI, high quality
- `BAAI/bge-small-en` (384 dim) - Good for Chinese/English

### 4. Vector Store
Store and search embeddings efficiently.

| Vector DB | Best for | Notes |
|-----------|----------|-------|
| Chroma | Local, lightweight | In-memory or persistent |
| FAISS | High performance | Facebook, GPU accelerated |
| Pinecone | Managed cloud | Production scaling |
| Qdrant | Self-hosted | Great filtering |

### 5. Retrieval
Find most similar chunks to user query.

Common retrieval methods:
- **Dense** (vector similarity) - Semantic understanding
- **Sparse** (BM25) - Keyword matching
- **Hybrid** - Both semantic and keyword

### 6. Generation
Combine retrieved chunks into prompt, send to LLM.

## Production RAG Improvements

### Retrieval Quality
- **Reranking**: Second-stage model to reorder retrieved chunks
- **Multi-query**: Generate multiple query variations
- **HyDE**: Generate hypothetical answer, embed that instead

### Chunking
- **Small chunks** (100-200 chars): More precise, but more retrieval calls
- **Large chunks** (500-1000 chars): More context, but may include noise
- **Overlap** (10-20%): Preserve boundary information

### Prompt Engineering

Use the following pieces of context to answer the question.
If the context doesn't contain the answer, say "I cannot answer based on the provided documents."

Context: {context}
Question: {question}
Answer:


## Common RAG Patterns

### Simple RAG (Today's implementation)
Query → Retrieve → Generate

### Advanced RAG
Query → Retrieve → Rerank → Generate → Check → Iterate

### Agentic RAG
LLM decides which tools/databases to query, can combine multiple sources.

## Metrics to Track

| Metric | What it measures |
|--------|------------------|
| Hit rate | Did retrieval find relevant chunks? |
| MRR | Rank of first relevant chunk |
| Answer relevance | Does answer address the question? |
| Faithfulness | Is answer grounded in retrieved context? |
| Latency | End-to-end time |

## References
- [LangChain RAG Tutorial](https://python.langchain.com/docs/tutorials/rag/)
- [RAGatouille](https://github.com/bclavie/RAGatouille) (ColBERT reranking)
- [LlamaIndex](https://www.llamaindex.ai/) (Alternative RAG framework)

Appendix: RAG vs Quantization (GPTQ/AWQ)
These concepts are often confused. Here's the distinction:

Quantization (GPTQ/AWQ)	RAG
What it does	Compresses model weights (FP16 → INT4)	Retrieves external documents as context
Why use it	Smaller memory, faster inference	More accurate, less hallucination, private knowledge
When to apply	Model loading time	Every request (runtime)
Changes model?	Yes (permanently compressed)	No (only changes input)
They work together: Your rag_demo.py uses a quantized model (./qwen2-awq) inside a RAG pipeline.

For a detailed comparison, see notes/06_quantization_vs_rag.md.
