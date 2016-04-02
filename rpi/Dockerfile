FROM sabayon/armhfp

MAINTAINER mudler <mudler@sabayonlinux.org>

# Set locales to en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Installing packages without questions
RUN rsync -av "rsync://rsync.at.gentoo.org/gentoo-portage/licenses/" "/usr/portage/licenses/" && \
	ls /usr/portage/licenses -1 | xargs -0 > /etc/entropy/packages/license.accept && \
	equo up && equo u && \
	equo i media-libs/raspberrypi-userland-0_pre20150921 \
	sys-kernel/raspberrypi-sources-3.10.1_pre-r20130719 && \
	rm -rf /etc/entropy/packages/license.accept && echo -5 | equo conf update

RUN wget https://raw.githubusercontent.com/Hexxeh/rpi-update/master/rpi-update -O /usr/sbin/rpi-update && chmod +x /usr/sbin/rpi-update

# Perform post-upgrade tasks (mirror sorting, updating repository db)
ADD ./scripts/setup.sh /setup.sh
RUN /bin/bash /setup.sh  && rm -rf /setup.sh

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /

# Define standard volumes
#VOLUME ["/usr/portage", "/usr/portage/distfiles", "/usr/portage/packages", "/var/lib/entropy/client/packages"]
