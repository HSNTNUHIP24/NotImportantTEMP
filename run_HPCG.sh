#!/bin/bash

## Originally, I want to use NVIDIA-HPCG on NVIDIA's github, but it turns out that it only support A and H series GPU.

## hpcg run
cd /workspace
if [ ! -f /workspace/xhpcg ]; then
    wget https://www.hpcg-benchmark.org/downloads/xhpcg-3.1_cuda-11_ompi-4.0_sm_60_sm70_sm80 -O /workspace/xhpcg
fi
chmod +x /workspace/xhpcg
module load nvhpc
export LD_LIBRARY_PATH=/opt/nvidia/hpc_sdk/Linux_x86_64/24.5/cuda/11.8/targets/x86_64-linux/lib:/opt/nvidia/hpc_sdk/Linux_x86_64/24.5/math_libs/11.8/targets/x86_64-linux/lib:/opt/nvidia/hpc_sdk/Linux_x86_64/24.5/comm_libs/11.8/hpcx/hpcx-2.14/ompi/lib
mpirun -np 1 ./xhpcg