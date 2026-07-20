# GitHub Actions + SonarQube Setup Guide

## 📋 Tổng Quan

Hệ thống CI/CD này tự động kiểm thử, phân tích chất lượng mã, và quét bảo mật cho mỗi pull request và push.

### Pipeline Flow
```
Code Push/PR
    ↓
[Parallel Jobs]
├── Backend Build & Test (.NET)
├── Frontend Build & Test (Next.js)
└── Security Scanning (npm audit + dotnet audit)
    ↓
SonarQube Code Quality Analysis
    ↓
Quality Gate Check
    ↓
Docker Build (optional, main branch only)
```

---

## 🚀 Setup Local SonarQube

### 1. **Chạy SonarQube với Docker**

```bash
# Từ thư mục project root
docker-compose -f docker-compose.sonarqube.yml up -d
```

**Chờ SonarQube khởi động (~1 phút)**
```bash
# Kiểm tra trạng thái
docker-compose -f docker-compose.sonarqube.yml logs sonarqube | tail -20
```

### 2. **Truy cập SonarQube Dashboard**
- URL: http://localhost:9000
- Username: `admin`
- Password: `admin` (sẽ được yêu cầu đổi lần đầu)

### 3. **Tạo Project Token**

```bash
# Login -> My Account -> Security -> Generate Token
# Token name: mini-task-management-ci
# Scope: Analyze scope
# Copy token, sẽ dùng trong GitHub Secrets
```

---

## 🔐 GitHub Secrets Configuration

### 1. **Đăng nhập GitHub & Truy cập Settings**
```
Repository → Settings → Secrets and variables → Actions
```

### 2. **Thêm Secrets**

| Secret Name | Value | Mô Tả |
|-------------|-------|-------|
| `SONAR_HOST_URL` | `http://localhost:9000` (local) hoặc `https://sonarcloud.io` (cloud) | SonarQube server URL |
| `SONAR_TOKEN` | Token từ bước 3 trên | Authentication token |
| `DOCKER_USERNAME` | Docker Hub username | (Optional, nếu push to Docker Hub) |
| `DOCKER_PASSWORD` | Docker Hub password | (Optional) |

**Ví dụ thêm secret bằng GitHub CLI:**
```bash
gh secret set SONAR_HOST_URL --body "http://localhost:9000"
gh secret set SONAR_TOKEN --body "your_token_here"
```

---

## 💻 Local Testing CI/CD

### 1. **Test Backend Locally**
```bash
cd MiniTaskManagement.Api

# Setup test environment
dotnet add MiniTaskManagement.Api.csproj package xunit
dotnet add MiniTaskManagement.Api.csproj package Moq
dotnet add MiniTaskManagement.Api.csproj package FluentAssertions

# Build
dotnet build --configuration Release

# Run tests with coverage
dotnet test \
  --configuration Release \
  /p:CollectCoverage=true \
  /p:CoverageFormat=opencover
```

### 2. **Test Frontend Locally**
```bash
cd task-ui

# Install dependencies
npm ci

# Run lint
npm run lint

# Setup and run tests
npm install --save-dev jest @testing-library/react @testing-library/jest-dom
npm test -- --coverage --watchAll=false

# Build
npm run build
```

### 3. **Run SonarQube Scan Locally**
```bash
# Install SonarScanner
# Windows
choco install sonarscanner-msbuild-net46

# macOS/Linux
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip
unzip sonar-scanner-cli-5.0.1.3006-linux.zip
export PATH=$PATH:/path/to/sonar-scanner-5.0.1.3006-linux/bin

# Begin SonarQube scan
sonar-scanner \
  -Dsonar.projectKey=mini-task-management \
  -Dsonar.sources=MiniTaskManagement.Api,task-ui \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=your_token_here
```

---

## 📊 Workflow Details

### **Job 1: Backend Build & Test**
```yaml
- Chạy PostgreSQL test container
- Restore .NET dependencies
- Build solution
- Run xUnit tests with coverage
- Upload test results & coverage
```

**Kết quả:**
- Test results → `.trx` files
- Coverage → `coverage.xml`

### **Job 2: Frontend Build & Test**
```yaml
- Install Node.js dependencies
- Run ESLint linting
- Run Jest tests with coverage
- Build Next.js application
- Upload coverage report
```

**Kết quả:**
- Coverage → `coverage/lcov.info`
- Build artifacts → `.next/`

### **Job 3: Security Scanning**
```yaml
- dotnet audit (NuGet packages)
- npm audit (npm packages)
- Trivy filesystem scan
- Upload SARIF results to GitHub Security
```

