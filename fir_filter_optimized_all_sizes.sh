# fix optimized code for all filter sizes
# cd ~/hls_projects/fir_filter_example

# Create a better optimization approach
cat > fix_optimized_code.sh << 'EOF'
#!/bin/bash

FILTER_SIZES=(8 16 32 64)

for size in "${FILTER_SIZES[@]}"; do
    echo "Fixing code for ${size}-tap filter..."
    
    cat > fir_optimized_${size}/src/fir_filter.cpp << EOL
# include full .cpp file here

EOL
done

echo "Optimization fixed for all sizes!"
EOF

chmod +x fix_optimized_code.sh
./fix_optimization.sh