FROM php:8.1.12-fpm

ENV COMPOSER_ALLOW_SUPERUSER=1

WORKDIR /var/www/html

RUN apt-get update && apt-get install -y \
    libzip-dev \
    zip \
    unzip

RUN docker-php-ext-install pdo_mysql zip


COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN pecl install swoole && docker-php-ext-enable swoole

COPY ./sistema .

RUN composer install --no-dev --optimize-autoloader
RUN composer require laravel/octane spiral/roadrunner

RUN php artisan octane:install --server="swoole"

EXPOSE 8000

CMD ["php", "artisan", "octane:start", "--host=0.0.0.0", "--port=8000"]
