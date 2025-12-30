.DEFAULT_GOAL := help

SHELL := /bin/bash

COMPOSE ?= docker compose
COMPOSE_FILES_BASE := -f compose.yaml
# Auto-include Cloudflare tunnel compose file only when token env file exists.
# This keeps common local commands working without requiring tunnel config.
COMPOSE_FILES := $(COMPOSE_FILES_BASE) $(if $(wildcard .env.cf-tunnel.vars),-f compose.cf-tunnel.yaml,)

.PHONY: help env build up down restart ps logs logs-backend logs-frontend clean push-images

help: ## Show available commands
	@awk 'BEGIN {FS = ":.*##"; printf "Usage:\n  make <target>\n\nTargets:\n"} /^[a-zA-Z0-9_.-]+:.*##/ {printf "  %-18s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

env: ## Create .env if missing (no-op otherwise)
	@touch .env
	@echo "Ensured .env exists"

build: ## Build images
	@$(COMPOSE) $(COMPOSE_FILES) build

up: ## Start services (detached)
	@$(COMPOSE) $(COMPOSE_FILES) up -d --build

down: ## Stop services (keep volumes)
	@$(COMPOSE) $(COMPOSE_FILES) down

restart: ## Restart services
	@$(COMPOSE) $(COMPOSE_FILES) restart

ps: ## Show container status
	@$(COMPOSE) $(COMPOSE_FILES) ps

logs: ## Tail logs for all services
	@$(COMPOSE) $(COMPOSE_FILES) logs -f --tail=200

logs-backend: ## Tail backend logs
	@$(COMPOSE) $(COMPOSE_FILES) logs -f --tail=200 backend

logs-frontend: ## Tail frontend logs
	@$(COMPOSE) $(COMPOSE_FILES) logs -f --tail=200 frontend

clean: ## Stop services and remove volumes + orphans
	@$(COMPOSE) $(COMPOSE_FILES) down -v --remove-orphans

push-images: ## Build + push images (uses image tags in compose.yaml)
	@set -euo pipefail; \
	IMAGES="$$( $(COMPOSE) $(COMPOSE_FILES_BASE) config --images )"; \
	echo "Building images:"; \
	echo "$$IMAGES" | sed 's/^/  /'; \
	$(COMPOSE) $(COMPOSE_FILES_BASE) build; \
	echo "Pushing images:"; \
	for img in $$IMAGES; do echo "  $$img"; docker push "$$img"; done
