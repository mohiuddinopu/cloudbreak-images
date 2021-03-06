FROM ubuntu:16.04 as builder

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gcc \
        libc6-dev

COPY /docker/common/src /src

RUN gcc -Wall -DCOMMAND='"/bin/systemd"' -o /systemd-wrapper /src/start-setuid.c

#####

FROM ubuntu:16.04

LABEL maintainer=Hortonworks

ARG SYSTEMCTL=https://raw.githubusercontent.com/hortonworks/docker-systemctl-replacement/3a885817b377f0307bd03d82323fa5749136de8f/files/docker/systemctl.py

ENV TERM linux
ENV PS1 "[\u@cloudbreak \W]\$ "

# Set default shell to bash
SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        cron \
        curl \
        gnupg2 \
        iproute2 \
        python-minimal \
        ssh \
        sudo \
        systemd && \
    rm -rf /var/lib/apt/lists/*

# Unneeded systemd services
RUN (cd /lib/systemd/system/sysinit.target.wants && \
    ls | grep -v systemd-tmpfiles-setup.service | xargs rm) && \
    rm -f /lib/systemd/system/multi-user.target.wants/* && \
    rm -f /lib/systemd/system/local-fs.target.wants/* && \
    rm -f /lib/systemd/system/sockets.target.wants/*udev* && \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl* && \
    rm -f /lib/systemd/system/basic.target.wants/* && \
    rm -f /etc/systemd/system/*.wants/*

# Replace systemctl during SaltStack provisioning
RUN dpkg-divert --add --rename /bin/systemctl && \
    curl -s -o /bin/systemctl $SYSTEMCTL && \
    chmod 755 /bin/systemctl

# SaltStack provisioning
COPY /saltstack/ /tmp/saltstack/
COPY /repos/     /tmp/repos/
COPY /scripts/   /tmp/scripts/

COPY docker/common/_grains/ /tmp/saltstack/base/salt/_grains/
COPY docker/common/_grains/ /tmp/saltstack/hortonworks/salt/_grains/
RUN printf '\n\nproviders:\n  service: systemd\n' >>/tmp/saltstack/config/minion
RUN /tmp/scripts/salt-install.sh ubuntu salt-repo-ubuntu16.list
RUN /tmp/scripts/salt-setup.sh hortonworks

# Undo systemctl replacement
RUN rm /bin/systemctl && \
    dpkg-divert --remove --rename /bin/systemctl

# Ycloud integration
RUN groupmod -g 99 nogroup && \
    usermod -u 99 -g nogroup nobody

COPY --from=builder /systemd-wrapper /systemd-wrapper
RUN chown root:nogroup /systemd-wrapper && \
    chmod 4750 /systemd-wrapper

RUN systemctl enable ssh cron

EXPOSE 22

CMD ["/systemd-wrapper", "--system"]
