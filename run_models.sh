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

# Loop through models and manage servers
for model in "${models[@]}"; do
    server_name="vllm-serve-$port"
    
    # Stop and delete the old server if it exists
    echo "Stopping and deleting old server: $server_name (if exists)"
    pm2 stop "$server_name" 2>/dev/null
    pm2 delete "$server_name" 2>/dev/null

    # Start the new server
    echo "Starting model: $model on port $port"
    pm2 start vllm --name "$server_name" --interpreter python3 -- serve "$model" --dtype auto --api-key $VLLM_API_KEY --port $port --tensor-parallel-size 4
    
    # Increment port for the next server
    ((port++))
done

echo "All models started successfully after cleaning up old servers."
