using Microsoft.AspNetCore.Mvc.Filters;
using omsapi.Models.Entities;
using omsapi.Services.Interfaces;
using omsapi.Infrastructure.Extensions;
using System.Security.Claims;

namespace omsapi.Filters
{
    public class AuditLogFilter : IAsyncActionFilter
    {
        private readonly IAuditLogService _auditLogService;
        private readonly ILogger<AuditLogFilter> _logger;

        public AuditLogFilter(IAuditLogService auditLogService, ILogger<AuditLogFilter> logger)
        {
            _auditLogService = auditLogService;
            _logger = logger;
        }

        public async Task OnActionExecutionAsync(ActionExecutingContext context, ActionExecutionDelegate next)
        {
            var request = context.HttpContext.Request;
            var method = request.Method;

            // Only log modification operations (POST, PUT, DELETE, PATCH)
            if (method == "GET" || method == "OPTIONS" || method == "HEAD")
            {
                await next();
                return;
            }

            if (request.Path.Value?.ToLower().Contains("/api/auth/login") == true)
            {
                await next();
                return;
            }

            var startTime = DateTime.UtcNow;

            // Execute Action
            ActionExecutedContext executedContext;
            try 
            {
                executedContext = await next();
            }
            catch (Exception)
            {
                // Should not happen as next() catches exceptions usually?
                // But if it bubbles up:
                 // Create a fake executed context or handle logging here?
                 // Usually next() returns context with Exception set.
                 throw; 
            }

            var duration = (long)(DateTime.UtcNow - startTime).TotalMilliseconds;
            var user = context.HttpContext.User;
            
            long? userId = null;
            string? username = null;

            if (user.Identity?.IsAuthenticated == true)
            {
                var idClaim = user.FindFirst("id");
                if (idClaim != null && long.TryParse(idClaim.Value, out long id))
                {
                    userId = id;
                }
                username = user.Identity.Name;
            }

            var actionName = context.ActionDescriptor.DisplayName ?? "Unknown Action";
            if (actionName.Length > 200)
            {
                actionName = actionName.Substring(0, 197) + "...";
            }

            var log = new SystemAuditLog
            {
                UserId = userId,
                UserName = username,
                Action = actionName,
                Route = request.Path,
                Method = method,
                IpAddress = context.HttpContext.GetClientIp(),
                UserAgent = request.Headers["User-Agent"].ToString(),
                IsSuccess = executedContext.Exception == null,
                ErrorMessage = executedContext.Exception?.Message,
                ExecutionDuration = duration,
                CreatedAt = DateTime.UtcNow
            };

            if (request.QueryString.HasValue)
            {
                log.Parameters = request.QueryString.Value;
            }

            // Use a try-catch block to ensure logging doesn't affect the response
            try
            {
                await _auditLogService.LogAsync(log);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to write audit log");
            }
        }
    }
}
