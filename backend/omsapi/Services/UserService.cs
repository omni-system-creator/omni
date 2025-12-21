using Microsoft.EntityFrameworkCore;
using omsapi.Data;
using omsapi.Models.Dtos;
using omsapi.Services.Interfaces;

using omsapi.Infrastructure.Attributes;

namespace omsapi.Services
{
    [AutoInject(ServiceLifetime.Scoped)]
    public class UserService : IUserService
    {
        private readonly OmsContext _context;
        private readonly IWebHostEnvironment _environment;

        public UserService(OmsContext context, IWebHostEnvironment environment)
        {
            _context = context;
            _environment = environment;
        }

        public async Task<(bool Success, string Message, string? AvatarUrl)> UploadAvatarAsync(long userId, IFormFile file)
        {
            if (file == null || file.Length == 0)
            {
                return (false, "请选择文件", null);
            }

            // 验证文件类型
            var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".gif" };
            var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
            if (!allowedExtensions.Contains(extension))
            {
                return (false, "仅支持 jpg, jpeg, png, gif 格式的图片", null);
            }

            // 验证文件大小 (例如 2MB)
            if (file.Length > 2 * 1024 * 1024)
            {
                return (false, "图片大小不能超过 2MB", null);
            }

            try
            {
                // 确保存储目录存在
                var uploadPath = Path.Combine(_environment.WebRootPath, "uploads", "avatars");
                if (!Directory.Exists(uploadPath))
                {
                    Directory.CreateDirectory(uploadPath);
                }

                // 生成唯一文件名
                var fileName = $"{userId}_{Guid.NewGuid()}{extension}";
                var filePath = Path.Combine(uploadPath, fileName);

                // 保存文件
                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await file.CopyToAsync(stream);
                }

                // 更新数据库
                var user = await _context.Users.FindAsync(userId);
                if (user == null)
                {
                    return (false, "用户不存在", null);
                }

                // 如果存在旧头像，删除旧文件
                if (!string.IsNullOrEmpty(user.Avatar))
                {
                    // 从 URL 解析出文件路径
                    // URL 格式通常是 /uploads/avatars/filename.ext
                    // 我们需要将其转换为物理路径
                    var oldAvatarPath = Path.Combine(_environment.WebRootPath, user.Avatar.TrimStart('/').Replace('/', Path.DirectorySeparatorChar));
                    
                    if (File.Exists(oldAvatarPath))
                    {
                        try
                        {
                            File.Delete(oldAvatarPath);
                        }
                        catch (Exception deleteEx)
                        {
                            // 删除失败不影响上传流程，仅记录日志或忽略
                            // Console.WriteLine($"删除旧头像失败: {deleteEx.Message}");
                        }
                    }
                }
                
                var avatarUrl = $"/uploads/avatars/{fileName}";
                user.Avatar = avatarUrl;
                await _context.SaveChangesAsync();

                return (true, "上传成功", avatarUrl);
            }
            catch (Exception ex)
            {
                // 记录日志
                return (false, $"上传失败: {ex.Message}", null);
            }
        }

        public async Task<(bool Success, string Message, UserDto? Data)> GetCurrentUserAsync(long userId)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null)
            {
                return (false, "用户不存在", null);
            }

            var userDto = new UserDto
            {
                Id = user.Id,
                Username = user.Username,
                Nickname = user.Nickname,
                Email = user.Email,
                Phone = user.Phone,
                Avatar = user.Avatar
            };

            return (true, "获取成功", userDto);
        }
        private string ComputeSha256Hash(string rawData)
        {
            using (var sha256Hash = System.Security.Cryptography.SHA256.Create())
            {
                var bytes = sha256Hash.ComputeHash(System.Text.Encoding.UTF8.GetBytes(rawData));
                var builder = new System.Text.StringBuilder();
                for (int i = 0; i < bytes.Length; i++)
                {
                    builder.Append(bytes[i].ToString("x2"));
                }
                return builder.ToString();
            }
        }

        public async Task<(bool Success, string Message)> UpdateProfileAsync(long userId, UpdateProfileDto dto)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null)
            {
                return (false, "用户不存在");
            }

            user.Nickname = dto.Nickname;
            user.Email = dto.Email;
            user.Phone = dto.Phone;

            await _context.SaveChangesAsync();
            return (true, "资料更新成功");
        }

        public async Task<(bool Success, string Message)> ChangePasswordAsync(long userId, ChangePasswordDto dto)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null)
            {
                return (false, "用户不存在");
            }

            var oldPasswordHash = ComputeSha256Hash(dto.OldPassword);
            if (user.Password != oldPasswordHash)
            {
                return (false, "旧密码错误");
            }

            user.Password = ComputeSha256Hash(dto.NewPassword);
            await _context.SaveChangesAsync();
            return (true, "密码修改成功");
        }
    }
}
