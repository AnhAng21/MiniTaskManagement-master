# Test Scenarios for Mini Task Management System

## 1. Authentication & Authorization

### 1.0 Triển khai chung
- Sử dụng API endpoint của `AuthController`.
- Chuẩn bị môi trường test với database sạch hoặc seed sẵn 2 tài khoản: một `User` và một `Admin`.
- Dùng Postman / Swagger / HTTP client hoặc test tự động để gửi request.
- Các endpoint chính:
  - `POST /api/auth/register`
  - `POST /api/auth/login`
  - `GET /api/users` hoặc admin endpoint tương tự để kiểm tra phân quyền
- Ghi lại token JWT từ kết quả login để dùng cho request tiếp theo.

### 1.1 User Registration
#### Bước triển khai
1. Gửi `POST /api/auth/register` với body:
   ```json
   {
     "fullName": "Test User",
     "email": "testuser@example.com",
     "password": "Password123!"
   }
   ```
2. Xác nhận response `200 OK` và thông báo `Register successful`.
3. Kiểm tra trong database bảng `Users` tồn tại user mới.

#### Biến thể kiểm thử
- Email đã tồn tại:
  - Dùng cùng `email` đã đăng ký, gửi lại request đăng ký.
  - Mong muốn `400 Bad Request` và message `Email already exists`.
- Password quá ngắn:
  - Gửi password < 8 ký tự.
  - Mong muốn `400 Bad Request` hoặc validation error nếu backend validate.
- Thiếu trường bắt buộc:
  - Bỏ `email` hoặc `password`.
  - Mong muốn `400 Bad Request` với lỗi validation.

### 1.2 User Login
#### Bước triển khai
1. Gửi `POST /api/auth/login` với body:
   ```json
   {
     "email": "testuser@example.com",
     "password": "Password123!"
   }
   ```
2. Xác nhận response `200 OK`.
3. Lấy giá trị token từ response: `accessToken` hoặc `token`.
4. Thử truy cập endpoint bảo vệ, ví dụ `GET /api/tasks` với header:
   ```http
   Authorization: Bearer <token>
   ```
5. Xác nhận response trả về dữ liệu thay vì `401 Unauthorized`.

#### Biến thể kiểm thử
- Email không tồn tại:
  - Đổi email sai.
  - Mong muốn `400 Bad Request` hoặc `401 Unauthorized`.
- Password sai:
  - Giữ email đúng, đổi password.
  - Mong muốn `400 Bad Request` hoặc `401 Unauthorized`.
- Token bị bỏ trống:
  - Không gắn header `Authorization`.
  - Mong muốn `401 Unauthorized`.

### 1.3 Role Validation
#### Bước triển khai
1. Tạo hoặc sử dụng tài khoản `User` và tài khoản `Admin`.
2. Login từng tài khoản và lấy token.
3. Gọi endpoint admin-only, ví dụ `GET /api/admin/users` hoặc một endpoint tương tự.

#### Kiểm tra `User` role
- Dùng token của `User`.
- Gọi endpoint admin.
- Mong muốn `403 Forbidden` hoặc `401 Unauthorized` nếu phân quyền đúng.

#### Kiểm tra `Admin` role
- Dùng token của `Admin`.
- Gọi same endpoint.
- Mong muốn `200 OK` và danh sách dữ liệu trả về.

#### Kiểm thử token xấu/expired
- Tạo token ngẫu nhiên hoặc sửa một ký tự trong token.
- Gọi endpoint bảo vệ.
- Mong muốn `401 Unauthorized`.
- Nếu có thể mô phỏng token hết hạn, dùng token expired và kiểm tra cùng kết quả.

### 1.4 Ghi nhận kết quả
- Ghi lại từng request, response code, và nội dung trả về.
- Kiểm tra trực tiếp dữ liệu trong bảng `Users` để xác nhận registration và role.
- Nếu viết test tự động, tạo 3 bộ test:
  1. `RegisterTests`
  2. `LoginTests`
  3. `AuthorizationTests`

## 2. Task Management

### 2.1 Create Task
- Verify a user can create a task with title, description, due date, project, and priority.
- Validate error when required task fields are missing.
- Verify task is assigned to the correct project and user.

### 2.2 Update Task
- Verify user can update task fields: title, description, status, due date.
- Verify user cannot modify task of another user unless authorized.
- Validate error when updating with invalid status.

### 2.3 Delete Task
- Verify user can delete their own task.
- Verify admin can delete any task.
- Verify deleting a non-existent task returns not found.

