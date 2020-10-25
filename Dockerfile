# docker build -f Dockerfile -t vsftpd:latest .
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

COPY pam_pwdfile/libpam-pwdfile-master.zip /tmp/libpam-pwdfile-master.zip

RUN set -ex \
    && unzip /tmp/libpam-pwdfile-master.zip -d /tmp \
    && make -C /tmp/libpam-pwdfile-master \
    && cp -p /tmp/libpam-pwdfile-master/pam_pwdfile.so /usr/lib64/security/ \
    && rm -rf /tmp/libpam-pwdfile-master.zip \
    && rm -rf /tmp/libpam-pwdfile-master \
    ;

COPY vsftpd.conf /etc/vsftpd.conf
COPY vsftpd_virtual /etc/pam.d/
COPY setup-ftp /usr/local/bin/setup-ftp

EXPOSE 20 21

CMD ["setup-ftp"]
