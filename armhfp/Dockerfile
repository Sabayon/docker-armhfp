FROM sabayon/base-armhfp

MAINTAINER mudler <mudler@sabayonlinux.org>

# Set locales to en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Adding qemu-static, so amd64 can build this image
ADD ./ext/qemu-arm-static /usr/bin/qemu-arm-binfmt
RUN mv /etc/entropy/repositories.conf.d/entropy_sabayonlinux.org.example /etc/entropy/repositories.conf.d/entropy_sabayonlinux.org

RUN rsync -av "rsync://rsync.at.gentoo.org/gentoo-portage/licenses/" "/usr/portage/licenses/" && \
	ls /usr/portage/licenses -1 | xargs -0 > /etc/entropy/packages/license.accept && \
	equo rescue spmsync &&  equo up && equo u && \
  equo i app-admin/sudo net-misc/openssh net-misc/networkmanager \
	app-misc/sabayon-live app-misc/sabayon-skel net-misc/ntp \
	sys-apps/keyboard-configuration-helpers \
	sys-apps/systemd app-misc/sabayon-version \
  sys-process/vixie-cron && \
	rm -rf /etc/entropy/packages/license.accept && echo -5 | equo conf update

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /

# Define standard volumes
#VOLUME ["/usr/portage", "/usr/portage/distfiles", "/usr/portage/packages", "/var/lib/entropy/client/packages"]
