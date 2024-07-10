#!/bin/bash
if [[ $EUID = 0 ]]; then
    echo "user is root, good."
else
    echo "not running as root!"
    exit 1
fi

module load nvhpc

## Mandatory
# cmake
apt install -y cmake file cmake-curses-gui

# openmpi (from nvhpc)
export MPI_ROOT=/opt/nvidia/hpc_sdk/Linux_x86_64/24.5/comm_libs/12.4/hpcx/hpcx-2.19/ompi
export OMPI_MCA_mpi_leave_pinned=1

# Boost
apt install -y libboost-program-options-dev libboost-atomic-dev
export CMAKE_PREFIX_PATH=$HOME/lib/boost:$CMAKE_PREFIX_PATH