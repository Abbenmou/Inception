
## This project has been created as part of the 42 curriculum by abbenmou

# Inception

## Description

### Project Overview

**Inception** is a system-administration and containerization project whose main goal is to build a small web infrastructure using **Docker Compose**.

The infrastructure is composed of several isolated containers, each dedicated to one service:

- **NGINX**: acts as the public-facing web server and reverse proxy.
- **WordPress + PHP-FPM**: provides the dynamic web application.
- **MariaDB**: stores the WordPress database.

The services communicate through a Docker network, while persistent application and database data are stored using Docker volumes. Sensitive configuration values are provided through Docker secrets rather than being hard-coded into images or exposed as ordinary environment variables.

The project is designed around the principle of **one main service per container**. Each container has a clearly defined responsibility and communicates with the other containers through the internal Docker network.

### Project Goal

The main objectives of the project are to:

1. Learn how Docker images and containers work.
2. Build custom Docker images from Dockerfiles.
3. Orchestrate multiple services with Docker Compose.
4. Configure NGINX as a reverse proxy and TLS endpoint.
5. Run WordPress through PHP-FPM.
6. Connect WordPress to MariaDB.
7. Persist data independently from container lifetimes.
8. Manage sensitive values using Docker secrets.
9. Understand service-to-service communication through Docker networking.

### Docker and Sources Included in the Project

Docker is the foundation of the project. Instead of installing NGINX, PHP-FPM, WordPress, and MariaDB directly on the host machine, each service runs inside its own container.

The project source files typically include:

```text
.
├── Makefile
├── secrets/
│   ├── db_name.txt
│   ├── db_password.txt
│   ├── db_root_password.txt
│   ├── db_user.txt
│   ├── wp_admin_email.txt 
│   ├── wp_admin_password.txt
│   ├── wp_admin_user.txt
│   ├── wp_user_email.txt
│   ├── wp_user_password.txt
│   ├── wp_user.txt
└── srcs/
    ├── docker-compose.yml
    ├── .env
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/
        │       └── nginx.conf
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── www.conf
        │   └── tools/
        │       └── init.sh
        └── mariadb/
            ├── Dockerfile
            ├── conf/
            │   └── mariadb.conf
            └── tools/
                └── init.sh
```

The exact filenames may differ depending on the implementation, but the important design principle is that the source contains the configuration and build instructions required to recreate the whole infrastructure.

### Main Design Choices

#### 1. One service per container

Each container is responsible for one major service:

- NGINX handles HTTP/HTTPS requests.
- WordPress handles PHP application execution through PHP-FPM.
- MariaDB handles persistent relational data.

This separation makes the system easier to understand, configure, debug, rebuild, and scale.

#### 2. Custom images built from Debian

The service images are built from a minimal Debian base image rather than relying on a fully configured third-party application image.

This makes the installation and configuration of each service explicit and demonstrates how the software stack is assembled.

#### 3. NGINX as the entry point

Only NGINX is exposed to the outside world. HTTPS traffic reaches NGINX first, and NGINX decides whether a request should be served directly or forwarded to PHP-FPM.

This creates a clear boundary between the public network and the internal application/database services.

#### 4. PHP-FPM for WordPress

WordPress is a PHP application. PHP-FPM provides the FastCGI process manager used to execute WordPress PHP scripts.

NGINX does not interpret PHP itself. Instead, it forwards PHP requests to PHP-FPM through the internal Docker network.

#### 5. MariaDB separated from WordPress

The database runs in its own container and is accessed by WordPress through the Docker network using the MariaDB service name as the database host.

This avoids coupling the web application and database into a single container.

#### 6. Persistent storage through named volumes

WordPress files and MariaDB data must survive container recreation. Named Docker volumes are therefore used for persistent data.

#### 7. Docker secrets for sensitive values

Passwords and other sensitive values are stored as Docker secrets and mounted inside the relevant containers, typically under `/run/secrets/`.

This prevents credentials from being placed directly in Dockerfiles or unnecessarily exposed as ordinary environment variables.

---

## Virtual Machines vs Docker

Both Virtual Machines (VMs) and Docker provide isolation, but they achieve it differently.

A **Virtual Machine** virtualizes hardware. A hypervisor creates a complete virtual computer containing its own kernel and operating system. Each VM therefore requires its own OS environment.

