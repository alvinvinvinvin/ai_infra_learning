#!/bin/bash
echo "=== Testing /v1/completions ==="
curl -s http://localhost:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"/home/cheer/qwen2","prompt":"What is AI?","max_tokens":50}' \
  | python3 -m json.tool | grep -A2 '"text"'

echo ""
echo "=== Testing /v1/chat/completions ==="
curl -s http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"/home/cheer/qwen2","messages":[{"role":"user","content":"Tell me a joke"}],"max_tokens":50}' \
  | python3 -m json.tool | grep -A2 '"content"'
