#!/bin/bash
if [[ $EUID = 0 ]]; then
    echo "user is root, good."
else
    echo "not running as root!"
    exit 1
fi

PFX=$(pwd)

apt update
apt install -y vim nano wget curl gnupg2 gpg-agent bc python3 libc-dev libc6-dev gcc g++ unzip git 
apt install -y linux-headers-`uname -r`

## lmod and lua
apt install -y liblua5.1-0 liblua5.1-0-dev lua5.1 tcl tcl8.6-dev libtcl8.6 lua-posix-dev
wget -qO- https://codeload.github.com/TACC/Lmod/tar.gz/refs/tags/8.7.43 | tar xvz
cd Lmod-8.7.43
./configure --prefix=/opt/apps
make install
ln -s /opt/apps/lmod/lmod/init/profile        /etc/profile.d/z00_lmod.sh
ln -s /opt/apps/lmod/lmod/init/cshrc          /etc/profile.d/z00_lmod.csh
source /etc/profile
cd $PFX

## intel oneapi mkl
wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | gpg --dearmor | tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | tee /etc/apt/sources.list.d/oneAPI.list
apt update
apt install -y intel-basekit intel-hpckit
/opt/intel/oneapi/modulefiles-setup.sh --output-dir=/opt/apps/modulefiles/intel
cat <<EOT >> /opt/apps/modulefiles/Linux/intel/latest.lua
-- -*- lua -*-
------------------------------------------------------------------------
--  Intel® oneAPI DPC++/C++/Fortran Compiler 2024.0.2 for Linux*
------------------------------------------------------------------------

function get_command_output(command)
    -- Run a command and return the output with whitespace stripped from the end
    return string.gsub(capture(command), '%s+$', '')
end

function detect_arch()
    -- Detect architecture information
    local cpu_family = get_command_output("grep -m1 '^cpu family' /proc/cpuinfo|awk '{print \$NF}'")

    local cpu_plat_table = {
        ["6"] = "Intel",
        ["25"] = "AMD",
    }

    arch_cpu = cpu_plat_table[cpu_family]
end


-- if mode() == "load" or mode() == "show" then
    detect_arch()
-- end


help(
[[
 Intel® oneAPI DPC++/C++/Fortran Compiler for Linux*
]])

whatis("Name         : Intel® oneAPI DPC++/C++/Fortran Compiler ")
whatis("Version      : 2024")
whatis("Release      : 49895")
whatis("Architecture : x86_64")
whatis("Category     : devel")
whatis("Summary      : Intel® oneAPI DPC++/C++/Fortran Compiler for Linux*")
whatis("License      : Copyright Intel Corporation.")
whatis("Description  : Standards driven high performance cross architecture DPC++/C++/Fortran compiler")
-- whatis("URL          : https://software.intel.com/en-us/parallel-studio-xe")
whatis("Installed on : Jan 03, 2024 ")
whatis("Installed by : Voldemort")


local intel_root = "/opt"
local version = "intel"
local name = "oneapi"
local comp_update="2024.2"
local tbb_update="2021.13"
local mkl_update="2024.2"
local mpi_update="2021.13"
local intel_arch = "intel64"
local comp_root = pathJoin(intel_root,version,name,"compiler",comp_update)
local tbb_root = pathJoin(intel_root,version,name,"tbb",tbb_update)
local mkl_root = pathJoin(intel_root,version,name,"mkl",mkl_update)
-- local mpi_root = pathJoin(intel_root,version,name,"mpi",mpi_update)

setenv("TBBROOT",tbb_root)
prepend_path("CPATH",pathJoin(tbb_root,"include"))
prepend_path("LIBRARY_PATH",pathJoin(tbb_root,"lib"))
prepend_path("LD_LIBRARY_PATH",pathJoin(tbb_root,"lib"))
prepend_path("CMAKE_PREFIX_PATH",tbb_root)

setenv("CMPLR_ROOT",comp_root)
prepend_path("PATH",pathJoin(comp_root,"bin"))
prepend_path("LIBRARY_PATH",pathJoin(comp_root,"lib"))
prepend_path("LIBRARY_PATH",pathJoin(comp_root,"opt/compiler/lib"))
prepend_path("LD_LIBRARY_PATH",pathJoin(comp_root,"lib"))
prepend_path("LD_LIBRARY_PATH",pathJoin(comp_root,"opt/compiler/lib"))
append_path("OCL_ICD_FILENAMES",pathJoin(comp_root,"lib/libintelocl.so"))
prepend_path("CMAKE_PREFIX_PATH",pathJoin(comp_root))
prepend_path("DIAGUTIL_PATH",pathJoin(comp_root,"etc/compiler/sys_check/sys_check.sh"))
prepend_path("PKG_CONFIG_PATH",pathJoin(comp_root,"lib/pkgconfig"))
prepend_path("NLSPATH",pathJoin(comp_root,"lib/compiler/locale/%l_%t/%N"))
prepend_path("MANPATH",pathJoin(comp_root,"share/man"))

setenv("MKLROOT",mkl_root)
prepend_path("LD_LIBRARY_PATH",pathJoin(mkl_root,"lib"))
prepend_path("LIBRARY_PATH",pathJoin(mkl_root,"lib"))
prepend_path("CPATH",pathJoin(mkl_root,"include"))
prepend_path("PKG_CONFIG_PATH",pathJoin(mkl_root,"lib/pkgconfig"))
prepend_path("CMAKE_PREFIX_PATH",pathJoin(mkl_root,"lib/cmake"))
prepend_path("NLSPATH",pathJoin(mkl_root,"share/locale/%l_%t/%N"))

-- setenv("I_MPI_ROOT",mpi_root)
-- prepend_path("CLASSPATH",pathJoin(mpi_root,"share/java/mpi.jar"))
-- prepend_path("PATH",pathJoin(mpi_root,"bin"))
-- prepend_path("LD_LIBRARY_PATH",pathJoin(mpi_root,"lib"))
-- prepend_path("LIBRARY_PATH",pathJoin(mpi_root,"lib"))
-- prepend_path("CPATH",pathJoin(mpi_root,"include"))
-- prepend_path("MANPATH",pathJoin(mpi_root,"share/man"))
-- setenv("FI_PROVIDER_PATH",pathJoin(mpi_root,"opt/mpi/libfabric/lib/prov:/usr/lib64/libfabric"))
-- prepend_path("PATH",pathJoin(mpi_root,"opt/mpi/libfabric/bin"))
-- prepend_path("LD_LIBRARY_PATH",pathJoin(mpi_root,"opt/mpi/libfabric/lib"))
-- prepend_path("LIBRARY_PATH",pathJoin(mpi_root,"opt/mpi/libfabric/lib"))

pushenv("CC", "icx")
pushenv("CXX", "icpx")
pushenv("F77", "ifx")
pushenv("F90", "ifx")
pushenv("FC", "ifx")


-- Setup Modulepath for packages built by this compiler
-- local mroot = pathJoin("/opt/ohpc",arch_cpu,"module/lmod")
-- local mdir = pathJoin(mroot,"comp/intel", version)
-- prepend_path("MODULEPATH", mdir)

-- Set family for this module
family("compiler")

 local output_tracking = " user \$USER hostname \$HOSTNAME"
 cmd = "logger -t lmod_tracking Intel Compiler " ..version ..output_tracking
 execute{cmd = cmd, modeA = {"load"}}
EOT

cd $PFX

## nvidia driver and cuda
export CC=gcc CXX=gcc
wget https://tw.download.nvidia.com/tesla/550.90.07/NVIDIA-Linux-x86_64-550.90.07.run
sh NVIDIA-Linux-x86_64-550.90.07.run --silent
curl https://developer.download.nvidia.com/hpc-sdk/ubuntu/DEB-GPG-KEY-NVIDIA-HPC-SDK | gpg --dearmor -o /usr/share/keyrings/nvidia-hpcsdk-archive-keyring.gpg
echo 'deb [signed-by=/usr/share/keyrings/nvidia-hpcsdk-archive-keyring.gpg] https://developer.download.nvidia.com/hpc-sdk/ubuntu/amd64 /' | tee /etc/apt/sources.list.d/nvhpc.list
apt update -y
apt install -y nvhpc-24-5
cat <<EOT >> /opt/apps/modulefiles/Linux/nvhpc/24.5.lua
help(
[[
NVIDIA HPC SDK
A Comprehensive Suite of Compilers, Libraries and Tools for HPC
]])

