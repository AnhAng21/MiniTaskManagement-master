# Hướng Dẫn Triển Khai Trên Máy Khác

Tài liệu này dành để đưa cho AI hoặc người khác trên máy thứ hai, nhằm tái tạo đúng môi trường và cấu hình giống như máy hiện tại.

## 1. Mục tiêu

- Thiết lập lại dự án Mini Task Management trên máy khác
- Cài đặt đầy đủ các công cụ cần thiết
- Chạy được GitHub Actions + SonarQube local tương tự máy này
- Triển khai được CI/CD và kiểm thử giống cấu trúc hiện tại

## 2. Yêu cầu phần cứng/phần mềm

### 2.1 Hệ điều hành

- Windows 10/11
- macOS
- Linux (Ubuntu, Debian, Fedora, v.v.)

### 2.2 Phần mềm cần cài

- Git
- Docker Desktop (hoặc Docker Engine với Docker Compose)
- .NET 10 SDK
- Node.js 20+
- npm (đi kèm Node.js)
- GitHub CLI (`gh`) nếu muốn tự động cấu hình secrets

### 2.3 Truy cập mạng

- Kết nối internet để tải mã nguồn, Docker image, packages
- Có thể cần truy cập GitHub và SonarQube (cục bộ hoặc SonarCloud)

## 3. Các file quan trọng trong repository này

- `.github/workflows/ci.yml` - workflow GitHub Actions
- `sonar-project.properties` - cấu hình SonarQube
- `docker-compose.sonarqube.yml` - khởi động SonarQube + PostgreSQL local
- `setup-ci-cd.sh` - script tự động cho macOS/Linux
- `setup-ci-cd.ps1` - script tự động cho Windows PowerShell
- `Makefile` - lệnh hỗ trợ cho môi trường Unix
- `GITHUB_ACTIONS_SETUP.md` - hướng dẫn chi tiết triển khai CI/CD
- `QUICKSTART.md` - hướng dẫn nhanh

## 4. Các bước chuẩn bị trên máy khác

### 4.1 Bước 1: Sao chép repository

Trên máy mới, clone repository từ GitHub:

```bash
git clone <repository-url>
cd MiniTaskManagement-master
```

Nếu repository đã có sẵn, chỉ cần vào thư mục gốc.

### 4.2 Bước 2: Cài đặt công cụ

#### Windows

- Cài Docker Desktop
- Cài Git for Windows
- Cài .NET 10 SDK
- Cài Node.js 20+
- (Tuỳ chọn) Cài GitHub CLI `gh`

#### macOS / Linux

- Cài Docker
- Cài Git
- Cài .NET 10 SDK
- Cài Node.js 20+
- (Tuỳ chọn) Cài GitHub CLI `gh`

### 4.3 Bước 3: Kiểm tra môi trường

```bash
git --version
docker --version
dotnet --version
node --version
npm --version
```

Nếu thiếu, cài thêm trước khi tiếp tục.

## 5. Chạy môi trường SonarQube local

### 5.1 Dùng Docker Compose

Từ thư mục gốc repository:

```bash
docker-compose -f docker-compose.sonarqube.yml up -d
```

### 5.2 Kiểm tra trạng thái

```bash
curl http://localhost:9000/api/system/health
```

Kết quả cần trả về trạng thái `UP`.

### 5.3 Đăng nhập SonarQube

- Truy cập: http://localhost:9000
- Login mặc định: `admin` / `admin`
- Đổi mật khẩu nếu được yêu cầu

### 5.4 Tạo token SonarQube

- Vào `My Account` → `Security`
- Chọn `Generate Tokens`
- Đặt tên `mini-task-management-ci`
- Copy token để sử dụng ở bước GitHub Secrets

## 6. Cấu hình GitHub Secrets

### 6.1 Cấu hình bằng GitHub UI

Vào:

```
Repository → Settings → Secrets and variables → Actions
```

Thêm các secrets:

