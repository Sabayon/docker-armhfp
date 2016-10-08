#!/bin/bash

/usr/sbin/env-update
. /etc/profile
export ACCEPT_LICENSE=*

sed -i 's/multifetch = 3/#multifetch = 3/' /etc/entropy/client.conf
/usr/bin/equo repo mirrorsort sabayonlinux.org
/usr/bin/equo up
# Be sure to have this on the image, always.
/usr/bin/equo i mate-base/mate x11-misc/lightdm x11-misc/lightdm-gtk-greeter
/usr/bin/equo u
systemctl enable lightdm
echo -5 | equo conf update && equo cleanup
sed -i 's/#multifetch = 3/multifetch = 3/' /etc/entropy/client.conf

exit 0
