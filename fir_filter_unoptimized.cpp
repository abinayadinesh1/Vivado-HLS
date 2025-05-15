#include <stdio.h>

#define FILTER_SIZE 8
#define NUM_SAMPLES 1024

void fir_filter_unoptimized(
    int input_data[NUM_SAMPLES],
    int output_data[NUM_SAMPLES],
    int coefficients[FILTER_SIZE]
) {
    static int delay_line[FILTER_SIZE] = {0};
    
    for (int i = 0; i < NUM_SAMPLES; i++) {
        for (int j = FILTER_SIZE - 1; j > 0; j--) {
            delay_line[j] = delay_line[j-1];
        }
        delay_line[0] = input_data[i];
        
        int accumulator = 0;
        for (int j = 0; j < FILTER_SIZE; j++) {
            accumulator += delay_line[j] * coefficients[j];
        }
        
        output_data[i] = accumulator;
    }
}
