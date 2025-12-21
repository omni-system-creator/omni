using Microsoft.AspNetCore.Mvc.Filters;
using omsapi.Models.Entities;
using omsapi.Services.Interfaces;
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

            // 只记录修改数据的操作 (POST, PUT, DELETE, PATCH)
            // GET 请求通常不记录，除非特别敏感
            if (method == "GET" || method == "OPTIONS" || method == "HEAD")
            {
                await next();
                return;
            }

            // 如果是登录接口，已经在 AuthService 中单独记录了，这里跳过避免重复
            if (request.Path.Value?.ToLower().Contains("/api/auth/login") == true)
            {
                await next();
                return;
            }

            var startTime = DateTime.Now;

            // 执行 Action
            var executedContext = await next();

            var duration = (long)(DateTime.Now - startTime).TotalMilliseconds;
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
            // 截断 Action 字段，防止超过数据库长度
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
                IpAddress = context.HttpContext.Connection.RemoteIpAddress?.ToString(),
                UserAgent = request.Headers["User-Agent"].ToString(),
                IsSuccess = executedContext.Exception == null,
                ErrorMessage = executedContext.Exception?.Message,
                ExecutionDuration = duration,
                CreatedAt = DateTime.Now
            };

            // 记录参数 (可选，注意敏感信息脱敏)
            // 这里简单记录 QueryString，Body 读取比较复杂需要 EnableBuffering
            if (request.QueryString.HasValue)
            {
                log.Parameters = request.QueryString.Value;
            }

            await _auditLogService.LogAsync(log);
        }
    }
}
