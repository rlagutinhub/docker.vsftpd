FROM oraclelinux:8-slim

MAINTAINER Lagutin R.A. <rlagutin@mta4.ru>

ARG FTP_UID=14
ARG FTP_GID=50

ENV LANG=ru_RU.UTF-8 \
    TZ=Europe/Moscow

RUN set -ex \
    && usermod -u ${FTP_UID} ftp \
    && groupmod -g ${FTP_GID} ftp \
    ;

RUN set -ex \
    && microdnf install rootfiles tar gzip glibc-langpack-ru \
    && microdnf install openssl nc ftp vsftpd \
    && microdnf clean all \
    ;

COPY vsftpd.* /etc/vsftpd/
COPY vsftpd_virtual /etc/pam.d/
COPY setup-ftp /usr/local/bin/

# EXPOSE 20 21 30025-30050

CMD ["setup-ftp"]
