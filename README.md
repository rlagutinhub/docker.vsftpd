# vsFTPD Server in a Docker
```
```
This vsftpd docker image is based on official oraclelinux:8-slim image and comes with following features:  

 * Virtual users
 * SSL support
 * Active and Passive mode
 * Logging to a file and STDOUT
 * Anonymous account access

Environment variables
----

This image uses environment variables to allow the configuration of some parameters at run time:

* Variable name: `FTP_FORCE_SSL`
* Default value: NO
* Accepted values: <NO|YES>
* Description: Set to YES if you want to allow use force secured SSL connections.

----

* Variable name: `FTP_LOG_FILE`
* Default value: NO
* Accepted values: <NO|YES>
* Description: Set to YES if you want the log file to be written in `/logs/vsftpd/vsftpd.log`.

----

* Variable name: `FTP_LISTEN_PORT`
* Default value: 21
* Accepted values: Any valid port number.
* Description: This is the port it will listen on for incoming FTP command connections. Remember to publish your ports with `docker -p` parameter.

----

* Variable name: `FTP_DATA_PORT`
* Default value: 20
* Accepted values: Any valid port number.
* Description: This is the port it will data connections (ftp-data). Remember to publish your ports with `docker -p` parameter.

----

* Variable name: `FTP_PASV_ADDRESS`
* Default value: NO
* Accepted values: Any IPv4 address or Hostname (see FTP_PASV_ADDR_RESOLVE).
* Description: IP address that vsftpd will advertise in response to the PASV command. This is useul when running behind a proxy, or with docker swarm.

----

* Variable name: `FTP_PASV_ADDR_RESOLVE`
* Default value: NO
* Accepted values: <NO|YES>
* Description: Set to YES if you want to use a hostname (as opposed to IP address) in the PASV_ADDRESS option.

----

* Variable name: `FTP_PASV_MIN_PORT`
* Default value: 30025
* Accepted values: Any valid port number.
* Description: This will be used as the lower bound of the passive mode port range. Remember to publish your ports with `docker -p` parameter.

----

* Variable name: `FTP_PASV_MAX_PORT`
* Default value: 30050
* Accepted values: Any valid port number.
* Description: This will be used as the upper bound of the passive mode port range. It will take longer to start a container with a high number of published ports.

----

* Variable name: `FTP_PASV_PROMISCUOUS`
* Default value: NO
* Accepted values: <NO|YES>
* Description: Set to YES if you want to disable the PASV security check that ensures the data connection originates from the same IP address as the control connection. Only enable if you know what you are doing! The only legitimate use for this is in some form of secure tunnelling scheme, or perhaps to facilitate FXP support.

----

* Variable name: `FTP_PORT_PROMISCUOUS`
* Default value: NO
* Accepted values: <NO|YES>
* Description: Set to YES if you want to disable the PORT security check that ensures that outgoing data connections can only connect to the client. Only enable if you know what you are doing! Legitimate use for this is to facilitate FXP support.

----

* Variable name: `FTP_REVERSE_LOOKUP_ENABLE`
* Default value: YES
* Accepted values: <NO|YES>
* Description: Set to NO if you want to avoid performance issues where a name server doesn't respond to a reverse lookup.

----

* Variable name: `FTP_ADM_NAME`
* Default value: admin
* Accepted values: Any string. Avoid whitespaces and special chars.
* Description: Username for the admin FTP account (not for workload). If you don't specify it through the `FTP_ADM_NAME` environment variable at run time, `admin` will be used by default.

----

* Variable name: `FTP_ADM_PASS`
* Default value: passw0rd
* Accepted values: Any string.
* Description: If you don't specify a password for the admin FTP account through `FTP_ADM_PASS` environment variable at run time, `passw0rd` will be used by default.

----

* Variable name: `FTP_ANON`
* Default value: NO
* Accepted values: <NO|YES>
* Description: Allow anonymous access to files in `/var/ftp/anonymous` directory.

----

* Variable name: `FTP_ANON_MODE`
* Default value: NO
* Accepted values: <NO|RW|ALL>
  * `NO` reade only
  * `RW` reade write and disallow delete
  * `ALL` reade write and allow delete
* Description: Grants access to user anonymous need to have access to files in `/var/ftp/anonymous` directory.

----

* Variable name: `FTP_USER_1,,,N`
* Default value: not defined
* Accepted values: `USERNAME:PASSWORD:LOCAL_ROOT:ACCESS_MODE:CMD:ANON`
  * `USERNAME` Any string. Avoid whitespaces and special chars.
  * `PASSWORD` Any string.
  * `LOCAL_ROOT` Any sub folder **only** in the dir `/var/ftp/pub`.
  * `ACCESS_MODE` Access mode. <RW|RO>
  * `CMD` Set to YES if you want to allow change the current directory to DIR. <NO|YES>
  * `ANON` Set to YES if you want to allow anonymous access to files in `LOCAL_ROOT` directory. <NO|YES>

    > `mount --bind` is used to configure anonymous access, but **this not supporting in docker swarm**. Only if set to YES, required `--cap-add=SYS_ADMIN` or `--privileged=true` when run your container to use mount inside container. Instead of --privileged you can be a bit more fine-grained and use --cap-add=SYS_ADMIN.

