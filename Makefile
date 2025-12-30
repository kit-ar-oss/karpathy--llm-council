.DEFAULT_GOAL := help

SHELL := /bin/bash

COMPOSE ?= docker compose
COMPOSE_FILE ?= compose.yaml

.PHONY: help env build up down restart ps logs logs-backend logs-frontend clean push-acr

help: ## Show available commands
	@awk 'BEGIN {FS = ":.*##"; printf "Usage:\n  make <target>\n\nTargets:\n"} /^[a-zA-Z0-9_.-]+:.*##/ {printf "  %-18s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

env: ## Create .env if missing (no-op otherwise)
	@touch .env
	@echo "Ensured .env exists"

build: ## Build images
	@$(COMPOSE) -f $(COMPOSE_FILE) build

up: ## Start services (detached)
	@$(COMPOSE) -f $(COMPOSE_FILE) up -d --build

down: ## Stop services (keep volumes)
	@$(COMPOSE) -f $(COMPOSE_FILE) down

restart: ## Restart services
	@$(COMPOSE) -f $(COMPOSE_FILE) restart

ps: ## Show container status
	@$(COMPOSE) -f $(COMPOSE_FILE) ps

logs: ## Tail logs for all services
	@$(COMPOSE) -f $(COMPOSE_FILE) logs -f --tail=200

logs-backend: ## Tail backend logs
	@$(COMPOSE) -f $(COMPOSE_FILE) logs -f --tail=200 backend

logs-frontend: ## Tail frontend logs
	@$(COMPOSE) -f $(COMPOSE_FILE) logs -f --tail=200 frontend

clean: ## Stop services and remove volumes + orphans
	@$(COMPOSE) -f $(COMPOSE_FILE) down -v --remove-orphans

push-acr: ## Build + push images to ACR (uses the image tags in compose.yaml)
	@set -euo pipefail; \
	IMAGES="$$( $(COMPOSE) -f $(COMPOSE_FILE) config --images )"; \
	echo "Building images:"; \
	echo "$$IMAGES" | sed 's/^/  /'; \
	$(COMPOSE) -f $(COMPOSE_FILE) build; \
	echo "Pushing images:"; \
	for img in $$IMAGES; do echo "  $$img"; docker push "$$img"; done
