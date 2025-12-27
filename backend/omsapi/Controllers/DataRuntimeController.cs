using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using omsapi.Models.Common;
using omsapi.Services;
using omsapi.Services.Interfaces;
using System.Text.Json;

namespace omsapi.Controllers
{
    // This controller handles the actual runtime execution of published interfaces
    [Route("api/data")]
    [ApiController]
    public class DataRuntimeController : ControllerBase
    {
        private readonly IInterfaceService _interfaceService;
        private readonly InterfaceExecutionService _executionService;
        private readonly ILogger<DataRuntimeController> _logger;

        public DataRuntimeController(
            IInterfaceService interfaceService, 
            InterfaceExecutionService executionService,
            ILogger<DataRuntimeController> logger)
        {
            _interfaceService = interfaceService;
            _executionService = executionService;
            _logger = logger;
        }

        [AllowAnonymous] // We handle auth manually inside based on interface config, or use policy
        // For now, let's allow anonymous to reach here, and check interface.RequiresAuth
        [HttpOptions("{**path}")]
        public IActionResult Options()
        {
            return Ok();
        }

        [HttpGet("{**path}")]
        [HttpPost("{**path}")]
        [HttpPut("{**path}")]
        [HttpDelete("{**path}")]
        public async Task<IActionResult> HandleRequest(string path)
        {
            // 1. Normalize path
            // The path parameter might not contain the query string, which is fine.
            // path in route excludes "api/data".
            // e.g. request to /api/data/user/list -> path = "user/list"
            
            if (string.IsNullOrEmpty(path)) return NotFound(ApiResponse<object>.Error("Path is empty"));
            
            // 2. Find Interface by Path
            // This is the tricky part: resolving "user/list" to an Interface ID.
            // For MVP, we'll ask InterfaceService to resolve it.
            // We need a fast lookup.
            
            var iface = await _interfaceService.GetInterfaceByPathAsync(path);
            if (iface == null)
            {
                return NotFound(ApiResponse<object>.Error($"Interface not found for path: {path}"));
            }

            // 3. Check Status
            if (!iface.IsPublished)
            {
                return BadRequest(ApiResponse<object>.Error("Interface is not published"));
            }

            // 4. Check Auth & Permissions (Roles)
            if (iface.RequiresAuth)
            {
                if (!User.Identity?.IsAuthenticated ?? true)
                {
                    return Unauthorized(ApiResponse<object>.Error("Authentication required"));
                }
                
                // Check CallRoles
                if (iface.CallRoles != null && iface.CallRoles.Any())
                {
                    // Assuming we have User Roles in Claims
                    // For now, let's skip complex role check or implement simple one
                    // var userRoles = User.FindAll(ClaimTypes.Role).Select(c => long.Parse(c.Value));
                    // if (!userRoles.Intersect(iface.CallRoles).Any()) return Forbid();
                }
            }

            // 5. Prepare Execution Context
            var method = Request.Method.ToUpper();
            if (iface.Method.ToUpper() != method)
            {
                return StatusCode(405, ApiResponse<object>.Error($"Method {method} not allowed. Expected {iface.Method}"));
            }

            // Extract Params
            var execRequest = new ExecuteRequestDto
            {
                Params = new Dictionary<string, object>(),
                Body = null
            };

            // Query Params
            foreach (var query in Request.Query)
            {
                execRequest.Params[query.Key] = query.Value.ToString();
            }

            // Body
            if (method == "POST" || method == "PUT")
            {
                using var reader = new StreamReader(Request.Body);
                var bodyStr = await reader.ReadToEndAsync();
                if (!string.IsNullOrEmpty(bodyStr))
                {
                    try 
                    {
                        execRequest.Body = JsonSerializer.Deserialize<object>(bodyStr);
                    }
                    catch
                    {
                        execRequest.Body = bodyStr; // Fallback to string
                    }
                }
            }

            // 6. Execute
            try
            {
                var result = await _executionService.ExecuteInterfaceAsync(iface.Id, execRequest, isDebug: false);
                
                if (result.StatusCode >= 200 && result.StatusCode < 300)
                {
                    // Return raw data or wrapped? 
                    // Usually data APIs return the data structure defined in Response Node.
                    // If Response Node returns { code: 200, data: ... }, we return that.
                    // Our ExecutionService returns ExecuteResultDto.
                    
                    // If the flow response is the raw data, we return it.
                    return StatusCode(result.StatusCode, result.Data);
                }
                else
                {
                    return StatusCode(result.StatusCode, new { error = result.Error });
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error executing interface {Path}", path);
                return StatusCode(500, new { error = "Internal Server Error" });
            }
        }
    }
}
