#!/bin/bash

# Wait for EBS mounts to become available
while [ ! -e /dev/xvdf ]
do
  echo 'waiting for /dev/xvdf to attach'
  sleep 10
done
mkdir /data

# Create filesystems and mount point info
if [[ $(file -s /dev/xvdf | awk '{ print $2 }') == data ]]
then
  mkfs -t ext4 /dev/xvdf > /tmp/mkfs.log
fi

# Mount the drive immediately and in fstab
echo "`file -s /dev/xvdf` /data ext4 defaults,nofail 0 0" | tee -a /etc/fstab
mount /data > /tmp/mount.log

# Goto where docker and jenkins data is stored
cd /var/lib

# Make the directories on the mounted drive
mkdir -p /data/jenkins
mkdir -p /data/docker

# After all that, symlink the /var/lib/docker and jenkins directories to /data
ln -s /data/jenkins jenkins
ln -s /data/docker docker

# Chown it over to the jenkins user
# sudo chown -h jenkins:root /var/lib/jenkins