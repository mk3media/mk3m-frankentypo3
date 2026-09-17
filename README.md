# Modern TYPO3 on FrankenPHP (Caddy + PHP 8.4) & Valkey

[![TYPO3 v13 / v14](https://img.shields.io/badge/TYPO3-v13%20%7C%20v14-orange.svg?logo=typo3)](https://typo3.org/)
[![PHP 8.4](https://img.shields.io/badge/PHP-8.4-777bb4.svg?logo=php)](https://www.php.net/)
[![FrankenPHP](https://img.shields.io/badge/FrankenPHP-1.12-blue.svg)](https://frankenphp.dev/)
[![Caddy Server](https://img.shields.io/badge/Web_Server-Caddy_v2-22b8cf.svg?logo=caddy)](https://caddyserver.com/)
[![Valkey 7 / 8](https://img.shields.io/badge/Cache-Valkey-red.svg)](https://valkey.io/)
[![License: GPL-2.0](https://img.shields.io/badge/License-GPL--2.0-blue.svg)](LICENSE)

A battle-tested, high-performance Docker setup for running **TYPO3 v13+ / v14** with **FrankenPHP (PHP 8.4 + embedded Caddy)**, **Valkey** (Redis-compatible in-memory caching), and **MariaDB LTS**.

---

## ⚡ Why FrankenPHP for TYPO3?

FrankenPHP is a modern application server for PHP written in Go, built on top of the Caddy web server.

- **Unified Single Binary Architecture**: Eliminates the overhead of managing separate Nginx/Apache reverse proxies and PHP-FPM daemons.
- **Native HTTP/2 & HTTP/3 Support**: Modern transport layer out-of-the-box with automatic gzip and Zstandard compression.
- **Production Hardened**: Pre-configured security headers, strict file execution blocking in upload folders, and CSP policies tailored for TYPO3.
- **Ultra-Fast Redis Caching via Valkey**: Native multi-database Redis backend caching for pages, page sections, hashes, and rootlines.

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
    │ │ Caddy Web Server (Static files, CSP, Security headers)            │ │
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
                 │  - pages              │       │  - secure root/user   │
                 │  - pagesection        │       │  - local-infile=0     │
                 │  - hash & rootline    │       └───────────────────────┘
                 └───────────────────────┘
```

---

## 📦 Stack Components

| Service | Image / Tool | Role |
| :--- | :--- | :--- |
| **web** | `dunglas/frankenphp:1.12-php8.4` | Application runtime, embedded Caddy web server, Composer |
| **db** | `mariadb:lts` | Persistent database with utf8mb4 / utf8mb4_unicode_ci |
| **valkey** | `valkey/valkey:7-alpine` | High-speed in-memory caching for TYPO3 Core cache layers |

---

## 🚀 Quickstart

### 1. Clone & Initialize Configuration

```bash
git clone https://github.com/your-username/typo3-frankenphp-template.git my-typo3-project
cd my-typo3-project

cp .env.example .env
```

Adjust your passwords and settings in `.env` as needed:
```ini
COMPOSE_PROJECT_NAME=my-typo3
HTTP_PORT=8080
MARIADB_ROOT_PASSWORD=your_secure_root_password
MARIADB_PASSWORD=your_secure_db_password
VALKEY_PASSWORD=your_secure_valkey_password
```

### 2. Prepare Composer Project

If starting a new project, copy the template `composer.json.example`:
```bash
mkdir -p data/web/config/system
cp composer.json.example data/web/composer.json
cp config/system/additional.php data/web/config/system/additional.php
```

### 3. Start Containers

```bash
# Using Makefile
make up

# Or directly with Docker Compose
docker compose up -d
```

### 4. Install Dependencies & Complete TYPO3 Setup

```bash
# Install PHP dependencies
make composer-install

# Run TYPO3 setup CLI
make typo3-setup
```

Open your browser at `http://localhost:8080` (or `http://localhost:8080/typo3`).

---

## ⚙️ Configuration Details

### Embedded Caddy Server (`frankenphp/Caddyfile`)
The Caddyfile contains battle-tested rules tailored for TYPO3:
- **Root directory**: Points to `/var/www/html/public`.
- **Static routing**: Serves `/fileadmin/*` and `/typo3temp/*` as static assets without executing PHP scripts.
- **Security hardening**:
  - `403 Forbidden` on direct execution of PHP files in uploads (`/fileadmin/*.php`, `/typo3temp/*.php`).
  - `403 Forbidden` on hidden files (`.*`), `composer.json`, `composer.lock`, and `*.env`.
  - Header `Content-Type: text/plain` for `.wrong` test files to satisfy the TYPO3 security audit.
  - Content Security Policy (CSP) isolating user asset folders.

### Valkey / Redis Integration (`config/system/additional.php`)
TYPO3 automatically routes core caches to Valkey using `\TYPO3\CMS\Core\Cache\Backend\RedisBackend`:
- `pages` -> Database 0
- `pagesection` -> Database 1
- `hash` -> Database 2
- `rootline` -> Database 3

### Reverse Proxy & Trusted Hosts
When running behind a host reverse proxy (Caddy, Traefik, Cloudflare, etc.):
- `reverseProxySSL = '*'`
- `reverseProxyIP = '*'`
- `reverseProxyHeaderMultiValue = 'first'`
- `trustedHostsPattern`: Configured via the `TRUSTED_HOSTS_PATTERN` environment variable.

---

## 🛠️ Common Makefile Commands

| Command | Description |
| :--- | :--- |
| `make up` | Start all services in the background |
| `make down` | Stop all services |
| `make restart` | Restart services |
| `make logs` | Follow live container logs |
| `make build` | Rebuild the FrankenPHP web container |
| `make ps` | Check container health status |
| `make cli` | Open an interactive Bash shell in the web container |
| `make cache-flush` | Flush all TYPO3 and Valkey caches |
| `make composer-install` | Execute `composer install` inside container |
| `make composer-update` | Execute `composer update` inside container |
| `make check-outdated` | Inspect outdated Composer packages |

---

## 🔒 Security Recommendations for Production

1. **Host Storage Permissions**:
   ```bash
   chmod 700 /path/to/data/mysql /path/to/data/valkey
   ```
2. **Container Isolation**:
   All services run with `security_opt: ["no-new-privileges:true"]`.
3. **Database Security**:
   MariaDB enforces `--local-infile=0` to eliminate client file upload injection vectors.
4. **Valkey Authentication**:
   Authentication is required via `--requirepass "${VALKEY_PASSWORD}"`.

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to open an issue or pull request.

---

## 📄 License

This project is licensed under the terms of the **GNU General Public License v2.0** ([LICENSE](LICENSE)).