**Docker containers** use operating-system-level virtualization. Containers share the host kernel while isolating processes, filesystems, networking, users, and other resources through Linux kernel features such as namespaces and cgroups.

| Aspect | Virtual Machines | Docker Containers |
|---|---|---|
| Virtualization level | Hardware / full machine | Operating-system level |
| Guest kernel | Each VM has its own kernel | Containers share the host kernel |
| Resource usage | Higher | Generally lower |
| Startup time | Usually slower | Usually much faster |
| Isolation | Strong machine-level isolation | Process-level isolation |
| Image size | Usually much larger | Usually much smaller |
| Best suited for | Full OS isolation, different kernels | Application/service isolation |

For Inception, Docker is more appropriate because the objective is to isolate services rather than create several complete virtual computers.

---

## Secrets vs Environment Variables

Both mechanisms can provide configuration values to containers, but they are not intended for exactly the same purpose.

### Environment Variables

Environment variables are convenient for ordinary configuration values such as:

```text
DOMAIN_NAME=abbenmou.42.fr
DB_HOST=mariadb
```

They are useful when an application needs simple configuration to be available in its environment.

However, passwords stored as environment variables can become easier to expose through configuration inspection, debugging tools, process environments, logs, or accidental propagation.

### Docker Secrets

Docker secrets are designed specifically for sensitive information such as:

```text
DB_PASSWORD
DB_ROOT_PASSWORD
WP_ADMIN_PASSWORD
```

A secret can be mounted into the container as a file, for example:

```text
/run/secrets/db_password.txt
```

The application or startup script then reads the value from that file.

### Comparison

| Aspect | Environment Variables | Secrets |
|---|---|---|
| Main purpose | Configuration | Sensitive data |
| Typical form | `NAME=value` | Mounted secret file |
| Suitable for passwords | Possible, but less desirable | Preferred |
| Visibility | Can be exposed as part of environment/configuration | Accessed only where mounted |
| Inception usage | Non-sensitive configuration | Database and WordPress credentials |

For this project, environment variables are appropriate for non-sensitive configuration, while passwords are handled through Docker secrets.

---

## Docker Network vs Host Network

A **Docker network** provides an isolated virtual network in which containers can communicate with one another.

For example, WordPress can connect to MariaDB using:

```text
mariadb:3306
```

Here, `mariadb` is resolved by Docker's internal DNS to the MariaDB container.

A **host network** removes most of this network isolation and makes a container use the host's network namespace directly.

| Aspect | Docker Network | Host Network |
|---|---|---|
| Network isolation | Yes | Very limited |
| Container-to-container communication | Via Docker networking | Via host networking |
| Service discovery | Docker DNS/service names | Host networking rules |
| Port isolation | Maintained by Docker | Reduced |
| Typical use in Inception | Yes | No |

The project uses a Docker network because the services need controlled internal communication while remaining isolated from the host network.

Only the required public port, normally HTTPS on port `443`, is published from the NGINX container.

---

## Docker Volumes vs Bind Mounts

Both volumes and bind mounts allow data to persist beyond the lifetime of a container, but Docker manages them differently.

### Docker Volumes

A Docker volume is storage managed by Docker.

For example:

```yaml
volumes:
  wordpress_data:
  mariadb_data:
```

The container can mount these volumes at locations such as:

```text
/var/www/html
/var/lib/mysql
```

Volumes are well suited to application data because Docker manages their lifecycle and storage location.

### Bind Mounts

A bind mount maps a specific host filesystem path into a container, for example:

```text
/home/user/project:/var/www/html
```

The host directly controls the source directory.

### Comparison

| Aspect | Docker Volume | Bind Mount |
|---|---|---|
| Managed by Docker | Yes | No |
| Source location | Docker-managed | Explicit host path |
| Portability | Generally better | More dependent on host layout |
| Host filesystem dependency | Lower | Higher |
| Typical use | Persistent application/database data | Development and direct host-file sharing |

For Inception, Docker volumes are preferable for WordPress and MariaDB persistent data because the data should survive container recreation without depending on a particular host path layout.

---

## Architecture and Request Flow

The public entry point is NGINX.

When a user accesses the configured domain over HTTPS, the request reaches the NGINX container. NGINX terminates the TLS connection and evaluates the requested URI.

