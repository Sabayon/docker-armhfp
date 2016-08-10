#!/bin/bash

/usr/sbin/env-update
. /etc/profile

setup_bootfs_fstab() {
	# add /dev/mmcblk0p1 to /etc/fstab
	local boot_part_type="${1}"
	echo "/dev/mmcblk0p1  /boot  ${boot_part_type}  defaults  0 2" >> /etc/fstab
}

setup_rootfs_fstab() {
	echo "/dev/mmcblk0p2 / ext4 noatime 0 1" >> /etc/fstab
}

rm -rfv /etc/fstab
#setup_bootfs_fstab "vfat"
setup_rootfs_fstab

# Force armv7l entropy architecture (kernel is 64bit)
echo "armv7l" > /etc/entropy/.arch"

exit 0
