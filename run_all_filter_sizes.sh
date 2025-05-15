#!/bin/bash

# Source Xilinx tools
source /opt/Xilinx/Vitis/2020.2/settings64.sh

# Filter sizes to test
FILTER_SIZES=(8 16 32 64 128 256)

echo "=== Running Comprehensive FIR Filter Tests ==="
echo "This will take some time... each synthesis takes 0-2 minutes"
echo "Total estimated time: $(( ${#FILTER_SIZES[@]} * 2 * 2 )) to $(( ${#FILTER_SIZES[@]} * 2 * 5 )) minutes"
echo ""

# Function to run a single test
run_single_test() {
    local size=$1
    local version=$2
    local start_time=$(date +%s)
    
    echo "Running ${size}-tap ${version} filter... ($(date +%H:%M:%S))"
    
    cd fir_${version}_${size}
    vitis_hls -f run_hls.tcl > hls_output.log 2>&1
    
    if [ $? -eq 0 ]; then
        echo "  ✓ Completed successfully"
    else
        echo "  ✗ Failed - check hls_output.log"
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    echo "  Duration: ${duration} seconds"
    cd ..
}

# Run all tests
total_start_time=$(date +%s)

for size in "${FILTER_SIZES[@]}"; do
    echo ""
    echo "=== Testing ${size}-tap filters ==="
    run_single_test $size "unoptimized"
    run_single_test $size "optimized"
done

total_end_time=$(date +%s)
total_duration=$((total_end_time - total_start_time))

echo ""
echo "=== All Tests Completed ==="
echo "Total time: ${total_duration} seconds ($(( total_duration / 60 )) minutes)"
echo ""
echo "Results will be analyzed with analyze_all_results.sh"
