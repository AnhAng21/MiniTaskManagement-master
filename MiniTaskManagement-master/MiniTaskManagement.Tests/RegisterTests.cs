using Xunit;
using Moq;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc;

public class RegisterTests
{
    // 1.1 Success Case
    [Fact]
    public async Task Register_WithValidData_Returns200Ok()
    {
        // Arrange
        var request = new RegisterDto 
        { 
            FullName = "Test User", 
            Email = "testuser@example.com", 
            Password = "Password123!" 
        };
        // Mock AuthService hoặc DbContext tại đây...

        // Act
        // var result = await _authController.Register(request);

        // Assert
        // var okResult = result.Should().BeOfType<OkObjectResult>().Subject;
        // okResult.Value.Should().BeEquivalentTo(new { message = "Register successful" });
    }

    // 1.1 Variant: Email already exists
    [Fact]
    public async Task Register_WhenEmailAlreadyExists_Returns400BadRequest()
    {
        // Arrange
        var request = new RegisterDto 
        { 
            FullName = "Test User", 
            Email = "existing@example.com", 
            Password = "Password123!" 
        };

        // Act & Assert
        // Trả về 400 Bad Request kèm message "Email already exists"
    }

    // 1.1 Variant: Short Password
    [Fact]
    public async Task Register_WhenPasswordIsTooShort_Returns400BadRequest()
    {
        // Arrange
        var request = new RegisterDto 
        { 
            FullName = "Test User", 
            Email = "test@example.com", 
            Password = "123" // < 8 ký tự
        };

        // Act & Assert
        // Controller/Validator nên trả về 400 Validation Error
    }
}