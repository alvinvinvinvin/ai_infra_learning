
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
