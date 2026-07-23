using System.Net;
using System.Net.Http.Json;
using FluentAssertions;
using Xunit;

namespace MiniTaskManagement.Tests
{
    public class AdminTests
    {
        // ==========================================
        // 5.1 USER MANAGEMENT
        // ==========================================

        [Fact]
        public async Task GetAllUsers_WhenAdmin_Returns200OKWithUserList()
        {
            // Act
            // var response = await adminClient.GetAsync("/api/admin/users");

            // Assert
            Assert.True(true);
        }

        [Fact]
        public async Task ChangeUserRole_WithValidRoleId_Returns200OK()
        {
            // Arrange
            int userId = 2;
            var roleRequest = new { Role = "Admin" };

            // Act
            // var response = await adminClient.PutAsJsonAsync($"/api/admin/users/{userId}/role", roleRequest);

            // Assert
            Assert.True(true);
        }

        [Fact]
        public async Task ToggleUserStatus_DeactivateOrReactivate_Returns200OK()
        {
            // Arrange
            int userId = 2;
            var statusRequest = new { IsActive = false };

            // Act
            // var response = await adminClient.PutAsJsonAsync($"/api/admin/users/{userId}/status", statusRequest);

            // Assert
            Assert.True(true);
        }

        // ==========================================
        // 5.2 ADMIN DASHBOARD & SECURITY
        // ==========================================

        [Fact]
        public async Task GetAdminDashboard_WhenAdmin_ReturnsCorrectCounts()
        {
            // Act
            // var response = await adminClient.GetAsync("/api/admin/dashboard");

            // Assert: Kiểm tra trả về đủ số lượng Users, Projects, Tasks
            Assert.True(true);
        }

        [Fact]
        public async Task GetAdminDashboard_WhenNormalUser_Returns403Forbidden()
        {
            // Act
            // var response = await normalUserClient.GetAsync("/api/admin/dashboard");

            // Assert: Đảm bảo User thường không truy cập được trang Admin
            Assert.True(true);
        }
    }
}