### 2.4 Task Status Flow
- Verify task status transitions correctly (e.g., Open → InProgress → Done).
- Verify timestamp or activity log is generated when status changes.
- Verify completed tasks are shown correctly in task lists.

### 2.5 Subtasks and Tags
- Verify user can create and update a subtask under a task.
- Verify subtask completion updates the parent task's progress or status logic.
- Verify user can add/remove tags from a task.
- Verify tags are returned correctly in the task details response.

### 2.6 Task Comments & Activity
- Verify user can add a comment to a task.
- Verify comments include the user name and timestamp.
- Verify activity log records task creation, updates, status changes, and comments.

## 3. Project Management

### 3.1 Create Project
- Verify user can create a project with valid name and description.
- Validate error when required project fields are missing.

### 3.2 Update Project
- Verify project details can be updated correctly.
- Verify invalid updates are rejected.

### 3.3 Project Access
- Verify project list returns projects visible to the user.
- Verify admin can access all projects.
- Verify a user cannot access private projects they are not part of.

## 4. Chat & Real-time Collaboration

### 4.1 Chat Room Management
- Verify user can create a chat room.
- Verify user can add members to a chat room.
- Verify only authorized users can access chat room details.

### 4.2 Chat Messaging
- Verify user can send a message in a chat room.
- Verify other room members receive the message in real-time.
- Verify message history is stored and returned correctly.

### 4.3 Read Receipts
- Verify message read status is tracked per user.
- Verify read receipts update when a user opens a chat room.

### 4.4 SignalR Authentication
- Verify chat hub connection accepts JWT via query string to authenticate.
- Verify unauthorized SignalR connections are rejected.

## 5. Admin Flows

### 5.1 User Management
- Verify admin can fetch the list of all users.
- Verify admin can change a user role.
- Verify admin can deactivate or reactivate a user account if supported.

### 5.2 Admin Dashboard
- Verify admin dashboard displays correct counts of users, projects, and tasks.
- Verify admin-only endpoints return forbidden for normal users.

## 6. API & Integration Scenarios

### 6.1 End-to-End API Flow
- Verify full flow: register → login → create project → create task → update task → add comment → view dashboard.
- Verify API response shapes for key endpoints match expectations.

### 6.2 Database Integration
- Verify task, project, user, comment, and chat data persist correctly in PostgreSQL.
- Verify foreign keys and relationships are enforced.

### 6.3 Error Handling
- Verify API returns meaningful error messages on invalid input.
- Verify HTTP status codes are correct for unauthorized, forbidden, not found, and validation errors.

## 7. Frontend Scenarios

### 7.1 Login Page
- Verify login form renders correctly.
- Verify validation warnings appear for empty credentials.
- Verify successful login navigates to dashboard.

### 7.2 Register Page
- Verify register form renders correctly.
- Verify form validates email format and password length.
- Verify successful registration shows confirmation or redirects.

### 7.3 Dashboard
- Verify dashboard loads user projects and tasks.
- Verify charts or summary widgets display correct counts.
- Verify navigation to task and project details works.

### 7.4 Task Form
- Verify task creation form input fields are present and required.
- Verify form submission sends correct API request.
- Verify validation handles invalid input.

### 7.5 Chat Interface
- Verify chat UI opens and displays existing messages.
- Verify sending a message updates the UI.
- Verify receiving a message from another user updates the chat view.

## 8. Security & Performance Scenarios

### 8.1 Security Tests
- Verify passwords are not returned in API responses.
- Verify JWT tokens are required for protected endpoints.
- Verify SQL injection attempts are rejected.
- Verify cross-site scripting attempts are sanitized in frontend displays.

### 8.2 Performance Tests
- Verify API response time is under acceptable threshold for list endpoints.
- Verify page load time for dashboard is within acceptable range.
- Verify SignalR chat connection establishment is stable under load.

## 9. Regression Scenarios
- Verify previously fixed issues do not recur after changes.
- Verify core flows continue to work after adding new features.
- Verify tests cover both happy path and edge cases.

## 10. Test Data and Fixtures
- Use seeded accounts for admin and regular users.
- Use sample projects, tasks, chat rooms, and messages.
- Validate cleanup between tests to avoid state leakage.

---

## Notes
- Prioritize **critical user flows** first: authentication, task creation/update, project access, and chat.
- Add automated tests for both **backend API** and **frontend UI**.
- Use this file as the base for writing unit, integration, and E2E test cases.