FROM ubuntu:16.04
ENV container docker
# Don't start any optional services except for the few we need.
RUN find /etc/systemd/system \
         /lib/systemd/system \
         -path '*.wants/*' \
         -not -name '*journald*' \
         -not -name '*systemd-tmpfiles*' \
         -not -name '*systemd-user-sessions*' \
         -exec rm \{} \;
RUN systemctl set-default multi-user.target
CMD ["/sbin/init"]

RUN apt-get update; apt-get -y upgrade
RUN apt-get -y install rsyslog logrotate ssmtp logwatch
RUN apt-get -y install cron openssh-server psmisc netcat mini-httpd git

RUN useradd --system --create-home vnc
COPY vnc-home /home/vnc/
RUN chown -R vnc:vnc /home/vnc/ && \
    chmod 700 /home/vnc/.ssh

WORKDIR /home/vnc/