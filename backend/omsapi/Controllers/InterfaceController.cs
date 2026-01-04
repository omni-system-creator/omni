using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using omsapi.Models.Common;
using omsapi.Models.Dtos;
using omsapi.Services;
using omsapi.Services.Interfaces;
using System.Security.Claims;

namespace omsapi.Controllers
{
    /// <summary>
    /// 接口管理控制器
    /// </summary>
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

        /// <summary>
        /// 获取分类树
        /// </summary>
        [HttpGet("categories")]
        public async Task<ActionResult<ApiResponse<List<InterfaceCategoryDto>>>> GetCategoryTree()
        {
            var data = await _interfaceService.GetCategoryTreeAsync();
            return Ok(ApiResponse<List<InterfaceCategoryDto>>.Success(data));
        }

        /// <summary>
        /// 获取分类详情
        /// </summary>
        [HttpGet("categories/{id}")]
        public async Task<ActionResult<ApiResponse<InterfaceCategoryDto>>> GetCategoryById(long id)
        {
            var data = await _interfaceService.GetCategoryByIdAsync(id);
            if (data == null) return NotFound(ApiResponse<object>.Error("Category not found"));
            return Ok(ApiResponse<InterfaceCategoryDto>.Success(data));
        }

        /// <summary>
        /// 创建分类
        /// </summary>
        [HttpPost("categories")]
        public async Task<ActionResult<ApiResponse<InterfaceCategoryDto>>> CreateCategory([FromBody] CreateInterfaceCategoryDto dto)
        {
            var data = await _interfaceService.CreateCategoryAsync(dto, GetUserId());
            return Ok(ApiResponse<InterfaceCategoryDto>.Success(data));
        }

        /// <summary>
        /// 更新分类
        /// </summary>
        [HttpPut("categories/{id}")]
        public async Task<ActionResult<ApiResponse<InterfaceCategoryDto>>> UpdateCategory(long id, [FromBody] UpdateInterfaceCategoryDto dto)
        {
            var data = await _interfaceService.UpdateCategoryAsync(id, dto);
            if (data == null) return NotFound(ApiResponse<object>.Error("Category not found"));
            return Ok(ApiResponse<InterfaceCategoryDto>.Success(data));
        }

        /// <summary>
        /// 删除分类
        /// </summary>
        [HttpDelete("categories/{id}")]
        public async Task<ActionResult<ApiResponse<object>>> DeleteCategory(long id)
        {
            var result = await _interfaceService.DeleteCategoryAsync(id);
            if (!result) return BadRequest(ApiResponse<object>.Error("Cannot delete category. It may have children or interfaces."));
            return Ok(ApiResponse<object>.Success(null, "Category deleted successfully"));
        }

        #endregion

        #region Interfaces

        /// <summary>
        /// 获取接口列表
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<ApiResponse<PagedResult<InterfaceDefinitionDto>>>> GetInterfaces([FromQuery] long? categoryId, [FromQuery] string? keyword, [FromQuery] int page = 1, [FromQuery] int pageSize = 10)
        {
            var data = await _interfaceService.GetInterfacesAsync(categoryId, keyword, page, pageSize);
            return Ok(ApiResponse<PagedResult<InterfaceDefinitionDto>>.Success(data));
        }

        /// <summary>
        /// 获取接口详情
        /// </summary>
        [HttpGet("{id}")]
        public async Task<ActionResult<ApiResponse<InterfaceDefinitionDto>>> GetInterfaceById(long id)
        {
            var data = await _interfaceService.GetInterfaceByIdAsync(id);
            if (data == null) return NotFound(ApiResponse<object>.Error("Interface not found"));
            return Ok(ApiResponse<InterfaceDefinitionDto>.Success(data));
        }

        /// <summary>
        /// 创建接口
        /// </summary>
        [HttpPost]
        public async Task<ActionResult<ApiResponse<InterfaceDefinitionDto>>> CreateInterface([FromBody] CreateInterfaceDto dto)
        {
            var data = await _interfaceService.CreateInterfaceAsync(dto, GetUserId());
            return Ok(ApiResponse<InterfaceDefinitionDto>.Success(data));
        }

        /// <summary>
        /// 更新接口
        /// </summary>
        [HttpPut("{id}")]
        public async Task<ActionResult<ApiResponse<InterfaceDefinitionDto>>> UpdateInterface(long id, [FromBody] UpdateInterfaceDto dto)
        {
            var data = await _interfaceService.UpdateInterfaceAsync(id, dto, GetUserId());
            if (data == null) return NotFound(ApiResponse<object>.Error("Interface not found"));
            return Ok(ApiResponse<InterfaceDefinitionDto>.Success(data));
        }

        /// <summary>
        /// 删除接口
        /// </summary>
        [HttpDelete("{id}")]
        public async Task<ActionResult<ApiResponse<object>>> DeleteInterface(long id)
        {
            var result = await _interfaceService.DeleteInterfaceAsync(id, GetUserId());
            if (!result) return NotFound(ApiResponse<object>.Error("Interface not found"));
            return Ok(ApiResponse<object>.Success(null, "Interface deleted successfully"));
        }

        /// <summary>
        /// 发布/取消发布接口
        /// </summary>
        [HttpPut("{id}/publish")]
        public async Task<ActionResult<ApiResponse<object>>> PublishInterface(long id, [FromQuery] bool isPublished)
        {
            var result = await _interfaceService.PublishInterfaceAsync(id, isPublished, GetUserId());
            if (!result) return NotFound(ApiResponse<object>.Error("Interface not found"));
            return Ok(ApiResponse<object>.Success(null, isPublished ? "Interface published" : "Interface unpublished"));
        }

        /// <summary>
        /// 调试接口
        /// </summary>
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
        
        /// <summary>
        /// 调试流程
        /// </summary>
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
