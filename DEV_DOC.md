# DEV_DOC.md — Inception Developer Documentation

## 1. Project overview

This project is a Docker-based web stack composed of three services:

- **NGINX**: HTTPS web server and reverse proxy.
- **WordPress**: PHP application running through PHP-FPM.
- **MariaDB**: database server used by WordPress.

The services are built as Docker images and launched together with Docker Compose.

The project is organized so that application processes run inside containers while persistent data is stored in Docker volumes.

A typical project structure is:

```text
.
├── Makefile
├── secrets/
├── srcs/
│   ├── docker-compose.yml
│   ├── .env
│   └── requirements/
│       ├── nginx/
│       ├── wordpress/
│       └── mariadb/
└── ...
```

The exact directory names may vary slightly depending on the project implementation.

---

## 2. Prerequisites

Before building the project, install and configure:

- **Docker Engine**
- **Docker Compose** through the `docker compose` command
- **GNU Make**
- **Git**, if the project is managed with Git

Check the installed versions:

```bash
docker --version
docker compose version
make --version
git --version
```

Make sure the Docker daemon is running:

```bash
docker info
```

If `docker info` cannot communicate with the daemon, start Docker before continuing.

The current user must also have permission to communicate with the Docker daemon.

---

## 3. Clone and enter the project

Clone the project repository:

```bash
git clone <REPOSITORY_URL>
```

Enter the project directory:

```bash
cd <PROJECT_DIRECTORY>
```

All following commands should normally be executed from the project root, where the `Makefile` is located.

---

## 4. Configure the environment

### 4.1 Environment file

The project uses an environment file to provide non-secret configuration values to Docker Compose.

A typical file is:

```text
srcs/.env
```

or the location specified by the project's `docker-compose.yml`.

Typical values include:

```text
DOMAIN_NAME=abbenmou.42.fr
```

Other variables can define paths, database names, or usernames depending on the implementation.

Do not place passwords or other sensitive credentials in `.env` when Docker secrets are used for them.

### 4.2 Domain configuration

For local development, the domain used by the project must resolve to the local machine.

For example, if the project uses:

```text
abbenmou.42.fr
```

the host system can map the domain to localhost through `/etc/hosts`:

```text
127.0.0.1 abbenmou.42.fr
```

The exact domain must match the value expected by the NGINX and WordPress configuration.

---

## 5. Configure secrets

Sensitive values are stored separately from the normal Compose configuration.

Typical secrets include:

```text
db_name.txt
db_password.txt
db_root_password.txt
db_user.txt
wp_admin_email.txt
wp_admin_password.txt
wp_admin_user.txt
wp_user.txt
wp_user_email.txt
wp_user_password.txt
```

The actual filenames depend on the project configuration.

For example, the project may have a structure such as:

```text
secrets/
├──db_name.txt
├──db_password.txt
├──db_root_password.txt
├──db_user.txt
├──wp_admin_email.txt
├──wp_admin_password.txt
├──wp_admin_user.txt
├──wp_user.txt
├──wp_user_email.txt
└──wp_user_password.txt
```

The Docker Compose file should map these files as Docker secrets. Inside the corresponding containers, they are made available under:

```text
/run/secrets/
```

For example:

```text
/run/secrets/db_password.txt
```

Keep secret files out of version control. Add them to `.gitignore` when appropriate.

Example:

```gitignore
secrets/*
```

The project should contain only the secret filenames/placeholders required to reproduce the setup, not real production passwords.

---

## 6. Review the Docker Compose configuration

Before the first build, check:

```text
srcs/docker-compose.yml
```

Verify the following:

- The three services are defined: NGINX, WordPress, and MariaDB.
- The services use the intended Dockerfiles.
- The services are attached to the same application network where required.
- Required ports are published by NGINX.
- Environment variables and secrets are correctly referenced.
- Named volumes are correctly mounted.
- Persistent data is not accidentally stored only inside the container filesystem.

You can validate the final Compose configuration with:

```bash
docker compose -f srcs/docker-compose.yml config
```

This is useful for detecting YAML syntax errors and configuration problems before starting the stack.

---

## 7. Build and launch the project

The recommended way to build and launch the project is through the `Makefile`.

From the project root:

```bash
make
```

A typical Makefile target performs the equivalent of:

```bash
docker compose -f srcs/docker-compose.yml up -d --build
```

The command:

