#!/bin/bash
set -e

DB_NAME=$(cat /run/secrets/db_name.txt)
DB_USER=$(cat /run/secrets/db_user.txt)
DB_PASS=$(cat /run/secrets/db_password.txt)
DB_ROOT_PASS=$(cat /run/secrets/db_root_password.txt)

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

if [ ! -d "/var/lib/mysql/$DB_NAME" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    cat > /tmp/init.sql <<EOF
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
FLUSH PRIVILEGES;
EOF

    exec mariadbd --user=mysql --datadir=/var/lib/mysql --init-file=/tmp/init.sql
fi

exec mariadbd --user=mysql --datadir=/var/lib/mysql