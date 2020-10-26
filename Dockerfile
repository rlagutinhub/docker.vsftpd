# docker build -f Dockerfile -t vsftpd:latest .
# docker run --rm -it -p 21:21/tcp -p 20:20/tcp -e "FTP_ADM_NAME=ftpadm" -e "FTP_ADM_PASS=passw0rd" vsftpd:latest
# docker run --rm -it -p 21:21/tcp -p 20:20/tcp -p 32757-32767:32757-32767/tcp -e "FTP_ADM_NAME=ftpadm" -e "FTP_ADM_PASS=passw0rd" vsftpd:latest


FROM oraclelinux:7-slim

MAINTAINER Lagutin R.A. <rlagutin@mta4.ru>

ARG FTP_UID=1000
ARG FTP_GID=1000

RUN set -x \
  && groupadd -g ${FTP_GID} ftpsys \
  && useradd --no-create-home --home-dir /var/ftp -s /sbin/nologin --uid ${FTP_UID} --gid ${FTP_GID} -c 'ftp system' ftpsys \
  ;

ENV LANG=en_US.UTF-8 \
    TZ=Europe/Moscow

RUN set -ex \
    && yum -y update \
    && yum -y --setopt=tsflags=nodocs install rootfiles tar gzip \
    && yum -y --setopt=tsflags=nodocs install vsftpd \
    && rm -rf /var/cache/yum/* \
    ;

COPY vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY vsftpd_virtual /etc/pam.d/
COPY setup-ftp /usr/local/bin/setup-ftp

EXPOSE 20 21

CMD ["setup-ftp"]