- Builds the required Docker images.
- Creates the Docker network and volumes if necessary.
- Creates the containers.
- Starts the services in detached mode.

To verify the result:

```bash
docker compose -f srcs/docker-compose.yml ps
```

The NGINX, WordPress, and MariaDB containers should be running.

---

## 8. Useful Makefile commands

The exact targets depend on the project's `Makefile`, but a typical Inception implementation provides commands such as:

### Build and start

```bash
make
```

### Stop and remove the stack

```bash
make down
```

### Rebuild images

```bash
make build
```

If the project does not provide a `build` target, use:

```bash
docker compose -f srcs/docker-compose.yml build
```

Always check the project's `Makefile` to confirm the available targets:

```bash
cat Makefile
```

---

## 9. Docker Compose commands

Docker Compose can be used directly when more control is needed.

### Start the stack

```bash
docker compose -f srcs/docker-compose.yml up -d
```

### Build and start

```bash
docker compose -f srcs/docker-compose.yml up -d --build
```

### Stop and remove containers

```bash
docker compose -f srcs/docker-compose.yml down
```

### Restart services

```bash
docker compose -f srcs/docker-compose.yml restart
```

### Display service status

```bash
docker compose -f srcs/docker-compose.yml ps
```

### Display logs

```bash
docker compose -f srcs/docker-compose.yml logs
```

### Follow logs

```bash
docker compose -f srcs/docker-compose.yml logs -f
```

### Display logs for one service

```bash
docker compose -f srcs/docker-compose.yml logs nginx
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs mariadb
```

---

## 10. Container management commands

List running containers:

```bash
docker ps
```

List all containers, including stopped ones:

```bash
docker ps -a
```

Inspect a container:

```bash
docker inspect <CONTAINER_NAME>
```

Open a shell inside a container:

```bash
docker exec -it <CONTAINER_NAME> /bin/bash
```

If Bash is not installed:

```bash
docker exec -it <CONTAINER_NAME> /bin/sh
```

Run a command without opening an interactive shell:

```bash
docker exec <CONTAINER_NAME> <COMMAND>
```

Example:

```bash
docker exec wordpress ls -la /var/www/html
```

Check the processes running inside a container:

```bash
docker top <CONTAINER_NAME>
```

---

## 11. Image management

List images:

```bash
docker images
```

Build a specific service:

```bash
docker compose -f srcs/docker-compose.yml build <SERVICE_NAME>
```

Remove unused images:

```bash
docker image prune
```

Use pruning commands carefully, especially on a development machine containing other Docker projects.

---

## 12. Network management

List Docker networks:

```bash
docker network ls
```

Inspect the project's network:

```bash
docker network inspect <NETWORK_NAME>
```

The WordPress and MariaDB containers should be able to communicate over the Docker network using their Compose service names.

For example, WordPress can normally reach MariaDB using the MariaDB service name as the database host:

```text
mariadb
```

The containers do not need to use the host machine's IP address for this internal connection.

---

## 13. Volumes and persistent data

The project uses **named Docker volumes** for persistent WordPress and MariaDB data.

Typical volume definitions look like:

```yaml
volumes:
  mariadb_data:
  wordpress_data:
```

The Compose file then mounts these volumes into the appropriate containers.

For example:

```text
MariaDB container  ->  mariadb_data
WordPress container -> wordpress_data
```

The purpose is to keep application data separate from the temporary container filesystem.

### Why this is necessary

A container's writable layer is tied to that particular container. When a container is removed and recreated, data stored only in that writable layer can be lost.

A volume has a lifecycle independent of an individual container. Therefore:

```text
container removed
       ↓
volume remains
       ↓
new container
       ↓
same volume mounted
       ↓
data available again
```

This allows the database and WordPress files to survive container recreation.

---

## 14. Where the data is stored

List Docker volumes:

```bash
docker volume ls
```

Inspect a specific volume:

```bash
docker volume inspect <VOLUME_NAME>
```

The `docker volume inspect` output shows the location managed by Docker.

For this project, the named volumes may use explicit host-side locations through the `local` volume driver and a `device` configuration.

For example, the project may use locations such as:

```text
/home/<USER>/data/mariadb
/home/<USER>/data/wordpress
```

When the project is configured this way:

```text
MariaDB persistent data:
    /home/<USER>/data/mariadb

WordPress persistent data:
    /home/<USER>/data/wordpress
```

