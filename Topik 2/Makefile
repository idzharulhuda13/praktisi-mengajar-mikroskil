.PHONY: help setup up down db-sync notebook test clean

help: ## Show this help message
	@echo "Demo 2: Gemini API + MySQL Analysis"
	@echo "====================================="
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Quick start:"
	@echo "  make setup       # Install uv, create venv, install deps"
	@echo "  make up          # Start MySQL container"
	@echo "  make notebook    # Launch Jupyter notebook"

setup: ## Install uv, create venv, install dependencies
	@command -v uv >/dev/null 2>&1 || { echo "Installing uv..."; curl -LsSf https://astral.sh/uv/install.sh | sh; }
	@if [ ! -d .venv ]; then echo "Creating virtual environment..."; uv venv; fi
	@echo "Installing dependencies..."
	@uv sync
	@echo "Setup complete!"

up: ## Start MySQL container (Docker)
	@docker compose up -d
	@echo "Waiting for MySQL to be ready..."
	@sleep 5
	@echo "MySQL is running on port 3306"

down: ## Stop and remove MySQL container
	@docker compose down
	@echo "MySQL container stopped"

db-sync: ## Re-create MySQL container with fresh data (runs init_mysql.sql)
	@docker compose down -v
	@docker compose up -d
	@sleep 5
	@echo "Fresh database created!"

notebook: ## Launch Jupyter notebook
	@uv run jupyter lab gemini_mysql_demo.ipynb

test: ## Quick test: check MySQL connection and imports
	@uv run python -c "import mysql.connector; print('mysql-connector: OK')"
	@uv run python -c "from google import genai; print('google-genai: OK')"
	@docker compose ps --format '{{.Name}}' | grep -q mikroskil-mysql-topik2 && echo "MySQL container: OK" || echo "MySQL container: NOT RUNNING (run 'make up')"

clean: ## Remove .venv, stop containers, clean cache
	@docker compose down -v 2>/dev/null || true
	@rm -rf .venv __pycache__
	@echo "Cleaned up"
