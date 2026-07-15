# User Documentation

## What this stack provides

This project runs a WordPress website backed by a MariaDB database, served
through an NGINX reverse proxy over HTTPS. Three services work together:

- **NGINX**: the only entrypoint, reachable on port 443 (HTTPS).
- **WordPress**: the website itself and its administration panel.
- **MariaDB**: stores all WordPress content (pages, posts, comments, users).

## Starting and stopping the project

From the project root:

```bash
make up      # or simply: make
```

To stop the stack (containers are removed, data is kept):

```bash
make down
```

To stop without removing containers:

```bash
make stop
```

To restart previously stopped containers:

```bash
make start
```

## Accessing the website

Open a browser and go to: https://bozil.42.fr/ 

Your browser will show a warning because the TLS certificate is self-signed.
This is expected in a local/development environment — click "advanced" and
proceed.

## Accessing the administration panel

Go to: https://bozil.42.fr/wp-admin

Log in with the administrator account (see "Managing credentials" below).

## Managing credentials

Credentials are never stored in plain text in the repository. They live in
two places:

- `srcs/.env`: non-sensitive settings (domain name, database name, usernames).
- `secrets/`: the actual passwords, one per file:
  - `secrets/db_password.txt` — WordPress database user password
  - `secrets/db_root_password.txt` — MariaDB root password
  - `secrets/credentials.txt` — WordPress admin and second user passwords

If you need to change a password, edit the relevant file in `secrets/`, then
rebuild the affected container(s) with `make re` (this resets and recreates
everything, including a fresh WordPress install if the volume is cleared).

## Checking that services are running correctly

```bash
docker compose -f srcs/docker-compose.yml ps
```

All three services (`mariadb`, `wordpress`, `nginx`) should show a status of
`Up`. If any service shows `Restarting`, check its logs:

```bash
docker logs mariadb
docker logs wordpress
docker logs nginx
```

You can also confirm the site responds correctly:

```bash
curl -k -I https://bozil.42.fr
```

A `200 OK` response confirms the whole chain (NGINX → WordPress → MariaDB) is
working.