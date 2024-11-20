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

# Number of GPUs available
gpu_count=4

# Track GPU assignments
gpu_index=0

# Loop through models and manage servers
for i in "${!models[@]}"; do
    model="${models[$i]}"
    server_name="vllm-serve-$port"
    log_file="logs/${server_name}.log"
    
    # Stop and delete the old server if it exists
    echo "Stopping and deleting old server: $server_name (if exists)"
    pm2 stop "$server_name" 2>/dev/null
    pm2 delete "$server_name" 2>/dev/null

    # Set CUDA_VISIBLE_DEVICES based on GPU index
    export CUDA_VISIBLE_DEVICES="$gpu_index"
    echo "Assigning model: $model to GPU $gpu_index"

    # Ensure the logs directory exists
    mkdir -p logs

    # Start the new server with logging
    echo "Starting model: $model on port $port (log: $log_file)"
    pm2 start vllm --name "$server_name" --interpreter python3 -- serve "$model" --dtype auto --api-key $VLLM_API_KEY --port $port --tensor-parallel-size 1 --output "$log_file"

    # Increment port for the next server
    ((port++))

    # Increment GPU index and wrap around
    ((gpu_index++))
    gpu_index=$((gpu_index % gpu_count))
done

echo "All models started successfully after cleaning up old servers."
