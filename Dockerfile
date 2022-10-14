ARG BASE_IMAGE_TAG=8.6.20220707-minimal
FROM rockylinux:$BASE_IMAGE_TAG

ARG USER
ARG UID
ARG OLS_VERSION
ARG OLS_REPO_URL
ARG LSPHP_VERSION

ENV TZ=$TZ

RUN microdnf update -y \ 
    && microdnf install -y epel-release

RUN rpm -Uvh $OLS_REPO_URL

RUN microdnf install -y openlitespeed-$OLS_VERSION

RUN microdnf install -y procps mysql openssl supervisor $LSPHP_VERSION $LSPHP_VERSION-common $LSPHP_VERSION-mysqlnd $LSPHP_VERSION-opcache \
    $LSPHP_VERSION-curl $LSPHP_VERSION-redis $LSPHP_VERSION-memcached $LSPHP_VERSION-intl \
    $LSPHP_VERSION-bcmath $LSPHP_VERSION-ctype $LSPHP_VERSION-fileinfo $LSPHP_VERSION-mbstring $LSPHP_VERSION-gd \
    $LSPHP_VERSION-pdo $LSPHP_VERSION-zip $LSPHP_VERSION-xml $LSPHP_VERSION-ldap

RUN /usr/local/lsws/$LSPHP_VERSION/bin/php -r "readfile('https://getcomposer.org/installer');" | /usr/local/lsws/$LSPHP_VERSION/bin/php -- --install-dir=/usr/bin/ --filename=composer
RUN ln -sf /usr/local/lsws/$LSPHP_VERSION/bin/php /usr/bin/php

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]