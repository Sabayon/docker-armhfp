#!/bin/bash
# Author: Geaaru, geaaru@gmail.com

MAKE_PORTAGE_FILE=${MAKE_PORTAGE_FILE:-/etc/portage/make.conf}
PORTDIR=${PORTDIR:-/usr/portage}
PORTAGE_LATEST_PATH=${PORTAGE_LATEST_PATH:-/portage-latest.tar.xz}
SABAYON_ARCH="${SABAYON_ARCH:-amd64}"
SABAYON_PORTAGE_CONF_REPOS=${SABAYON_PORTAGE_CONF_REPOS:-https://github.com/Sabayon/build.git}
SABAYON_PORTAGE_CONF_INSTALLDIR="${SABAYON_PORTAGE_CONF_INSTALLDIR:-/opt}"
SABAYON_PORTAGE_CONF_INSTALLNAME="${SABAYON_PORTAGE_CONF_INSTALLNAME:-sabayon-build}"
REPOS_CONF_DIR=${REPOS_CONF_DIR:-/etc/portage/repos.conf/}

sabayon_mask_upstream_pkgs () {

  local maskfile=${1:-/var/lib/layman/sabayon-distro/profiles/targets/sabayon/arm/package.mask}
  local outfile=${2:-/etc/portage/package.mask/00-sabayon.package.mask}

  grep GLOBAL_MASK ${maskfile} | awk '{ print  $3 }'  | tail -n +2 > ${outfile}
}

sabayon_set_default_shell () {
  local shell=${1:-/bin/bash}

  chsh -s ${shell} || return 1

  return 0
}

sabayon_set_resolvconf () {
  local dns="${1:-1.1.1.1}"
  local dns2="${2}"

  echo "nameserver ${dns}" > /etc/resolv.conf
  if [ -n "${dns2}" ] ; then
    echo "nameserver ${dns2}" >> /etc/resolv.conf
  fi

  return 0
}

sabayon_check_etc_portage () {

  if [[ ! -d /etc/portage/package.keywords ]] ; then
    mkdir -p /etc/portage/package.keywords
  fi

  if [[ ! -d /etc/portage/package.use ]] ; then
    mkdir -p /etc/portage/package.use
  fi

  if [[ ! -d /etc/portage/package.mask ]] ; then
    mkdir -p /etc/portage/package.mask
  fi

  if [[ ! -d /etc/portage/package.unmask ]] ; then
    mkdir -p /etc/portage/package.unmask
  fi

  if [[ ! -d /etc/portage/package.keywords ]] ; then
    mkdir -p /etc/portage/package.keywords
  fi

  return 0
}

sabayon_load_locate () {
  eselect locale set en_US.utf8 || return 1
  . /etc/profile
  return 0
}

sabayon_install_overlay () {

  local name=$1
  local unofficial=${2:-0}

  # Fetch list
  layman -f || return 1

  echo "Installing overlay ${name}..."

  # Install overlay
  if [ $unofficial -eq 0 ] ; then
    layman -a ${name} || return 1
  else
    echo 'y' | layman -a ${name} ||  return 1
  fi

  return 0
}

sabayon_install_build () {

  local builddir=${SABAYON_PORTAGE_CONF_INSTALLDIR}/${SABAYON_PORTAGE_CONF_INSTALLNAME}

  [ -z "${PORTDIR}" ] && return 1
  [ -z "${SABAYON_ARCH}" ] && return 1
  [ -z "${SABAYON_PORTAGE_CONF_INSTALLDIR}" ] && return 1
  [ -z "${SABAYON_PORTAGE_CONF_INSTALLNAME}" ] && return 1

  if [  -d "${builddir}" ] ; then

    pushd ${builddir}

    git add .
    git commit . -m "Local changes"
    EDITOR=cat git pull -ff

  else
    pushd "${SABAYON_PORTAGE_CONF_INSTALLDIR}"

    git clone ${SABAYON_PORTAGE_CONF_REPOS} ${SABAYON_PORTAGE_CONF_INSTALLNAME}

    # Configure repos
    git config --global user.name "root" || return 1
    git config --global user.email "root@localhost" || return 1

    # Temporary for use ${SABAYON_ARCH} variable
    ln -s ${builddir}/conf/intel ${builddir}/conf/amd64 || return 1
  fi

  popd

  return 0
}

sabayon_configure_portage () {

  local init_etc=${1:-0}
  local reposdir="${SABAYON_PORTAGE_CONF_INSTALLDIR}/${SABAYON_PORTAGE_CONF_INSTALLNAME}"

  sabayon_install_build || return 1

  # TODO: check if correct maintains intel configuration

  if [ ${init_etc} -eq 1 ] ; then
    cd /etc
    mv portage portage-gentoo || return 1
    ln -sf ${reposdir}/conf/armhfp/portage portage || return 1

  fi

  return 0
}

sabayon_save_pkgs_install_list () {
  # Writing package list file
  equo q list installed -qv > /etc/sabayon-pkglist || return 1

  return 0
}

sabayon_upgrade_kernel () {

  local paren_slink=""
  local paren_children=""
  local kernel_target_pkg="${1:-sys-kernel/linux-sabayon}"
  local available_kernel=$(equo match "${kernel_target_pkg}" -q --showslot)

  echo -en "\n@@ Upgrading kernel to ${available_kernel}\n\n"

  kernel-switcher switch "${available_kernel}" || return 1

  # now delete stale files in /lib/modules
  for slink in $(find /lib/modules/ -type l); do
    if [ ! -e "${slink}" ]; then
      echo "Removing broken symlink: ${slink}"
      rm "${slink}" # ignore failure, best effort
      # check if parent dir is empty, in case, remove
      paren_slink=$(dirname "${slink}")
      paren_children=$(find "${paren_slink}")
      if [ -z "${paren_children}" ]; then
        echo "${paren_slink} is empty, removing"
        rmdir "${paren_slink}" # ignore failure, best effort
      fi
    fi
  done

  return 0
}

sabayon_create_reposfile () {

  local url=${1:-rsync://rsync.europe.gentoo.org/gentoo-portage}
  local f=${2:-gentoo.conf}

  mkdir -p ${REPOS_CONF_DIR} || return 1

  echo "
[DEFAULT]
main-repo = gentoo

[gentoo]
location = /usr/portage
sync-type = rsync
sync-uri = ${url}
" > ${REPOS_CONF_DIR}${f}

  return $?
}

# vim: ts=2 sw=2 expandtab