**Kết quả:**
- CVE reports in GitHub Security tab

### **Job 4: SonarQube Analysis**
```yaml
- Merge coverage reports từ backend & frontend
- Run SonarQube scanner
- Check Quality Gate
```

**Kết quả:**
- Code quality metrics
- Quality gate pass/fail
- Security hotspots
- Code smells & bugs

---

## 📈 Quality Gate Rules

Default SonarQube Quality Gates:
- ✅ Code Coverage ≥ 80%
- ✅ Duplicated Lines ≤ 3%
- ✅ Maintainability Rating ≥ A
- ✅ Security Hotspots Reviewed = 100%
- ✅ No Critical/Blocker Issues

**Customize trong SonarQube:**
```
Administration → Quality Gates → Modify
```

---

## 🐛 Troubleshooting

### **GitHub Actions Fails with "SonarQube Token not found"**
```bash
# Kiểm tra secrets được set đúng
gh secret list

# Thêm lại
gh secret set SONAR_TOKEN --body "$(cat sonar.token)"
```

### **SonarQube Not Reachable**
```bash
# Kiểm tra container đang chạy
docker ps | grep sonarqube

# View logs
docker-compose -f docker-compose.sonarqube.yml logs sonarqube

# Restart
docker-compose -f docker-compose.sonarqube.yml restart
```

### **Test Coverage Not Showing**
```bash
# Kiểm tra coverage file được generate
ls -la coverage.xml
ls -la task-ui/coverage/lcov.info

# Verify file path trong GitHub Actions
```

### **.NET Tests Not Running**
```bash
# Kiểm tra connection string
echo $ConnectionStrings__DefaultConnection

# Manual test run
dotnet test MiniTaskManagement.Api \
  --logger "console;verbosity=detailed" \
  --verbosity detailed
```

---

## 🔄 Continuous Improvement

### **1. Setup Code Coverage Badges**

Add to README.md:
```markdown
[![Code Coverage](https://img.shields.io/sonarcloud/coverage/mini-task-management?server=https%3A%2F%2Fsonarcloud.io)](https://sonarcloud.io/dashboard?id=mini-task-management)
[![Quality Gate](https://sonarcloud.io/api/project_badges/quality_gate?project=mini-task-management&server=https%3A%2F%2Fsonarcloud.io)](https://sonarcloud.io/dashboard?id=mini-task-management)
```

### **2. Setup Branch Protection**

```
Repository → Settings → Branches → Add rule
├── Require status checks to pass
│   ├── backend-build
│   ├── frontend-build
│   ├── security
│   └── sonarqube
└── Require code reviews before merging
```

### **3. Setup Notifications**

```
Repository → Settings → Notifications
└── Send notifications on CI failures
```

---

## 🌐 Using SonarCloud (Cloud Version)

### **1. Signup**
- Go to https://sonarcloud.io
- Login with GitHub
- Import repository

### **2. Generate Token**
```
My Account → Security → Generate Token
```

### **3. Update GitHub Secrets**
```bash
gh secret set SONAR_HOST_URL --body "https://sonarcloud.io"
gh secret set SONAR_TOKEN --body "your_cloud_token"
```

### **Advantages:**
- ✅ No server maintenance
- ✅ Free for public repos
- ✅ Better integrations
- ✅ Automatic updates

---

## 📚 Additional Resources

### GitHub Actions
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)

### SonarQube
- [SonarQube Documentation](https://docs.sonarqube.org/)
- [Quality Gates](https://docs.sonarqube.org/latest/user-guide/quality-gates/)
- [SonarCloud](https://sonarcloud.io)

### Testing Tools
- [xUnit.net](https://xunit.net/)
- [Moq](https://github.com/moq/moq4)
- [Jest](https://jestjs.io/)
- [React Testing Library](https://testing-library.com/react)

---

## ✅ Next Steps

1. [ ] Clone repository locally
2. [ ] Install Docker
3. [ ] Run `docker-compose -f docker-compose.sonarqube.yml up -d`
4. [ ] Access http://localhost:9000 and create token
5. [ ] Add GitHub Secrets
6. [ ] Push to main/develop branch to trigger workflow
7. [ ] Monitor workflow execution in GitHub Actions
8. [ ] Review SonarQube dashboard and quality metrics

---

## 📞 Support

For issues:
1. Check GitHub Actions logs: `Actions → Workflow → Job → Logs`
2. Check SonarQube analysis: http://localhost:9000 → Project
3. Check security scan results: `Security → Code scanning alerts`

