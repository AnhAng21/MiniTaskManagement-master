# 📋 GitHub Actions + SonarQube Implementation Checklist

## 🎯 Pre-Implementation

### Prerequisites
- [ ] Docker Desktop installed
- [ ] Git installed and configured
- [ ] GitHub account with repository access
- [ ] GitHub CLI installed (optional but recommended)
- [ ] .NET 10 SDK installed
- [ ] Node.js 20+ installed

### Repository Setup
- [ ] Clone repository locally
- [ ] Verify project structure:
  - [ ] `MiniTaskManagement.Api/MiniTaskManagement.Api.csproj` exists
  - [ ] `task-ui/package.json` exists
  - [ ] `.gitignore` configured properly

---

## 🚀 Setup Phase (Day 1)

### Local SonarQube Setup
- [ ] Run setup script: `bash setup-ci-cd.sh` (or `.ps1` for Windows)
  - OR manually: `docker-compose -f docker-compose.sonarqube.yml up -d`
- [ ] Wait 2-3 minutes for SonarQube to fully start
- [ ] Verify: `curl http://localhost:9000/api/system/health`
- [ ] Access dashboard: http://localhost:9000
- [ ] Login with: admin / admin
- [ ] Change admin password (if prompted)

### Create SonarQube Token
- [ ] Navigate to: My Account → Security
- [ ] Click "Generate Token"
- [ ] Name: `mini-task-management-ci`
- [ ] Scope: Analyze scope
- [ ] Copy token to clipboard
- [ ] Save token in secure location (password manager)

### GitHub Secrets Configuration
- [ ] Verify you're in the GitHub repository
- [ ] Go to: Settings → Secrets and variables → Actions
- [ ] Click "New repository secret"
- [ ] Add Secret #1:
  - [ ] Name: `SONAR_HOST_URL`
  - [ ] Value: `http://localhost:9000`
- [ ] Add Secret #2:
  - [ ] Name: `SONAR_TOKEN`
  - [ ] Value: (paste token from SonarQube)
- [ ] Verify secrets are listed (token should be masked)

---

## 🔧 Configuration Phase (Day 1-2)

### Workflow Files
- [ ] `.github/workflows/ci.yml` created ✅
- [ ] `sonar-project.properties` created ✅
- [ ] `docker-compose.sonarqube.yml` created ✅
- [ ] All files committed to repository

### Setup Scripts
- [ ] `setup-ci-cd.sh` executable for Linux/macOS:
  ```bash
  chmod +x setup-ci-cd.sh
  ```
- [ ] `setup-ci-cd.ps1` ready for Windows PowerShell
- [ ] `Makefile` with helper commands available

### Documentation
- [ ] `GITHUB_ACTIONS_SETUP.md` - Read and understood ✅
- [ ] `CI_CD_IMPLEMENTATION.md` - Reviewed ✅
- [ ] `QUICKSTART.md` - Bookmarked ✅
- [ ] `TESTING_PROPOSAL.md` - Reference kept ✅

---

## 🧪 Testing Phase (Day 2-3)

### Backend Test Setup
- [ ] Navigate to: `MiniTaskManagement.Api/`
- [ ] Install xUnit: `dotnet add MiniTaskManagement.Api.csproj package xunit`
- [ ] Install Moq: `dotnet add MiniTaskManagement.Api.csproj package Moq`
- [ ] Install FluentAssertions: `dotnet add MiniTaskManagement.Api.csproj package FluentAssertions`
- [ ] Install Microsoft.NET.Test.Sdk: `dotnet add MiniTaskManagement.Api.csproj package Microsoft.NET.Test.Sdk`
- [ ] Verify build: `dotnet build --configuration Release`
- [ ] Test locally: `dotnet test /p:CollectCoverage=true`

### Frontend Test Setup
- [ ] Navigate to: `task-ui/`
- [ ] Install Jest: `npm install --save-dev jest`
- [ ] Install React Testing Library: `npm install --save-dev @testing-library/react`
- [ ] Install testing utilities:
  ```bash
  npm install --save-dev @testing-library/jest-dom @testing-library/user-event jest-environment-jsdom
  ```
- [ ] Verify build: `npm run build`
- [ ] Test locally: `npm test -- --watchAll=false` (if tests exist)

---

## 🚀 Deployment Phase (Day 3-4)

### First Workflow Trigger
- [ ] Create feature branch: `git checkout -b feature/ci-cd-setup`
- [ ] Make a small change (e.g., update README)
- [ ] Commit: `git commit -m "Setup CI/CD pipeline"`
- [ ] Push: `git push origin feature/ci-cd-setup`
- [ ] Go to: Repository → Actions
- [ ] Watch workflow run in real-time
- [ ] Wait for all jobs to complete

### Workflow Verification
- [ ] ✅ Backend build job completed
- [ ] ✅ Frontend build job completed  
- [ ] ✅ Security scan job completed
- [ ] ✅ SonarQube analysis job completed
- [ ] ✅ Summary job completed
- [ ] ✅ No job failures

### Coverage Report Review
- [ ] Backend coverage generated
- [ ] Frontend coverage generated (if tests exist)
- [ ] Coverage reports uploaded as artifacts
- [ ] Download and review locally

### SonarQube Results Review
- [ ] Visit: http://localhost:9000
- [ ] Verify project appears in dashboard
- [ ] Check code coverage metrics
- [ ] Review any identified issues
- [ ] Verify Quality Gate status

---

## 🔒 Security Phase (Day 4)

### Security Scanning
- [ ] npm audit results visible in GitHub Actions
- [ ] dotnet audit results visible in GitHub Actions
- [ ] Trivy scan results uploaded to GitHub Security tab
- [ ] No Critical/High severity CVEs (or plan to fix)
- [ ] Review Security → Code scanning alerts

