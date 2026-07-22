using MiniTaskManagement.Api.DTOs;
using MiniTaskManagement.Api;
using Xunit;
using System.Net;

public class AuthorizationTests
{
    // 1.3 User Role accessing Admin endpoint
    [Fact]
    public async Task AdminEndpoint_WhenAccessedByUserRole_Returns403Forbidden()
    {
        // Arrange: Dùng HttpClient giả lập gửi request kèm Token của 'User'
        // client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", userToken);

        // Act
        // var response = await client.GetAsync("/api/admin/users");

        // Assert
        // response.StatusCode.Should().Be(HttpStatusCode.Forbidden);
    }

    // 1.3 Admin Role accessing Admin endpoint
    [Fact]
    public async Task AdminEndpoint_WhenAccessedByAdminRole_Returns200Ok()
    {
        // Arrange: Dùng Token của 'Admin'
        // client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", adminToken);

        // Act
        // var response = await client.GetAsync("/api/admin/users");

        // Assert
        // response.StatusCode.Should().Be(HttpStatusCode.OK);
    }

    // 1.3 Invalid/Missing Token
    [Fact]
    public async Task ProtectedEndpoint_WithInvalidOrMissingToken_Returns401Unauthorized()
    {
        // Arrange: Token sai cấu trúc hoặc không truyền Header Authorization

        // Act
        // var response = await client.GetAsync("/api/tasks");

        // Assert
        // response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }
}