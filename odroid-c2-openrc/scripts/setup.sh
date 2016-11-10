#!/bin/bash

/usr/sbin/env-update
. /etc/profile
export ACCEPT_LICENSE=*
UPGRADE_REPO="sabayon-limbo"

sed -i 's/multifetch = 3/#multifetch = 3/' /etc/entropy/client.conf
if [ -n "${UPGRADE_REPO}" ]; then
	echo "Upgrading system by enabling ${UPGRADE_REPO}"
	equo repo enable "${UPGRADE_REPO}"
	FORCE_EAPI=2 equo update

	/usr/bin/equo repo mirrorsort "${UPGRADE_REPO}"  # ignore errors
	/usr/bin/equo repo mirrorsort sabayonlinux.org

	ETP_NONINTERACTIVE=1 equo upgrade --fetch
	ETP_NONINTERACTIVE=1 equo upgrade --purge
	echo "-5" | equo conf update
fi
# Prepare the rootfs
/usr/bin/equo i sys-apps/sysvinit sys-apps/openrc
/usr/bin/equo mask sys-apps/systemd-sysv-utils app-misc/sabayon-version

# /usr/bin/equo i sys-fs/udev sys-fs/udev-init-scripts
# /usr/bin/equo mask sys-apps/systemd
rc-update add ntpd
rc-update add NetworkManager
rc-update add sshd

echo -5 | equo conf update && equo cleanup
sed -i 's/#multifetch = 3/multifetch = 3/' /etc/entropy/client.conf


exit 0
