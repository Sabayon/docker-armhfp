FROM sabayon/rpi-armhfp

MAINTAINER mudler <mudler@sabayonlinux.org>

# Set locales to en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV ACCEPT_LICENSE=*

# Installing packages without questions
RUN sed -i 's/multifetch = 3/#multifetch = 3/' /etc/entropy/client.conf && \
	equo up && equo u && \
	equo i kodi-raspberrypi app-misc/sabayon-auto-updater && \
	echo -5 | equo conf update && equo cleanup && sed -i 's/#multifetch = 3/multifetch = 3/' /etc/entropy/client.conf

RUN systemctl enable kodi-raspberrypi && systemctl enable sabayon-auto-updater.timer && systemctl disable getty@tty1
RUN gpasswd -a kodi audio
ADD ./config.txt /boot/config.txt
RUN echo 'root=/dev/mmcblk0p2 rootfstype=ext4 rootwait consoleblank=0 loglevel=1 quiet logo.nologo' > /boot/cmdline.txt
# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /

# Define standard volumes
#VOLUME ["/usr/portage", "/usr/portage/distfiles", "/usr/portage/packages", "/var/lib/entropy/client/packages"]
