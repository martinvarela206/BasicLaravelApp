


# Dockerfile para Laravel con Apache y SQLite
FROM php:8.2-apache

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

WORKDIR /var/www/html

# Copia el contenido del proyecto Laravel
COPY . /var/www/html

# Cambia el DocumentRoot de Apache a /var/www/html/public
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/public|g' /etc/apache2/sites-available/000-default.conf

# Habilita mod_rewrite para Laravel
RUN a2enmod rewrite

# Configura Apache para permitir URLs amigables
RUN sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf


RUN composer install --no-dev --optimize-autoloader

# Crear archivo SQLite si no existe y asegurar permisos
RUN mkdir -p /var/www/html/database \
    && touch /var/www/html/database/database.sqlite \
    && chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/database

EXPOSE 80

CMD ["apache2-foreground"]
