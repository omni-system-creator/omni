using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using omsapi.Models.Common;

namespace omsapi.Middleware
{
    public class GlobalExceptionFilter : IExceptionFilter
    {
        private readonly ILogger<GlobalExceptionFilter> _logger;

        public GlobalExceptionFilter(ILogger<GlobalExceptionFilter> logger)
        {
            _logger = logger;
        }

        public void OnException(ExceptionContext context)
        {
            _logger.LogError(context.Exception, "An unhandled exception occurred.");

            var response = ApiResponse<object>.Error(context.Exception.Message, 500);
            
            // Always return 200 OK status code as requested
            context.HttpContext.Response.StatusCode = 200;
            context.Result = new JsonResult(response);
            context.ExceptionHandled = true;
        }
    }
}
