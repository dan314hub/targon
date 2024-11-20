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
    
    # Stop and delete the old server if it exists
    echo "Stopping and deleting old server: $server_name (if exists)"
    pm2 stop "$server_name" 2>/dev/null
    pm2 delete "$server_name" 2>/dev/null

    # Set CUDA_VISIBLE_DEVICES based on GPU index
    export CUDA_VISIBLE_DEVICES="$gpu_index"
    echo "Assigning model: $model to GPU $gpu_index"

    # Start the new server
    echo "Starting model: $model on port $port"
    pm2 start vllm --name "$server_name" --interpreter python3 -- serve "$model" --dtype auto --api-key $VLLM_API_KEY --port $port --tensor-parallel-size 4
    
    # Increment port for the next server
    ((port++))

    # Increment GPU index
    ((gpu_index++))

    # If all GPUs are used and processes remain, stagger execution for GPU 3
    if [[ $gpu_index -ge $gpu_count ]]; then
        if [[ $i -lt $((${#models[@]} - 1)) ]]; then
            echo "Waiting for process on GPU 3 to finish before starting the next one."
            pm2 wait "$server_name"  # Wait for the process on GPU 3 to finish
        fi
        gpu_index=$((gpu_count - 1))  # Reset to GPU 3 for staggered processes
    fi
done

echo "All models started successfully after cleaning up old servers."
