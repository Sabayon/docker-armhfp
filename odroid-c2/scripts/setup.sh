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

# Force armv7l entropy architecture (kernel is 64bit)
echo "armv7l" > /etc/entropy/.arch
echo "~arm" > /etc/entropy/packages/package.keywords
echo "arm" >> /etc/entropy/packages/package.keywords

# Perform package upgrades
ACCEPT_LICENSE=* equo up && equo u

# Networkmanager gives issues on aarch64
systemctl disable NetworkManager
equo rm net-misc/networkmanager
cat > /etc/systemd/network/default_dhcp.network << "EOF"
[Network]
DHCP=ipv4

[DHCP]
UseDomains=true
EOF

systemctl enable systemd-networkd

# Cleanup
equo cleanup

# Accepts configuration updates
echo -5 | equo conf update

rm -rfv /etc/fstab
setup_rootfs_fstab

exit 0
