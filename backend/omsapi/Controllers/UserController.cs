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
    [Authorize] // 需要登录
    public class UserController : ControllerBase
    {
        private readonly IUserService _userService;

        public UserController(IUserService userService)
        {
            _userService = userService;
        }

        [HttpPost("avatar")]
        public async Task<ApiResponse<object>> UploadAvatar(IFormFile file)
        {
            // 获取当前用户ID
            var userIdClaim = User.FindFirst("id");
            if (userIdClaim == null || !long.TryParse(userIdClaim.Value, out long userId))
            {
                return ApiResponse<object>.Error("无法获取用户信息", 401);
            }

            var (success, message, avatarUrl) = await _userService.UploadAvatarAsync(userId, file);

            if (!success)
            {
                return ApiResponse<object>.Error(message, 400);
            }

            return ApiResponse<object>.Success(new { avatarUrl }, message);
        }

        [HttpGet("me")]
        public async Task<ApiResponse<object>> GetCurrentUser()
        {
            var userIdClaim = User.FindFirst("id");
            if (userIdClaim == null || !long.TryParse(userIdClaim.Value, out long userId))
            {
                return ApiResponse<object>.Error("无法获取用户信息", 401);
            }

            var (success, message, data) = await _userService.GetCurrentUserAsync(userId);

            if (!success)
            {
                return ApiResponse<object>.Error(message, 400);
            }

            return ApiResponse<object>.Success(data);
        }

        [HttpPut("profile")]
        public async Task<ApiResponse<object>> UpdateProfile([FromBody] UpdateProfileDto dto)
        {
            var userIdClaim = User.FindFirst("id");
            if (userIdClaim == null || !long.TryParse(userIdClaim.Value, out long userId))
            {
                return ApiResponse<object>.Error("无法获取用户信息", 401);
            }

            var (success, message) = await _userService.UpdateProfileAsync(userId, dto);

            if (!success)
            {
                return ApiResponse<object>.Error(message, 400);
            }

            return ApiResponse<object>.Success(null, message);
        }

        [HttpPost("change-password")]
        public async Task<ApiResponse<object>> ChangePassword([FromBody] ChangePasswordDto dto)
        {
            var userIdClaim = User.FindFirst("id");
            if (userIdClaim == null || !long.TryParse(userIdClaim.Value, out long userId))
            {
                return ApiResponse<object>.Error("无法获取用户信息", 401);
            }

            var (success, message) = await _userService.ChangePasswordAsync(userId, dto);

            if (!success)
            {
                return ApiResponse<object>.Error(message, 400);
            }

            return ApiResponse<object>.Success(null, message);
        }
    }
}