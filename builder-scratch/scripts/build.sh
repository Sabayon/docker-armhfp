#!/bin/bash
# Author: Geaaru <geaaru@sabayonlinux.org>
#

SOURCE_DIR=${SOURCE_DIR:-/sabayon}
SABAYON_PROFILE_ID=${SABAYON_PROFILE_ID:-65}
SABAYON_EQUO_DIR="/var/lib/entropy/client/database/"

. $(dirname $(readlink -f $BASH_SOURCE))/commons.sh

FILES_TO_REMOVE=(
  "/.viminfo"
  "/.history"
  "/.zcompdump"
  "/var/log/emerge.log"
  "/var/log/emerge-fetch.log"
  "/usr/portage/licenses"
  "/etc/entropy/packages/license.accept"
  "/sabayon/"

  # Cleaning portage metadata cache
  "/usr/portage/metadata/md5-cache/*"
  "/var/log/emerge/*"
  "/var/log/entropy/*"
  "/usr/portage/distfiles/"
  "/usr/portage/packages/"
  "/root/* /root/.*"
  "/etc/zsh"

  # cleaning licenses accepted
  "/usr/portage/licenses"
)

# Docker build command doesn't support caps (why????)
# so we need disable sandbox to avoid errors:
# ptrace(PTRACE_TRACEME, ..., 0x0000000000000000, 0x0000000000000000): Operation not permitted
SABAYON_EXTRA_ENV=(
  "dev-libs/gobject-introspection no-sandbox.conf"

  "sys-apps/sandbox no-sandbox.conf"
  "sys-libs/glibc no-sandbox.conf"

  "dev-lang/go no-sandbox.conf"
  "dev-go/go-md2man no-sandbox.conf"

  # SYS_PTRACE problem"
  "sys-libs/ncurses no-sandbox.conf"
)

sabayon_clean_makeconf () {
  sed -i -e 's:^PYTHON_.*::g' ${MAKE_PORTAGE_FILE}
  sed -i -e 's:^CFLAGS.*::g' ${MAKE_PORTAGE_FILE}
  sed -i -e 's:^CXXFLAGS.*::g' ${MAKE_PORTAGE_FILE}
}

sabayon_stage3_init_equo () {

  local equodir=${SABAYON_EQUO_DIR}/${SABAYON_ARCH}
  local size=""

  mkdir -p ${equodir}
  cd ${equodir}

  cat ${SOURCE_DIR}/equo.sql | sqlite3 equo.db

  size=$(ls -l ${equodir}/equo.db  | cut -d' ' -f5)
  if [ x"$size" == x"0" ] ; then
    echo "Something go wrong on create equo.db."
    exit 1
  fi

  echo "Create equo.db database from schema correctly."
}

