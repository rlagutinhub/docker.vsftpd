# Docker Image:
# docker build -f Dockerfile -t vsftpd:latest .

# Docker Volume:
# docker volume create vsftpd_data
# docker volume create vsftpd_logs

# Docker Container:
# docker run -dit \
#  -e "FTP_FORCE_SSL=NO" \
#  -e "FTP_LISTEN_PORT=21" \
#  -e "FTP_DATA_PORT=20" \
#  -e "FTP_PASV_MIN_PORT=32500" \
#  -e "FTP_PASV_MAX_PORT=32599" \
#  -e "FTP_ADM_NAME=admin" \
#  -e "FTP_ADM_PASS=passw0rd" \
#  -e "FTP_USER_1=user1:pass1:/var/ftp/pub/data1:rw:yes" \
#  -e "FTP_USER_2=user2:pass2:/var/ftp/pub/data1/data2:ro:yes" \
#  -e "FTP_USER_3=user3:pass3:/var/ftp/pub/data1/data3:rw:no" \
#  --stop-timeout 60 \
#  --memory="2048m" --cpus=1 \
#  --network=bridge -p 20:20/tcp -p 21:21/tcp -p 32500-32599:32500-32599/tcp \
#  -v vsftpd_data:/var/ftp/pub \
#  -v vsftpd_logs:/logs \
#  --name vsftpd \
#  vsftpd:latest

# Other:
# docker ps -a
# docker image ls
# docker exec -it vsftpd bash
# docker logs vsftpd --follow
# docker container start vsftpd
# docker container stop vsftpd
# docker container rm -f vsftpd
# docker network rm vsftpd_net
# docker volume rm vsftpd_data
# docker volume rm vsftpd_logs
# docker image rm vsftpd:latest

FROM oraclelinux:8-slim

MAINTAINER Lagutin R.A. <rlagutin@mta4.ru>

ARG FTP_UID=1000
ARG FTP_GID=1000

ENV LANG=ru_RU.UTF-8 \
    TZ=Europe/Moscow

RUN set -x \
    && groupadd -g ${FTP_GID} ftpsecure \
    && useradd --no-create-home --home-dir /var/ftp -s /sbin/nologin --uid ${FTP_UID} --gid ${FTP_GID} -c 'ftp secure' ftpsecure \
    ;

RUN set -ex \
    && microdnf install rootfiles tar gzip glibc-langpack-ru \
    && microdnf install openssl nc ftp vsftpd \
    && microdnf clean all \
    ;

COPY vsftpd.* /etc/vsftpd/
COPY vsftpd_virtual /etc/pam.d/
COPY setup-ftp /usr/local/bin/

# EXPOSE 20 21 32500-32599

CMD ["setup-ftp"]
