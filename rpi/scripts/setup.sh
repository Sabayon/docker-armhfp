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

echo 'SUBSYSTEM=="vchiq",GROUP="video",MODE="0660"' > /etc/udev/rules.d/10-vchiq-permissions.rules
eselect opengl set raspberrypi-userland

rm -rfv /etc/fstab
setup_bootfs_fstab "vfat"
setup_rootfs_fstab

sed -i "s/\tupdate_vc_libs/\#\tupdate_vc_libs/g" /usr/sbin/rpi-update || die "Cannot exclude update_vc_libs: Manually intervention needed"

echo "y" | SKIP_BACKUP=1 UPDATE_SELF=0 /usr/sbin/rpi-update

exit 0
