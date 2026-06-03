#!/bin/bash
echo "=== Temperature 0.1 (Conservative) ==="
curl -s http://localhost:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"/home/cheer/qwen2","prompt":"The capital of France is","max_tokens":15,"temperature":0.1}' \
  | python3 -m json.tool | grep '"text"'

echo ""
echo "=== Temperature 1.5 (Creative) ==="
curl -s http://localhost:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"/home/cheer/qwen2","prompt":"The capital of France is","max_tokens":15,"temperature":1.5}' \
  | python3 -m json.tool | grep '"text"'
