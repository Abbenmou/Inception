FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y php-fpm php-mysql php-cli mariadb-client curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -sSL -o /usr/local/bin/wp \
        https://github.com/wp-cli/wp-cli/releases/download/v2.11.0/wp-cli-2.11.0.phar && \
    chmod +x /usr/local/bin/wp

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

COPY tools/init.sh /init.sh
RUN chmod +x /init.sh
EXPOSE 9000
ENTRYPOINT ["/init.sh"]