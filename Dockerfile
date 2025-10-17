


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

# Ejecuta migraciones antes de iniciar Apache
CMD php artisan migrate --force && apache2-foreground

## EN server con docker hay que ejecutar:
        # docker build -t laravel-sqlite-apache .
        # docker run -p 8080:80 laravel-sqlite-apache

## En ssh del server, para ver los dockers corriendo:
        # docker ps
## Eliminar un docker:
##       docker stop laravel_app
##       docker rm laravel_app
## Tambien se puede usar rmi y el id del contenedor
## Para ver las imagenes es docker images
## Para ver el historial de comando en ssh es history