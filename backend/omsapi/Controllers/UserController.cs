using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using omsapi.Models.Common;
using omsapi.Models.Dtos;
using omsapi.Services.Interfaces;
using System.Security.Claims;

namespace omsapi.Controllers
{
    /// <summary>
    /// 用户管理控制器
    /// </summary>
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

        /// <summary>
        /// 上传头像
        /// </summary>
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

        /// <summary>
        /// 获取当前用户
        /// </summary>
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

        /// <summary>
        /// 获取当前用户的组织列表
        /// </summary>
        [HttpPost("switch-org/{orgId}")]
        public async Task<ApiResponse<bool>> SwitchOrg(long orgId)
        {
            var userIdClaim = User.FindFirst("id");
            if (userIdClaim == null || !long.TryParse(userIdClaim.Value, out long userId))
            {
                return ApiResponse<bool>.Error("无法获取用户信息", 401);
            }
            var result = await _userService.SwitchOrganizationAsync(userId, orgId);
            if (result.Success)
            {
                return ApiResponse<bool>.Success(true, result.Message);
            }
            return ApiResponse<bool>.Error(result.Message);
        }

        [HttpGet("orgs")]
        public async Task<ApiResponse<List<UserOrgDto>>> GetMyOrgs()
        {
            var userIdClaim = User.FindFirst("id");
            if (userIdClaim == null || !long.TryParse(userIdClaim.Value, out long userId))
            {
                return ApiResponse<List<UserOrgDto>>.Error("无法获取用户信息", 401);
            }

            var data = await _userService.GetUserOrganizationsAsync(userId);
            return ApiResponse<List<UserOrgDto>>.Success(data);
        }

        /// <summary>
        /// 更新个人资料
        /// </summary>
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

        /// <summary>
        /// 修改密码
        /// </summary>
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

        /// <summary>
        /// 获取所有用户
        /// </summary>
        [HttpGet]
        //[Authorize(Roles = "ADMIN")] // 暂不开启严格的角色验证，方便调试
        public async Task<ApiResponse<List<UserListDto>>> GetAll()
        {
            var userIdClaim = User.FindFirst("id");
            if (userIdClaim == null || !long.TryParse(userIdClaim.Value, out long userId))
            {
                return ApiResponse<List<UserListDto>>.Error("无法获取用户信息", 401);
            }
            var (success, message, data) = await _userService.GetAllUsersAsync(userId);
            if (!success) return ApiResponse<List<UserListDto>>.Error(message);
            return ApiResponse<List<UserListDto>>.Success(data!);
        }

        /// <summary>
        /// 获取用户详情
        /// </summary>
        [HttpGet("{id}")]
        public async Task<ApiResponse<UserListDto>> GetById(long id)
        {
            var (success, message, data) = await _userService.GetUserByIdAsync(id);
            if (!success) return ApiResponse<UserListDto>.Error(message);
            return ApiResponse<UserListDto>.Success(data!);
        }

        /// <summary>
        /// 创建用户
        /// </summary>
        [HttpPost]
        public async Task<ApiResponse<object>> Create([FromBody] CreateUserDto dto)
        {
            var (success, message) = await _userService.CreateUserAsync(dto);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null, message);
        }

        /// <summary>
        /// 更新用户
        /// </summary>
        [HttpPut("{id}")]
        public async Task<ApiResponse<object>> Update(long id, [FromBody] UpdateUserDto dto)
        {
            var (success, message) = await _userService.UpdateUserAsync(id, dto);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null, message);
        }

        /// <summary>
        /// 删除用户
        /// </summary>
        [HttpDelete("{id}")]
        public async Task<ApiResponse<object>> Delete(long id)
        {
            var (success, message) = await _userService.DeleteUserAsync(id);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null, message);
        }

        /// <summary>
        /// 重置密码
        /// </summary>
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
