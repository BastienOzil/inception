#!/bin/bash
set -e

DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

if [ ! -f "/var/lib/mysql/.inception_initialized" ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null

    mysqld_safe --datadir=/var/lib/mysql --skip-networking=0 &

    for i in $(seq 1 30); do
        if mysqladmin ping -u root --silent 2>/dev/null; then
            echo "MariaDB is up, proceeding with setup."
            break
        fi
        echo "Waiting for MariaDB to be ready for setup... ($i)"
        sleep 1
    done

    mariadb -u root <<-EOSQL
        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
        FLUSH PRIVILEGES;
EOSQL

    mysqladmin -u root -p"${DB_ROOT_PASSWORD}" shutdown
    wait
    touch /var/lib/mysql/.inception_initialized
fi

exec mysqld_safe --datadir=/var/lib/mysql