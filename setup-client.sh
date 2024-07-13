#!/bin/bash
if [[ $EUID = 0 ]]; then
    echo "user is root, good."
else
    echo "not running as root!"
    exit 1
fi

if dpkg -l | grep -q ufw; then
    ufw disable
    apt remove --purge ufw -y
fi
if dpkg -l | grep -q iptables; then
    iptables -F
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT
fi

sed -i "/#\$nrconf{restart} = 'i';/s/.*/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf
adduser -u 1010 user --disabled-password --gecos ""
echo 'user:user123' | chpasswd
addgroup -gid 1111 munge
addgroup -gid 1121 slurm
adduser -u 1111 munge --disabled-password --gecos "" -gid 1111
adduser -u 1121 slurm --disabled-password --gecos "" -gid 1121

apt update
apt install -y linux-headers-`uname -r`
apt install -y vim nano wget curl gnupg2 gpg-agent bc python3 libc-dev libc6-dev gcc g++ unzip git build-essential libmunge-dev libmunge2 munge systemd nfs-common 

sudo mkdir /workspace
chmod 777 /workspace
chmod 777 /opt

echo pca1:/home /home nfs auto,timeo=14,intr 0 0 | sudo tee -a /etc/fstab
echo pca1:/workspace /workspace nfs auto,timeo=14,intr 0 0 | sudo tee -a /etc/fstab
echo pca1:/opt /opt nfs auto,timeo=14,intr 0 0 | sudo tee -a /etc/fstab

ln -s /opt/apps/lmod/lmod/init/profile        /etc/profile.d/z00_lmod.sh
ln -s /opt/apps/lmod/lmod/init/cshrc          /etc/profile.d/z00_lmod.csh

cat <<EOT > /etc/profile.d/z00_spack.sh
export SPACK_ROOT="/opt/spack"
. /opt/spack/share/spack/setup-env.sh
EOT

wget https://tw.download.nvidia.com/tesla/550.90.07/NVIDIA-Linux-x86_64-550.90.07.run
sh NVIDIA-Linux-x86_64-550.90.07.run --silent
