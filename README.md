# vsFTPD Server in a Docker
```
```
This vsftpd docker image is based on official oraclelinux:8-slim image and comes with following features:  

 * Virtual users
 * Active and Passive mode
 * Logging to a file and STDOUT
 * Not anonymous access

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
* Accepted values: Any IPv4 address
* Description: IP address that vsftpd will advertise in response to the PASV command. This is useul when running behind a proxy, or with docker swarm.

----

* Variable name: `FTP_PASV_MIN_PORT`
* Default value: 32500
* Accepted values: Any valid port number.
* Description: This will be used as the lower bound of the passive mode port range. Remember to publish your ports with `docker -p` parameter.

----

* Variable name: `FTP_PASV_MAX_PORT`
* Default value: 32599
* Accepted values: Any valid port number.
* Description: This will be used as the upper bound of the passive mode port range. It will take longer to start a container with a high number of published ports.

----

* Variable name: `FTP_ADM_NAME`
* Default value: admin
* Accepted values: Any string. Avoid whitespaces and special chars.
* Description: Username for the full access FTP account. If you don't specify it through the `FTP_ADM_NAME` environment variable at run time, `admin` will be used by default.

----

* Variable name: `FTP_ADM_PASS`
* Default value: passw0rd
* Accepted values: Any string.
* Description: If you don't specify a password for the full access FTP account through `FTP_ADM_PASS` environment variable at run time, `passw0rd` will be used by default.

----

* Variable name: `FTP_USER_1,,,N`
* Default value: not defined
* Accepted values: username:password:local_root:access_mode:cmd
  * `username` Any string. Avoid whitespaces and special chars.
  * `password` Any string.
  * `local_root` Any sub folder **only** in the dir `/var/ftp/pub`.
  * `access_mode` Access mode. <RW|RO>
  * `cmd` Set to YES if you want to allow change the current directory to DIR. <NO|YES>
* Description: Adds multiple users.


Use cases
----

1) Docker Image:

```bash
docker build -f Dockerfile -t vsftpd:latest .
```

2) Docker Volume:

```bash
docker volume create vsftpd_data
docker volume create vsftpd_logs
```

3) Docker Container:

```bash
docker run -dit \
 -e "FTP_FORCE_SSL=NO" \
 -e "FTP_LOG_FILE=NO" \
 -e "FTP_LISTEN_PORT=21" \
 -e "FTP_DATA_PORT=20" \
 -e "FTP_PASV_ADDRESS=NO" \
 -e "FTP_PASV_MIN_PORT=32500" \
 -e "FTP_PASV_MAX_PORT=32599" \
 -e "FTP_ADM_NAME=admin" \
 -e "FTP_ADM_PASS=passw0rd" \
 -e "FTP_USER_1=user1:pass1:/var/ftp/pub/data1:rw:yes" \
 -e "FTP_USER_2=user2:pass2:/var/ftp/pub/data1/data2:ro:yes" \
 -e "FTP_USER_3=user3:pass3:/var/ftp/pub/data1/data3:rw:no" \
 --stop-timeout 60 \
 --memory="2048m" --cpus=1 \
 --network=bridge -p 20:20/tcp -p 21:21/tcp -p 32500-32599:32500-32599/tcp \
 -v vsftpd_data:/var/ftp/pub \
 -v vsftpd_logs:/logs \
 --name vsftpd \
 vsftpd:latest
```

4) Other:

```bash
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
