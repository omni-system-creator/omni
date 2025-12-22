using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using omsapi.Models.Common;
using omsapi.Models.Dtos.Archive;
using omsapi.Services.Interfaces;

namespace omsapi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class ArchiveController : ControllerBase
    {
        private readonly IArchiveService _archiveService;

        public ArchiveController(IArchiveService archiveService)
        {
            _archiveService = archiveService;
        }

        #region Fond
        [HttpGet("fond")]
        public async Task<ApiResponse<List<ArchFondDto>>> GetFonds()
        {
            var (success, message, data) = await _archiveService.GetFondsAsync();
            if (!success) return ApiResponse<List<ArchFondDto>>.Error(message);
            return ApiResponse<List<ArchFondDto>>.Success(data!);
        }

        [HttpPost("fond")]
        public async Task<ApiResponse<ArchFondDto>> CreateFond([FromBody] CreateFondDto dto)
        {
            var (success, message, data) = await _archiveService.CreateFondAsync(dto);
            if (!success) return ApiResponse<ArchFondDto>.Error(message);
            return ApiResponse<ArchFondDto>.Success(data!);
        }

        [HttpPut("fond/{id}")]
        public async Task<ApiResponse<object>> UpdateFond(long id, [FromBody] UpdateFondDto dto)
        {
            var (success, message) = await _archiveService.UpdateFondAsync(id, dto);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null, message);
        }

        [HttpDelete("fond/{id}")]
        public async Task<ApiResponse<object>> DeleteFond(long id)
        {
            var (success, message) = await _archiveService.DeleteFondAsync(id);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null, message);
        }
        #endregion

        #region Type
        [HttpGet("type")]
        public async Task<ApiResponse<List<ArchTypeDto>>> GetTypes()
        {
            var (success, message, data) = await _archiveService.GetTypesAsync();
            if (!success) return ApiResponse<List<ArchTypeDto>>.Error(message);
            return ApiResponse<List<ArchTypeDto>>.Success(data!);
        }

        [HttpPost("type")]
        public async Task<ApiResponse<ArchTypeDto>> CreateType([FromBody] CreateArchTypeDto dto)
        {
            var (success, message, data) = await _archiveService.CreateTypeAsync(dto);
            if (!success) return ApiResponse<ArchTypeDto>.Error(message);
            return ApiResponse<ArchTypeDto>.Success(data!);
        }

        [HttpPut("type/{id}")]
        public async Task<ApiResponse<object>> UpdateType(long id, [FromBody] UpdateArchTypeDto dto)
        {
            var (success, message) = await _archiveService.UpdateTypeAsync(id, dto);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null, message);
        }

        [HttpDelete("type/{id}")]
        public async Task<ApiResponse<object>> DeleteType(long id)
        {
            var (success, message) = await _archiveService.DeleteTypeAsync(id);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null, message);
        }
        #endregion

        #region File
        [HttpGet("file")]
        public async Task<ApiResponse<List<ArchFileDto>>> GetArchFiles([FromQuery] ArchQueryDto query)
        {
            var (success, message, data) = await _archiveService.GetArchFilesAsync(query);
            if (!success) return ApiResponse<List<ArchFileDto>>.Error(message);
            return ApiResponse<List<ArchFileDto>>.Success(data!);
        }

        [HttpGet("file/{id}")]
        public async Task<ApiResponse<ArchFileDto>> GetArchFileById(long id)
        {
            var (success, message, data) = await _archiveService.GetArchFileByIdAsync(id);
            if (!success) return ApiResponse<ArchFileDto>.Error(message);
            return ApiResponse<ArchFileDto>.Success(data!);
        }

        [HttpPost("file")]
        public async Task<ApiResponse<ArchFileDto>> CreateArchFile([FromBody] CreateArchFileDto dto)
        {
            var userIdClaim = User.FindFirst("id");
            long userId = 0;
            if (userIdClaim != null)
            {
                long.TryParse(userIdClaim.Value, out userId);
            }

            var (success, message, data) = await _archiveService.CreateArchFileAsync(dto, userId);
            if (!success) return ApiResponse<ArchFileDto>.Error(message);
            return ApiResponse<ArchFileDto>.Success(data!);
        }

        [HttpPut("file/{id}")]
        public async Task<ApiResponse<object>> UpdateArchFile(long id, [FromBody] UpdateArchFileDto dto)
        {
            var (success, message) = await _archiveService.UpdateArchFileAsync(id, dto);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null, message);
        }

        [HttpDelete("file/{id}")]
        public async Task<ApiResponse<object>> DeleteArchFile(long id)
        {
            var (success, message) = await _archiveService.DeleteArchFileAsync(id);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null, message);
        }
        #endregion
    }
}
