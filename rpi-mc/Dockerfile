FROM sabayon/rpi-armhfp

MAINTAINER mudler <mudler@sabayonlinux.org>

# Set locales to en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Installing packages without questions
RUN rsync -av "rsync://rsync.at.gentoo.org/gentoo-portage/licenses/" "/usr/portage/licenses/" && \
	sed -i 's/multifetch = 3/#multifetch = 3/' /etc/entropy/client.conf && ls /usr/portage/licenses -1 | xargs -0 > /etc/entropy/packages/license.accept && \
	equo up && equo u && \
	equo i kodi-raspberrypi app-misc/sabayon-auto-updater && \
	echo -5 | equo conf update && equo cleanup && sed -i 's/#multifetch = 3/multifetch = 3/' /etc/entropy/client.conf

RUN systemctl enable kodi-raspberrypi && systemctl enable sabayon-auto-updater.timer
RUN gpasswd -a kodi audio
ADD ./config.txt /boot/config.txt
# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /

# Define standard volumes
#VOLUME ["/usr/portage", "/usr/portage/distfiles", "/usr/portage/packages", "/var/lib/entropy/client/packages"]
