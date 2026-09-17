# mk3m-frankentypo3: Modern TYPO3 on FrankenPHP & Valkey

[![CI Build Check](https://github.com/mk3media/mk3m-frankentypo3/actions/workflows/docker-build.yml/badge.svg)](https://github.com/mk3media/mk3m-frankentypo3/actions)
[![TYPO3 v13 / v14](https://img.shields.io/badge/TYPO3-v13%20%7C%20v14-orange.svg?logo=typo3)](https://typo3.org/)
[![PHP 8.4](https://img.shields.io/badge/PHP-8.4-777bb4.svg?logo=php)](https://www.php.net/)
[![FrankenPHP](https://img.shields.io/badge/FrankenPHP-1.12-blue.svg)](https://frankenphp.dev/)
[![Caddy Server](https://img.shields.io/badge/Web_Server-Caddy_v2-22b8cf.svg?logo=caddy)](https://caddyserver.com/)
[![Valkey 7 / 8](https://img.shields.io/badge/Cache-Valkey-red.svg)](https://valkey.io/)
[![License: GPL-2.0](https://img.shields.io/badge/License-GPL--2.0-blue.svg)](LICENSE)

A battle-tested, production-ready Docker boilerplate for running **TYPO3 v13+ / v14** with **FrankenPHP (PHP 8.4 + embedded Caddy web server)**, **Valkey** (Redis-compatible in-memory cache), and **MariaDB LTS**.

---

## 💡 Origin & Community Preview

This boilerplate was generated with AI assistance, extracted and generalized from a working TYPO3 setup running in a private development environment.

> [!NOTE]
> While based on a proven production configuration, this standalone public template is an initial release. Community feedback, real-world testing across different operating systems, and contributions are warmly welcome!

---

## 📑 Table of Contents

- [💡 Origin & Community Preview](#-origin--community-preview)
- [⚡ Why FrankenPHP for TYPO3?](#-why-frankenphp-for-typo3)
- [🏗️ Architecture Overview](#️-architecture-overview)
- [📦 Stack Components](#-stack-components)
- [🚀 Quickstart](#-quickstart)
- [⚙️ Configuration Details](#️-configuration-details)
  - [Embedded Caddy Server](#embedded-caddy-server-frankenphpcaddyfile)
  - [Valkey / Redis Integration](#valkey--redis-integration-configsystemadditionalphp)
  - [Reverse Proxy & Trusted Hosts](#reverse-proxy--trusted-hosts)
- [🛠️ Developer Workflows](#️-developer-workflows)
  - [Makefile Commands](#makefile-commands)
  - [Database Import & Export](#database-import--export)
  - [Local Port Exposure & Overrides](#local-port-exposure--overrides)
  - [Enabling Xdebug for Local Development](#enabling-xdebug-for-local-development)
- [🔒 Security & Production Hardening](#-security--production-hardening)
- [❓ FAQ & Troubleshooting](#-faq--troubleshooting)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)

---

## ⚡ Why FrankenPHP for TYPO3?

FrankenPHP is a modern application server for PHP written in Go, built on top of the high-performance Caddy web server.

- **Unified Architecture**: Replaces the classic two-tier setup (Nginx/Apache + PHP-FPM) with a single, highly concurrent Go binary.
- **Native HTTP/2 & HTTP/3**: Automatic modern transport protocols, Brotli/Zstandard/Gzip compression, and TLS capabilities out of the box.
- **Ultra-Fast Redis Caching via Valkey**: Native multi-database Redis caching backend for TYPO3 pages, page sections, cache hashes, and rootlines.
- **Pre-Hardened for TYPO3**: Out-of-the-box protection against direct `.php` execution in upload folders, CSP headers for user assets, and full compatibility with TYPO3 security audits.

---

## 🏗️ Architecture Overview

```
                          ┌───────────────────────────┐
                          │  Host / Ingress Proxy     │
                          │  (Caddy, Traefik, Nginx)  │
                          └─────────────┬─────────────┘
                                        │ (Reverse Proxy via HTTP/HTTPS)
                                        ▼
    ┌───────────────────────────────────────────────────────────────────────┐
    │ FrankenPHP Web Container (:80 / :443)                                │
    │ ┌───────────────────────────────────────────────────────────────────┐ │
    │ │ Caddy Web Server (Static assets, CSP, Security headers)           │ │
    │ └─────────────────────────────────┬─────────────────────────────────┘ │
    │                                   │ (Direct in-memory worker/thread)  │
    │ ┌─────────────────────────────────▼─────────────────────────────────┐ │
    │ │ PHP 8.4 Engine (OPcache, APCu, GD, WebP, ImageMagick, Ghostscript)│ │
    │ └──────────────────────┬───────────────────────────────┬────────────┘ │
    └────────────────────────┼───────────────────────────────┼──────────────┘
                             │                               │
                             ▼                               ▼
                 ┌───────────────────────┐       ┌───────────────────────┐
                 │  Valkey Container     │       │  MariaDB Container    │
                 │  (:6379, DBs 0 - 3)   │       │  (:3306, utf8mb4)     │
                 │  - pages (db 0)       │       │  - secure root/user   │
                 │  - pagesection (db 1) │       │  - local-infile=0     │
                 │  - hash (db 2)        │       └───────────────────────┘
                 │  - rootline (db 3)    │
                 └───────────────────────┘
```

---

## 📦 Stack Components

| Service | Image / Base | Description |
| :--- | :--- | :--- |
| **`web`** | `dunglas/frankenphp:1.12-php8.4-bookworm` | Web application runtime, embedded Caddy server, Composer, ImageMagick |
| **`db`** | `mariadb:lts` | Persistent SQL database configured with `utf8mb4_unicode_ci` |
| **`valkey`** | `valkey/valkey:7-alpine` | High-speed in-memory cache server with password authentication |

---

## 🚀 Quickstart

### 1. Clone & Configure Environment

```bash
git clone https://github.com/mk3media/mk3m-frankentypo3.git my-typo3-project
cd my-typo3-project

cp .env.example .env
```

Adjust your credentials and domain settings in `.env`:
```ini
COMPOSE_PROJECT_NAME=mk3m-frankentypo3
HTTP_PORT=8080
MARIADB_ROOT_PASSWORD=your_secure_root_password
MARIADB_PASSWORD=your_secure_db_password
VALKEY_PASSWORD=your_secure_valkey_password
```

### 2. Prepare Composer & Configuration

If starting a fresh project, copy the boilerplate files:
```bash
mkdir -p data/web/config/system
cp composer.json.example data/web/composer.json
cp config/system/additional.php data/web/config/system/additional.php
```

### 3. Start Containers

```bash
# Using Makefile
make up

# Or directly via Docker Compose
docker compose up -d
```

### 4. Install Dependencies & Complete TYPO3 Setup

```bash
# Install PHP dependencies
make composer-install

# Run the TYPO3 CLI setup wizard
make typo3-setup
```

Open your browser at `http://localhost:8080` (or `http://localhost:8080/typo3`).

---

## ⚙️ Configuration Details

### Embedded Caddy Server (`frankenphp/Caddyfile`)
The Caddyfile includes essential security directives:
- **Document Root**: Points to `/var/www/html/public`.
- **Static Assets**: Routes `/fileadmin/*` and `/typo3temp/*` through Caddy's fast `file_server` without invoking PHP.
- **Security Protections**:
  - `403 Forbidden` for direct `.php` execution inside `/fileadmin/` and `/typo3temp/`.
  - `403 Forbidden` on hidden files (`.*`), `composer.*`, and `*.env`.
  - Serves `Content-Type: text/plain` for `.wrong` test files to satisfy TYPO3 security audits.
  - Custom Content Security Policy (CSP) isolating user uploads.

### Valkey / Redis Integration & System Settings (`config/system/additional.php`)
The template includes a pre-configured `config/system/additional.php` that is mounted read-only into `/var/www/html/config/system/additional.php:ro`:
- **Repository-Tracked**: Keeps caching rules, trusted hosts, and proxy configuration in Git while application code lives in persistent storage (`data/web`).
- **High-Churn Cache Offloading**: Automatically routes TYPO3 cache groups to isolated Valkey DB partitions using `\TYPO3\CMS\Core\Cache\Backend\RedisBackend`:
  - `pages` -> Database Index `0`
  - `pagesection` -> Database Index `1`
  - `hash` -> Database Index `2`
  - `rootline` -> Database Index `3`
- **Dynamic Environment Bridging**: Automatically reads `TRUSTED_HOSTS_PATTERN`, `REDIS_HOST`, `REDIS_PORT`, `REDIS_PASSWORD`, and permission masks (`0660`/`2770`) from `.env`.

### Reverse Proxy & Trusted Hosts
When running behind an ingress reverse proxy (e.g., host Caddy, Traefik, or Nginx):
- `reverseProxySSL = '*'`
- `reverseProxyIP = '*'`
- `reverseProxyHeaderMultiValue = 'first'`
- `trustedHostsPattern`: Controlled dynamically via `TRUSTED_HOSTS_PATTERN` in `.env`.

---

## 🛠️ Developer Workflows

### Makefile Commands

| Command | Action |
| :--- | :--- |
| `make up` | Start all services in the background |
| `make down` | Stop all services |
| `make restart` | Restart all services |
| `make logs` | Follow live container logs |
| `make build` | Rebuild the FrankenPHP image from `frankenphp/Dockerfile` |
| `make ps` | Inspect running container health status |
| `make cli` | Open an interactive Bash shell in the web container |
| `make cache-flush` | Flush all TYPO3 and Valkey caches |
| `make composer-install` | Run `composer install` inside the container |
| `make composer-update` | Run `composer update` inside the container |
| `make check-outdated` | Check for outdated Composer dependencies |

### Database Import & Export

**Import an SQL dump**:
```bash
docker compose exec -T db mariadb -u typo3 -p${MARIADB_PASSWORD} typo3 < backup.sql
```

**Export an SQL dump**:
```bash
docker compose exec -T db mariadb-dump -u typo3 -p${MARIADB_PASSWORD} typo3 > dump_$(date +%Y%m%d).sql
```

### Local Port Exposure & Overrides
To expose direct ports (e.g., MySQL port `3306` for PhpStorm, DBeaver, or TablePlus), copy the override file:
```bash
cp docker-compose.override.yml.example docker-compose.override.yml
```
Docker Compose automatically merges `docker-compose.override.yml` into your setup without modifying version-controlled files.

### Enabling Xdebug for Local Development
If you need step-debugging with Xdebug:
1. Add `xdebug` to `install-php-extensions` in `frankenphp/Dockerfile`:
   ```dockerfile
   RUN install-php-extensions ... xdebug
   ```
2. Add Xdebug configuration to `frankenphp/conf.d/typo3.ini`:
   ```ini
   [xdebug]
   xdebug.mode = debug
   xdebug.start_with_request = yes
   xdebug.client_host = host.docker.internal
   xdebug.client_port = 9003
   ```
3. Rebuild the web container:
   ```bash
   make build
   ```

---

## 🔒 Security & Production Hardening

- **Privilege Separation**: All services run with `security_opt: ["no-new-privileges:true"]`.
- **Database Safety**: MariaDB is started with `--local-infile=0` to block SQL file read injections.
- **Cache Authentication**: Valkey enforces password authentication via `--requirepass "${VALKEY_PASSWORD}"`.
- **Host Permissions**: For Linux hosts, protect sensitive database and cache directories:
  ```bash
  chmod 700 /path/to/data/mysql /path/to/data/valkey
  ```

---

## ❓ FAQ & Troubleshooting

<details>
<summary><b>Q: I get "The requested host does not match the configured trusted hosts" error</b></summary>

**A:** Update `TRUSTED_HOSTS_PATTERN` in your `.env` file to match your domain (e.g. `TRUSTED_HOSTS_PATTERN=(my-site\.example\.com|localhost)`), then run:
```bash
make cache-flush
```
</details>

<details>
<summary><b>Q: How do I change PHP upload and memory limits?</b></summary>

**A:** Adjust the settings in `frankenphp/conf.d/typo3.ini`, then run `make restart`.
</details>

<details>
<summary><b>Q: How do I flush Valkey Redis cache directly?</b></summary>

**A:** Execute `valkey-cli` via Docker:
```bash
docker compose exec valkey valkey-cli -a "${VALKEY_PASSWORD}" flushall
```
</details>

---

## 🤝 Contributing
 
Contributions, feedback, and pull requests are welcome! Please review our [Contributing Guidelines](CONTRIBUTING.md) and [Code of Conduct](CODE_OF_CONDUCT.md) before getting started.

---

## 👨‍💻 Maintainer & Attribution

Created and maintained by **Matthias Kleinschmidt** ([@mk-73](https://github.com/mk-73)) for [**mk3media**](https://github.com/mk3media).

---

## 📄 License

This project is licensed under the **GNU General Public License v2.0** ([LICENSE](LICENSE)).
