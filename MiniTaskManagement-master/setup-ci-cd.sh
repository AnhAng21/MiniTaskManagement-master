#!/bin/bash
# Quick Setup Script for GitHub Actions + SonarQube

set -e

echo "🚀 Mini Task Management - CI/CD Setup Script"
echo "=============================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check prerequisites
echo -e "${BLUE}📋 Checking prerequisites...${NC}"

if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}⚠️  Docker not found. Please install Docker Desktop.${NC}"
    echo "   Download: https://www.docker.com/products/docker-desktop"
    exit 1
fi

if ! command -v git &> /dev/null; then
    echo -e "${YELLOW}⚠️  Git not found. Please install Git.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker found${NC}"
echo -e "${GREEN}✅ Git found${NC}"
echo ""

# Step 1: Start SonarQube
echo -e "${BLUE}1️⃣  Starting SonarQube Server...${NC}"
docker-compose -f docker-compose.sonarqube.yml up -d

echo -e "${YELLOW}⏳ Waiting for SonarQube to be ready (this may take 1-2 minutes)...${NC}"
sleep 30

# Check if SonarQube is ready
max_attempts=12
attempt=0
while [ $attempt -lt $max_attempts ]; do
    if curl -s http://localhost:9000/api/system/health | grep -q "UP"; then
        echo -e "${GREEN}✅ SonarQube is ready!${NC}"
        break
    fi
    echo "⏳ Still waiting... ($((attempt + 1))/$max_attempts)"
    sleep 10
    attempt=$((attempt + 1))
done

if [ $attempt -eq $max_attempts ]; then
    echo -e "${YELLOW}⚠️  SonarQube startup timeout. Check with: docker logs sonarqube-server${NC}"
fi

echo ""
echo -e "${GREEN}✅ SonarQube is running at http://localhost:9000${NC}"
echo ""

# Step 2: Create SonarQube Token
echo -e "${BLUE}2️⃣  Setting up SonarQube Token...${NC}"
echo -e "${YELLOW}Please follow these steps manually:${NC}"
echo "1. Go to http://localhost:9000"
echo "2. Login with: admin / admin"
echo "3. You'll be prompted to change the default password (do it)"
echo "4. Click Profile icon → My Account → Security"
echo "5. Under 'Generate Tokens' section, create a token named 'mini-task-management-ci'"
echo "6. Copy the token and save it"
echo ""
read -p "Press Enter once you've created the token and copied it: "

# Step 3: GitHub Setup (if using GitHub Actions)
echo ""
echo -e "${BLUE}3️⃣  GitHub Actions Setup${NC}"
read -p "Are you using GitHub Actions? (y/n) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Paste the SonarQube token you just created:${NC}"
    read -s SONAR_TOKEN
    echo ""
    
    if command -v gh &> /dev/null; then
        echo -e "${BLUE}Adding GitHub Secrets...${NC}"
        
        # Check if we're in a git repository
        if git rev-parse --git-dir > /dev/null 2>&1; then
            gh secret set SONAR_HOST_URL --body "http://localhost:9000" || echo "Could not set SONAR_HOST_URL"
            gh secret set SONAR_TOKEN --body "$SONAR_TOKEN" || echo "Could not set SONAR_TOKEN"
            
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✅ GitHub Secrets configured${NC}"
            else
                echo -e "${YELLOW}⚠️  Could not set secrets via GitHub CLI${NC}"
                echo "   Please set them manually in: Settings → Secrets and variables → Actions"
            fi
        else
            echo -e "${YELLOW}⚠️  Not in a Git repository${NC}"
            echo "   Please set secrets manually in: Settings → Secrets and variables → Actions"
        fi
    else
        echo -e "${YELLOW}⚠️  GitHub CLI not installed${NC}"
        echo "   Please set secrets manually in: Settings → Secrets and variables → Actions"
        echo "   Add:"
        echo "   - SONAR_HOST_URL = http://localhost:9000"
        echo "   - SONAR_TOKEN = (paste your token here)"
    fi
fi

echo ""

# Step 4: Install test dependencies
echo -e "${BLUE}4️⃣  Installing test dependencies...${NC}"

echo -e "${YELLOW}Backend dependencies (xUnit, Moq, etc.)${NC}"
cd MiniTaskManagement.Api

# Check if project file exists
if [ -f "MiniTaskManagement.Api.csproj" ]; then
    echo "   Installing .NET test packages..."
    dotnet add MiniTaskManagement.Api.csproj package xunit 2>/dev/null || echo "   ⚠️  Could not add xunit"
    dotnet add MiniTaskManagement.Api.csproj package Moq 2>/dev/null || echo "   ⚠️  Could not add Moq"
    dotnet add MiniTaskManagement.Api.csproj package FluentAssertions 2>/dev/null || echo "   ⚠️  Could not add FluentAssertions"
    echo -e "${GREEN}✅ Backend dependencies updated${NC}"
else
    echo -e "${YELLOW}⚠️  Could not find MiniTaskManagement.Api.csproj${NC}"
fi

cd ..

echo -e "${YELLOW}Frontend dependencies (Jest, React Testing Library, etc.)${NC}"
cd task-ui

if [ -f "package.json" ]; then
    echo "   Installing npm test packages..."
    npm install --save-dev jest @testing-library/react @testing-library/jest-dom @testing-library/user-event jest-environment-jsdom 2>/dev/null || echo "   ⚠️  Could not install npm packages"
    echo -e "${GREEN}✅ Frontend dependencies updated${NC}"
else
    echo -e "${YELLOW}⚠️  Could not find package.json${NC}"
fi

cd ..

echo ""

# Summary
echo "=============================================="
echo -e "${GREEN}✅ Setup Complete!${NC}"
echo "=============================================="
echo ""
echo "📊 Dashboard URLs:"
echo "   SonarQube: http://localhost:9000"
echo ""
echo "🧪 Next Steps:"
echo "   1. Write unit tests for your code"
echo "   2. Push to GitHub to trigger CI/CD pipeline"
echo "   3. Monitor: GitHub Actions → Workflows"
echo "   4. Review: SonarQube → Projects"
echo ""
echo "📚 Documentation:"
echo "   - Setup Guide: GITHUB_ACTIONS_SETUP.md"
echo "   - Testing Proposal: TESTING_PROPOSAL.md"
echo ""
echo "💾 Useful Commands:"
echo "   docker-compose -f docker-compose.sonarqube.yml logs sonarqube  # View logs"
echo "   docker-compose -f docker-compose.sonarqube.yml restart        # Restart"
echo "   docker-compose -f docker-compose.sonarqube.yml down           # Stop"
echo ""

