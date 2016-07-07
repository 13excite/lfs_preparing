#!/bin/bash

#NEED CREATED PARTITION
#DEFAULT /dev/vdb1 - LFS partition; /dev/vdb2 - swap 

#default VM main partition for LFS
mkfs -v -t ext4 /dev/vdb1

#default swap partiton 
mkswap /dev/vdb2

#create env var and check
export LFS=/mnt/lfs
echo $LFS
sleep 4

#mount LFS partition
mkdir -pv $LFS
mount -v -t ext4 /dev/vdb1 $LFS

#enable swap
/sbin/swapon -v /dev/vdb2

#create dirictory for source packeges and make this directory writable and sticky
mkdir -v $LFS/sources
chmod -v a+wt $LFS/sources

#download packeges
wget http://www.linuxfromscratch.org/lfs/view/stable-systemd/wget-list
wget --input-file=wget-list --continue --directory-prefix=$LFS/sources

#verify packeges
pushd $LFS/sources
md5sum -c md5sums
popd

#create symlink on the host system
mkdir -v $LFS/tools
ln -sv $LFS/tools /

#create user lfs and group also named
groupadd lfs
useradd -s /bin/bash -g lfs -m -k /dev/null lfs

echo 'You need change password for lfs user'
sleep 5
passwd lfs
#grant lfs full access and making owner
chown -v lfs $LFS/tools
chown -v lfs $LFS/sources

#login as lfs
su - lfs

#create a new .bash_profile
cat > ~/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF

#create the .bashrc file
cat > ~/.bashrc << "EOF"
set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/tools/bin:/bin:/usr/bin
export LFS LC_ALL LFS_TGT PATH
EOF

#source the just-created user profile
source ~/.bash_profile
