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
    chmod +x /setup.sh && /bin/bash /setup.sh && rm -rf /setup.sh

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /

# Define standard volumes
#VOLUME ["/usr/portage", "/usr/portage/distfiles", "/usr/portage/packages", "/var/lib/entropy/client/packages"]
