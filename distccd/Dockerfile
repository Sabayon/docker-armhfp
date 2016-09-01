FROM sabayon/armhfp

MAINTAINER mudler <mudler@sabayonlinux.org>

# Set locales to en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV ACCEPT_LICENSE=*

RUN equo up && equo u && equo i distcc gcc base-gcc

# Cleaning accepted license2s
RUN rm -rf /etc/entropy/packages/license.accept

RUN echo -5 | equo conf update

# Perform post-upgrade tasks (mirror sorting, updating repository db)
ADD ./scripts/setup.sh /setup.sh
RUN /bin/bash /setup.sh  && rm -rf /setup.sh

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /

CMD ["/usr/bin/distccd", "--allow", "0.0.0.0/0", "--user", "distcc", "--log-level", "notice", "--log-stderr", "--no-detach"]

EXPOSE 3632