local nvhome = "/opt/nvidia/hpc_sdk"
local target = "Linux_x86_64"
local version = "24.5"

whatis("Name         : NVIDIA HPC SDK")
whatis("Version      : " .. version)
whatis("Category     : nvhpc")
whatis("Description  : A Comprehensive Suite of Compilers, Libraries and Tools for HPC")
whatis("URL          : https://developer.nvidia.com/hpc-sdk")
whatis("Installed on : 20230719")
whatis("Installed by : Voldemort")
family("nvhpc")

if mode() == "load" then
printmegs = [[
--------------------------------
Loading NVIDIA HPC SDK 23.5 with CUDA / OpenMPI
You can copy or echo "\$NV_EXAMPLE"
(ex: echo \$NV_EXAMPLE; cp -r \$NV_EXAMPLE /home/\$USER)
--------------------------------
]]
LmodMessage(printmegs)

local output_tracking = " user \$USER hostname \$HOSTNAME jobid \$SLURM_JOBID user \$SLURM_JOB_USER account \$SLURM_JOB_ACCOUNT"
cmd = "logger -t lmod_tracking nvhpc" .. version .. output_tracking
execute{cmd = cmd, modeA = {"load"}}
end


local nvcudadir = pathJoin(nvhome, target, version, "cuda")
local nvcompdir = pathJoin(nvhome, target, version, "compilers")
local nvmathdir = pathJoin(nvhome, target, version, "math_libs")
local nvcommdir = pathJoin(nvhome, target, version, "comm_libs")
-- kmo add example
local nvexample = pathJoin(nvhome, target, version, "examples")

setenv("NVHPC", nvhome)
setenv("NVHPC_ROOT",pathJoin(nvhome, target, version))
setenv("CC", pathJoin(nvcompdir, "bin", "nvc"))
setenv("CXX", pathJoin(nvcompdir, "bin", "nvc++"))
setenv("FC", pathJoin(nvcompdir, "bin", "nvfortran"))
setenv("F90", pathJoin(nvcompdir, "bin", "nvfortran"))
setenv("F77", pathJoin(nvcompdir, "bin", "nvfortran"))
-- add localrc
-- setenv("NVLOCALRC", pathJoin(nvcompdir, "bin", "localrc"))
-- add nvhpc example
setenv("NV_EXAMPLE", nvexample)

prepend_path("PATH", pathJoin(nvcudadir, "bin"))
prepend_path("PATH", pathJoin(nvcompdir, "bin"))
prepend_path("PATH", pathJoin(nvcommdir, "mpi", "bin"))
prepend_path("PATH", pathJoin(nvcompdir, "extras", "qd", "bin"))

prepend_path("LIBRARY_PATH", pathJoin(nvcudadir, "lib64"))
prepend_path("LIBRARY_PATH", pathJoin(nvcudadir, "extras", "CUPTI", "lib64"))
prepend_path("LIBRARY_PATH", pathJoin(nvcompdir, "lib"))
prepend_path("LIBRARY_PATH", pathJoin(nvmathdir, "lib64"))
prepend_path("LIBRARY_PATH", pathJoin(nvcommdir, "mpi", "lib"))
prepend_path("LIBRARY_PATH", pathJoin(nvcommdir, "nccl", "lib"))
prepend_path("LIBRARY_PATH", pathJoin(nvcommdir, "nvshmem", "lib"))
prepend_path("LIBRARY_PATH", pathJoin(nvcompdir, "extras", "qd", "lib"))
-- add cuda compat
prepend_path("LIBRARY_PATH", pathJoin(nvcudadir, "lib64", "compat"))

