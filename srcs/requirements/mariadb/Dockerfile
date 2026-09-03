FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y mariadb-server mariadb-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY conf/50-server.conf /etc/mysql/mariadb.conf.d/60-server.conf

COPY tools/init.sh /init.sh
RUN chmod +x /init.sh
EXPOSE 3306
ENTRYPOINT ["/init.sh"]