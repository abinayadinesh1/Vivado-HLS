# Vivado-HLS
### to access the Vivado GUI using a MAC's built in Screen Sharing application:
- have one terminal open, ssh'd into the EC2 instance
```ssh -i <path to .pem key> ec2-user@<ip address>```


- in another terminal window, run
```ssh -i <path to .pem key> -L 5901:localhost:5901 ec2-user@<ip address>```

open your Screen Sharing application, and connect to localhost:5901
done!

###
to write a script and launch it completely via the command line:
```
source /opt/Xilinx/Vitis/2020.2/settings64.sh

# Create a simple HLS project
mkdir -p ~/hls_project/src
cd ~/hls_project

# Create source files
cat > src/simple_add.cpp << 'EOF'
#include <ap_int.h>

void simple_add(int a, int b, int *c) {
    *c = a + b;
}
EOF

cat > src/simple_add_tb.cpp << 'EOF'
#include <stdio.h>

void simple_add(int a, int b, int *c);

int main() {
    int a = 5;
    int b = 10;
    int c;
    
    simple_add(a, b, &c);
    
    printf("Result: %d + %d = %d\n", a, b, c);
    
    return (c == 15) ? 0 : 1;
}
EOF

# Create TCL script
cat > run_hls.tcl << 'EOF'
open_project -reset simple_add_proj
set_top simple_add
add_files src/simple_add.cpp
add_files -tb src/simple_add_tb.cpp
open_solution -reset "solution1"
set_part {xcvu9p-flgb2104-2-i}
create_clock -period 10
csim_design
csynth_design
exit
EOF

# Run HLS
vitis_hls -f run_hls.tcl
```
