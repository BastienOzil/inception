*This project has been created as part of the 42 curriculum by Bozil*

•**Description**:
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

All images are built from custom Dockerfiles based on `debian:bookworm`, the actual penultimate stable Debian release.
Persistent data is stored using Docker named volumes, physically located on the host at `/home/bozil/data/`.
All containers communicate through a dedicated Docker bridge network.

Difference between VM and docker:
- A virtual machine virtualizes an entire operating system, including its own kernel, which makes it heavier to run and slower to start.
- Docker containers share the host's kernel and only isolate processes and filesystems, which makes them much lighter and faster to start, at the cost of a slightly reduced isolation compared to a full VM.

Here the structure:

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

• **Instructions**:
Prerequisites:
- A Linux virtual machine (this project was built and tested on Debian 13).
- Docker Engine and the Docker Compose plugin installed.
- Your user added to the `docker` group to run Docker without `sudo`.

Setup:
1. Clone this repository.
2. Create the `secrets/` folder at the project root (ignored by Git) containing:
   - `db_password.txt`
   - `db_root_password.txt`
   - `credentials.txt`
3. Make sure `srcs/.env` exists and contains the non-sensitive configuration
   variables (domain name, database name, usernames, ports).
4. Add an entry in `/etc/hosts` pointing your domain to `127.0.0.1`:

Running the project:
- From the project root: make
- Stopping the project: make down
- Resetting everything: make fclean
- Accessing the website: Once the containers are running, visit: https://bozil.42.fr

•**Resources**:
Infos about docker:
- https://www.hostinger.com/fr/tutoriels/tutoriel-docker?utm_term=
- https://docs.docker.com/compose/
- https://docs.docker.com/
WordPress: https://wp-cli.org/
MariaDB: https://mariadb.com/kb/en/documentation/
Debian version-https://www.debian.org/download.fr.html
AI:Claude was used throughout this project to help design the overall architecture, debug the Dockerfiles and configuration files.
Also help to make the readme
