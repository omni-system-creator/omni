using Microsoft.EntityFrameworkCore;
using omsapi.Data;
using omsapi.Infrastructure.Attributes;
using omsapi.Models.Dtos;
using omsapi.Services.Interfaces;
using Microsoft.AspNetCore.Http;
using omsapi.Models.Entities;
using Microsoft.AspNetCore.Hosting;
using omsapi.Models.Enums;

namespace omsapi.Services
{
    [AutoInject(ServiceLifetime.Scoped)]
    public class SystemConfigService : ISystemConfigService
    {
        private readonly OmsContext _context;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly IWebHostEnvironment _env;

        public SystemConfigService(OmsContext context, IHttpContextAccessor httpContextAccessor, IWebHostEnvironment env)
        {
            _context = context;
            _httpContextAccessor = httpContextAccessor;
            _env = env;
        }

        private async Task<long?> GetCurrentOrgIdAsync()
        {
            var userIdStr = _httpContextAccessor.HttpContext?.User?.FindFirst("id")?.Value;
            if (long.TryParse(userIdStr, out var userId))
            {
                var user = await _context.Users.FindAsync(userId);
                return user?.CurrentOrgId;
            }
            return null;
        }

        public async Task<(bool Success, string Message, List<SystemConfigDto>? Data)> GetAllConfigsAsync()
        {
            var orgId = await GetCurrentOrgIdAsync();
            
            // 1. Get all global configs
            var globalConfigs = await _context.SystemConfigs
                .Where(c => c.OrgId == null)
                .ToListAsync();

            // 2. Get org overrides if any
            List<SystemConfig> orgConfigs = new();
            if (orgId.HasValue)
            {
                orgConfigs = await _context.SystemConfigs
                    .Where(c => c.OrgId == orgId)
                    .ToListAsync();
            }

            var result = new List<SystemConfigDto>();

            foreach (var global in globalConfigs)
            {
                var orgConfig = orgConfigs.FirstOrDefault(c => c.Key == global.Key);
                var effective = orgConfig ?? global;

                result.Add(new SystemConfigDto
                {
                    Id = effective.Id,
                    Category = global.Category,
                    Key = global.Key,
                    Type = global.Type,
                    Value = effective.Value,
                    Description = effective.Description ?? global.Description,
                    IsSystem = global.IsSystem,
                    OrgId = effective.OrgId,
                    IsOverridable = global.IsOverridable,
                    CreatedAt = effective.CreatedAt,
                    UpdatedAt = effective.UpdatedAt
                });
            }

            return (true, "获取成功", result.OrderBy(c => c.Category).ThenBy(c => c.Key).ToList());
        }

        public async Task<(bool Success, string Message, SystemConfigDto? Data)> GetConfigByKeyAsync(string key)
        {
            var orgId = await GetCurrentOrgIdAsync();
            
            var globalConfig = await _context.SystemConfigs.FirstOrDefaultAsync(c => c.Key == key && c.OrgId == null);
            if (globalConfig == null) return (false, "配置不存在", null);

            SystemConfig? orgConfig = null;
            if (orgId.HasValue)
            {
                orgConfig = await _context.SystemConfigs.FirstOrDefaultAsync(c => c.Key == key && c.OrgId == orgId);
            }

            var effective = orgConfig ?? globalConfig;

            var dto = new SystemConfigDto
            {
                Id = effective.Id,
                Category = globalConfig.Category,
                Key = globalConfig.Key,
                Type = globalConfig.Type,
                Value = effective.Value,
                Description = effective.Description ?? globalConfig.Description,
                IsSystem = globalConfig.IsSystem,
                OrgId = effective.OrgId,
                IsOverridable = globalConfig.IsOverridable,
                CreatedAt = effective.CreatedAt,
                UpdatedAt = effective.UpdatedAt
            };

            return (true, "获取成功", dto);
        }

        public async Task<(bool Success, string Message)> UpdateConfigAsync(long id, UpdateSystemConfigDto dto)
        {
            var config = await _context.SystemConfigs.FindAsync(id);
            if (config == null) return (false, "配置不存在");

            var orgId = await GetCurrentOrgIdAsync();

            // Check if we are updating a global config or an org override
            if (config.OrgId == null)
            {
                // It is a global config
                if (orgId.HasValue)
                {
                    // User belongs to an Org, so they are trying to override
                    if (!config.IsOverridable)
                    {
                        return (false, "该配置项不允许修改");
                    }

                    // Create override
                    var newConfig = new SystemConfig
                    {
                        Category = config.Category,
                        Key = config.Key,
                        Type = config.Type,
                        Value = dto.Value,
                        Description = dto.Description ?? config.Description,
                        IsSystem = false,
                        OrgId = orgId,
                        IsOverridable = true
                    };
                    _context.SystemConfigs.Add(newConfig);
                    await _context.SaveChangesAsync();
                    return (true, "设置已更新（组织特定）");
                }
                else
                {
                    // User does NOT belong to an Org (System Admin in Global Context)
                    if (config.Value != dto.Value)
                    {
                        DeleteConfigFile(config);
                    }
                    config.Value = dto.Value;
                    if (dto.Description != null) config.Description = dto.Description;
                    config.UpdatedAt = DateTime.Now;
                    await _context.SaveChangesAsync();
                    return (true, "全局设置已更新");
                }
            }
            else
            {
                // It is an existing org config
                if (orgId.HasValue && config.OrgId != orgId)
                {
                    return (false, "无权修改其他组织的配置");
                }
                
                if (config.Value != dto.Value)
                {
                    DeleteConfigFile(config);
                }
                config.Value = dto.Value;
                if (dto.Description != null) config.Description = dto.Description;
                config.UpdatedAt = DateTime.Now;
                await _context.SaveChangesAsync();
                return (true, "更新成功");
            }
        }

        public async Task<(bool Success, string Message)> DeleteConfigAsync(long id)
        {
            var config = await _context.SystemConfigs.FindAsync(id);
            if (config == null) return (false, "配置不存在");

            var orgId = await GetCurrentOrgIdAsync();

            if (config.OrgId == null)
            {
                // Global Config
                if (orgId.HasValue)
                {
                    return (false, "无法删除全局配置");
                }
                
                if (config.IsSystem)
                {
                    return (false, "系统内置配置无法删除");
                }

                DeleteConfigFile(config);
                _context.SystemConfigs.Remove(config);
                await _context.SaveChangesAsync();
                return (true, "全局配置已删除");
            }
            else
            {
                // Org Config
                if (orgId.HasValue && config.OrgId != orgId)
                {
                    return (false, "无权删除其他组织的配置");
                }

                DeleteConfigFile(config);
                _context.SystemConfigs.Remove(config);
                await _context.SaveChangesAsync();
                return (true, "配置重置成功（已恢复默认值）");
            }
        }

        private void DeleteConfigFile(SystemConfig config)
        {
            if ((config.Type == ConfigType.Image || config.Type == ConfigType.File) && !string.IsNullOrEmpty(config.Value))
            {
                try 
                {
                    // Check if value is a local path (starts with /uploads/system/)
                    if (config.Value.StartsWith("/uploads/system/", StringComparison.OrdinalIgnoreCase))
                    {
                         var webRootPath = _env.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
                         var relativePath = config.Value.TrimStart('/');
                         var fullPath = Path.Combine(webRootPath, relativePath.Replace('/', Path.DirectorySeparatorChar));
                         
                         if (File.Exists(fullPath))
                         {
                             File.Delete(fullPath);
                         }
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error deleting config file: {ex.Message}");
                }
            }
        }
    }
}
