#!/bin/bash
#
# Master build script for the entire application.

# --- Frontend Build ---
(
    echo "=================================================="
    echo "Starting Frontend build from: $(pwd)"
    
    cd frontend || { echo "Error: 'frontend' directory not found."; exit 1; }
    
    ./build.sh
    
    echo "Frontend build complete."
) 

# --- Backend Build ---
(
    echo "=================================================="
    echo "Starting Backend build from: $(pwd)"
    
    cd backend || { echo "Error: 'backend' directory not found."; exit 1; }
    
    ./build.sh
    
    echo "Backend build complete."
)

echo "=================================================="
echo "All services built successfully."
