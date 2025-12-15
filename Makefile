# =============================================
# Financial Transaction System - Makefile
# =============================================

.PHONY: help dev down logs clean test bootstrap db-shell

# Default target
help:
	@echo "Available commands:"
	@echo "  make dev        - Start all services"
	@echo "  make down       - Stop all services"
	@echo "  make logs       - View all logs"
	@echo "  make clean      - Remove all containers and volumes"
	@echo "  make bootstrap  - Initialize LocalStack resources"
	@echo "  make db-shell   - Open PostgreSQL shell"
	@echo "  make test       - Run tests"

# Start development environment
dev:
	@echo "🚀 Starting development environment..."
	docker compose up -d
	@echo "⏳ Waiting for services to be healthy..."
	@sleep 10
	@make bootstrap
	@echo "✅ Environment ready!"
	@echo ""
	@echo "Services:"
	@echo "  PostgreSQL: localhost:5432"
	@echo "  Redis:      localhost:6379"
	@echo "  LocalStack: localhost:4566"

# Stop all services
down:
	@echo "🛑 Stopping services..."
	docker compose down

# View logs
logs:
	docker compose logs -f

# Clean everything
clean:
	@echo "🧹 Cleaning up..."
	docker compose down -v --remove-orphans
	docker system prune -f

# Bootstrap LocalStack
bootstrap:
	@echo "🔧 Bootstrapping LocalStack..."
	docker compose exec -T localstack bash /etc/localstack/init/ready.d/bootstrap-localstack.sh

# Database shell
db-shell:
	docker compose exec postgres psql -U postgres -d transactions

# Run tests
test:
	@echo "🧪 Running tests..."
	@echo "Tests not yet implemented"

# Check service status
status:
	@echo "📊 Service Status:"
	@docker compose ps
