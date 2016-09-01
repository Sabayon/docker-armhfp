#!/bin/bash

/usr/sbin/env-update
. /etc/profile

sed -i 's/multifetch = 3/#multifetch = 3/' /etc/entropy/client.conf

pushd /etc/portage
git stash
git pull
popd

equo up && equo u && equo i distcc gcc base-gcc
echo -5 | equo conf update
equo cleanup
sed -i 's/#multifetch = 3/multifetch = 3/' /etc/entropy/client.conf