For a static resource such as an image, NGINX can serve the file directly from the WordPress filesystem.

For a PHP resource, NGINX forwards the request to PHP-FPM in the WordPress container using FastCGI.

PHP-FPM executes the WordPress PHP code. WordPress can then communicate with MariaDB through the Docker network to read or modify database data.

The generated response is returned from PHP-FPM to NGINX, then NGINX sends the final HTTP response back to the browser.

The database is never exposed directly to the public network.

---

## Service Responsibilities

### NGINX

NGINX is the reverse proxy and HTTPS endpoint.

Its responsibilities include:

- Listening for HTTPS connections.
- Loading the TLS certificate and private key.
- Serving static files.
- Forwarding PHP requests to PHP-FPM.
- Applying HTTP request handling rules.
- Returning responses to clients.

### WordPress / PHP-FPM

WordPress is the application layer.

PHP-FPM provides the PHP worker processes required to execute PHP scripts.

WordPress is responsible for:

- Generating dynamic web pages.
- Processing application logic.
- Reading and writing WordPress data.
- Communicating with MariaDB.

### MariaDB

MariaDB is the relational database server.

It stores information such as:

- WordPress users.
- Posts and pages.
- Site settings.
- Metadata.
- Plugin and theme data.

---

## Instructions

### Prerequisites

Install the required tools on the host system:

- Docker
- Docker Compose support (`docker compose`)
- GNU Make
- Git

On a Linux system using Docker Engine, verify the installation with:

```bash
docker --version
docker compose version
make --version
```

### Clone the Project

Clone the repository and enter its directory:

```bash
git clone <repository-url>
cd inception
```

### Configure the Environment

The project may use an `.env` file for non-sensitive configuration such as the domain name and database host.

Example:

```env
DOMAIN_NAME=abbenmou.42.fr
DB_HOST=mariadb
```

Do not store production passwords directly in the `.env` file when the project is configured to use Docker secrets.

### Configure Secrets

Create the required secret files under the project's secrets directory.

Example:

```text
secrets/
├── db_name.txt
├── db_user.txt
├── db_password.txt
├── db_root_password.txt
├── wp_admin_user.txt
└── wp_admin_password.txt
```

Each file should contain the corresponding value.

For example:

```bash
printf '%s\n' 'my_database' > secrets/db_name.txt
printf '%s\n' 'wpuser' > secrets/db_user.txt
printf '%s\n' 'strong_password' > secrets/db_password.txt
```

Use appropriate secure passwords for an actual deployment.

### Configure the Domain

For local testing, the configured domain should resolve to the local machine.

For example, `/etc/hosts` can contain:

```text
127.0.0.1 abbenmou.42.fr
```

Replace `abbenmou.42.fr` with the domain configured by the project.

### Build and Start the Infrastructure

From the project root:

```bash
make
```

Depending on the Makefile implementation, this may build the images and start the complete infrastructure.

The equivalent Docker Compose command is commonly:

```bash
docker compose -f srcs/docker-compose.yml up --build
```

To run the infrastructure in detached mode:

```bash
docker compose -f srcs/docker-compose.yml up --build -d
```

### Check Running Containers

```bash
docker compose -f srcs/docker-compose.yml ps
```

### Inspect Logs

For a specific service:

```bash
docker compose -f srcs/docker-compose.yml logs nginx
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs mariadb
```

For all services:

```bash
docker compose -f srcs/docker-compose.yml logs
```

### Stop the Infrastructure

```bash
docker compose -f srcs/docker-compose.yml down
```

Or, when supported by the Makefile:

```bash
make down
```

### Remove Containers and Volumes

Be careful: removing volumes deletes persistent application/database data.

A complete cleanup commonly uses:

```bash
docker compose -f srcs/docker-compose.yml down -v
```

The exact Makefile target should be checked before running a destructive cleanup command.

---

## Usage Examples

### Open the Website

Open the configured domain in a browser:

```text
https://abbenmou.42.fr
```

Example:

```text
https://abbenmou.42.fr
```

### WordPress Administration

The WordPress administration interface is normally available at:

```text
https://abbenmou.42.fr/wp-admin/
```

### Test HTTPS

From the host:

```bash
curl -k https://abbenmou.42.fr
```

The `-k` option allows testing with a certificate that is not trusted by the host, which is common with locally generated certificates.

