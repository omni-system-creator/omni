using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using omsapi.Models.Common;
using omsapi.Models.Dtos.BigView;
using omsapi.Services.Interfaces;
using System.Security.Claims;

namespace omsapi.Controllers
{
    /// <summary>
    /// 大屏项目管理控制器
    /// </summary>
    [Route("api/bigview/project")]
    [ApiController]
    public class BigViewProjectController : ControllerBase
    {
        private readonly IBigViewProjectService _service;

        public BigViewProjectController(IBigViewProjectService service)
        {
            _service = service;
        }

        /// <summary>
        /// 获取项目列表
        /// </summary>
        [HttpGet("list")]
        public async Task<ApiResponse<object>> GetList([FromQuery] int page = 1, [FromQuery] int limit = 10, [FromQuery] string? keyword = null)
        {
            var (success, message, data, total) = await _service.GetListAsync(page, limit, keyword);
            if (!success) return ApiResponse<object>.Error(message);
            
            return ApiResponse<object>.Success(new { rows = data, total = total });
        }

        /// <summary>
        /// 获取项目详情
        /// </summary>
        [HttpGet("detail")]
        public async Task<ApiResponse<BigViewProjectDto>> GetDetail([FromQuery] long id)
        {
            var (success, message, data) = await _service.GetByIdAsync(id);
            if (!success) return ApiResponse<BigViewProjectDto>.Error(message);
            return ApiResponse<BigViewProjectDto>.Success(data!);
        }

        /// <summary>
        /// 创建项目
        /// </summary>
        [HttpPost("create")]
        public async Task<ApiResponse<long>> Create([FromBody] CreateBigViewProjectDto dto)
        {
            var userIdStr = User.FindFirst("id")?.Value;
            long userId = 0;
            if (userIdStr != null) long.TryParse(userIdStr, out userId);

            var (success, message, id) = await _service.CreateAsync(dto, userId);
            if (!success) return ApiResponse<long>.Error(message);
            return ApiResponse<long>.Success(id);
        }

        /// <summary>
        /// 更新项目
        /// </summary>
        [HttpPost("update")]
        public async Task<ApiResponse<object>> Update([FromBody] UpdateBigViewProjectDto dto)
        {
            var (success, message) = await _service.UpdateAsync(dto);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null);
        }

        /// <summary>
        /// 删除项目
        /// </summary>
        [HttpDelete("delete")]
        public async Task<ApiResponse<object>> Delete([FromQuery] string? ids, [FromQuery] long? id)
        {
            if (string.IsNullOrEmpty(ids) && id.HasValue)
            {
                ids = id.Value.ToString();
            }

            if (string.IsNullOrEmpty(ids))
            {
                return ApiResponse<object>.Error("IDs or ID required");
            }

            var (success, message) = await _service.DeleteAsync(ids);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null);
        }
        
        /// <summary>
        /// 发布/取消发布项目
        /// </summary>
        [HttpPost("publish")]
        public async Task<ApiResponse<object>> Publish([FromBody] PublishBigViewProjectDto dto)
        {
             var (success, message) = await _service.ChangeReleaseStateAsync(dto.Id, dto.State);
             if (!success) return ApiResponse<object>.Error(message);
             return ApiResponse<object>.Success(null);
        }
    }
}
