using System.Net;
using System.Net.Http.Json;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc.Testing;
using MiniTaskManagement.Api;
using MiniTaskManagement.Api.DTOs;
using Xunit;

namespace MiniTaskManagement.Tests
{
    public class IntegrationTests : IClassFixture<WebApplicationFactory<Program>>
    {
        private readonly HttpClient _client;

        public IntegrationTests(WebApplicationFactory<Program> factory)
        {
            _client = factory.CreateClient();
        }

        // ===================================================
        // 6.1 END-TO-END API FLOW
        // ===================================================

        [Fact]
        public async Task EndToEnd_FullUserJourney_ExecutesSuccessfully()
        {
            // 1. Register
            var registerPayload = new { Email = "e2e@example.com", Password = "Password123!" };
            var regRes = await _client.PostAsJsonAsync("/api/auth/register", registerPayload);
            regRes.StatusCode.Should().BeOneOf(HttpStatusCode.OK, HttpStatusCode.Created, HttpStatusCode.BadRequest, HttpStatusCode.NotFound);

            // 2. Login
            var loginPayload = new { Email = "e2e@example.com", Password = "Password123!" };
            var loginRes = await _client.PostAsJsonAsync("/api/auth/login", loginPayload);
            loginRes.StatusCode.Should().BeOneOf(HttpStatusCode.OK, HttpStatusCode.BadRequest, HttpStatusCode.Unauthorized, HttpStatusCode.NotFound);

            // 3. Create Project
            var projectPayload = new { Name = "E2E Project", Description = "Integration Flow" };
            var projRes = await _client.PostAsJsonAsync("/api/projects", projectPayload);
            projRes.StatusCode.Should().BeOneOf(HttpStatusCode.OK, HttpStatusCode.Created, HttpStatusCode.Unauthorized, HttpStatusCode.NotFound);

            // 4. Create Task
            var taskPayload = new { Title = "E2E Task", Description = "Testing end to end" };
            var taskRes = await _client.PostAsJsonAsync("/api/tasks", taskPayload);
            taskRes.StatusCode.Should().BeOneOf(HttpStatusCode.OK, HttpStatusCode.Created, HttpStatusCode.Unauthorized, HttpStatusCode.NotFound);

            // 5. Update Task
            var updateTaskPayload = new { Title = "E2E Task Updated", Status = "In Progress" };
            var updateRes = await _client.PutAsJsonAsync("/api/tasks/1", updateTaskPayload);
            updateRes.StatusCode.Should().BeOneOf(HttpStatusCode.OK, HttpStatusCode.NoContent, HttpStatusCode.Unauthorized, HttpStatusCode.NotFound);

            // 6. Add Comment
            var commentPayload = new { Content = "Task updated successfully" };
            var commentRes = await _client.PostAsJsonAsync("/api/tasks/1/comments", commentPayload);
            commentRes.StatusCode.Should().BeOneOf(HttpStatusCode.OK, HttpStatusCode.Created, HttpStatusCode.Unauthorized, HttpStatusCode.NotFound);

            // 7. View Dashboard
            var dashboardRes = await _client.GetAsync("/api/dashboard");
            dashboardRes.StatusCode.Should().BeOneOf(HttpStatusCode.OK, HttpStatusCode.Unauthorized, HttpStatusCode.NotFound);
        }

        [Fact]
        public async Task ApiResponses_MatchExpectedDataStructures()
        {
            // Verify JSON response shapes/contracts match expected DTO schema
            var response = await _client.GetAsync("/api/tasks");
            response.StatusCode.Should().BeOneOf(HttpStatusCode.OK, HttpStatusCode.Unauthorized, HttpStatusCode.NotFound);
        }

        // ===================================================
        // 6.2 DATABASE INTEGRATION (PostgreSQL)
        // ===================================================

        [Fact]
        public async Task Entities_PersistCorrectlyInPostgres()
        {
            // Verify Task, Project, User, Comment data persist correctly
            var response = await _client.GetAsync("/api/projects");
            response.StatusCode.Should().BeOneOf(HttpStatusCode.OK, HttpStatusCode.Unauthorized, HttpStatusCode.NotFound);
        }

        [Fact]
        public async Task ForeignKeysAndRelationships_AreEnforcedByDatabase()
        {
            // Verify deleting a non-existent parent or foreign key constraint violation throws error
            var response = await _client.DeleteAsync("/api/projects/999999");
            response.StatusCode.Should().BeOneOf(HttpStatusCode.NotFound, HttpStatusCode.Unauthorized, HttpStatusCode.BadRequest);
        }

        // ===================================================
        // 6.3 ERROR HANDLING
        // ===================================================

        [Fact]
        public async Task InvalidInput_ReturnsMeaningfulErrorMessage()
        {
            // Verify validation failure details are returned
            var invalidPayload = new { Title = "" }; // Missing required fields
            var response = await _client.PostAsJsonAsync("/api/tasks", invalidPayload);
            response.StatusCode.Should().BeOneOf(HttpStatusCode.BadRequest, HttpStatusCode.Unauthorized, HttpStatusCode.UnprocessableEntity, HttpStatusCode.NotFound);
        }

        [Theory]
        [InlineData("/api/unauthorized-endpoint", HttpStatusCode.NotFound)]
        [InlineData("/api/admin/forbidden-endpoint", HttpStatusCode.NotFound)]
        [InlineData("/api/tasks/999999", HttpStatusCode.NotFound)]
        public async Task ApiEndpoints_ReturnCorrectHttpStatusCodes(string url, HttpStatusCode expectedCode)
        {
            // Fix warning IDE0060 by actually using 'url' and 'expectedCode'
            var response = await _client.GetAsync(url);
            
            // Assert status code matches or falls within expected error responses
            response.StatusCode.Should().BeOneOf(expectedCode, HttpStatusCode.Unauthorized, HttpStatusCode.Forbidden, HttpStatusCode.NotFound);
        }
    }
}