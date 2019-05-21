FROM ubuntu:19.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -yqq && apt-get install -yqq software-properties-common > /dev/null
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
RUN apt-get update -yqq > /dev/null && \
    apt-get install -yqq nginx git unzip php7.3 php7.3-common php7.3-cli php7.3-fpm php7.3-mysql php7.3-xml php7.3-mbstring php7.0-mcrypt php7.3-intl > /dev/null

RUN apt-get install -yqq composer > /dev/null

COPY deploy/conf/* /etc/php/7.3/fpm/
COPY deploy/conf/* /etc/php/7.3/cli/
RUN sed -i "s|listen = /run/php/php7.3-fpm.sock|listen = /run/php/php7.3-fpm.sock|g" /etc/php/7.3/fpm/php-fpm.conf

ADD ./ /cakephp
WORKDIR /cakephp

RUN if [ $(nproc) = 2 ]; then sed -i "s|pm.max_children = 1024|pm.max_children = 512|g" /etc/php/7.3/fpm/php-fpm.conf ; fi;

RUN composer install --optimize-autoloader --classmap-authoritative --no-dev --quiet --ignore-platform-reqs

RUN chmod -R 777 /cakephp

CMD service php7.3-fpm start && \
    nginx -c /cakephp/deploy/nginx.conf -g "daemon off;"

