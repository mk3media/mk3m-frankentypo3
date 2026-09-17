.PHONY: help up down restart logs build ps cli typo3-setup cache-flush composer-install composer-update check-outdated

# Default shell
SHELL := /usr/bin/env bash

# Display help message by default
help:
	@echo "TYPO3 FrankenPHP & Valkey Management"
	@echo ""
	@echo "Usage:"
	@echo "  make up                Start all containers in background"
	@echo "  make down              Stop all containers"
	@echo "  make restart           Restart containers"
	@echo "  make logs              Follow container logs"
	@echo "  make build             Rebuild the FrankenPHP web image"
	@echo "  make ps                List running containers and health status"
	@echo "  make cli               Open interactive bash in the web container"
	@echo "  make typo3-setup       Run TYPO3 setup / console setup"
	@echo "  make cache-flush       Flush all TYPO3 and Valkey caches"
	@echo "  make composer-install  Run composer install in web container"
	@echo "  make composer-update   Run composer update in web container"
	@echo "  make check-outdated    Check for outdated dependencies"
	@echo ""

up:
	docker compose up -d

down:
	docker compose down

restart:
	docker compose restart

logs:
	docker compose logs -f

build:
	docker compose build --no-cache web

ps:
	docker compose ps

cli:
	docker compose exec web bash

typo3-setup:
	docker compose exec web ./vendor/bin/typo3 setup

cache-flush:
	docker compose exec web ./vendor/bin/typo3 cache:flush

composer-install:
	docker compose exec web composer install

composer-update:
	docker compose exec web composer update

check-outdated:
	docker compose exec web composer outdated -D
