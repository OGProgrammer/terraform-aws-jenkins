#!/bin/bash

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "BEGIN"

export ENV_NAME=${EnvName}
echo "${EnvName}" > /opt/env

### MOUNT EBS DRIVE (Jenkins Data Storage in-case of EC2 Migration)

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
echo '/dev/xvdf /data ext4 defaults 0 0' | tee -a /etc/fstab
mount /data > /tmp/mount.log

# Goto where jenkins data is stored
cd /var/lib

# Make the directory on the mounted drive
mkdir -p /data/jenkins
mkdir -p /data/docker

# After all that, symlink jenkins directory to /data
ln -s /data/jenkins jenkins
ln -s /data/docker docker

### INSTALL JENKINS & DEPS

# Grab the provision script from s3

until aws s3 cp --recursive s3://${JenkinsBucket} /; do
    echo "Trying to copy S3 files down to EC2."
    sleep 10
done

# Make bash scripts executable
chmod +x /init.sh /var/lib/jenkins/configure-git.sh

# Provision the Jenkins server
/init.sh

echo "END"