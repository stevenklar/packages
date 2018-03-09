#### Source ####
FROM debian AS debian

# Install git to pull the newest packages repository
RUN apt-get update && \
    apt-get install -y git

# Install packages master
RUN git clone https://github.com/terramar-labs/packages.git /app

#### Composer ####
FROM composer:1.6 as composer

# Only copy the composer.json-File for complete dependencies list
COPY --from=debian /app/composer.json /app/composer.json
RUN composer update --ignore-platform-reqs --no-scripts

#### Main Image ####
FROM php:7.1-alpine

# Copy results of packages installation and composer vendors
COPY --from=debian /app /app
COPY --from=composer /app/vendor /app/vendor

# Install mysql driver
RUN docker-php-ext-install pdo_mysql

# Permissions for default user
RUN chown -R 1000:1000 /app

# switch to app folder for easier packages access
WORKDIR /app

# Switch to default user
USER 1000:1000

# Run simple php server
CMD ["php", "-S", "0.0.0.0:8080", "-t", "web", "-d", "date.timezone=Europe/Berlin"]
