FROM php:7.1-apache
ADD . /var/www/
WORKDIR /var/www/
RUN apt-get update && apt-get install -y \
    git \           
    zip \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
 && docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install -j$(nproc) gd \
 && docker-php-ext-install -j$(nproc) pdo_mysql
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
 && php composer-setup.php --version=1.6.5 \
 && mv composer.phar /usr/local/bin/composer \
 && rm composer-setup.php
RUN composer install
RUN rm -rf ./html \
 && cat .env.dist | grep -v DATABASE_URL > ./.env \ 
 && mv ./public ./html \
 && echo "DATABASE_URL=mysql://tagger:tagger@db:3306/tagger" >> ./.env \
 && ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/
