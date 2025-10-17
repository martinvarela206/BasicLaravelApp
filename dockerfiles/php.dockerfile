FROM php:8.2-fpm

# Instala extensiones necesarias
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    git \
    curl \
    && docker-php-ext-install pdo_sqlite mbstring exif pcntl bcmath gd

# Instala Composer
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

# Copia los archivos del proyecto
COPY . /var/www

# Instala dependencias de Laravel
RUN composer install --no-dev --optimize-autoloader

# Permisos para storage y cache
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

EXPOSE 9000
CMD ["php-fpm"]