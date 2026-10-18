FROM php:8.5-cli

RUN apt-get update && apt-get install -y --no-install-recommends git unzip libpq-dev libzip-dev libicu-dev curl ca-certificates \
    && docker-php-ext-install pdo_pgsql zip intl pcntl bcmath \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app
COPY . .

RUN composer install --optimize-autoloader --no-interaction --no-scripts \
    && npm ci \
    && npm run build \
    && rm -rf node_modules

RUN mkdir -p storage/framework/{cache,sessions,views} storage/logs bootstrap/cache \
    && chmod -R 777 storage bootstrap/cache

CMD php artisan migrate --force && if [ "$SEED_ON_BOOT" = "1" ]; then php artisan db:seed --force; fi && php artisan serve --host=0.0.0.0 --port=${PORT:-8080}
