using Microsoft.AspNetCore.Mvc;
using omsapi.Models.Common;
using omsapi.Models.Dtos.System;
using omsapi.Services.Interfaces;

namespace omsapi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AnonceController : ControllerBase
    {
        private readonly IAnonceService _anonceService;
        // 假设有一个获取当前用户ID的方法或Service，这里简化处理，假设从Claims获取
        // 实际项目中可能有一个 UserContextService

        public AnonceController(IAnonceService anonceService)
        {
            _anonceService = anonceService;
        }

        private long GetCurrentUserId()
        {
            // 简单的从 Claims 获取 UserId，如果没有则返回 0 或抛出异常
            var claim = User.FindFirst("id");
            if (claim != null && long.TryParse(claim.Value, out var id))
            {
                return id;
            }
            return 0; 
        }

        [HttpGet]
        public async Task<ApiResponse<PagedResult<AnonceDto>>> GetList([FromQuery] AnonceQueryDto query)
        {
            var result = await _anonceService.GetListAsync(query);
            return ApiResponse<PagedResult<AnonceDto>>.Success(result);
        }

        [HttpGet("{id}")]
        public async Task<ApiResponse<AnonceDto>> Get(long id)
        {
            var result = await _anonceService.GetByIdAsync(id);
            if (result == null) return ApiResponse<AnonceDto>.Error("Not found");
            return ApiResponse<AnonceDto>.Success(result);
        }

        [HttpPost]
        public async Task<ApiResponse<AnonceDto>> Create([FromBody] CreateAnonceDto dto)
        {
            var userId = GetCurrentUserId();
            var result = await _anonceService.CreateAsync(dto, userId);
            return ApiResponse<AnonceDto>.Success(result);
        }

        [HttpPut("{id}")]
        public async Task<ApiResponse<AnonceDto>> Update(long id, [FromBody] UpdateAnonceDto dto)
        {
            var userId = GetCurrentUserId();
            var result = await _anonceService.UpdateAsync(id, dto, userId);
            if (result == null) return ApiResponse<AnonceDto>.Error("Not found");
            return ApiResponse<AnonceDto>.Success(result);
        }

        [HttpDelete("{id}")]
        public async Task<ApiResponse<bool>> Delete(long id)
        {
            var result = await _anonceService.DeleteAsync(id);
            if (!result) return ApiResponse<bool>.Error("Not found");
            return ApiResponse<bool>.Success(true);
        }

        [HttpPost("{id}/publish")]
        public async Task<ApiResponse<bool>> Publish(long id)
        {
            var result = await _anonceService.PublishAsync(id, true);
            if (!result) return ApiResponse<bool>.Error("Not found");
            return ApiResponse<bool>.Success(true);
        }

        [HttpPost("{id}/revoke")]
        public async Task<ApiResponse<bool>> Revoke(long id)
        {
            var result = await _anonceService.PublishAsync(id, false);
            if (!result) return ApiResponse<bool>.Error("Not found");
            return ApiResponse<bool>.Success(true);
        }
    }
}
