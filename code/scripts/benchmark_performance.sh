#!/bin/bash
echo "=== Performance Benchmark (10 requests) ==="
total=0
for i in {1..10}; do
  time=$(curl -s -o /dev/null -w "%{time_total}" \
    http://localhost:8000/v1/completions \
    -H "Content-Type: application/json" \
    -d '{"model":"/home/cheer/qwen2","prompt":"What is machine learning?","max_tokens":50}')
  echo "Request $i: ${time}s"
  total=$(echo "$total + $time" | bc 2>/dev/null || echo "$total + $time" | bc)
done
if command -v bc &> /dev/null; then
  avg=$(echo "scale=3; $total / 10" | bc)
  echo "Average latency: ${avg}s"
else
  echo "Install bc for average calculation: sudo apt install bc"
fi