### Dependency Management
- [ ] Understand vulnerable dependencies (if any)
- [ ] Plan fixes for high-severity CVEs
- [ ] Document any accepted risks

---

## 📊 Optimization Phase (Day 5+)

### Branch Protection Rules
- [ ] Go to: Settings → Branches
- [ ] Create rule for: `main`
- [ ] [ ] Require status checks to pass:
  - [ ] backend-build
  - [ ] frontend-build
  - [ ] security
  - [ ] sonarqube
- [ ] [ ] Require code reviews before merge (optional)
- [ ] [ ] Require branches to be up to date before merge
- [ ] Test protection by attempting to merge unvalidated PR

### PR Integration
- [ ] Create a test PR
- [ ] Verify status checks run automatically
- [ ] Verify checks block merge if they fail
- [ ] Verify comments/badges on PR (if configured)
- [ ] Merge PR to trigger workflow on main

### CI/CD Monitoring Setup
- [ ] Subscribe to GitHub Actions notifications
- [ ] Setup Slack/Teams webhook (optional)
- [ ] Configure email notifications (optional)
- [ ] Document runbook for failed workflows

---

## 📈 Testing & Coverage Phase (Week 2+)

### Unit Testing
- [ ] Create test project: `MiniTaskManagement.Tests`
- [ ] Write tests for critical services
- [ ] Achieve 70%+ code coverage target
- [ ] All tests passing in CI/CD

### Integration Testing
- [ ] Setup test database (PostgreSQL container)
- [ ] Write integration tests for data flows
- [ ] Test authentication flow
- [ ] Test core business logic

### E2E Testing (Optional)
- [ ] Setup Cypress or Playwright
- [ ] Write end-to-end test scenarios
- [ ] Add to CI/CD pipeline

---

## 🎓 Team Documentation (Day 6+)

### Knowledge Sharing
- [ ] Hold team briefing on CI/CD setup
- [ ] Explain workflow triggers and stages
- [ ] Demonstrate GitHub Actions dashboard
- [ ] Show SonarQube quality metrics
- [ ] Document common issues and solutions

### Best Practices
- [ ] Document commit message conventions
- [ ] Create contribution guidelines
- [ ] Setup PR template with CI/CD checklist
- [ ] Add status badges to README

### Troubleshooting Guide
- [ ] Document common workflow failures
- [ ] Create runbook for debugging
- [ ] Setup FAQ for team

---

## 🛠️ Maintenance Checklist (Ongoing)

### Weekly
- [ ] Review failed workflows
- [ ] Check SonarQube quality metrics
- [ ] Monitor security scan results
- [ ] Update dependencies if needed

### Monthly
- [ ] Review and update SonarQube quality gates
- [ ] Audit GitHub Actions usage/costs
- [ ] Update workflow if tool versions change
- [ ] Review code coverage trends

### Quarterly
- [ ] Evaluate tool alternatives
- [ ] Update security scanning policies
- [ ] Review and optimize workflow performance
- [ ] Plan major upgrades

---

## ✅ Final Verification

### System Working
- [ ] Workflow runs on every push ✅
- [ ] Workflow runs on pull requests ✅
- [ ] All jobs complete successfully ✅
- [ ] Coverage reports generated ✅
- [ ] SonarQube metrics available ✅
- [ ] Security scans working ✅
- [ ] Quality Gate enforced ✅

### Team Ready
- [ ] Team understands workflow ✅
- [ ] Team can debug failures ✅
- [ ] Team follows best practices ✅
- [ ] Documentation complete ✅

---

## 📞 Support & Troubleshooting

### Issues Encountered

**Issue**: GitHub Actions workflow not triggering
```
[ ] Verify .github/workflows/ci.yml path is correct
[ ] Check GitHub Actions is enabled in Settings
[ ] Verify branch is main or develop
[ ] Check secrets are configured
[ ] Try re-running workflow manually
```

**Issue**: SonarQube not responding
```
[ ] Check container: docker ps | grep sonarqube
[ ] View logs: docker logs sonarqube-server
[ ] Restart: docker-compose -f docker-compose.sonarqube.yml restart
[ ] Reset: docker-compose -f docker-compose.sonarqube.yml down -v
```

**Issue**: Tests not running in CI/CD
```
[ ] Verify test dependencies installed
[ ] Check connection strings configured
[ ] Review GitHub Actions logs for errors
[ ] Test locally first before pushing
```

---

## 🎉 Success Criteria

✅ **Complete When**:
1. GitHub Actions workflow runs successfully on push
2. All jobs complete without errors
3. Coverage reports are generated
4. SonarQube dashboard shows metrics
5. Quality Gate passes
6. Team understands the pipeline
7. Branch protection rules enforced
8. Security scans working

---

## 📋 Quick Reference

| Command | Purpose |
|---------|---------|
| `make setup-all` | Setup everything |
| `make sonar-logs` | View SonarQube logs |
| `make test-backend` | Run backend tests |
| `make test-frontend` | Run frontend tests |
| `make scan-local` | Local SonarQube scan |
| `gh secret list` | View GitHub secrets |
| `git push origin main` | Trigger workflow |

---

## 📚 Document References

| Document | When to Read |
|----------|--------------|
| QUICKSTART.md | First thing! Quick overview |
| GITHUB_ACTIONS_SETUP.md | Detailed setup guide |
| CI_CD_IMPLEMENTATION.md | Implementation details |
| TESTING_PROPOSAL.md | Overall testing strategy |
| Makefile | Helper commands |

---

**Last Updated**: 2026-07-20  
**Status**: Ready for Implementation

> 💡 **Tip**: Print this checklist and check off items as you complete them!

