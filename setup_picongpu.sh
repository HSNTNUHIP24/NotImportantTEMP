#!/bin/bash
if [[ $EUID = 0 ]]; then
    echo "user is root, good."
else
    echo "not running as root!"
    exit 1
fi

module load nvhpc

# cmake and other apt things
apt install -y cmake file cmake-curses-gui git rsync libpng-dev libblosc-dev libjpeg-dev libjansson-dev paraview-dev
spack install pngwriter openpmd-api isaac

# openmpi (from nvhpc)
export MPI_ROOT=/opt/nvidia/hpc_sdk/Linux_x86_64/24.5/comm_libs/12.4/hpcx/hpcx-2.19/ompi
export OMPI_MCA_mpi_leave_pinned=1

# Boost
apt install -y libboost-program-options-dev libboost-atomic-dev libboost-all-dev
# export CMAKE_PREFIX_PATH=/usr/lib/x86_64-linux-gnu:$CMAKE_PREFIX_PATH

git clone https://github.com/ComputationalRadiationPhysics/picongpu.git /home/user/src/picongpu
export PICSRC=/home/user/src
export PIC_EXAMPLES=$PICSRC/share/picongpu/examples
export PATH=$PATH:$PICSRC
export PATH=$PATH:$PICSRC/bin
export PATH=$PATH:$PICSRC/src/tools/bin
export PYTHONPATH=$PICSRC/lib/python:$PYTHONPATH

# ## libpng (apt)
# export PNG_ROOT=/usr/lib/x86_64-linux-gnu
# export CMAKE_PREFIX_PATH=$PNG_ROOT:$CMAKE_PREFIX_PATH


## pngwriter
mkdir -p /home/user/src /home/user/lib
git clone -b 0.7.0 https://github.com/pngwriter/pngwriter.git /home/user/src/pngwriter/
cd /home/user/src/pngwriter
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=/home/user/lib/pngwriter ..
make install

export CMAKE_PREFIX_PATH=/home/user/lib/pngwriter:$CMAKE_PREFIX_PATH

## openPMD API
mkdir -p /home/user/src /home/user/lib
git clone -b 0.15.0 https://github.com/openPMD/openPMD-api.git /home/user/src/openPMD-api
cd /home/user/src/openPMD-api
mkdir build && cd build
cmake .. -DopenPMD_USE_MPI=ON -DCMAKE_INSTALL_PREFIX=/home/user/lib/openPMD-api

export CMAKE_PREFIX_PATH="/home/user/lib/openPMD-api:$CMAKE_PREFIX_PATH"

# ## c blosc (apt)
# export BLOSC_ROOT=/usr/lib/x86_64-linux-gnu
# export CMAKE_PREFIX_PATH=$BLOSC_ROOT:$CMAKE_PREFIX_PATH

## isaac (interactive visualization tool, i think it's not needed)
# cd /home/user
# git clone https://github.com/ComputationalRadiationPhysics/isaac.git
# cd isaac
# cd lib
# mkdir build
# cd build
# cmake ..
# make install

## FFTW3
mkdir -p /home/user/src /home/user/lib
cd /home/user/src
wget -qO- http://fftw.org/fftw-3.3.10.tar.gz | tar xvz
FFTW_ROOT=/home/user/lib/fftw-3.3.10
./configure --prefix="$FFTW_ROOT"
make
make install

export FFTW_ROOT=/home/user/lib/fftw-3.3.10
export LD_LIBRARY_PATH=$FFTW_ROOT:$LD_LIBRARY_PATH