init () {
  uname -a

  sabayon_load_locate

  sabayon_check_etc_portage

  sabayon_set_resolvconf "208.67.222.222" "208.67.220.220"

  sabayon_set_default_shell "/bin/bash"

  emerge-webrsync

  sabayon_install_overlay "sabayon" 1
  sabayon_install_overlay "sabayon-distro" 1

  eselect profile list
  eselect profile set ${SABAYON_PROFILE_ID}

  sabayon_clean_makeconf

  # Create /etc/portage/00-sabayon.package.mask until ::gentoo is supported
  # under profile directory.
  sabayon_mask_upstream_pkgs

  sabayon_create_reposfile

  [ ! -e /etc/portage/env/no-sandbox.conf ] && \
    echo 'FEATURES="-sandbox -usersandbox"' > /etc/portage/env/no-sandbox.conf

  for ((i = 0 ; i < ${#SABAYON_EXTRA_ENV[@]} ; i++)) ; do
    echo -e ${SABAYON_EXTRA_ENV[${i}]} >> \
      /etc/portage/package.env/01-sabayon.package.env
  done

  cat /etc/portage/package.env/01-sabayon.package.env || true
}

build_gcc () {
  for ((i = 0 ; i < ${#SABAYON_EXTRA_MASK[@]} ; i++)) ; do
    echo ${SABAYON_EXTRA_MASK[${i}]} >> \
      /etc/portage/package.mask/00-sabayon.package.mask
  done

  emerge -C $(qlist -IC dev-perl/) $(qlist -IC virtual/perl) \
    $(qlist -IC perl-core/) \
    app-crypt/pinentry \
    sys-apps/texinfo \
    sys-apps/baselayout \
    dev-python/requests \
    dev-vcs/git \
    app-text/po4a \
    media-gfx/graphite2 \
    app-eselect/eselect-python

  # Force building of bash without ebuild
  # baselayout needed for /etc/profile file
  emerge -u app-shells/bash app-crypt/gnupg sys-apps/baselayout --oneshot --quiet -b


  emerge ${SAB_EMERGE_OPTS} -b dev-perl/XML-Parser \
    sys-apps/util-linux \
    $(qgrep -JN sys-libs/readline | cut -f1 -d":" | uniq | sed -e 's:^:=:g' | grep -v "util-linux" )

  emerge sys-devel/gcc-config sys-apps/gentoo-functions -b -j -u


  export current_gcc=$(gcc-config -c)
  export current_gcc_version=$(echo $(gcc-config -c) | awk 'match($0, /[0-9].[0-9].[0-9]/) { print substr($0, RSTART, RLENGTH) }')

  FEATURES="-collision-protect -protect-owned" emerge -b sys-devel/base-gcc::sabayon-distro --quiet-build

  export sabayon_gcc=$(gcc-config -c)
  export sabayon_gcc_version=$(echo $(gcc-config -c) | awk 'match($0, /[0-9].[0-9].[0-9]/) { print substr($0, RSTART, RLENGTH) }')

  gcc-config ${current_gcc}

  . /etc/profile

  FEATURES="-collision-protect -protect-owned" emerge -b sys-devel/gcc::sabayon-distro  --quiet-build

  if [ ${sabayon_gcc_version} != ${current_gcc_version} ] ; then
    emerge --unmerge =sys-devel/gcc-${current_gcc_version}::gentoo || true
    # If there is same version this is not needed.
  fi

  FEATURES="-collision-protect -protect-owned" emerge -K sys-devel/base-gcc::sabayon-distro \
    sys-devel/gcc::sabayon-distro

  gcc-config ${sabayon_gcc}
  . /etc/profile
}

build_system () {

  # Force use of py3.6
  eselect python set python3.6

  emerge --unmerge app-admin/eselect app-text/xmlto
  emerge sandbox coreutils -j -b

  # Fix problem after upgrade of glibc
  sed -e 's/compat/compat files/g' -i  /etc/nsswitch.conf

  # Force installation of libaio: missing dependency of lvm2!!!
  emerge dev-libs/libaio -j -b

  # Needed for builder and sark-localbuild
  emerge sys-process/tini dev-python/shyaml app-portage/gentoolkit -j -b

  emerge --newuse --deep --with-bdeps=y -j @system --buildpkg -pv
  emerge --newuse --deep --with-bdeps=y -j @system --buildpkg

  emerge ${SAB_EMERGE_OPTS} @preserved-rebuild -b -j
}

build_sabayon_stuff () {
  emerge sys-apps/entropy-server sys-apps/entropy app-admin/equo dev-tcltk/expect \
    dev-vcs/git dev-python/requests -j

  sabayon_set_default_shell "/bin/bash"

  emerge enman app-misc/sabayon-sark app-misc/sabayon-devkit -b -j

  # Create equo database and directory
  sabayon_stage3_init_equo

  # Calling equo rescue generate, unfortunately we have to use expect
  /usr/bin/expect ${SOURCE_DIR}/equo-rescue-generate.exp

  # Configuring for build
  echo "*" > /etc/eix-sync.conf

  sed -i 's/#multifetch = 3/multifetch = 3/' /etc/entropy/client.conf

  # Clean
  rm -rf "${FILES_TO_REMOVE[@]}"
}

export ACCEPT_LICENSE='*'
export SAB_EMERGE_OPTS='-j --with-bdeps=y'

case $1 in
  init)
    init
    ;;
  build_gcc)
    build_gcc
    ;;
  build_system)
    build_system
    ;;
  build_sabayon_stuff)
    build_sabayon_stuff
    ;;
  *)
  echo "Use init|build"
  exit 1
esac

exit $?

