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

        // --- 管理员接口 ---

        [HttpGet]
        //[Authorize(Roles = "ADMIN")] // 暂不开启严格的角色验证，方便调试
        public async Task<ApiResponse<List<UserListDto>>> GetAll()
        {
            var (success, message, data) = await _userService.GetAllUsersAsync();
            if (!success) return ApiResponse<List<UserListDto>>.Error(message);
            return ApiResponse<List<UserListDto>>.Success(data!);
        }

        [HttpGet("{id}")]
        public async Task<ApiResponse<UserListDto>> GetById(long id)
        {
            var (success, message, data) = await _userService.GetUserByIdAsync(id);
            if (!success) return ApiResponse<UserListDto>.Error(message);
            return ApiResponse<UserListDto>.Success(data!);
        }

        [HttpPost]
        public async Task<ApiResponse<object>> Create([FromBody] CreateUserDto dto)
        {
            var (success, message) = await _userService.CreateUserAsync(dto);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null, message);
        }

        [HttpPut("{id}")]
        public async Task<ApiResponse<object>> Update(long id, [FromBody] UpdateUserDto dto)
        {
            var (success, message) = await _userService.UpdateUserAsync(id, dto);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null, message);
        }

        [HttpDelete("{id}")]
        public async Task<ApiResponse<object>> Delete(long id)
        {
            var (success, message) = await _userService.DeleteUserAsync(id);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null, message);
        }

        [HttpPost("{id}/reset-password")]
        public async Task<ApiResponse<object>> ResetPassword(long id, [FromBody] ResetPasswordDto dto)
        {
            // 管理员重置密码，只需要新密码
            if (string.IsNullOrEmpty(dto.NewPassword))
            {
                return ApiResponse<object>.Error("新密码不能为空");
            }
            var (success, message) = await _userService.ResetPasswordAsync(id, dto.NewPassword);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null, message);
        }
    }
}