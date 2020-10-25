FROM oraclelinux:7-slim

MAINTAINER Lagutin R.A. <rlagutin@mta4.ru>

ARG FTP_UID=1000
ARG FTP_GID=1000

RUN set -x \
  && groupadd -g ${FTP_GID} vsftpd \
  && useradd --no-create-home --home-dir /var/ftp -s /sbin/nologin --uid ${FTP_UID} --gid ${FTP_GID} -c 'vsftpd user' vsftpd \
  ;

ENV LANG=en_US.UTF-8 \
    TZ=Europe/Moscow

RUN set -ex \
    && yum -y update \
    && yum -y --setopt=tsflags=nodocs install rootfiles tar gzip zip unzip gcc make pam-devel openssl httpd-tools vsftpd \
    && rm -rf /var/cache/yum/* \
    ;

RUN set -ex \
    && make -C /tmp/libpam-pwdfile \
    && cp -p /tmp/libpam-pwdfile/pam_pwdfile.so /usr/lib64/security/ \
    && rm -rf /tmp/libpam-pwdfile
    ;

COPY vsftpd.conf /etc/vsftpd.conf
COPY vsftpd_virtual /etc/pam.d/
COPY setup-ftp /usr/local/bin/setup-ftp

EXPOSE 20 21

CMD ["setup-ftp"]
