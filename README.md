# Rocky Linux based OpenLiteSpeed PHP docker container

Install an OpenLiteSpeed container with lsphp in Rocky Linux.

## Prerequisites
*  [Install Docker](https://www.docker.com/)

## Modules/packages
* mysql client
* supervisor

## LSPHP extensions
mysqlnd, opcache, curl, redis, memcached, intl, bcmath, ctype, fileinfo, mbstring, gd, pdo, zip, xml, ldap

## Environment variables

* **TZ** \
Container timezone

## Arguments
* **BASE_IMAGE_TAG** \
Rocky Linux image version \
Default: 8.6.20220707-minimal

* **OLS_VERSION** \
OpenLiteSpeed version \
Example: 1.7.16 \
[OpenLiteSpeed](https://openlitespeed.org/release-log/)

* **OLS_REPO_URL** \
OpenLiteSpeed RPM repository url \
Example: http://rpms.litespeedtech.com/centos/litespeed-repo-1.1-1.el8.noarch.rpm \

* **LSPHP_VERSION** \
LSPHP version \
Example: lsphp80 \
[OpenLiteSpeed PHP](https://openlitespeed.org/kb/default-php-settings-for-openlitespeed/)


## Usage
### Create a docker compose file **docker-compose.yml**
```
version: '3.8'

services:
  app:
    image: rocky-php
    build:
      args:
        USER: admin
        UID: 1000
        OLS_REPO_URL: http://rpms.litespeedtech.com/centos/litespeed-repo-1.1-1.el8.noarch.rpm
        OLS_VERSION: 1.7.16
        LSPHP_VERSION: lsphp80
    container_name: ${PROJECT_NAME}-app
    restart: always
    tty: true
    env_file:
      - .env
    ports:
      - ${OLS_HTTP_HOST_PORT:-80}:${OLS_HTTP_CONTAINER_PORT:-80}
      - ${OLS_HTTPS_HOST_PORT:-443}:${OLS_HTTPS_CONTAINER_PORT:-443}
      - ${OLS_HTTPS_HOST_PORT:-443}:${OLS_HTTPS_CONTAINER_PORT:-443}/udp
      - ${OLS_ADMIN_HOST_PORT:-7080}:${OLS_ADMIN_CONTAINER_PORT:-7080}
```

### Build the image and create a container
```
$ docker-compose -f docker-compose.yml up -d --build
```

### Copy files from container to host
We will copy files from container to the host before mouting volumes. Make sure that the following paths exist:
* <path_on_host>\docker-compose\lsws\admin
* <path_on_host>\docker-compose\lsws\<lsphp_version>\etc

#### Copy OpenLiteSpeed admin configurations
```
$ docker container cp <container_name>:/usr/local/lsws/admin/conf <path_on_host>\docker-compose\lsws\admin\conf
```

#### Copy OpenLiteSpeed configurations
```
$ docker container cp <container_name>:/usr/local/lsws/conf <path_on_host>\docker_tutorial\docker-compose\lsws\conf
```

#### Copy PHP ini for your specific PHP version that was specified during the docker build. If you have installed lsphp80, replace <lsphp_version> with lsphp80
```
$ docker container cp <container_name>:/usr/local/lsws/<lsphp_version>/etc/php.ini <path_on_host>\docker-compose\lsws\<lsphp_version>\etc\php.ini
```

### Map volumes in your docker-compose.yml file
```
version: '3.8'

services:
  app:
    image: rocky-php
    build:
      args:
        USER: admin
        UID: 1000
        OLS_REPO_URL: http://rpms.litespeedtech.com/centos/litespeed-repo-1.1-1.el8.noarch.rpm
        OLS_VERSION: 1.7.16
        LSPHP_VERSION: lsphp80
    container_name: ${PROJECT_NAME}-app
    restart: always
    tty: true
    env_file:
      - .env
    volumes:
      - ./docker-compose/lsws/logs:/usr/local/lsws/logs/
      - ./docker-compose/lsws/conf:/usr/local/lsws/conf
      - ./docker-compose/lsws/admin/conf:/usr/local/lsws/admin/conf
      - ./sites:/var/www/
      - ./docker-compose/lsws/lsphp80/etc/php.ini:/usr/local/lsws/lsphp80/etc/php.ini
    ports:
      - ${OLS_HTTP_HOST_PORT:-80}:${OLS_HTTP_CONTAINER_PORT:-80}
      - ${OLS_HTTPS_HOST_PORT:-443}:${OLS_HTTPS_CONTAINER_PORT:-443}
      - ${OLS_HTTPS_HOST_PORT:-443}:${OLS_HTTPS_CONTAINER_PORT:-443}/udp
      - ${OLS_ADMIN_HOST_PORT:-7080}:${OLS_ADMIN_CONTAINER_PORT:-7080}
```

### Run the newly created container with volumes
```
$ docker-compose -f docker-compose.yml up -d
```

### Change OpenLiteSpeed admin password
```
docker exec -it <container-name> /usr/local/lsws/admin/misc/admpass.sh
```

### Access OpenLiteSpeed admin on your host
[OpenLiteSpeed admin](http://localhost:7080) and enter the username and password specified in the last step.


## Check OpenLiteSpeed status
```
$ docker exec -it <container-name> /usr/local/lsws/bin/lswsctrl status
```

## Use composer
```
$ docker exec -it <container-name> /usr/local/lsws/<lsphp_version>/bin/php /usr/bin/composer
```