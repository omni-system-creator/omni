using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using omsapi.Models.Common;
using omsapi.Models.Dtos;
using omsapi.Services.Interfaces;
using System.Security.Claims;

namespace omsapi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class FileController : ControllerBase
    {
        private readonly IFileService _fileService;

        public FileController(IFileService fileService)
        {
            _fileService = fileService;
        }

        private long GetCurrentUserId()
        {
            var userIdClaim = User.FindFirst("id");
            if (userIdClaim == null || !long.TryParse(userIdClaim.Value, out long userId))
            {
                throw new UnauthorizedAccessException("User ID not found in token");
            }
            return userId;
        }

        [HttpGet]
        public async Task<ApiResponse<List<FileDto>>> GetFiles([FromQuery] FileQueryDto query)
        {
            try
            {
                var userId = GetCurrentUserId();
                
                // If not querying a specific department and not specified owner, default to current user
                // Unless querying for public files
                if (!query.DeptId.HasValue && !query.OwnerId.HasValue && (!query.IsPublic.HasValue || !query.IsPublic.Value))
                {
                    query.OwnerId = userId;
                }

                var (success, message, data) = await _fileService.GetFilesAsync(query, userId);
                if (!success) return ApiResponse<List<FileDto>>.Error(message);

                return ApiResponse<List<FileDto>>.Success(data, message);
            }
            catch (Exception ex)
            {
                return ApiResponse<List<FileDto>>.Error(ex.Message);
            }
        }

        [HttpPost("folder")]
        public async Task<ApiResponse<FileDto>> CreateFolder([FromBody] CreateFolderDto dto)
        {
            try
            {
                var userId = GetCurrentUserId();
                var (success, message, data) = await _fileService.CreateFolderAsync(dto, userId);
                
                if (!success) return ApiResponse<FileDto>.Error(message);
                return ApiResponse<FileDto>.Success(data, message);
            }
            catch (Exception ex)
            {
                return ApiResponse<FileDto>.Error(ex.Message);
            }
        }

        [HttpPost("upload")]
        public async Task<ApiResponse<FileDto>> UploadFile(IFormFile file, [FromForm] long? parentId, [FromForm] long? deptId, [FromForm] bool isPublic = false)
        {
            try
            {
                var userId = GetCurrentUserId();
                var (success, message, data) = await _fileService.UploadFileAsync(file, parentId, userId, deptId, isPublic);
                
                if (!success) return ApiResponse<FileDto>.Error(message);
                return ApiResponse<FileDto>.Success(data, message);
            }
            catch (Exception ex)
            {
                return ApiResponse<FileDto>.Error(ex.Message);
            }
        }

        [HttpPut("{id}")]
        public async Task<ApiResponse<object>> UpdateFile(long id, [FromBody] UpdateFileDto dto)
        {
            try
            {
                var userId = GetCurrentUserId();
                var (success, message) = await _fileService.UpdateFileAsync(id, dto, userId);
                
                if (!success) return ApiResponse<object>.Error(message);
                return ApiResponse<object>.Success(null, message);
            }
            catch (Exception ex)
            {
                return ApiResponse<object>.Error(ex.Message);
            }
        }

        [HttpDelete("{id}")]
        public async Task<ApiResponse<object>> DeleteFile(long id)
        {
            try
            {
                var userId = GetCurrentUserId();
                var (success, message) = await _fileService.DeleteFileAsync(id, userId);
                
                if (!success) return ApiResponse<object>.Error(message);
                return ApiResponse<object>.Success(null, message);
            }
            catch (Exception ex)
            {
                return ApiResponse<object>.Error(ex.Message);
            }
        }

        [HttpPut("{id}/rename")]
        public async Task<ApiResponse<object>> RenameFile(long id, [FromBody] RenameFileDto dto)
        {
            try
            {
                var userId = GetCurrentUserId();
                var (success, message) = await _fileService.RenameFileAsync(id, dto, userId);
                
                if (!success) return ApiResponse<object>.Error(message);
                return ApiResponse<object>.Success(null, message);
            }
            catch (Exception ex)
            {
                return ApiResponse<object>.Error(ex.Message);
            }
        }

        [HttpGet("{id}/download")]
        public async Task<IActionResult> DownloadFile(long id)
        {
            try
            {
                var userId = GetCurrentUserId();
                var (success, message, contentType, stream, fileName) = await _fileService.DownloadFileAsync(id, userId);
                
                if (!success || stream == null) return NotFound(message);

                return File(stream, contentType ?? "application/octet-stream", fileName);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPost("share")]
        public async Task<ApiResponse<object>> ShareFile([FromBody] ShareFileDto dto)
        {
            try
            {
                var userId = GetCurrentUserId();
                var (success, message) = await _fileService.ShareFileAsync(dto, userId);
                
                if (!success) return ApiResponse<object>.Error(message);
                
                // If it's a public link, 'message' contains the token (based on Service implementation)
                if (dto.IsPublicLink)
                {
                    return ApiResponse<object>.Success(new { Token = message }, "链接生成成功");
                }

                return ApiResponse<object>.Success(null, message);
            }
            catch (Exception ex)
            {
                return ApiResponse<object>.Error(ex.Message);
            }
        }

        [HttpGet("shared/me")]
        public async Task<ApiResponse<List<FileShareDto>>> GetSharedWithMe()
        {
            try
            {
                var userId = GetCurrentUserId();
                var (success, message, data) = await _fileService.GetSharedWithMeAsync(userId);
                
                if (!success) return ApiResponse<List<FileShareDto>>.Error(message);
                return ApiResponse<List<FileShareDto>>.Success(data, message);
            }
            catch (Exception ex)
            {
                return ApiResponse<List<FileShareDto>>.Error(ex.Message);
            }
        }

        [HttpGet("shared/others")]
        public async Task<ApiResponse<List<FileShareDto>>> GetMySharedFiles()
        {
            try
            {
                var userId = GetCurrentUserId();
                var (success, message, data) = await _fileService.GetMySharedFilesAsync(userId);
                
                if (!success) return ApiResponse<List<FileShareDto>>.Error(message);
                return ApiResponse<List<FileShareDto>>.Success(data, message);
            }
            catch (Exception ex)
            {
                return ApiResponse<List<FileShareDto>>.Error(ex.Message);
            }
        }

        [HttpGet("share/public/{token}")]
        [AllowAnonymous]
        public async Task<ApiResponse<FileShareDto>> GetPublicShare(string token)
        {
            try
            {
                var (success, message, data) = await _fileService.GetPublicShareByTokenAsync(token);
                if (!success) return ApiResponse<FileShareDto>.Error(message);
                return ApiResponse<FileShareDto>.Success(data, message);
            }
            catch (Exception ex)
            {
                return ApiResponse<FileShareDto>.Error(ex.Message);
            }
        }

        [HttpGet("share/public/{token}/download")]
        [AllowAnonymous]
        public async Task<IActionResult> DownloadPublicShare(string token)
        {
            try
            {
                var (success, message, contentType, stream, fileName) = await _fileService.DownloadPublicShareAsync(token);
                
                if (!success || stream == null) return NotFound(message);

                return File(stream, contentType ?? "application/octet-stream", fileName);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }
    }
}
