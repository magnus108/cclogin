FROM php:7.1.7-apache

RUN a2enmod rewrite

# install the PHP extensions we need
RUN apt-get update && apt-get install -y libpng12-dev libjpeg-dev libpq-dev \
	&& rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
	&& docker-php-ext-install gd mbstring opcache pdo pdo_mysql pdo_pgsql zip

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
    echo 'upload_max_filesize = 50M'; \
    echo 'post_max_size = 50M'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini


# install dependancies
RUN apt-get update && apt-get install -y curl wget git mysql-client libmagickwand-dev imagemagick
RUN pecl install imagick && docker-php-ext-enable imagick
RUN wget -qO- https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer


USER www-data
ENV HOME=/var/www/html

COPY composer.json composer.lock $HOME/
RUN composer install

COPY web $HOME/

USER root