---

## Technical Choices

### TLS / HTTPS

The NGINX container is responsible for TLS termination. The private key and certificate are configured in the NGINX server block.

HTTPS is used because the project requires the web application to be served securely and because it prevents credentials and session traffic from being sent as plain HTTP.

### FastCGI

NGINX communicates with PHP-FPM using FastCGI.

A simplified flow is:

```text
Browser
   |
   | HTTPS
   v
NGINX
   |
   | FastCGI
   v
PHP-FPM
   |
   | SQL
   v
MariaDB
```

NGINX is therefore a web server/reverse proxy, while PHP-FPM is responsible for executing PHP.

### Service Discovery

Containers communicate using Docker Compose service names rather than hard-coded container IP addresses.

For example:

```text
DB_HOST=mariadb
```

Docker's internal DNS resolves `mariadb` to the corresponding container.

This is preferable to manually depending on container IP addresses, which may change when containers are recreated.

### Persistent Data

The WordPress files and MariaDB database directory are stored on Docker volumes.

This allows containers to be recreated without automatically losing the persistent application state.

---

## Project Structure

A typical project structure is:

```text
inception/
├── Makefile
├── README.md
├── secrets/
│   └── *.txt
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── nginx.conf
        │   └── tools/
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── www.conf
        │   └── tools/
        └── mariadb/
            ├── Dockerfile
            ├── conf/
            │   └── mariadb.conf
            └── tools/
```

Each Dockerfile describes how its service image is constructed, configuration files define service behavior, and startup scripts initialize the service when necessary.

---

## Resources

### Official Documentation

- Docker Documentation: https://docs.docker.com/
- Docker Compose Documentation: https://docs.docker.com/compose/
- Dockerfile Reference: https://docs.docker.com/reference/dockerfile/
- Docker Volumes: https://docs.docker.com/engine/storage/volumes/
- Docker Bind Mounts: https://docs.docker.com/engine/storage/bind-mounts/
- Docker Networking: https://docs.docker.com/engine/network/
- Docker Secrets: https://docs.docker.com/engine/swarm/secrets/

### NGINX

- NGINX Documentation: https://nginx.org/en/docs/
- NGINX Beginner's Guide: https://nginx.org/en/docs/beginners_guide.html
- NGINX FastCGI Module: https://nginx.org/en/docs/http/ngx_http_fastcgi_module.html

### PHP / PHP-FPM

- PHP Documentation: https://www.php.net/docs.php
- PHP-FPM Documentation: https://www.php.net/manual/en/install.fpm.php

### WordPress

- WordPress Developer Resources: https://developer.wordpress.org/
- WordPress Documentation: https://wordpress.org/documentation/

### MariaDB

- MariaDB Documentation: https://mariadb.com/docs/

### Linux Containers

- Linux namespaces: https://man7.org/linux/man-pages/man7/namespaces.7.html
- Linux cgroups: https://www.kernel.org/doc/html/latest/admin-guide/cgroup-v2.html

---

## AI Usage

AI tools were used as a learning and development aid during the project.

The AI was mainly used for **technical explanations, debugging assistance, configuration analysis, and conceptual clarification**.

Examples of tasks for which AI assistance was used include:

- Understanding Docker architecture and the relationship between Docker Engine, `dockerd`, images, containers, and processes.
- Understanding Linux namespaces and how container isolation works.
- Understanding Docker Compose and service-to-service networking.
- Explaining the structure and semantics of an NGINX configuration file.
- Understanding NGINX request routing, `location` blocks, static files, FastCGI, and PHP-FPM.
- Understanding the relationship between WordPress, PHP-FPM, NGINX, and MariaDB.
- Explaining MariaDB initialization and startup behavior.
- Comparing Docker concepts such as secrets, environment variables, volumes, bind mounts, and network modes.

---

## Conclusion

The Inception project demonstrates how a traditional web stack can be separated into isolated containerized services.

NGINX provides the public HTTPS entry point, WordPress runs through PHP-FPM, and MariaDB provides persistent database storage. Docker Compose coordinates the services, Docker networking connects them internally, Docker volumes preserve application data, and Docker secrets protect sensitive configuration values.

The resulting architecture provides clear service boundaries, reproducible deployment, persistent storage, and controlled communication between components.
