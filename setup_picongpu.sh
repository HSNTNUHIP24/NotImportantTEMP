#!/bin/bash
if [[ $EUID = 0 ]]; then
    echo "user is root, good."
else
    echo "not running as root!"
    exit 1
fi

module load nvhpc

sed -i "s/cxx: null/cxx: g++/g" ~/.spack/linux/compilers.yaml
sed -i "s/f77: null/f77: gfortran-12/g" ~/.spack/linux/compilers.yaml
sed -i "s/fc: null/fc: gfortran-12/g" ~/.spack/linux/compilers.yaml

# cmake and other apt things
apt install -y cmake file cmake-curses-gui git rsync libpng-dev libjpeg-dev libjansson-dev paraview-dev gfortran-12
echo "cmake:"
spack install --reuse cmake@3.26.5 %gcc
spack load cmake@3.26.5 ^openssl %gcc

echo "openpmd-api:"
spack install --reuse --no-checksum openpmd-api@0.15.2 +python %gcc \
    ^adios2@2.9.2 ++blosc2 +cuda cuda_arch=70\
    ^cmake@3.26.5 \
    ^hdf5@1.14.3 \
    ^openmpi@4.1.5 +atomics +cuda cuda_arch=70\
    ^python@3.11.6 \
    ^py-numpy@1.23.5

echo "boost:"
spack install --reuse boost@1.83.0 \
    +program_options \
    +atomic \
    ~python \
    cxxstd=17 \
    %gcc

echo "pngwriter"
spack install --reuse pngwriter@0.7.0 %gcc

echo "pip:"
spack mark -e py-pip ^python@3.11.6 %gcc

cat <<EOT > picongpu.profile
# Name and Path of this Script ############################### (DO NOT change!)
export PIC_PROFILE=\$(cd \$(dirname \$BASH_SOURCE) && pwd)"/"\$(basename \$BASH_SOURCE)

# User Information ################################# (edit the following lines)
#   - automatically add your name and contact to output file meta data
#   - send me a mail on batch system jobs: NONE, BEGIN, END, FAIL, REQUEUE, ALL,
#     TIME_LIMIT, TIME_LIMIT_90, TIME_LIMIT_80 and/or TIME_LIMIT_50
export MY_MAILNOTIFY="ALL"
export MY_MAIL="someone@example.com"
export MY_NAME="\$(whoami) <\$MY_MAIL>"

# Text Editor for Tools ###################################### (edit this line)
#   - examples: "nano", "vim", "emacs -nw", "vi" or without terminal: "gedit"
export EDITOR="nano"

# load packages
spack unload

# PIConGPU build dependencies #################################################
#   need to load correct cmake and gcc to compile picongpu

spack load cmake@3.26.5 ^openssl %gcc

# General modules #############################################################
#   correct dependencies are automatically loaded, if successfully installed using install.sh
#   and no name confilcts in spack, see install.sh for more precise definition
#   if name conflicts occur

spack load openpmd-api@0.15.2 %gcc \
    ^adios2@2.9.2 \
    ^hdf5@1.14.3 \
    ^openmpi@4.1.5 +atomics +cuda cuda_arch=70 \
    ^python@3.11.6 \
    ^py-numpy@1.23.5
spack load boost@1.83.0 %gcc

# PIConGPU output dependencies ################################################
#
spack load pngwriter@0.7.0 %gcc

# Python pip dependency #######################################################
spack load py-pip ^python@3.11.6 %gcc


# Environment #################################################################
#
export PICSRC=\$HOME/src/picongpu
export PIC_EXAMPLES=\$PICSRC/share/picongpu/examples
export PIC_BACKEND="cuda:70"

# Path to the required templates of the system,
# relative to the PIConGPU source code of the tool bin/pic-create.
export PIC_SYSTEM_TEMPLATE_PATH=\${PIC_SYSTEM_TEMPLATE_PATH:-"etc/picongpu/bash-devServer-hzdr"}

export PATH=\$PICSRC/bin:\$PATH
export PATH=\$PICSRC/src/tools/bin:\$PATH

export PYTHONPATH=\$PICSRC/lib/python:\$PYTHONPATH

# "tbg" default options #######################################################
export TBG_SUBMIT="bash"
export TBG_TPLFILE="etc/picongpu/bash-devServer-hzdr/mpiexec.tpl"

# Load autocompletion for PIConGPU commands
BASH_COMP_FILE=\$PICSRC/bin/picongpu-completion.bash
if [ -f "\$BASH_COMP_FILE" ] ; then
    source \$BASH_COMP_FILE
else
    echo "bash completion file '\$BASH_COMP_FILE' not found." >&2
fi
EOT