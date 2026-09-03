FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y php-fpm php-mysql php-cli mariadb-client curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -o /usr/local/bin/wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp-cli.phar \
    && printf '#!/bin/sh\nphp /usr/local/bin/wp-cli.phar "$@"\n' > /usr/local/bin/wp \
    && chmod +x /usr/local/bin/wp

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

COPY tools/init.sh /init.sh
RUN chmod +x /init.sh
EXPOSE 9000
ENTRYPOINT ["/init.sh"]