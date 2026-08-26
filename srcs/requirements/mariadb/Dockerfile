FROM debian:bookworm

RUN apt-get update && \
    apt-get intall -y mariadb-server mariadb-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY conf/mariadb.conf /etc/mysql/mariadb.conf.d/mariadb.conf

COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
EXPOSE 3306
ENTRYPOINT ["tools/entrypoint.sh"]