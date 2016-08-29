FROM sabayon/base-armhfp

MAINTAINER mudler <mudler@sabayonlinux.org>

# Set locales to en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV ACCEPT_LICENSE=*
# Adding qemu-static, so amd64 can build this image
ADD ./ext/qemu-arm-static /usr/bin/qemu-arm-binfmt
ADD ./scripts/setup.sh /setup.sh

# Updating, adding basic packages, and running setup.sh
RUN mv /etc/entropy/repositories.conf.d/entropy_sabayonlinux.org.example /etc/entropy/repositories.conf.d/entropy_sabayonlinux.org && 
    /usr/bin/equo rescue spmsync && /usr/bin/equo repo mirrorsort sabayonlinux.org &&  /usr/bin/equo up && \
    /usr/bin/equo u --multifetch=1 && /usr/bin/equo i --multifetch=1 app-admin/sudo net-misc/openssh \
    net-misc/networkmanager app-misc/sabayon-live app-misc/sabayon-skel net-misc/ntp \
    sys-apps/keyboard-configuration-helpers sys-apps/systemd app-misc/sabayon-version \
    sys-process/vixie-cron && echo -5 | /usr/bin/equo conf update && chmod +x /setup.sh && \
    /bin/bash /setup.sh && rm -rf /setup.sh

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /

# Define standard volumes
#VOLUME ["/usr/portage", "/usr/portage/distfiles", "/usr/portage/packages", "/var/lib/entropy/client/packages"]
