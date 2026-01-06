using Microsoft.EntityFrameworkCore;
using omsapi.Data;
using omsapi.Infrastructure.Attributes;
using omsapi.Models.Dtos;
using omsapi.Services.Interfaces;

namespace omsapi.Services
{
    [AutoInject(ServiceLifetime.Scoped)]
    public class PermissionService : IPermissionService
    {
        private readonly OmsContext _context;

        public PermissionService(OmsContext context)
        {
            _context = context;
        }

        public async Task<(bool Success, string Message, List<PermissionTreeDto>? Data)> GetAllPermissionsAsync()
        {
            var allPerms = await _context.Permissions
                .OrderBy(p => p.SortOrder)
                .Select(p => new PermissionTreeDto
                {
                    Id = p.Id,
                    Name = p.Name,
                    Code = p.Code,
                    Type = p.Type,
                    Icon = p.Icon,
                    Path = p.Path,
                    Component = p.Component,
                    Query = p.Query,
                    SortOrder = p.SortOrder,
                    IsVisible = p.IsVisible,
                    ParentId = p.ParentId
                })
                .ToListAsync();

            var tree = BuildPermissionTree(allPerms, null);
            return (true, "获取成功", tree);
        }

        public async Task<(bool Success, string Message)> CreatePermissionAsync(CreatePermissionDto dto)
        {
            if (await _context.Permissions.AnyAsync(p => p.Code == dto.Code))
            {
                return (false, "权限编码已存在");
            }

            var perm = new omsapi.Models.Entities.SystemPermission
            {
                Name = dto.Name,
                Code = dto.Code,
                Type = dto.Type,
                Icon = dto.Icon,
                Path = dto.Path,
                Component = dto.Component,
                Query = dto.Query,
                ParentId = dto.ParentId,
                SortOrder = dto.SortOrder,
                IsVisible = dto.IsVisible,
                CreatedAt = DateTime.Now
            };

            _context.Permissions.Add(perm);
            await _context.SaveChangesAsync();
            return (true, "创建成功");
        }

        public async Task<(bool Success, string Message)> UpdatePermissionAsync(long id, UpdatePermissionDto dto)
        {
            var perm = await _context.Permissions.FindAsync(id);
            if (perm == null) return (false, "权限不存在");

            if (dto.Code != null && dto.Code != perm.Code)
            {
                if (await _context.Permissions.AnyAsync(p => p.Code == dto.Code))
                {
                    return (false, "权限编码已存在");
                }
            }

            if (dto.Name != null) perm.Name = dto.Name;
            if (dto.Code != null) perm.Code = dto.Code;
            if (dto.Type != null) perm.Type = dto.Type;
            if (dto.Icon != null) perm.Icon = dto.Icon;
            if (dto.Path != null) perm.Path = dto.Path;
            if (dto.Component != null) perm.Component = dto.Component;
            if (dto.Query != null) perm.Query = dto.Query;
            if (dto.ParentId.HasValue) perm.ParentId = dto.ParentId;
            if (dto.SortOrder.HasValue) perm.SortOrder = dto.SortOrder.Value;
            if (dto.IsVisible.HasValue) perm.IsVisible = dto.IsVisible.Value;
            
            perm.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();
            return (true, "更新成功");
        }

        public async Task<(bool Success, string Message)> DeletePermissionAsync(long id)
        {
            var perm = await _context.Permissions.FindAsync(id);
            if (perm == null) return (false, "权限不存在");

            // 检查是否有子权限
            if (await _context.Permissions.AnyAsync(p => p.ParentId == id))
            {
                return (false, "存在子权限，无法删除");
            }

            // 检查是否有角色关联 (可选：也可以级联删除)
            // 这里选择级联删除角色关联，因为权限删了，关联也没意义了
            var strategy = _context.Database.CreateExecutionStrategy();
            return await strategy.ExecuteAsync(async () =>
            {
                using var transaction = await _context.Database.BeginTransactionAsync();
                try
                {
                    var rolePerms = await _context.RolePermissions.Where(rp => rp.PermissionId == id).ToListAsync();
                    _context.RolePermissions.RemoveRange(rolePerms);

                    _context.Permissions.Remove(perm);

                    await _context.SaveChangesAsync();
                    await transaction.CommitAsync();
                    return (true, "删除成功");
                }
                catch (Exception ex)
                {
                    await transaction.RollbackAsync();
                    return (false, "删除失败: " + ex.Message);
                }
            });
        }

        public async Task<(bool Success, string Message)> BatchUpdateStructureAsync(List<UpdatePermissionStructureDto> dtos)
        {
            if (dtos == null || !dtos.Any()) return (true, "没有需要更新的数据");

            var strategy = _context.Database.CreateExecutionStrategy();
            return await strategy.ExecuteAsync(async () =>
            {
                using var transaction = await _context.Database.BeginTransactionAsync();
                try
                {
                    var ids = dtos.Select(d => d.Id).ToList();
                    var perms = await _context.Permissions.Where(p => ids.Contains(p.Id)).ToListAsync();

                    foreach (var dto in dtos)
                    {
                        var perm = perms.FirstOrDefault(p => p.Id == dto.Id);
                        if (perm != null)
                        {
                            perm.ParentId = dto.ParentId;
                            perm.SortOrder = dto.SortOrder;
                            perm.UpdatedAt = DateTime.Now;
                        }
                    }

                    await _context.SaveChangesAsync();
                    await transaction.CommitAsync();
                    return (true, "结构更新成功");
                }
                catch (Exception ex)
                {
                    await transaction.RollbackAsync();
                    return (false, "更新失败: " + ex.Message);
                }
            });
        }

        private List<PermissionTreeDto> BuildPermissionTree(List<PermissionTreeDto> all, long? parentId)
        {
            return all
                .Where(p => p.ParentId == parentId)
                .Select(p =>
                {
                    p.Children = BuildPermissionTree(all, p.Id);
                    if (p.Children.Count == 0) p.Children = null;
                    return p;
                })
                .ToList();
        }
    }
}
