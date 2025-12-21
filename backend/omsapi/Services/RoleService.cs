using Microsoft.EntityFrameworkCore;
using omsapi.Data;
using omsapi.Infrastructure.Attributes;
using omsapi.Models.Dtos;
using omsapi.Services.Interfaces;

namespace omsapi.Services
{
    [AutoInject(ServiceLifetime.Scoped)]
    public class RoleService : IRoleService
    {
        private readonly OmsContext _context;

        public RoleService(OmsContext context)
        {
            _context = context;
        }

        public async Task<(bool Success, string Message, List<RoleDto>? Data)> GetAllRolesAsync(long? deptId = null)
        {
            var query = _context.Roles.AsQueryable();

            if (deptId.HasValue)
            {
                query = query.Where(r => r.DeptId == deptId);
            }

            var roles = await query
                .Include(r => r.ChildRoleRelations)
                .OrderBy(r => r.Id)
                .Select(r => new RoleDto
                {
                    Id = r.Id,
                    Name = r.Name,
                    Code = r.Code,
                    Description = r.Description,
                    IsSystem = r.IsSystem,
                    CreatedAt = r.CreatedAt,
                    DeptId = r.DeptId,
                    ChildRoleIds = r.ChildRoleRelations.Select(cr => cr.ChildRoleId).ToList()
                })
                .ToListAsync();

            return (true, "获取成功", roles);
        }

        public async Task<(bool Success, string Message, RoleDto? Data)> GetRoleByIdAsync(long id)
        {
            var role = await _context.Roles
                .Include(r => r.ChildRoleRelations)
                .FirstOrDefaultAsync(r => r.Id == id);

            if (role == null) return (false, "角色不存在", null);

            return (true, "获取成功", new RoleDto
            {
                Id = role.Id,
                Name = role.Name,
                Code = role.Code,
                Description = role.Description,
                IsSystem = role.IsSystem,
                CreatedAt = role.CreatedAt,
                DeptId = role.DeptId,
                ChildRoleIds = role.ChildRoleRelations.Select(cr => cr.ChildRoleId).ToList()
            });
        }

        public async Task<(bool Success, string Message)> CreateRoleAsync(CreateRoleDto dto)
        {
            if (await _context.Roles.AnyAsync(r => r.Code == dto.Code))
            {
                return (false, "角色编码已存在");
            }

            var role = new omsapi.Models.Entities.SystemRole
            {
                Name = dto.Name,
                Code = dto.Code,
                Description = dto.Description,
                IsSystem = false,
                DeptId = dto.DeptId,
                CreatedAt = DateTime.Now
            };

            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                _context.Roles.Add(role);
                await _context.SaveChangesAsync();

                if (dto.ChildRoleIds != null && dto.ChildRoleIds.Any())
                {
                    if (dto.ChildRoleIds.Contains(role.Id))
                    {
                        await transaction.RollbackAsync();
                        return (false, "角色不能包含自身");
                    }

                    foreach (var childId in dto.ChildRoleIds.Distinct())
                    {
                        _context.RoleInheritances.Add(new omsapi.Models.Entities.SystemRoleInheritance
                        {
                            ParentRoleId = role.Id,
                            ChildRoleId = childId
                        });
                    }
                    await _context.SaveChangesAsync();
                }

                await transaction.CommitAsync();
                return (true, "创建成功");
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                return (false, "创建失败: " + ex.Message);
            }
        }

        public async Task<(bool Success, string Message)> UpdateRoleAsync(long id, UpdateRoleDto dto)
        {
            var role = await _context.Roles.FindAsync(id);
            if (role == null) return (false, "角色不存在");

            if (dto.Name != null) role.Name = dto.Name;
            if (dto.Description != null) role.Description = dto.Description;
            if (dto.DeptId.HasValue) role.DeptId = dto.DeptId.Value; // Note: if null passed, it might mean "no change" or "clear". Usually UpdateDto null means no change. If user wants to clear, might need specific logic. Assuming null = no change here.
            
            role.UpdatedAt = DateTime.Now;

            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                if (dto.ChildRoleIds != null)
                {
                    if (dto.ChildRoleIds.Contains(id))
                    {
                        return (false, "角色不能包含自身");
                    }

                    // 移除旧关系
                    var oldRelations = await _context.RoleInheritances.Where(ri => ri.ParentRoleId == id).ToListAsync();
                    _context.RoleInheritances.RemoveRange(oldRelations);

                    // 添加新关系
                    foreach (var childId in dto.ChildRoleIds.Distinct())
                    {
                        _context.RoleInheritances.Add(new omsapi.Models.Entities.SystemRoleInheritance
                        {
                            ParentRoleId = id,
                            ChildRoleId = childId
                        });
                    }
                }

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();
                return (true, "更新成功");
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                return (false, "更新失败: " + ex.Message);
            }
        }

        public async Task<(bool Success, string Message)> DeleteRoleAsync(long id)
        {
            var role = await _context.Roles.FindAsync(id);
            if (role == null) return (false, "角色不存在");

            if (role.IsSystem) return (false, "系统角色不可删除");

            // 检查是否有用户关联
            if (await _context.UserRoles.AnyAsync(ur => ur.RoleId == id))
            {
                return (false, "该角色下存在用户，无法删除");
            }

            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                // 删除角色权限关联
                var perms = await _context.RolePermissions.Where(rp => rp.RoleId == id).ToListAsync();
                _context.RolePermissions.RemoveRange(perms);

                // 删除角色
                _context.Roles.Remove(role);
                
                await _context.SaveChangesAsync();
                await transaction.CommitAsync();
                return (true, "删除成功");
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                return (false, "删除失败: " + ex.Message);
            }
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
                    SortOrder = p.SortOrder,
                    IsVisible = p.IsVisible,
                    ParentId = p.ParentId
                })
                .ToListAsync();

            var tree = BuildPermissionTree(allPerms, null);
            return (true, "获取成功", tree);
        }

        public async Task<(bool Success, string Message, List<long>? Data)> GetRolePermissionIdsAsync(long roleId)
        {
            var ids = await _context.RolePermissions
                .Where(rp => rp.RoleId == roleId)
                .Select(rp => rp.PermissionId)
                .ToListAsync();

            return (true, "获取成功", ids);
        }

        public async Task<(bool Success, string Message)> AssignPermissionsAsync(long roleId, List<long> permissionIds)
        {
            var role = await _context.Roles.FindAsync(roleId);
            if (role == null) return (false, "角色不存在");

            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                // 移除旧权限
                var oldPerms = await _context.RolePermissions.Where(rp => rp.RoleId == roleId).ToListAsync();
                _context.RolePermissions.RemoveRange(oldPerms);

                // 添加新权限
                if (permissionIds != null && permissionIds.Any())
                {
                    // 去重，防止前端传来重复 ID 导致数据库唯一约束冲突
                    var uniqueIds = permissionIds.Distinct().ToList();

                    var newPerms = uniqueIds.Select(pid => new omsapi.Models.Entities.SystemRolePermission
                    {
                        RoleId = roleId,
                        PermissionId = pid,
                        CreatedAt = DateTime.Now
                    });
                    _context.RolePermissions.AddRange(newPerms);
                }

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();
                return (true, "权限分配成功");
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                return (false, "分配失败: " + ex.Message);
            }
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
