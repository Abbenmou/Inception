# USER_DOC.md — Inception User Documentation

## 1. Overview

This project runs a small web stack using Docker containers. The stack is composed of three main services:

- **NGINX**: acts as the web server and reverse proxy. It receives HTTPS requests from the browser and forwards PHP-related requests to WordPress/PHP-FPM.
- **WordPress**: provides the website and its administration interface. PHP-FPM executes the WordPress PHP code.
- **MariaDB**: stores the WordPress database, including users, posts, pages, settings, and other WordPress data.

The services communicate through a Docker network and are started together with Docker Compose.

Persistent data is stored outside the lifetime of individual containers by using Docker volumes:

- **MariaDB data**: stores the database files.
- **WordPress data**: stores the WordPress website files.

This means that removing and recreating the containers does not normally remove the persistent website and database data.

---

## 2. Starting the project

### Prerequisites

Make sure Docker and Docker Compose are installed and that the Docker daemon is running.

From the project root, start the stack with:

```bash
make
```

If the project does not provide a `Makefile`, use Docker Compose directly:

```bash
docker compose -f srcs/docker-compose.yml up -d
```

The `-d` option starts the containers in detached mode, so the terminal remains available.

To check the containers immediately after startup:

```bash
docker compose -f srcs/docker-compose.yml ps
```

All required services should appear as running.

---

## 3. Stopping the project

To stop the project while keeping the containers and persistent volumes:

```bash
make down
```

or, without a Makefile:

```bash
docker compose -f srcs/docker-compose.yml down
```

This stops and removes the containers created by Docker Compose.

### Important

Do **not** remove the persistent volumes unless you intentionally want to delete the stored application data.

For example, this command removes the containers **and** the volumes:

```bash
docker compose -f srcs/docker-compose.yml down -v
```

Using `-v` can delete the MariaDB database and WordPress persistent data.

---

## 4. Accessing the website

Once the stack is running, open the configured domain in a web browser:

```text
https://abbenmou.42.fr
```

For a typical 42 Inception configuration, the domain may look like:

```text
https://abbenmou.42.fr
```

The connection is made through **NGINX**, which is the public-facing service of the stack.

If the browser reports a certificate warning, verify that the project's TLS certificate and NGINX configuration are correctly configured.

---

## 5. Accessing the WordPress administration panel

The WordPress administration panel is available at:

```text
https://abbenmou.42.fr/wp-admin/
```

or:

```text
https://abbenmou.42.fr/wp-login.php
```

Use the WordPress administrator credentials configured for the project.

After logging in, the administrator can manage the website, including:

- Posts and pages
- Users
- Themes
- Plugins
- WordPress settings
- Media

---

## 6. Locating and managing credentials

Sensitive credentials should not be hard-coded directly into Dockerfiles, application source code, or committed configuration files.

In this project, credentials are provided through Docker secrets. They are available inside the relevant containers under:

```text
/run/secrets/
```

Examples include:

```text
/run/secrets/db_name.txt
/run/secrets/db_user.txt
/run/secrets/db_password.txt
/run/secrets/db_root_password.txt
/run/secrets/wp_admin_user.txt
/run/secrets/wp_admin_pass.txt
```

The exact filenames depend on the project configuration.

### Checking the configured secrets

To inspect which secret files are available inside a container:

```bash
docker exec -it <container_name> ls -l /run/secrets/
```

Do not print or expose secret contents unnecessarily.

### Changing credentials

Credentials should be changed in the project's secret source files/configuration, then the affected services should be recreated so that the new values are loaded.

After changing database credentials, make sure that the WordPress configuration and MariaDB configuration remain consistent.

For administrator credentials, update the WordPress administrator account through the WordPress administration interface whenever possible.

### Security note

Never commit passwords, secret files, private keys, or other sensitive credentials to Git.

---

## 7. Checking that the services are running correctly

### Check container status

From the project root:

```bash
docker compose -f srcs/docker-compose.yml ps
```

The expected services are:

```text
nginx
wordpress
mariadb
```

Their state should indicate that the containers are running.

### Check logs

To inspect all service logs:

```bash
docker compose -f srcs/docker-compose.yml logs
```

To follow the logs in real time:

```bash
docker compose -f srcs/docker-compose.yml logs -f
```

To inspect one service:

```bash
docker compose -f srcs/docker-compose.yml logs nginx
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs mariadb
```

Look for errors such as failed connections, configuration errors, permission problems, or processes that have exited.

### Check individual containers

You can also inspect the containers directly:

```bash
docker ps
```

A healthy stack should show the NGINX, WordPress, and MariaDB containers as running.

### Check the website from the browser

Open:

```text
https://abbenmou.42.fr
```

If the WordPress website loads correctly, NGINX is accepting the request and forwarding it to the application correctly.

Then open:

```text
https://abbenmou.42.fr/wp-admin/
```

and verify that the administration panel is accessible.

### Check MariaDB connectivity

Inspect the MariaDB logs:

```bash
docker compose -f srcs/docker-compose.yml logs mariadb
```

The MariaDB service should finish its initialization successfully and remain running.

---

## 8. Useful commands

### Start

```bash
make
```

### Stop

```bash
make down
```

### Show running containers

```bash
docker compose -f srcs/docker-compose.yml ps
```

### Show logs

```bash
docker compose -f srcs/docker-compose.yml logs
```

### Follow logs

```bash
docker compose -f srcs/docker-compose.yml logs -f
```

### Restart the stack

```bash
docker compose -f srcs/docker-compose.yml restart
```

### Rebuild and restart

After changing a Dockerfile or application configuration:

```bash
docker compose -f srcs/docker-compose.yml up -d --build
```

---

## 9. Quick verification checklist

A working installation should satisfy all of the following:

1. The `nginx`, `wordpress`, and `mariadb` containers are running.
2. The WordPress website opens at `https://abbenmou.42.fr`.
3. The WordPress administration panel opens at `https://abbenmou.42.fr/wp-admin/`.
4. WordPress can access the MariaDB database.
5. No critical errors are visible in the service logs.
6. Persistent WordPress and MariaDB data remain available after containers are recreated.
