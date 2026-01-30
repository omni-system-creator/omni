using Microsoft.EntityFrameworkCore;
using omsapi.Data;
using omsapi.Infrastructure.Attributes;
using omsapi.Models.Dtos;
using omsapi.Models.Entities;
using omsapi.Services.Interfaces;
using System.Security.Claims;

namespace omsapi.Services
{
    [AutoInject(ServiceLifetime.Scoped)]
    public class UserConfigService : IUserConfigService
    {
        private readonly OmsContext _context;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public UserConfigService(OmsContext context, IHttpContextAccessor httpContextAccessor)
        {
            _context = context;
            _httpContextAccessor = httpContextAccessor;
        }

        private long GetCurrentUserId()
        {
            var userIdStr = _httpContextAccessor.HttpContext?.User?.FindFirst("id")?.Value;
            if (long.TryParse(userIdStr, out var userId))
            {
                return userId;
            }
            throw new UnauthorizedAccessException("User not authenticated");
        }

        private async Task<long?> GetCurrentOrgIdAsync()
        {
            var userId = GetCurrentUserId();
            var user = await _context.Users.AsNoTracking()
                .Where(u => u.Id == userId)
                .Select(u => new { u.CurrentOrgId })
                .FirstOrDefaultAsync();
            return user?.CurrentOrgId;
        }

        public async Task<(bool Success, string Message, List<UserConfigDto>? Data)> GetConfigsAsync(string? prefix = null)
        {
            var userId = GetCurrentUserId();
            var orgId = await GetCurrentOrgIdAsync();

            if (!orgId.HasValue) return (false, "当前未选择组织", null);

            var query = _context.Set<SystemUserConfig>()
                .Where(c => c.UserId == userId && c.OrgId == orgId.Value);

            if (!string.IsNullOrEmpty(prefix))
            {
                query = query.Where(c => c.Key.StartsWith(prefix));
            }

            var configs = await query
                .Select(c => new UserConfigDto
                {
                    Key = c.Key,
                    Value = c.Value,
                    Description = c.Description
                })
                .ToListAsync();

            return (true, "获取成功", configs);
        }

        public async Task<(bool Success, string Message)> SetConfigAsync(UserConfigDto dto)
        {
            var userId = GetCurrentUserId();
            var orgId = await GetCurrentOrgIdAsync();

            if (!orgId.HasValue) return (false, "当前未选择组织");

            var config = await _context.Set<SystemUserConfig>()
                .FirstOrDefaultAsync(c => c.UserId == userId && c.OrgId == orgId.Value && c.Key == dto.Key);

            if (config == null)
            {
                config = new SystemUserConfig
                {
                    UserId = userId,
                    OrgId = orgId.Value,
                    Key = dto.Key,
                    Value = dto.Value,
                    Description = dto.Description,
                    CreatedAt = DateTime.Now
                };
                _context.Set<SystemUserConfig>().Add(config);
            }
            else
            {
                config.Value = dto.Value;
                if (!string.IsNullOrEmpty(dto.Description))
                {
                    config.Description = dto.Description;
                }
                config.UpdatedAt = DateTime.Now;
            }

            await _context.SaveChangesAsync();
            return (true, "保存成功");
        }

        public async Task<(bool Success, string Message)> DeleteConfigAsync(string key)
        {
            var userId = GetCurrentUserId();
            var orgId = await GetCurrentOrgIdAsync();

            if (!orgId.HasValue) return (false, "当前未选择组织");

            var config = await _context.Set<SystemUserConfig>()
                .FirstOrDefaultAsync(c => c.UserId == userId && c.OrgId == orgId.Value && c.Key == key);

            if (config == null) return (false, "配置不存在");

            _context.Set<SystemUserConfig>().Remove(config);
            await _context.SaveChangesAsync();

            return (true, "删除成功");
        }
    }
}
