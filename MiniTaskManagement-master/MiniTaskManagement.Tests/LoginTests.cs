using MiniTaskManagement.Api.DTOs;
using MiniTaskManagement.Api;
using Xunit;
using FluentAssertions;

public class LoginTests
{
    // 1.2 Success Case
    [Fact]
    public async Task Login_WithCorrectCredentials_Returns200OkWithToken()
    {
        // Arrange
        var request = new LoginRequest
        { 
            Email = "testuser@example.com", 
            Password = "Password123!" 
        };

        // Act
        // var result = await _authController.Login(request);

        // Assert
        // Kiểm tra response trả về token không bị rỗng (NotNullOrEmpty)
    }

    // 1.2 Variant: Wrong Password
    [Fact]
    public async Task Login_WithIncorrectPassword_Returns401UnauthorizedOr400BadRequest()
    {
        // Arrange
        var request = new LoginRequest
        { 
            Email = "testuser@example.com", 
            Password = "WrongPassword!" 
        };

        // Act & Assert
        // Mong muốn kết quả là 401 Unauthorized hoặc 400 Bad Request
    }

    // 1.2 Variant: Non-existent Email
    [Fact]
    public async Task Login_WithNonExistentEmail_Returns401UnauthorizedOr400BadRequest()
    {
        // Arrange
        var request = new LoginRequest
        { 
            Email = "notfound@example.com", 
            Password = "Password123!" 
        };

        // Act & Assert
    }
}