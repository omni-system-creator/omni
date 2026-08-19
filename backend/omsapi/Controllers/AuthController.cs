using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using omsapi.Models.Common;
using omsapi.Models.Dtos;
using omsapi.Services.Interfaces;

namespace omsapi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        [HttpPost("login")]
        public async Task<ApiResponse<object>> Login([FromBody] LoginRequest request)
        {
            var (success, message, data) = await _authService.LoginAsync(request);

            if (!success)
            {
                return ApiResponse<object>.Error(message, 400);
            }

            return ApiResponse<object>.Success(data);
        }

        /// <summary>
        /// 管理员模拟登录指定用户
        /// </summary>
        [HttpPost("impersonate/{targetUserId:long}")]
        [Authorize]
        public async Task<ApiResponse<object>> Impersonate(long targetUserId)
        {
            var userIdClaim = User.FindFirst("id");
            if (userIdClaim == null || !long.TryParse(userIdClaim.Value, out long operatorUserId))
            {
                return ApiResponse<object>.Error("无法获取当前用户信息", 401);
            }

            var (success, message, data) = await _authService.ImpersonateAsync(operatorUserId, targetUserId);
            if (!success)
            {
                return ApiResponse<object>.Error(message, 400);
            }

            return ApiResponse<object>.Success(data, message);
        }

        [HttpPost("register")]
        public async Task<ApiResponse<object>> Register([FromBody] RegisterRequest request)
        {
            var (success, message, data) = await _authService.RegisterAsync(request);

            if (!success)
            {
                return ApiResponse<object>.Error(message, 400);
            }

            return ApiResponse<object>.Success(data, message);
        }

        [HttpPost("upload-registration-file")]
        [AllowAnonymous]
        public async Task<ApiResponse<object>> UploadRegistrationFile(IFormFile file)
        {
            var (success, message, url) = await _authService.UploadRegistrationFileAsync(file);
             if (!success)
            {
                return ApiResponse<object>.Error(message, 400);
            }
            return ApiResponse<object>.Success(new { Url = url }, message);
        }

        /// <summary>
        /// 注册页"未点提交就删除上传的证照/授权书"时清理已上传的物理文件，避免产生大量垃圾。
        /// 注意：底层 IAuthService 已做路径白名单（仅限 /uploads/registration/）和路径穿越双重保护，不需要登录也可安全调用。
        /// </summary>
        [HttpPost("delete-registration-file")]
        [AllowAnonymous]
        public async Task<ApiResponse<object>> DeleteRegistrationFile([FromBody] DeleteRegistrationFileRequest request)
        {
            var (success, message) = await _authService.DeleteRegistrationFileAsync(request.FileUrl);
            if (!success)
            {
                return ApiResponse<object>.Error(message, 400);
            }
            return ApiResponse<object>.Success(null, message);
        }

        /// <summary>
        /// 删除注册上传文件的请求 DTO（单文件）。单独写类是为了兼容 ASP.NET Core FromBody 绑定 JSON Body。
        /// </summary>
        public class DeleteRegistrationFileRequest
        {
            public string FileUrl { get; set; } = string.Empty;
        }

        [HttpPost("recognize-license")]
        [AllowAnonymous]
        public async Task<ApiResponse<object>> RecognizeLicense(IFormFile file)
        {
            var (success, message, data) = await _authService.RecognizeLicenseAsync(file);
            if (!success)
            {
                return ApiResponse<object>.Error(message, 400);
            }
            return ApiResponse<object>.Success(data, message);
        }


        [HttpGet("routes")]
        [Authorize]
        public async Task<ApiResponse<List<MenuItemDto>>> GetRoutes()
        {
            var userIdClaim = User.FindFirst("id");
            if (userIdClaim == null || !long.TryParse(userIdClaim.Value, out long userId))
            {
                return ApiResponse<List<MenuItemDto>>.Error("无法获取用户信息", 401);
            }

            var (success, message, data) = await _authService.GetUserRoutesAsync(userId);
            if (!success) return ApiResponse<List<MenuItemDto>>.Error(message);
            return ApiResponse<List<MenuItemDto>>.Success(data!);
        }

        [HttpGet("permissions")]
        [Authorize]
        public async Task<ApiResponse<List<string>>> GetPermissions()
        {
            var userIdClaim = User.FindFirst("id");
            if (userIdClaim == null || !long.TryParse(userIdClaim.Value, out long userId))
            {
                return ApiResponse<List<string>>.Error("无法获取用户信息", 401);
            }

            var (success, message, data) = await _authService.GetUserPermissionsAsync(userId);
            if (!success) return ApiResponse<List<string>>.Error(message);
            return ApiResponse<List<string>>.Success(data!);
        }
    }
}