prepend_path("LD_LIBRARY_PATH", pathJoin(nvcudadir, "lib64"))
prepend_path("LD_LIBRARY_PATH", pathJoin(nvcudadir, "extras", "CUPTI", "lib64"))
prepend_path("LD_LIBRARY_PATH", pathJoin(nvcompdir, "lib"))
prepend_path("LD_LIBRARY_PATH", pathJoin(nvmathdir, "lib64"))
prepend_path("LD_LIBRARY_PATH", pathJoin(nvcommdir, "mpi", "lib"))
prepend_path("LD_LIBRARY_PATH", pathJoin(nvcommdir, "nccl", "lib"))
prepend_path("LD_LIBRARY_PATH", pathJoin(nvcommdir, "nvshmem", "lib"))
prepend_path("LD_LIBRARY_PATH", pathJoin(nvcompdir, "extras", "qd", "lib"))
-- add cuda compat
prepend_path("LD_LIBRARY_PATH", pathJoin(nvcudadir, "lib64", "compat"))

prepend_path("CPATH", pathJoin(nvmathdir, "include"))
prepend_path("CPATH", pathJoin(nvcommdir, "mpi", "include"))
prepend_path("CPATH", pathJoin(nvcommdir, "nccl", "include"))
prepend_path("CPATH", pathJoin(nvcommdir, "nvshmem", "include"))
prepend_path("CPATH", pathJoin(nvcompdir, "extras", "qd", "include", "qd"))
-- mark-out by kmo
-- prepend_path("MANPATH", pathJoin(nvcompdir, "man"))

setenv("OPAL_PREFIX", pathJoin(nvcommdir, "mpi"))
EOT
cd $PFX

## openmpi
module load intel/latest
wget https://download.open-mpi.org/release/open-mpi/v5.0/openmpi-5.0.3.tar.gz
tar zxf openmpi-5.0.3.tar.gz
cd openmpi-5.0.3
./configure --prefix=/opt/openmpi CC=icx CXX=icpx FC=ifx
make -j16
make install
cat <<EOT >> /opt/apps/modulefiles/Linux/openmpi/5.0.3.lua
whatis([[Name : OpenMPI]])
whatis([[Version : 5.0.3]])


local root = "/opt/openmpi"

prepend_path("PATH", pathJoin(root, "bin"))
prepend_path("LD_LIBRARY_PATH", pathJoin(root, "lib"))
prepend_path("CPATH", pathJoin(root, "include"))

prepend_path("LIBRARY_PATH", pathJoin(root, "lib"))
EOT
module unload intel/latest
cd $PFX

## hpl install
cd /opt
wget https://github.com/TWTom041/hipac_practice/releases/download/hpl/hpl.zip
unzip hpl.zip
rm hpl.zip
ln -s /opt/intel/oneapi/compiler/latest/linux/compiler/lib/intel64_lin/libiomp5.so /opt/intel/oneapi/mkl/latest/lib/intel64/libiomp5.so
cd /opt/hpl-2.0_FERMI_v15
make arch=CUDA
cd $PFX

## hpcg install
cd /opt
git clone https://github.com/NVIDIA/nvidia-hpcg
cd nvidia-hpcg
sed -i "s/USE_GRACE=1/USE_GRACE=0/g" build_sample.sh
MPI_PATH=/opt/nvidia/hpc_sdk/Linux_x86_64/24.5/comm_libs/mpi CUDA_PATH=/opt/nvidia/hpc_sdk/Linux_x86_64/24.5/cuda MATHLIBS_PATH=/opt/nvidia/hpc_sdk/Linux_x86_64/24.5/math_libs NCCL_PATH=/opt/nvidia/hpc_sdk/Linux_x86_64/24.5/comm_libs/nccl NVPL_SPARSE_PATH=/opt/nvidia/hpc_sdk/Linux_x86_64/24.5/math_libs/12.4/targets/x86_64-linux build_sample.sh
