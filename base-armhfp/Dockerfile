FROM sabayon/gentoo-stage3-base-armhf

MAINTAINER mudler <mudler@sabayonlinux.org>

# Supporting crossbuilding with binfmt
ADD ext/qemu-arm-static /usr/bin/qemu-arm-binfmt

# Set locales to en_US.UTF-8
RUN echo "en_US.UTF-8 UTF-8 " >> /etc/locale.gen &&  locale-gen &&  eselect locale set en_US.utf8 && env-update && source /etc/profile
ENV LC_ALL=en_US.UTF-8

# Upgrading portage and installing necessary packages
RUN emerge-webrsync && \
	layman -S && layman -a sabayon && layman -a sabayon-distro

# Configure the sabayon box, installing equo setting up locales
ADD ./script/sabayon-configuration.sh /
RUN /bin/bash /sabayon-configuration.sh && rm -rf /sabayon-configuration.sh

# Generating empty equo db
ADD ./script/generate-equo-db.sh /
ADD ./ext/equo.sql /
RUN /bin/bash /generate-equo-db.sh  && rm -rf /equo.sql /generate-equo-db.sh

# Calling equo rescue generate, unfortunately we have to use expect
ADD ./script/equo-rescue-generate.exp /
RUN /usr/bin/expect /equo-rescue-generate.exp &&  rm -rf /equo-rescue-generate.exp

# Portage configurations
ADD ./script/sabayon-configuration-build.sh /sabayon-configuration-build.sh
RUN /bin/bash /sabayon-configuration-build.sh && rm -rf /sabayon-configuration-build.sh

# Cleanup and applying configs
ADD ./script/post-update.sh /post-update.sh
RUN /bin/bash /post-update.sh && rm -rf /post-update.sh
