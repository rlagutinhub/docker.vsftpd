FROM oraclelinux:7-slim

MAINTAINER Lagutin R.A. <rlagutin@mta4.ru>

ARG FTP_UID=15
ARG FTP_GID=50

ENV LANG=en_US.UTF-8 \
    TZ=Europe/Moscow

RUN set -ex \
    && yum -y update \
    && yum -y --setopt=tsflags=nodocs install rootfiles tar gzip zip unzip gcc make pam-devel httpd-tools vsftpd \
    && rm -rf /var/cache/yum/* \
    ;

RUN usermod -u ${FTP_UID} ftp
RUN groupmod -g ${FTP_GID} ftp

COPY vsftpd.conf /etc/vsftpd.conf 
COPY setup-ftp /usr/local/bin/setup-ftp

EXPOSE 20 21 4559 4560 4561 4562 4563 4564

CMD ["setup-ftp"]
