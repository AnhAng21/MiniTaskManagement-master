# Quick Setup Script for GitHub Actions + SonarQube (Windows)
# Run as Administrator

Write-Host "🚀 Mini Task Management - CI/CD Setup Script (Windows)" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""

# Function to check if command exists
function Test-CommandExists {
    param($command)
    $null = Get-Command $command -ErrorAction SilentlyContinue
    return $?
}

# Check prerequisites
Write-Host "📋 Checking prerequisites..." -ForegroundColor Cyan

if (-not (Test-CommandExists docker)) {
    Write-Host "⚠️  Docker not found. Please install Docker Desktop." -ForegroundColor Yellow
    Write-Host "   Download: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

if (-not (Test-CommandExists git)) {
    Write-Host "⚠️  Git not found. Please install Git for Windows." -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Docker found" -ForegroundColor Green
Write-Host "✅ Git found" -ForegroundColor Green
Write-Host ""

# Step 1: Start SonarQube
Write-Host "1️⃣  Starting SonarQube Server..." -ForegroundColor Cyan
docker-compose -f docker-compose.sonarqube.yml up -d

Write-Host "⏳ Waiting for SonarQube to be ready (this may take 1-2 minutes)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Check if SonarQube is ready
$maxAttempts = 12
$attempt = 0
while ($attempt -lt $maxAttempts) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:9000/api/system/health" -UseBasicParsing -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200 -and $response.Content -like "*UP*") {
            Write-Host "✅ SonarQube is ready!" -ForegroundColor Green
            break
        }
    }
    catch {
        # Ignore errors and retry
    }
    
    Write-Host "⏳ Still waiting... ($($attempt + 1)/$maxAttempts)" -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    $attempt++
}

if ($attempt -eq $maxAttempts) {
    Write-Host "⚠️  SonarQube startup timeout. Check with: docker logs sonarqube-server" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "✅ SonarQube is running at http://localhost:9000" -ForegroundColor Green
Write-Host ""

# Step 2: Create SonarQube Token
Write-Host "2️⃣  Setting up SonarQube Token..." -ForegroundColor Cyan
Write-Host "Please follow these steps manually:" -ForegroundColor Yellow
Write-Host "1. Go to http://localhost:9000"
Write-Host "2. Login with: admin / admin"
Write-Host "3. You'll be prompted to change the default password (do it)"
Write-Host "4. Click Profile icon → My Account → Security"
Write-Host "5. Under 'Generate Tokens' section, create a token named 'mini-task-management-ci'"
Write-Host "6. Copy the token and save it"
Write-Host ""
Read-Host "Press Enter once you've created the token and copied it"

# Step 3: GitHub Setup (if using GitHub Actions)
Write-Host ""
Write-Host "3️⃣  GitHub Actions Setup" -ForegroundColor Cyan
$useGitHub = Read-Host "Are you using GitHub Actions? (y/n)"

if ($useGitHub -eq 'y' -or $useGitHub -eq 'Y') {
    Write-Host "Paste the SonarQube token you just created:" -ForegroundColor Yellow
    $sonarToken = Read-Host -AsSecureString "Token"
    $sonarTokenPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($sonarToken))
    
    if (Test-CommandExists gh) {
        Write-Host "Adding GitHub Secrets..." -ForegroundColor Cyan
        
        # Check if we're in a git repository
        if (Test-Path .git) {
            gh secret set SONAR_HOST_URL --body "http://localhost:9000" 2>$null | Out-Null
            gh secret set SONAR_TOKEN --body "$sonarTokenPlain" 2>$null | Out-Null
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ GitHub Secrets configured" -ForegroundColor Green
            }
            else {
                Write-Host "⚠️  Could not set secrets via GitHub CLI" -ForegroundColor Yellow
                Write-Host "   Please set them manually in: Settings → Secrets and variables → Actions" -ForegroundColor Yellow
            }
        }
        else {
            Write-Host "⚠️  Not in a Git repository" -ForegroundColor Yellow
            Write-Host "   Please set secrets manually in: Settings → Secrets and variables → Actions" -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "⚠️  GitHub CLI not installed" -ForegroundColor Yellow
        Write-Host "   Please set secrets manually in: Settings → Secrets and variables → Actions" -ForegroundColor Yellow
        Write-Host "   Add:" -ForegroundColor Yellow
        Write-Host "   - SONAR_HOST_URL = http://localhost:9000" -ForegroundColor Yellow
        Write-Host "   - SONAR_TOKEN = (paste your token here)" -ForegroundColor Yellow
    }
}

Write-Host ""

# Step 4: Install test dependencies
Write-Host "4️⃣  Installing test dependencies..." -ForegroundColor Cyan

Write-Host "Backend dependencies (xUnit, Moq, etc.)" -ForegroundColor Yellow
Push-Location MiniTaskManagement.Api

if (Test-Path "MiniTaskManagement.Api.csproj") {
    Write-Host "   Installing .NET test packages..."
    dotnet add MiniTaskManagement.Api.csproj package xunit 2>$null | Out-Null
    dotnet add MiniTaskManagement.Api.csproj package Moq 2>$null | Out-Null
    dotnet add MiniTaskManagement.Api.csproj package FluentAssertions 2>$null | Out-Null
    Write-Host "✅ Backend dependencies updated" -ForegroundColor Green
}
else {
    Write-Host "⚠️  Could not find MiniTaskManagement.Api.csproj" -ForegroundColor Yellow
}

Pop-Location

Write-Host "Frontend dependencies (Jest, React Testing Library, etc.)" -ForegroundColor Yellow
Push-Location task-ui

if (Test-Path "package.json") {
    Write-Host "   Installing npm test packages..."
    npm install --save-dev jest "@testing-library/react" "@testing-library/jest-dom" "@testing-library/user-event" jest-environment-jsdom 2>$null | Out-Null
    Write-Host "✅ Frontend dependencies updated" -ForegroundColor Green
}
else {
    Write-Host "⚠️  Could not find package.json" -ForegroundColor Yellow
}

Pop-Location

Write-Host ""

# Summary
Write-Host "======================================================" -ForegroundColor Green
Write-Host "✅ Setup Complete!" -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Dashboard URLs:" -ForegroundColor Cyan
Write-Host "   SonarQube: http://localhost:9000" -ForegroundColor Green
Write-Host ""
Write-Host "🧪 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Write unit tests for your code" -ForegroundColor Green
Write-Host "   2. Push to GitHub to trigger CI/CD pipeline" -ForegroundColor Green
Write-Host "   3. Monitor: GitHub Actions → Workflows" -ForegroundColor Green
Write-Host "   4. Review: SonarQube → Projects" -ForegroundColor Green
Write-Host ""
Write-Host "📚 Documentation:" -ForegroundColor Cyan
Write-Host "   - Setup Guide: GITHUB_ACTIONS_SETUP.md" -ForegroundColor Green
Write-Host "   - Testing Proposal: TESTING_PROPOSAL.md" -ForegroundColor Green
Write-Host ""
Write-Host "💾 Useful Commands:" -ForegroundColor Cyan
Write-Host "   docker-compose -f docker-compose.sonarqube.yml logs sonarqube  # View logs" -ForegroundColor Green
Write-Host "   docker-compose -f docker-compose.sonarqube.yml restart        # Restart" -ForegroundColor Green
Write-Host "   docker-compose -f docker-compose.sonarqube.yml down           # Stop" -ForegroundColor Green
Write-Host ""
