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
