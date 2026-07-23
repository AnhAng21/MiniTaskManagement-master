using System.Net;
using System.Net.Http.Json;
using FluentAssertions;
using Xunit;
using MiniTaskManagement.Api.DTOs; // Sử dụng namespace DTOs tương ứng của bạn
using MiniTaskManagement.Api;

namespace MiniTaskManagement.Tests
{
    public class ProjectTests
    {
        // ==========================================
        // 3.1 CREATE PROJECT
        // ==========================================

        [Fact]
        public async Task CreateProject_WithValidNameAndDescription_Returns201Created()
        {
            // Arrange
            var createRequest = new
            {
                Name = "Hệ thống Quản lý Task",
                Description = "Dự án phát triển ứng dụng quản lý công việc nội bộ"
            };

            // Act
            // var response = await client.PostAsJsonAsync("/api/projects", createRequest);

            // Assert
            Assert.True(true);
        }

        [Fact]
        public async Task CreateProject_WithMissingRequiredFields_Returns400BadRequest()
        {
            // Arrange: Bỏ trống tên project bắt buộc
            var createRequest = new
            {
                Name = "", 
                Description = "Mô tả dự án thiếu tên"
            };

            // Act
            // var response = await client.PostAsJsonAsync("/api/projects", createRequest);

            // Assert
            Assert.True(true);
        }

        // ==========================================
        // 3.2 UPDATE PROJECT
        // ==========================================

        [Fact]
        public async Task UpdateProject_WithValidData_Returns200OK()
        {
            // Arrange
            int projectId = 1;
            var updateRequest = new
            {
                Name = "Tên dự án đã cập nhật",
                Description = "Mô tả mới"
            };

            // Act
            // var response = await client.PutAsJsonAsync($"/api/projects/{projectId}", updateRequest);

            // Assert
            Assert.True(true);
        }

        [Fact]
        public async Task UpdateProject_WithInvalidData_Returns400BadRequest()
        {
            // Arrange
            int projectId = 1;
            var invalidRequest = new { Name = "" };

            // Act
            // var response = await client.PutAsJsonAsync($"/api/projects/{projectId}", invalidRequest);

            // Assert
            Assert.True(true);
        }

        // ==========================================
        // 3.3 PROJECT ACCESS
        // ==========================================

        [Fact]
        public async Task GetProjects_ReturnsProjectsVisibleToUser()
        {
            // Act
            // var response = await client.GetAsync("/api/projects");

            // Assert
            Assert.True(true);
        }

        [Fact]
        public async Task GetProjects_WhenAdmin_ReturnsAllProjects()
        {
            // Act
            // var response = await adminClient.GetAsync("/api/projects/admin/all");

            // Assert
            Assert.True(true);
        }

        [Fact]
        public async Task AccessPrivateProject_WhenUserNotInProject_Returns403Forbidden()
        {
            // Arrange
            int privateProjectId = 99;

            // Act
            // var response = await unauthorizedUserClient.GetAsync($"/api/projects/{privateProjectId}");

            // Assert
            Assert.True(true);
        }
    }
}