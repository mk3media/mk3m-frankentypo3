FROM dunglas/frankenphp:1.12.7-php8.4-bookworm

LABEL org.opencontainers.image.title="mk3m-frankentypo3" \
      org.opencontainers.image.description="High-performance TYPO3 runtime with FrankenPHP, Caddy, and Valkey" \
      org.opencontainers.image.authors="mk3media" \
      org.opencontainers.image.licenses="GPL-2.0"

# Install PHP extensions required and recommended for TYPO3 v13+
RUN install-php-extensions \
    mysqli \
    pdo_mysql \
    gd \
    intl \
    zip \
    opcache \
    mbstring \
    exif \
    bcmath \
    soap \
    curl \
    apcu \
    fileinfo \
    iconv \
    sodium \
    xml \
    dom \
    simplexml \
    redis

# Install system dependencies, image processing utilities & locale tools
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       git \
       unzip \
       tzdata \
       locales \
       ca-certificates \
       libpng-dev \
       libjpeg-dev \
       libfreetype6-dev \
       libicu-dev \
       libonig-dev \
       libxml2-dev \
       libcurl4-openssl-dev \
       libzip-dev \
       libwebp-dev \
       libwebp7 \
       libwebpdemux2 \
       libwebpmux3 \
       imagemagick \
       ghostscript \
       graphicsmagick \
       libheif1 \
       netpbm \
    && rm -rf /var/lib/apt/lists/*

# Set default timezone
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Generate system locales for TYPO3 localized formatting
RUN echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && echo "fr_FR.UTF-8 UTF-8" >> /etc/locale.gen \
    && echo "es_ES.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=de_DE.UTF-8

ENV LANG=de_DE.UTF-8 \
    LANGUAGE=de_DE:de \
    LC_ALL=de_DE.UTF-8

# Update system CA certificates
RUN update-ca-certificates

# Copy PHP and OPcache configuration
COPY conf.d/typo3.ini /usr/local/etc/php/conf.d/typo3.ini
COPY conf.d/opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && echo "COMPOSER_ALLOW_SUPERUSER=1" >> /etc/environment \
    && echo "COMPOSER_NO_INTERACTION=1" >> /etc/environment

WORKDIR /var/www/html

EXPOSE 80 443

# Default entrypoint runs FrankenPHP
CMD ["frankenphp", "run"]
