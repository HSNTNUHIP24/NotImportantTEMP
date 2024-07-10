#!/bin/bash
## hpl install
module load nvhpc
cd /opt
wget https://github.com/TWTom041/NotImportantTEMP/releases/download/hpl/hpl.zip
unzip hpl.zip
rm hpl.zip
ln -s /opt/intel/oneapi/compiler/latest/lib/libiomp5.so /opt/intel/oneapi/mkl/latest/lib/intel64/libiomp5.so
cd /opt/hpl-2.0_FERMI_v15
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/hpl-2.0_FERMI_v15/src/cuda
make arch=CUDA -j16
module unload nvhpc
cd $PFX