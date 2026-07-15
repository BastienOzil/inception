*This project has been created as part of the 42 curriculum by bozil.*

# Inception

## Description

Inception is a system administration project whose goal is to virtualize a small
web infrastructure using Docker, with each service running in its own dedicated
container, orchestrated through Docker Compose.

The stack is composed of three custom-built containers:
- **NGINX**, configured to accept only TLSv1.2/TLSv1.3 connections, acting as the
  single entrypoint to the infrastructure on port 443.
- **WordPress + php-fpm**, installed and configured from scratch, without any
  web server bundled inside.
- **MariaDB**, hosting the WordPress database, without any web server bundled
  inside either.

Here the structure:
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

All images are built from custom Dockerfiles based on `debian:bookworm` (the
penultimate stable Debian release at the time of writing), with no pre-made
images pulled from DockerHub. Persistent data (the WordPress database and the
WordPress site files) is stored using Docker named volumes, physically located
on the host at `/home/bozil/data/`. All containers communicate through a
dedicated Docker bridge network and restart automatically in case of a crash.

### Virtual Machines vs Docker
A virtual machine virtualizes an entire operating system, including its own
kernel, which makes it heavier to run and slower to start. Docker containers
share the host's kernel and only isolate processes and filesystems, which makes
them much lighter and faster to start, at the cost of a slightly reduced
isolation compared to a full VM.

### Secrets vs Environment Variables
Environment variables declared in a `.env` file are convenient but remain
readable in plaintext by anyone with access to the container configuration or
process environment. Docker secrets are mounted as read-only files inside
`/run/secrets/` at runtime and are not persisted in the image or exposed
through `docker inspect`, which makes them a safer choice for storing
passwords and other sensitive values.

### Docker Network vs Host Network
Using the host network mode would make a container share the host's network
stack directly, exposing all its ports without isolation and without going
through Docker's internal DNS resolution between services. A dedicated Docker
network isolates the containers from the host network, only allows the
explicitly published ports to be reached from outside, and lets containers
resolve each other by service name.

### Docker Volumes vs Bind Mounts
A bind mount links a container path directly to an arbitrary path on the host
filesystem, without any abstraction, which can lead to permission and
portability issues. A named volume is managed by Docker itself, decoupling
the container from the exact host path while still allowing that data to
persist physically on disk, which is safer, more portable, and the method
required for this project.

## Instructions

See [DEV_DOC.md](DEV_DOC.md) for full setup and build instructions, and
[USER_DOC.md](USER_DOC.md) for day-to-day usage once the stack is running.

Quick start:
```bash
cp srcs/.env.example srcs/.env
cp secrets/db_password.txt.example secrets/db_password.txt
cp secrets/db_root_password.txt.example secrets/db_root_password.txt
cp secrets/credentials.txt.example secrets/credentials.txt
# edit these files with your own values
echo "127.0.0.1 bozil.42.fr" | sudo tee -a /etc/hosts
make
```
Then visit `https://bozil.42.fr`.

## Resources

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose documentation](https://docs.docker.com/compose/)
- [WordPress CLI documentation](https://wp-cli.org/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)
- [NGINX documentation](https://nginx.org/en/docs/)
- AI Claude was used throughout this project to help design the structure this documentation. In accordance with the project's guidelines on AI usage.
