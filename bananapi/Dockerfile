FROM sabayon/armhfp

MAINTAINER geaaru <geaaru@gmail.com>

# Set locales to en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Perform post-upgrade tasks (mirror sorting, updating repository db)
ADD ./scripts/setup.sh /setup.sh
RUN /bin/bash /setup.sh  && rm -rf /setup.sh

# Firmware and modules blob
ADD ./firmware_modules.tar /
ADD ./boot.tar /
# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /

