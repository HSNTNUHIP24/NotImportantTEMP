#!/bin/bash
## hpcg install
cd /opt
git clone https://github.com/TWTom041/nvidia-hpcg
cd nvidia-hpcg
sed -i "s/USE_GRACE=1/USE_GRACE=0/g" build_sample.sh
mkdir -p build
cd build
../configure CUDA_X86
make -j16 MPI_PATH=/opt/nvidia/hpc_sdk/Linux_x86_64/24.5/comm_libs/mpi CUDA_PATH=/opt/nvidia/hpc_sdk/Linux_x86_64/24.5/cuda MATHLIBS_PATH=/opt/nvidia/hpc_sdk/Linux_x86_64/24.5/math_libs NCCL_PATH=/opt/nvidia/hpc_sdk/Linux_x86_64/24.5/comm_libs/nccl NVPL_SPARSE_PATH=/opt/nvidia/hpc_sdk/Linux_x86_64/24.5/math_libs/12.4/targets/x86_64-linux