- `SONAR_HOST_URL` = `http://localhost:9000`
- `SONAR_TOKEN` = `<SonarQube token đã tạo>`

### 6.2 Cấu hình bằng GitHub CLI (nếu có)

```bash
gh secret set SONAR_HOST_URL --body "http://localhost:9000"
gh secret set SONAR_TOKEN --body "<sonar-token>"
```

## 7. Cài dependencies và chạy thử

### 7.1 Backend

```bash
cd MiniTaskManagement.Api
dotnet restore
```

### 7.2 Frontend

```bash
cd task-ui
npm ci
```

### 7.3 Cài thêm test packages (nếu chưa có)

#### Backend

```bash
cd MiniTaskManagement.Api
dotnet add MiniTaskManagement.Api.csproj package xunit
dotnet add MiniTaskManagement.Api.csproj package Moq
dotnet add MiniTaskManagement.Api.csproj package FluentAssertions
```

#### Frontend

```bash
cd task-ui
npm install --save-dev jest @testing-library/react @testing-library/jest-dom @testing-library/user-event jest-environment-jsdom
```

## 8. Chạy script tự động

### Nếu máy là Linux / macOS

```bash
bash setup-ci-cd.sh
```

### Nếu máy là Windows

```powershell
powershell -ExecutionPolicy Bypass .\setup-ci-cd.ps1
```

Script sẽ:
- Kiểm tra Docker và Git
- Khởi động SonarQube
- Hướng dẫn tạo token
- Cài các package test cơ bản
- Nếu có GitHub CLI, cố gắng thiết lập secrets

## 9. Chạy workflow bằng tay

### 9.1 Chạy SonarQube local

```bash
docker-compose -f docker-compose.sonarqube.yml up -d
```

### 9.2 Kiểm tra SonarQube

```bash
curl http://localhost:9000/api/system/health
```

### 9.3 Chạy test backend

```bash
cd MiniTaskManagement.Api
dotnet test --configuration Release /p:CollectCoverage=true /p:CoverageFormat=opencover
```

### 9.4 Chạy test frontend

```bash
cd task-ui
npm test -- --coverage --watchAll=false
```

## 10. Chạy GitHub Actions trên máy khác

Trên máy khác chỉ cần push code lên GitHub rồi mở:

```
Repository → Actions
```

GitHub Actions sẽ tự động chạy workflow `.github/workflows/ci.yml` khi:
- Push lên branch `main` hoặc `develop`
- Mở pull request vào `main`/`develop`

## 11. Nếu muốn dùng SonarCloud thay vì SonarQube local

- Đăng ký SonarCloud
- Tạo project trên SonarCloud
- Dùng `SONAR_HOST_URL=https://sonarcloud.io`
- Dùng token từ SonarCloud
- Cập nhật workflow hoặc secrets nếu cần

## 12. Tài liệu tham khảo

- `GITHUB_ACTIONS_SETUP.md` — Hướng dẫn chi tiết
- `QUICKSTART.md` — Hướng dẫn nhanh
- `CI_CD_IMPLEMENTATION.md` — Thông tin triển khai đầy đủ
- `TESTING_PROPOSAL.md` — Chiến lược kiểm thử

## 13. Gợi ý cho AI trên máy kia

Bạn có thể giao AI làm theo các bước:
1. Clone repo
2. Cài Docker, Git, .NET 10, Node.js 20
3. Chạy `setup-ci-cd.sh` hoặc `setup-ci-cd.ps1`
4. Tạo token SonarQube và thêm GitHub secrets
5. Chạy test backend/frontend
6. Push code để kích hoạt GitHub Actions

---

## 14. Lưu ý cuối

- Máy khác cần có quyền truy cập Internet và có thể chạy Docker.
- Nếu không thể cài Docker, chỉ có thể làm phần code và test local, không chạy SonarQube local.
- Các file trên máy hiện tại đã đầy đủ để sao chép cấu hình và triển khai giống nhau.
