#!/bin/bash

# List of models
models=(
    "NousResearch/Meta-Llama-3.1-8B-Instruct"
    "NTQAI/Nxcode-CQ-7B-orpo"
    "deepseek-ai/deepseek-coder-33b-instruct"
    "gryphe/mythomax-l2-13b"
    "nvidia/Llama-3.1-Nemotron-70B-Instruct-HF"
)

# Base port
port=8001

# API Key
export VLLM_API_KEY="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"


# Run processes one at a time due to GPU constraints
for model in "${models[@]}"; do
    server_name="vllm-serve-$port"

    export CUDA_VISIBLE_DEVICES="0,1,2,3"  # Use all GPUs
    pm2 start vllm --name "$server_name" --interpreter python3 -- serve "$model" --dtype auto --api-key $VLLM_API_KEY --port $port --tensor-parallel-size 4

    # Increment port
    ((port++))
done

echo "All models started successfully after cleaning up old servers."
