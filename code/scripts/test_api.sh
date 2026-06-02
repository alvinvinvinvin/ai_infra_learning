#!/bin/bash
curl -s http://localhost:8000/generate -d '{
"prompt": "What is machine learning?",
"max_tokens": 50
}' | python -m json.tool
