# Dockerfile multi-stage para Laravel + Nginx + PHP-FPM

# Etapa 1: Composer y dependencias PHP
FROM php:8.2-fpm AS php-base

RUN apt-get update && apt-get install -y \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libsqlite3-dev \
    zip \
    unzip \
    git \
    curl \
    && docker-php-ext-install pdo_sqlite mbstring exif pcntl bcmath gd

COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

COPY . /var/www

RUN composer install --no-dev --optimize-autoloader

RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

# Etapa 2: Nginx + PHP-FPM
FROM nginx:1.25 AS nginx-base

COPY --from=php-base /var/www /var/www
COPY --from=php-base /usr/local/etc/php/conf.d /usr/local/etc/php/conf.d

# Copia configuración personalizada de nginx
COPY dockerfiles/nginx/default.conf /etc/nginx/conf.d/default.conf

WORKDIR /var/www

# Instala PHP-FPM en la imagen de Nginx
RUN apt-get update && apt-get install -y php8.2-fpm

EXPOSE 80

CMD ["/bin/bash", "-c", "php-fpm & nginx -g 'daemon off;'"]
