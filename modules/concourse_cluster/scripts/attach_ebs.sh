#!/bin/bash
if [ $# -ne 3 ]; then
    echo "This script will mount an EBS volume assuming it's been attached at the"
    echo "provided mount point. Ensure you've passed in a valid device."
    echo "Name of the device is required. Please supply it as parameter 1 (e.g. /dev/xvdh)"
    echo "Name of the mount point is required. Please supply it as parameter 2 (e.g. /data/foo)"
    echo "Name of the file system type is required. Please supply it as parameter 3 (e.g. ext4)"
	exit 1;
fi

if [ ! -b $1 ]; then
    echo "The device provided $1 does not exist. Cannot continue."
    exit 1;
fi

set -e
echo "Formatting device to use file system $3"
mkfs -t $3 $1
echo "Creating directory to mount the volume to at $2"
mkdir -p $2
echo "Mounting drive..."
mount $1 $2
echo "Updating fstab..."
echo $1 $2 $3 defaults,nofail 0 2 >> /etc/fstab
echo "Done. Bye!"