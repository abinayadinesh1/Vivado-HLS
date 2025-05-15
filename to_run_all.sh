cd ~/hls_projects/fir_filter_example

# 1. Source the Xilinx tools
source /opt/Xilinx/Vitis/2020.2/settings64.sh

# 2. Run all filter sizes using your existing script
chmod +x run_all_filter_sizes.sh
./run_all_filter_sizes.sh
