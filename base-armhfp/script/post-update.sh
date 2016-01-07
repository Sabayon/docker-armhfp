#!/bin/bash

PACKAGES_TO_REMOVE=(

)

FILES_TO_REMOVE=(
   "/.viminfo"
   "/.history"
   "/.zcompdump"
   "/var/log/emerge.log"
   "/var/log/emerge-fetch.log"
   "/usr/portage/licenses"
   "/etc/entropy/packages/license.accept"
   "/equo-rescue-generate.exp"
    "/equo.sql"
    "/generate-equo-db.sh"
    "/post-upgrade.sh"
    "/sabayon-configuration-build.sh"
    "/sabayon-configuration.sh"
    "/post-upgrade.sh"

    # Cleaning portage metadata cache
    "/usr/portage/metadata/md5-cache/*"
    "/var/log/emerge/*"
    "/var/log/entropy/*"
    "/root/* /root/.*"
    "/etc/zsh"

    "/post-update.sh"

    # cleaning licenses accepted
    "/usr/portage/licenses"
)

# removing portage and keeping profiles and metadata)
#ls  /usr/portage/ | grep -v 'profiles' | grep -v 'metadata' | xargs rm -rf

mkdir -p /etc/portage/repos.conf/
echo "[DEFAULT]
main-repo = gentoo

[gentoo]
location = /usr/portage
sync-type = rsync
sync-uri = rsync://rsync.europe.gentoo.org/gentoo-portage
" > /etc/portage/repos.conf/gentoo.conf

# Upgrading packages

rsync -av "rsync://rsync.at.gentoo.org/gentoo-portage/licenses/" "/usr/portage/licenses/" && ls /usr/portage/licenses -1 | xargs -0 > /etc/entropy/packages/license.accept && \
echo -5 | equo conf update

# Cleanup
#equo rm --deep --configfiles --force-system "${PACKAGES_TO_REMOVE[@]}"

# Remove compilation tools
#equo rm --nodeps --force-system autoconf automake bison yacc gcc localepurge

# Writing package list file
equo q list installed -qv > /etc/sabayon-pkglist

equo cleanup

# Cleanup
rm -rf "${FILES_TO_REMOVE[@]}"


