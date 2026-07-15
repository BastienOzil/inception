# Developer Documentation

## Prerequisites

- A Debian-based virtual machine (built and tested on Debian 13).
- Docker Engine and the Docker Compose plugin.
- `make`.
- Your user added to the `docker` group (`sudo usermod -aG docker $USER`,
  then re-log or `newgrp docker`).

## Setting up the environment from scratch

Clone the repository, then create your local configuration files from the
provided examples (these are git-ignored and must be created manually):

```bash
cp srcs/.env.example srcs/.env
cp secrets/db_password.txt.example secrets/db_password.txt
cp secrets/db_root_password.txt.example secrets/db_root_password.txt
cp secrets/credentials.txt.example secrets/credentials.txt
```

Edit each file:
- `srcs/.env`: set `DOMAIN_NAME` to `<your_login>.42.fr` and adjust the other
  non-sensitive values if needed.
- `secrets/*.txt`: replace placeholder values with strong passwords.

Add your domain to `/etc/hosts` so it resolves locally:

```bash
echo "127.0.0.1 <your_login>.42.fr" | sudo tee -a /etc/hosts
```

## Project structure
```
inception/
├── Makefile
├── secrets/
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/
    ├── docker-compose.yml
    ├── .env
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/
        │   │   └── my.cnf
        │   └── tools/
        │       └── db-setup.sh
        ├── nginx/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/
        │   │   └── nginx.conf
        │   └── tools/
        │       └── (si besoin)
        └── wordpress/
            ├── Dockerfile
            ├── .dockerignore
            ├── conf/
            │   └── www.conf
            └── tools/
                └── wp-setup.sh
```
Each service directory contains its own `Dockerfile`, a `conf/` folder for
configuration files copied into the image, and a `tools/` folder for the
entrypoint script.

## Building and launching with the Makefile

```bash
make          # creates host data dirs, builds images, starts containers
make down     # stops and removes containers (keeps volumes/data)
make stop     # stops containers without removing them
make start    # restarts stopped containers
make clean    # down + prune dangling images
make fclean   # clean + remove host data dirs + remove named volumes
make re       # fclean + all (full reset)
make status   # show containers, volumes, and the network
make logs     # follow logs of all services
```

## Useful Docker Compose commands

```bash
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml logs -f <service>
docker compose -f srcs/docker-compose.yml build --no-cache <service>
docker compose -f srcs/docker-compose.yml exec <service> bash
```

## Data persistence

Two named volumes are declared in `srcs/docker-compose.yml`:

- `db_data`, mounted at `/var/lib/mysql` inside the `mariadb` container.
- `wp_data`, mounted at `/var/www/html` inside both the `wordpress` and
  `nginx` containers.

Both volumes use the `local` driver with `driver_opts` (`type: none`,
`o: bind`) pointing to `/home/<login>/data/mariadb` and
`/home/<login>/data/wordpress` on the host. This satisfies the project's
requirement of using named volumes (not bind mounts in the compose sense)
while still storing the data at a specific host path.

Data survives container restarts, `make down`/`make up` cycles, and full VM
reboots, as long as the volumes themselves are not explicitly removed
(`make fclean` or `docker volume rm` will delete them).

To inspect a volume's actual host path:

```bash
docker volume inspect db_data
docker volume inspect wp_data
```

## Changing a service's configuration (e.g. a port)

Example: changing MariaDB's port from `2424` to `3333`.

1. Update `DB_PORT` in `srcs/.env`.
2. Update `port = 3333` in
   `srcs/requirements/mariadb/conf/my.cnf`.
3. Update the corresponding `expose` value in `srcs/docker-compose.yml`.
4. Rebuild and restart:
```bash
   docker compose -f srcs/docker-compose.yml up -d --build mariadb
```
5. Verify the service is reachable again:
```bash
   docker logs mariadb
   docker logs wordpress
```

Since `wp-setup.sh` reads `${DB_PORT}` from the environment rather than
hardcoding it, WordPress automatically reconnects using the new port after a
restart.