These directories contain the data that must survive container recreation.

Do not manually delete these directories unless you intentionally want to remove the persistent project data.

---

## 15. Checking volume mounts

To verify which volumes a container is using:

```bash
docker inspect <CONTAINER_NAME>
```

Look at the `Mounts` section.

A more compact Compose-level check is:

```bash
docker compose -f srcs/docker-compose.yml ps
```

Then inspect the corresponding container if you need to confirm the exact host path and container path.

For example:

```bash
docker inspect mariadb
docker inspect wordpress
```

---

## 16. Rebuilding without deleting persistent data

A normal rebuild can be performed with:

```bash
docker compose -f srcs/docker-compose.yml up -d --build
```

This recreates containers when necessary while keeping named volumes.

This is normally the preferred operation after changing:

- Dockerfiles
- Application configuration
- NGINX configuration
- PHP configuration
- Other files copied into the images

The persistent database and WordPress data should remain in their volumes.

---

## 17. Removing the stack and volumes

Stopping and removing the containers normally does not remove named volumes:

```bash
docker compose -f srcs/docker-compose.yml down
```

Removing the volumes as well requires:

```bash
docker compose -f srcs/docker-compose.yml down -v
```

The `-v` option is destructive for persistent application data.

Only use it when a completely fresh installation is required.

For example, after:

```bash
docker compose -f srcs/docker-compose.yml down -v
```

the MariaDB database and WordPress persistent files stored in those volumes will no longer be available through the Compose project.

---

## 18. Typical development workflow

A normal development cycle is:

### First installation

```bash
git clone <REPOSITORY_URL>
cd <PROJECT_DIRECTORY>
# Configure .env and secrets
# Configure /etc/hosts if necessary
make
```

### Check the stack

```bash
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml logs
```

### Modify the project

After changing a Dockerfile or configuration copied into an image:

```bash
docker compose -f srcs/docker-compose.yml up -d --build
```

### Stop the project

```bash
make down
```

### Start it again

```bash
make
```

The persistent volumes should preserve the WordPress and MariaDB data.

---

## 19. Troubleshooting

### A container exits immediately

Check its logs:

```bash
docker compose -f srcs/docker-compose.yml logs <SERVICE_NAME>
```

Also check:

```bash
docker ps -a
```

### WordPress cannot connect to MariaDB

Check:

```bash
docker compose -f srcs/docker-compose.yml logs mariadb
docker compose -f srcs/docker-compose.yml logs wordpress
```

Verify that:

- MariaDB is running.
- WordPress uses the correct database hostname.
- The database name is correct.
- The database username and password match.
- The required secrets are mounted under `/run/secrets/`.
- Both services are attached to the correct Docker network.

### The website cannot be reached

Check:

```bash
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml logs nginx
```

Also verify that the expected port is published by NGINX and that the configured domain resolves to the host machine.

### Data appears to have disappeared

First verify that the containers are using the expected volumes:

```bash
docker volume ls
docker inspect <CONTAINER_NAME>
```

Do not use `docker compose down -v` unless you intentionally want to delete the project's volumes.

---

## 20. Important files

The main developer-facing files are normally:

```text
Makefile
srcs/docker-compose.yml
srcs/.env
srcs/requirements/nginx/Dockerfile
srcs/requirements/nginx/conf/...
srcs/requirements/wordpress/Dockerfile
srcs/requirements/wordpress/conf/...
srcs/requirements/mariadb/Dockerfile
srcs/requirements/mariadb/conf/...
secrets/...
```

The exact filenames depend on the implementation.

The most important roles are:

- **Makefile**: provides convenient project-level commands.
- **docker-compose.yml**: defines services, networks, volumes, environment variables, secrets, and dependencies.
- **Dockerfiles**: describe how each service image is built.
- **Configuration files**: configure NGINX, PHP-FPM, WordPress, and MariaDB.
- **Secret files**: provide sensitive credentials at runtime.
- **Named volumes**: preserve WordPress and MariaDB data.

---

## 21. Persistence summary

The key persistence rule for the project is:

```text
Docker container
    └── temporary container filesystem

Docker named volume
    └── persistent application data
```

The WordPress and MariaDB containers can therefore be removed and recreated without losing the data stored in their named volumes.

For this project, the persistent data is intended to be stored in the configured locations for:

```text
mariadb_data   → MariaDB database files
wordpress_data → WordPress files
```
