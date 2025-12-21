using Microsoft.AspNetCore.Authentication.JwtBearer;
using omsapi.Models.Common;
using System.Text.Json;

namespace omsapi.Middleware
{
    public static class JwtBearerEventsConfig
    {
        public static void Configure(JwtBearerOptions options)
        {
            options.Events = new JwtBearerEvents
            {
                OnChallenge = async context =>
                {
                    // Skip the default logic
                    context.HandleResponse();

                    context.Response.StatusCode = 200; // Always 200
                    context.Response.ContentType = "application/json";

                    var response = ApiResponse<object>.Error("Unauthorized", 401);
                    var json = JsonSerializer.Serialize(response, new JsonSerializerOptions 
                    { 
                        PropertyNamingPolicy = JsonNamingPolicy.CamelCase 
                    });

                    await context.Response.WriteAsync(json);
                },
                OnForbidden = async context =>
                {
                    context.Response.StatusCode = 200; // Always 200
                    context.Response.ContentType = "application/json";

                    var response = ApiResponse<object>.Error("Forbidden", 403);
                    var json = JsonSerializer.Serialize(response, new JsonSerializerOptions 
                    { 
                        PropertyNamingPolicy = JsonNamingPolicy.CamelCase 
                    });

                    await context.Response.WriteAsync(json);
                }
            };
        }
    }
}
