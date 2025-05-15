[ec2-user@ip-172-31-82-56 src]$ cat fir_filter.cpp
#include <stdio.h>

#define FILTER_SIZE 8
#define NUM_SAMPLES 1024

void fir_filter_dsp_optimized(
    int input_data[NUM_SAMPLES],
    int output_data[NUM_SAMPLES],
    int coefficients[FILTER_SIZE]
) {
    // Remove complex AXI interfaces that hurt performance
    
    // Static delay line with smart partitioning
    static int delay_line[FILTER_SIZE];
    #pragma HLS array_partition variable=delay_line complete
    
    // Load coefficients into registers for faster access
    int local_coeffs[FILTER_SIZE];
    #pragma HLS array_partition variable=local_coeffs complete
    
    // Copy coefficients once
    for (int i = 0; i < FILTER_SIZE; i++) {
        #pragma HLS UNROLL
        local_coeffs[i] = coefficients[i];
    }
    
    // Main processing loop
    main_loop: for (int i = 0; i < NUM_SAMPLES; i++) {
        #pragma HLS PIPELINE II=1
        
        // Shift delay line with controlled unrolling  
        for (int j = FILTER_SIZE - 1; j > 0; j--) {
            #pragma HLS UNROLL
            delay_line[j] = delay_line[j-1];
        }
        delay_line[0] = input_data[i];
        
        // MAC with explicit DSP usage
        int accumulator = 0;
        for (int j = 0; j < FILTER_SIZE; j++) {
            #pragma HLS UNROLL
            #pragma HLS resource variable=accumulator core=DSP48E
            int product = delay_line[j] * local_coeffs[j];
            accumulator += product;
        }
        
        output_data[i] = accumulator;
    }
}
