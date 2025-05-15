#!/bin/bash

echo "=== Simple Performance Metrics Extraction ==="
echo ""
echo "Filter Size | Version     | Target | Estimated | Clock Freq | Latency Min | Latency Max | Loop II | DSP | LUT"
echo "-----------|------------|--------|-----------|-----------|------------|------------|---------|-----|----"

extract_simple() {
    local size=$1
    local version=$2
    local rpt="fir_${version}_${size}/fir_${version}_${size}_proj/solution1/syn/report/fir_filter_${version}_csynth.rpt"
    
    if [ ! -f "$rpt" ]; then
        printf "%10s | %-10s | %6s | %9s | %9s | %10s | %10s | %7s | %3s | %3s\n" \
               "${size}" "${version}" "N/F" "N/F" "N/F" "N/F" "N/F" "N/F" "N/F" "N/F"
        return
    fi
    
    # Get timing - take FIRST ap_clk line (the timing one, not interface)
    local timing_line=$(grep "|ap_clk" "$rpt" | head -1)
    local target=$(echo "$timing_line" | awk -F'|' '{print $3}' | sed 's/[ ]*//g')
    local estimated=$(echo "$timing_line" | awk -F'|' '{print $4}' | sed 's/[ ]*//g')
    
    # Calculate frequency
    local freq=""
    if [[ "$estimated" =~ ([0-9.]+)ns ]]; then
        local period_num=${BASH_REMATCH[1]}
        freq=$(echo "scale=0; 1000 / $period_num" | bc 2>/dev/null)
        freq="${freq}MHz"
    fi
    
    # Get latency - use the simple pattern that works
    local lat_line=$(grep -A 5 "Latency (cycles)" "$rpt" | grep -v "Latency (cycles)" | grep -v "min.*max" | grep -v "+-" | grep "[0-9]" | head -1)
    local lat_min=$(echo "$lat_line" | awk -F'|' '{print $2}' | sed 's/[ ]*//g')
    local lat_max=$(echo "$lat_line" | awk -F'|' '{print $3}' | sed 's/[ ]*//g')
    
    # Get loop II - be specific about main loop
    local main_loop_line=$(grep "main_loop\|VITIS_LOOP_15_1" "$rpt")
    local loop_ii=$(echo "$main_loop_line" | awk -F'|' '{print $5}' | sed 's/[ ]*//g')
    
    # Get resources - search for the FIRST Total line
    # Field 4 = DSP, Field 6 = LUT
    local total_line=$(grep -i "|Total" "$rpt" | head -1)
    local dsp=$(echo "$total_line" | awk -F'|' '{print $4}' | sed 's/[ ]*//g')
    local lut=$(echo "$total_line" | awk -F'|' '{print $6}' | sed 's/[ ]*//g')
    
    # Set defaults
    if [ -z "$target" ]; then target="N/A"; fi
    if [ -z "$estimated" ]; then estimated="N/A"; fi
    if [ -z "$freq" ]; then freq="N/A"; fi
    if [ -z "$lat_min" ]; then lat_min="N/A"; fi
    if [ -z "$lat_max" ]; then lat_max="N/A"; fi
    if [ -z "$loop_ii" ]; then loop_ii="N/A"; fi
    if [ -z "$dsp" ]; then dsp="N/A"; fi
    if [ -z "$lut" ]; then lut="N/A"; fi
    
    printf "%10s | %-10s | %6s | %9s | %9s | %10s | %10s | %7s | %3s | %3s\n" \
           "${size}" "${version}" "$target" "$estimated" "$freq" "$lat_min" "$lat_max" "$loop_ii" "$dsp" "$lut"
}

# Extract for all sizes
FILTER_SIZES=(8 16 32 64 128 256)

for size in "${FILTER_SIZES[@]}"; do
    extract_simple $size "unoptimized"
    extract_simple $size "optimized"
    echo ""  # Add empty line between filter sizes
done
