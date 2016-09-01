#!/bin/bash

/usr/sbin/env-update
. /etc/profile

sed -i 's/multifetch = 3/#multifetch = 3/' /etc/entropy/client.conf

pushd /etc/portage
git stash
git pull
popd

equo i base-gcc
equo cleanup
sed -i 's/#multifetch = 3/multifetch = 3/' /etc/entropy/client.conf

exit 0