* Description: Adds multiple users for the workloads.


Use cases
----

1) Docker Image:

```
docker build -f Dockerfile -t vsftpd:latest .
```

2) Docker Volume:

```
docker volume create vsftpd_data
docker volume create vsftpd_logs
```

3.1) Docker Container:

```
docker run -dit \
 -e "FTP_FORCE_SSL=NO" \
 -e "FTP_LOG_FILE=NO" \
 -e "FTP_LISTEN_PORT=21" \
 -e "FTP_DATA_PORT=20" \
 -e "FTP_PASV_ADDRESS=NO" \
 -e "FTP_PASV_ADDR_RESOLVE=NO" \
 -e "FTP_PASV_MIN_PORT=30025" \
 -e "FTP_PASV_MAX_PORT=30050" \
 -e "FTP_PASV_PROMISCUOUS=NO" \
 -e "FTP_PORT_PROMISCUOUS=NO" \
 -e "FTP_REVERSE_LOOKUP_ENABLE=NO" \
 -e "FTP_ADM_NAME=admin" \
 -e "FTP_ADM_PASS=passw0rd" \
 -e "FTP_ANON=YES" \
 -e "FTP_ANON_MODE=RW" \
 -e "FTP_USER_1=user1:pass1:/var/ftp/pub/data1:rw:yes:yes" \
 -e "FTP_USER_2=user2:pass2:/var/ftp/pub/data1/data2:ro:yes:no" \
 -e "FTP_USER_3=user3:pass3:/var/ftp/pub/data1/data3:rw:no:yes" \
 --privileged=true \
 --restart unless-stopped \
 --stop-timeout 60 \
 --memory="2048m" --cpus=1 \
 --network=bridge -p 20:20/tcp -p 21:21/tcp -p 30025-30050:30025-30050/tcp \
 -v vsftpd_data:/var/ftp/pub \
 -v vsftpd_logs:/logs \
 --name vsftpd \
 vsftpd:latest
```

3.2) Docker Compose (standalone):

`docker-compose -p vsftpd -f docker-compose.yml up -d`
```
version: '3.7'
services:
  vsftpd:
    image: vsftpd:latest
    container_name: vsftpd
    privileged: true
    restart: unless-stopped
    volumes:
      - vsftpd_logs:/logs:rw
      - vsftpd_data:/var/ftp/pub:rw
    ports:
      - "20:20/tcp"
      - "21:21/tcp"
      # - "30020:30020/tcp"
      # - "30021:30021/tcp"
      - "30025-30050:30025-30050/tcp"
    network_mode: bridge
    environment:
      - "FTP_FORCE_SSL=YES"
      - "FTP_LOG_FILE=NO"
      - "FTP_LISTEN_PORT=21"
      - "FTP_DATA_PORT=20"
      - "FTP_PASV_ADDRESS=ftp.example.com"
      - "FTP_PASV_ADDR_RESOLVE=YES"
      - "FTP_PASV_MIN_PORT=30025"
      - "FTP_PASV_MAX_PORT=30050"
      - "FTP_PASV_PROMISCUOUS=NO"
      - "FTP_PORT_PROMISCUOUS=NO"
      - "FTP_REVERSE_LOOKUP_ENABLE=NO"
      - "FTP_ADM_NAME=admin"
      - "FTP_ADM_PASS=passw0rd"
      - "FTP_ANON=YES"
      - "FTP_ANON_MODE=ALL"
      - "FTP_USER_1=user1:pass1:/var/ftp/pub/data1:rw:yes:yes"
      - "FTP_USER_2=user2:pass2:/var/ftp/pub/data2:ro:yes:yes"
      - "FTP_USER_3=user3:pass3:/var/ftp/pub/data3:rw:no:yes"
    stop_grace_period: 1m
volumes:
  vsftpd_logs:
    external: true
  vsftpd_data:
    external: true
```

4) Other:

```
docker ps -a
docker image ls
docker exec -it vsftpd bash
docker logs vsftpd --follow
docker container start vsftpd
docker container stop vsftpd
docker container rm -f vsftpd
docker network rm vsftpd_net
docker volume rm vsftpd_data
docker volume rm vsftpd_logs
docker image rm vsftpd:latest
```

## On DockerHub / GitHub
___
* DockerHub [rlagutinhub/docker.vsftpd](https://hub.docker.com/r/rlagutinhub/docker.vsftpd)
* GitHub [rlagutinhub/docker.vsftpd](https://github.com/rlagutinhub/docker.vsftpd)
