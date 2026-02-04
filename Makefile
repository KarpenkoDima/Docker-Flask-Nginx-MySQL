.PHONY: up down build restart logs status clean help

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

up: ## Start all services
	docker compose up -d

down: ## Stop all services
	docker compose down

build: ## Build and start all services
	docker compose up -d --build

restart: ## Restart all services
	docker compose restart

logs: ## Show logs from all services
	docker compose logs -f

logs-flask: ## Show Flask logs
	docker compose logs -f flask

logs-nginx: ## Show Nginx logs
	docker compose logs -f nginx

logs-mysql: ## Show MySQL logs
	docker compose logs -f mysql

status: ## Show status of all services
	docker compose ps

shell-flask: ## Open shell in Flask container
	docker compose exec flask bash

shell-nginx: ## Open shell in Nginx container
	docker compose exec nginx sh

shell-mysql: ## Open MySQL CLI
	docker compose exec mysql mysql -u myuser -pmypassword myapp

test: ## Test API endpoints
	@echo "--- Health Check ---"
	@curl -s http://localhost:8080/health | python3 -m json.tool 2>/dev/null || echo "Service unavailable"
	@echo "\n--- Get Users ---"
	@curl -s http://localhost:8080/users | python3 -m json.tool 2>/dev/null || echo "Service unavailable"

clean: ## Stop services and remove volumes
	docker compose down -v
	docker system prune -f
