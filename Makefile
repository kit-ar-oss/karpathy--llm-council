.DEFAULT_GOAL := help

SHELL := /bin/bash

COMPOSE ?= docker compose
COMPOSE_FILE ?= compose.yaml

ACR_LOGIN_SERVER ?= example.azurecr.io
ACR_REPO ?= example/llm-council
IMAGE_TAG ?= latest

BACKEND_IMAGE := $(ACR_LOGIN_SERVER)/$(ACR_REPO)/backend:$(IMAGE_TAG)
FRONTEND_IMAGE := $(ACR_LOGIN_SERVER)/$(ACR_REPO)/frontend:$(IMAGE_TAG)

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

push-acr: ## Build + push backend/frontend images to Azure ACR (set ACR_LOGIN_SERVER/ACR_REPO/IMAGE_TAG)
	@echo "Building images:"
	@echo "  $(BACKEND_IMAGE)"
	@echo "  $(FRONTEND_IMAGE)"
	@ACR_LOGIN_SERVER=$(ACR_LOGIN_SERVER) ACR_REPO=$(ACR_REPO) IMAGE_TAG=$(IMAGE_TAG) \
		$(COMPOSE) -f $(COMPOSE_FILE) build
	@docker push "$(BACKEND_IMAGE)"
	@docker push "$(FRONTEND_IMAGE)"
