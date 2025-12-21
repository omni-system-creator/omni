using Microsoft.EntityFrameworkCore;
using omsapi.Data;
using omsapi.Infrastructure.Attributes;
using omsapi.Models.Dtos;
using omsapi.Services.Interfaces;

namespace omsapi.Services
{
    [AutoInject(ServiceLifetime.Scoped)]
    public class SystemConfigService : ISystemConfigService
    {
        private readonly OmsContext _context;

        public SystemConfigService(OmsContext context)
        {
            _context = context;
        }

        public async Task<(bool Success, string Message, List<SystemConfigDto>? Data)> GetAllConfigsAsync()
        {
            var configs = await _context.SystemConfigs
                .OrderBy(c => c.Category)
                .ThenBy(c => c.Key)
                .Select(c => new SystemConfigDto
                {
                    Id = c.Id,
                    Category = c.Category,
                    Key = c.Key,
                    Value = c.Value,
                    Description = c.Description,
                    IsSystem = c.IsSystem,
                    CreatedAt = c.CreatedAt,
                    UpdatedAt = c.UpdatedAt
                })
                .ToListAsync();

            return (true, "获取成功", configs);
        }

        public async Task<(bool Success, string Message, SystemConfigDto? Data)> GetConfigByKeyAsync(string key)
        {
            var config = await _context.SystemConfigs.FirstOrDefaultAsync(c => c.Key == key);
            if (config == null)
            {
                return (false, "配置不存在", null);
            }

            var dto = new SystemConfigDto
            {
                Id = config.Id,
                Category = config.Category,
                Key = config.Key,
                Value = config.Value,
                Description = config.Description,
                IsSystem = config.IsSystem,
                CreatedAt = config.CreatedAt,
                UpdatedAt = config.UpdatedAt
            };

            return (true, "获取成功", dto);
        }

        public async Task<(bool Success, string Message)> UpdateConfigAsync(long id, UpdateSystemConfigDto dto)
        {
            var config = await _context.SystemConfigs.FindAsync(id);
            if (config == null)
            {
                return (false, "配置不存在");
            }

            config.Value = dto.Value;
            if (dto.Description != null)
            {
                config.Description = dto.Description;
            }
            config.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();
            return (true, "更新成功");
        }
    }
}
