# FROM sabayon/armhfp
# Temporary use geaaru/stage3 until gentoo/stage3 is available.
FROM geaaru/stage3-gentoo-systemd-armv7a_hardfp

LABEL maintainer="mudler <mudler@sabayonlinux.org>"

# Set locales to en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Supporting crossbuilding with binfmt
ADD ext/qemu-arm-static /usr/bin/qemu-arm-binfmt

ADD ./scripts/ /sabayon

RUN chmod a+x /sabayon/build.sh && /sabayon/build.sh init &&
  /sabayon/build.sh build

ADD ./scripts/depcheck /usr/local/bin/depcheck

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /

# Define standard volumes
VOLUME ["/usr/portage", "/usr/portage/distfiles", "/usr/portage/packages", "/var/lib/entropy/client/packages"]

# Define default command.
ENTRYPOINT ["/usr/sbin/builder"]
