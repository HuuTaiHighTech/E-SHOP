# Use the official PHP image with Apache pre-installed
FROM php:8.2.12-apache

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
        libonig-dev \
        libzip-dev \
        zip \
        unzip \
        default-mysql-client \
    && docker-php-ext-install mbstring zip exif pcntl pdo_mysql \
    && docker-php-ext-enable opcache

# Install Composer globally
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set the working directory to the root of the Laravel application
WORKDIR /var/www/html

# Copy the application source code to the container
COPY . /var/www/html/

# Copy the example environment file to .env and generate application key
# Make sure your .env.example file contains the appropriate environment variables
COPY .env.example .env
RUN php artisan key:generate
RUN php artisan storage:link

# Install application dependencies with Composer
RUN composer install --no-interaction --optimize-autoloader --no-dev

# Set correct permissions on the application files
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Configure Apache document root
RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/000-default.conf
RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/apache2.conf

# Enable Apache mod_rewrite for Laravel route support
RUN a2enmod rewrite
RUN echo 'ServerName localhost' >> /etc/apache2/apache2.conf

# Expose port 80 for the web server
EXPOSE 80

# Set the container's environment variables based on your provided .env settings
ENV APP_NAME="E-SHOP" \
    APP_ENV=local \
    APP_KEY="base64:EiVZgSyycJ/A8sM5/G7h+WicagLW2V5BAnypTN19zr8=" \
    APP_DEBUG=true \
    LOG_CHANNEL=stack \
    DB_CONNECTION=mysql \
    DB_HOST=host.docker.internal \
    DB_PORT=3306 \
    DB_DATABASE=test-etech \
    DB_USERNAME=root \
    DB_PASSWORD= \
    BROADCAST_DRIVER=log \
    CACHE_DRIVER=file \
    QUEUE_CONNECTION=sync \
    SESSION_DRIVER=file \
    SESSION_LIFETIME=120 \
    REDIS_HOST=127.0.0.1 \
    REDIS_PASSWORD=null \
    REDIS_PORT=6379 \
    MAIL_MAILER=smtp \
    MAIL_HOST=smtp.mailtrap.io \
    MAIL_PORT=2525 \
    MAIL_USERNAME=438176b1b37bd9 \
    MAIL_PASSWORD=4b2e1c3788e5b3 \
    MAIL_ENCRYPTION=tls \
    MAIL_FROM_ADDRESS="from@example.com" \
    MAIL_FROM_NAME="${APP_NAME}" \
    AWS_ACCESS_KEY_ID= \
    AWS_SECRET_ACCESS_KEY= \
    AWS_DEFAULT_REGION=us-east-1 \
    AWS_BUCKET= \
    PUSHER_APP_ID= \
    PUSHER_APP_KEY= \
    PUSHER_APP_SECRET= \
    PUSHER_APP_CLUSTER=mt1 \
    MIX_PUSHER_APP_KEY="${PUSHER_APP_KEY}" \
    MIX_PUSHER_APP_CLUSTER="${PUSHER_APP_CLUSTER}" \
    BRAINTREE_ENVIRONMENT=sandbox \
    BRAINTREE_MERCHANT_ID=xd26y34kjcpd64jn \
    BRAINTREE_PUBLIC_KEY=kgx5mwvknvn7873j \
    BRAINTREE_PRIVATE_KEY=696836bc268985bb6214998fe4d7b89e \
    PAYPAL_CLIENT_ID=ATCMI4_1b1RqMVzdmNOuLhmkt_qAPt2CcKCNBWG5CfkqFfT4llhshNx518Uq0swfNce6g0yVDmNyNBbb \
    PAYPAL_CLIENT_SECRET=EFxtXDt3HUJumJXFQfd5E8KC5q9oPYRW5oycoulqvy0GwjxBHAik1B2Cck_0sAoP1wQBgQiNISDLNZIZ

# The php:apache image automatically starts Apache in the foreground, so no CMD is needed
