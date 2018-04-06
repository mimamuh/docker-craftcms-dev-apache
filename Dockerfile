# Use this image for local development and testing only!
# This image is made for local development and testing of craftcms 3
FROM php:7.2-apache-stretch

# enable mod_rewrite & ssl
RUN a2enmod rewrite \
  && a2enmod ssl

# install needed php dependencies for craft-cms 3
# php 7.2 has the following extensions prepacked and could be activated with docker-php-ext-install when not already activaed:
# bcmath bz2 calendar ctype curl dba dom enchant exif fileinfo filter ftp gd gettext gmp hash iconv imap interbase intl json ldap mbstring mysqli oci8 odbc opcache pcntl pdo pdo_dblib pdo_firebird pdo_mysql pdo_oci pdo_odbc pdo_pgsql pdo_sqlite pgsql phar posix pspell readline recode reflection session shmop simplexml snmp soap sockets sodium spl standard sysvmsg sysvsem sysvshm tidy tokenizer wddx xml xmlreader xmlrpc xmlwriter xsl zend_test zip
RUN apt-get update && apt-get install --assume-yes --quiet \
  libzip-dev \
  libfreetype6-dev \
  libjpeg62-turbo-dev \
  libpng-dev \
  libicu-dev \
  mysql-client \
  && docker-php-ext-configure zip --with-libzip \
  && docker-php-ext-install -j$(nproc) zip \
  && docker-php-ext-install -j$(nproc) pdo_mysql  \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ \
  && docker-php-ext-install -j$(nproc) gd \
  && docker-php-ext-configure intl \
  && docker-php-ext-install -j$(nproc) intl \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# change document root of apache to craft-cms' default web root
ENV APACHE_DOCUMENT_ROOT=/var/www/html/web

# change new document root in apaches config file
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
  && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

LABEL squaresandbrackets.com.version="1.0.0"
LABEL squaresandbrackets.com.name="Apache Craftcms 3 Dev"
LABEL squaresandbrackets.com.description="Container is used in local development of craft cms 3 websites and should only be used for local development. It is only the apache server, so choose a database on your own."
LABEL squaresandbrackets.com.release-date="2018-04-06"
LABEL squaresandbrackets.com.version.is-production="false"

# copy php.ini to server
COPY php.ini /usr/local/etc/php/

# exposes default 80 for http and 443 for https
EXPOSE 80 443 


