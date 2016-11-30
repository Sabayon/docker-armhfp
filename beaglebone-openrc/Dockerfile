FROM sabayon/armhfp

MAINTAINER amynka <amynka@sabayonlinux.org>

# Set locales to en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Perform post-upgrade tasks (mirror sorting, updating repository db)
ADD ./scripts/setup.sh /setup.sh
ADD ./uboot/u-boot.img /opt/backup/uboot/
ADD ./uboot/MLO /opt/backup/uboot/
RUN /bin/bash /setup.sh  && rm -rf /setup.sh

ADD ./firmware_modules.tar /lib
ADD ./boot.tar /boot

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /
