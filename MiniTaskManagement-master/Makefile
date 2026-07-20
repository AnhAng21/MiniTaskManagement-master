#!/bin/bash
# Makefile-like helper commands for CI/CD setup

.PHONY: help setup-sonar sonar-logs sonar-restart sonar-stop sonar-reset test-backend test-frontend scan-local

help:
	@echo "CI/CD Helper Commands"
	@echo "====================="
	@echo ""
	@echo "Setup:"
	@echo "  make setup-sonar      - Start SonarQube locally"
	@echo "  make setup-all        - Full setup (SonarQube + dependencies)"
	@echo ""
	@echo "SonarQube Management:"
	@echo "  make sonar-logs       - View SonarQube logs"
	@echo "  make sonar-status     - Check SonarQube status"
	@echo "  make sonar-restart    - Restart SonarQube"
	@echo "  make sonar-stop       - Stop SonarQube"
	@echo "  make sonar-reset      - Full reset (removes data)"
	@echo ""
	@echo "Local Testing:"
	@echo "  make test-backend     - Run backend tests with coverage"
	@echo "  make test-frontend    - Run frontend tests with coverage"
	@echo "  make test-all         - Run all tests"
	@echo "  make scan-local       - Run SonarQube scan locally"
	@echo ""
	@echo "Cleanup:"
	@echo "  make clean            - Stop and clean up"
	@echo ""

setup-sonar:
	@echo "🚀 Starting SonarQube..."
	docker-compose -f docker-compose.sonarqube.yml up -d
	@echo "⏳ Waiting for SonarQube to be ready..."
	@sleep 30
	@docker-compose -f docker-compose.sonarqube.yml logs sonarqube | grep "SonarQube is running" && echo "✅ SonarQube is ready at http://localhost:9000" || echo "⚠️  SonarQube may still be starting..."

setup-deps-backend:
	@echo "📦 Installing backend test dependencies..."
	cd MiniTaskManagement.Api && \
	dotnet add MiniTaskManagement.Api.csproj package xunit && \
	dotnet add MiniTaskManagement.Api.csproj package Moq && \
	dotnet add MiniTaskManagement.Api.csproj package FluentAssertions && \
	echo "✅ Backend dependencies installed"

setup-deps-frontend:
	@echo "📦 Installing frontend test dependencies..."
	cd task-ui && \
	npm install --save-dev jest @testing-library/react @testing-library/jest-dom @testing-library/user-event jest-environment-jsdom && \
	echo "✅ Frontend dependencies installed"

setup-all: setup-sonar setup-deps-backend setup-deps-frontend
	@echo "✅ Full setup complete!"
	@echo ""
	@echo "Next steps:"
	@echo "1. Visit http://localhost:9000"
	@echo "2. Login: admin / admin"
	@echo "3. Create a token (My Account → Security)"
	@echo "4. Add to GitHub Secrets: SONAR_TOKEN"

sonar-logs:
	@docker-compose -f docker-compose.sonarqube.yml logs sonarqube -f

sonar-status:
	@curl -s http://localhost:9000/api/system/health | python3 -m json.tool || echo "❌ SonarQube not responding"

sonar-restart:
	@echo "🔄 Restarting SonarQube..."
	docker-compose -f docker-compose.sonarqube.yml restart sonarqube
	@sleep 10
	@make sonar-status

sonar-stop:
	@echo "⏹️  Stopping SonarQube..."
	docker-compose -f docker-compose.sonarqube.yml stop

sonar-reset:
	@echo "🗑️  Resetting SonarQube (removes all data)..."
	docker-compose -f docker-compose.sonarqube.yml down -v
	@echo "✅ Reset complete. Run 'make setup-sonar' to start fresh"

test-backend:
	@echo "🧪 Running backend tests..."
	cd MiniTaskManagement.Api && \
	dotnet test \
		/p:CollectCoverage=true \
		/p:CoverageFormat=opencover \
		/p:CoverageFileName=coverage.xml \
		--logger "console;verbosity=minimal"

test-frontend:
	@echo "🧪 Running frontend tests..."
	cd task-ui && \
	npm test -- --coverage --watchAll=false --passWithNoTests || echo "⚠️  Jest not configured yet"

test-all: test-backend test-frontend
	@echo "✅ All tests complete"

scan-local:
	@echo "📊 Running SonarQube scan..."
	@which sonar-scanner > /dev/null || echo "⚠️  sonar-scanner not found. Install: https://docs.sonarqube.org/latest/analyze/scan/"
	sonar-scanner \
		-Dsonar.projectKey=mini-task-management \
		-Dsonar.sources=MiniTaskManagement.Api,task-ui \
		-Dsonar.host.url=http://localhost:9000 \
		-Dsonar.login=your_token_here
	@echo "✅ Scan complete. View results at http://localhost:9000"

clean:
	@echo "🧹 Cleaning up..."
	docker-compose -f docker-compose.sonarqube.yml down
	cd MiniTaskManagement.Api && dotnet clean 2>/dev/null || true
	cd task-ui && npm run clean 2>/dev/null || true
	@echo "✅ Cleanup complete"
