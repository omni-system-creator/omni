using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using omsapi.Models.Common;
using omsapi.Models.Dtos;
using omsapi.Services;
using omsapi.Services.Interfaces;
using System.Security.Claims;

namespace omsapi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class InterfaceController : ControllerBase
    {
        private readonly IInterfaceService _interfaceService;
        private readonly InterfaceExecutionService _executionService;

        public InterfaceController(IInterfaceService interfaceService, InterfaceExecutionService executionService)
        {
            _interfaceService = interfaceService;
            _executionService = executionService;
        }

        private long GetUserId()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
            if (userIdClaim != null && long.TryParse(userIdClaim.Value, out long userId))
            {
                return userId;
            }
            return 0;
        }

        #region Categories

        [HttpGet("categories")]
        public async Task<ActionResult<ApiResponse<List<InterfaceCategoryDto>>>> GetCategoryTree()
        {
            var data = await _interfaceService.GetCategoryTreeAsync();
            return Ok(ApiResponse<List<InterfaceCategoryDto>>.Success(data));
        }

        [HttpGet("categories/{id}")]
        public async Task<ActionResult<ApiResponse<InterfaceCategoryDto>>> GetCategoryById(long id)
        {
            var data = await _interfaceService.GetCategoryByIdAsync(id);
            if (data == null) return NotFound(ApiResponse<object>.Error("Category not found"));
            return Ok(ApiResponse<InterfaceCategoryDto>.Success(data));
        }

        [HttpPost("categories")]
        public async Task<ActionResult<ApiResponse<InterfaceCategoryDto>>> CreateCategory([FromBody] CreateInterfaceCategoryDto dto)
        {
            var data = await _interfaceService.CreateCategoryAsync(dto, GetUserId());
            return Ok(ApiResponse<InterfaceCategoryDto>.Success(data));
        }

        [HttpPut("categories/{id}")]
        public async Task<ActionResult<ApiResponse<InterfaceCategoryDto>>> UpdateCategory(long id, [FromBody] UpdateInterfaceCategoryDto dto)
        {
            var data = await _interfaceService.UpdateCategoryAsync(id, dto);
            if (data == null) return NotFound(ApiResponse<object>.Error("Category not found"));
            return Ok(ApiResponse<InterfaceCategoryDto>.Success(data));
        }

        [HttpDelete("categories/{id}")]
        public async Task<ActionResult<ApiResponse<object>>> DeleteCategory(long id)
        {
            var result = await _interfaceService.DeleteCategoryAsync(id);
            if (!result) return BadRequest(ApiResponse<object>.Error("Cannot delete category. It may have children or interfaces."));
            return Ok(ApiResponse<object>.Success(null, "Category deleted successfully"));
        }

        #endregion

        #region Interfaces

        [HttpGet]
        public async Task<ActionResult<ApiResponse<PagedResult<InterfaceDefinitionDto>>>> GetInterfaces([FromQuery] long? categoryId, [FromQuery] string? keyword, [FromQuery] int page = 1, [FromQuery] int pageSize = 10)
        {
            var data = await _interfaceService.GetInterfacesAsync(categoryId, keyword, page, pageSize);
            return Ok(ApiResponse<PagedResult<InterfaceDefinitionDto>>.Success(data));
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<ApiResponse<InterfaceDefinitionDto>>> GetInterfaceById(long id)
        {
            var data = await _interfaceService.GetInterfaceByIdAsync(id);
            if (data == null) return NotFound(ApiResponse<object>.Error("Interface not found"));
            return Ok(ApiResponse<InterfaceDefinitionDto>.Success(data));
        }

        [HttpPost]
        public async Task<ActionResult<ApiResponse<InterfaceDefinitionDto>>> CreateInterface([FromBody] CreateInterfaceDto dto)
        {
            var data = await _interfaceService.CreateInterfaceAsync(dto, GetUserId());
            return Ok(ApiResponse<InterfaceDefinitionDto>.Success(data));
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<ApiResponse<InterfaceDefinitionDto>>> UpdateInterface(long id, [FromBody] UpdateInterfaceDto dto)
        {
            var data = await _interfaceService.UpdateInterfaceAsync(id, dto, GetUserId());
            if (data == null) return NotFound(ApiResponse<object>.Error("Interface not found"));
            return Ok(ApiResponse<InterfaceDefinitionDto>.Success(data));
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<ApiResponse<object>>> DeleteInterface(long id)
        {
            var result = await _interfaceService.DeleteInterfaceAsync(id, GetUserId());
            if (!result) return NotFound(ApiResponse<object>.Error("Interface not found"));
            return Ok(ApiResponse<object>.Success(null, "Interface deleted successfully"));
        }

        [HttpPut("{id}/publish")]
        public async Task<ActionResult<ApiResponse<object>>> PublishInterface(long id, [FromQuery] bool isPublished)
        {
            var result = await _interfaceService.PublishInterfaceAsync(id, isPublished, GetUserId());
            if (!result) return NotFound(ApiResponse<object>.Error("Interface not found"));
            return Ok(ApiResponse<object>.Success(null, isPublished ? "Interface published" : "Interface unpublished"));
        }

        [HttpPost("{id}/debug")]
        public async Task<ActionResult<ApiResponse<ExecuteResultDto>>> DebugInterface(long id, [FromBody] ExecuteRequestDto request)
        {
            try
            {
                var result = await _executionService.ExecuteInterfaceAsync(id, request, true);
                return Ok(ApiResponse<ExecuteResultDto>.Success(result));
            }
            catch (Exception ex)
            {
                return Ok(ApiResponse<object>.Error(ex.Message));
            }
        }
        
        [HttpPost("debug-flow")]
        public async Task<ActionResult<ApiResponse<ExecuteResultDto>>> DebugFlow([FromBody] DebugFlowRequestDto request)
        {
            try
            {
                // If SessionId is provided, we can choose to return immediately and let the client listen to SignalR events.
                // However, for compatibility with current frontend logic (which awaits response), we'll await execution.
                // The execution service will push events to SignalR if SessionId is present.
                
                var result = await _executionService.ExecuteFlowAsync(request.FlowConfig, request.Data, true);
                return Ok(ApiResponse<ExecuteResultDto>.Success(result));
            }
            catch (Exception ex)
            {
                return Ok(ApiResponse<object>.Error(ex.Message));
            }
        }

        #endregion
    }
}
