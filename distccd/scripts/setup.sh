#!/bin/bash

/usr/sbin/env-update
. /etc/profile

pushd /etc/portage
git stash
git pull
popd

equo i base-gcc
equo cleanup

exit 0
