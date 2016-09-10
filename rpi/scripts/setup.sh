#!/bin/bash

/usr/sbin/env-update
. /etc/profile
export ACCEPT_LICENSE=*

setup_bootfs_fstab() {
	# add /dev/mmcblk0p1 to /etc/fstab
	local boot_part_type="${1}"
	echo "/dev/mmcblk0p1  /boot  ${boot_part_type}  defaults  0 2" >> /etc/fstab
}

setup_rootfs_fstab() {
	echo "/dev/mmcblk0p2 / ext4 noatime 0 1" >> /etc/fstab
}

die() { echo "$@" 1>&2 ; exit 1; }

sed -i 's/multifetch = 3/#multifetch = 3/' /etc/entropy/client.conf
/usr/bin/equo repo mirrorsort sabayonlinux.org
/usr/bin/equo up 
# Be sure to have this on the image, always.
/usr/bin/equo i media-libs/raspberrypi-userland app-admin/rpi-update 
/usr/bin/equo u
echo -5 | equo conf update && equo cleanup
sed -i 's/#multifetch = 3/multifetch = 3/' /etc/entropy/client.conf

echo 'SUBSYSTEM=="vchiq",GROUP="video",MODE="0660"' > /etc/udev/rules.d/10-vchiq-permissions.rules
eselect opengl set raspberrypi-userland

rm -rfv /etc/fstab
setup_bootfs_fstab "vfat"
setup_rootfs_fstab

echo "y" | SKIP_BACKUP=1 /usr/sbin/rpi-update

exit 0
