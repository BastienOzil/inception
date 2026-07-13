FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    php-fpm \
    php-mysql \
    php-curl \
    php-gd \
    php-mbstring \
    php-xml \
    php-zip \
    php-intl \
    curl \
    ca-certificates \
    default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

RUN PHP_FPM_BIN=$(ls /usr/sbin/php-fpm* | head -n1) && \
    ln -sf "$PHP_FPM_BIN" /usr/sbin/php-fpm

RUN mkdir -p /var/www/html

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/wp-setup.sh /usr/local/bin/wp-setup.sh
RUN chmod +x /usr/local/bin/wp-setup.sh

WORKDIR /var/www/html

EXPOSE 4242

ENTRYPOINT ["/usr/local/bin/wp-setup.sh"]