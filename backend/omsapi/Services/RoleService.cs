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

        private static string GetCodeSuffix(string fullCode)
        {
            if (string.IsNullOrWhiteSpace(fullCode)) return string.Empty;
            var idx = fullCode.LastIndexOf('-');
            return idx >= 0 ? fullCode[(idx + 1)..] : fullCode;
        }

        private async Task<string> GetDeptCodePathAsync(long? deptId)
        {
            if (!deptId.HasValue) return string.Empty;
            var codes = new List<string>();
            var currentId = deptId;
            while (currentId.HasValue)
            {
                var dept = await _context.Depts.FindAsync(currentId.Value);
                if (dept == null) break;
                if (!string.IsNullOrEmpty(dept.Code))
                {
                    codes.Insert(0, dept.Code);
                }
                currentId = dept.ParentId == 0 ? null : dept.ParentId;
            }
            return string.Join("-", codes);
        }

        private async Task<bool> IsAdminAsync(long userId)
        {
            var roles = await _context.UserRoles
                .Where(ur => ur.UserId == userId)
                .Include(ur => ur.Role)
                .ToListAsync();
            return roles.Any(ur => ur.Role.Code == "SuperAdmin");
        }

        private async Task<long?> GetUserRootDeptIdAsync(long userId)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user?.DeptId == null) return null;
            var current = await _context.Depts.FindAsync(user.DeptId.Value);
            while (current != null && current.ParentId != null && current.ParentId != 0)
            {
                current = await _context.Depts.FindAsync(current.ParentId);
            }
            return current?.Id;
        }

        private async Task<List<long>> GetDescendantDeptIdsAsync(long rootId)
        {
            var result = new List<long> { rootId };
            var queue = new Queue<long>();
            queue.Enqueue(rootId);
            while (queue.Count > 0)
            {
                var parentId = queue.Dequeue();
                var children = await _context.Depts
                    .Where(d => d.ParentId == parentId)
                    .Select(d => d.Id)
                    .ToListAsync();
                foreach (var cid in children)
                {
                    if (!result.Contains(cid))
                    {
                        result.Add(cid);
                        queue.Enqueue(cid);
                    }
                }
            }
            return result;
        }

        public async Task<(bool Success, string Message, List<RoleDto>? Data)> GetAllRolesAsync(long userId, long? deptId = null)
        {
            var isAdmin = await IsAdminAsync(userId);
            var query = _context.Roles.AsQueryable();

            if (deptId.HasValue)
            {
                query = query.Where(r => r.DeptId == deptId);
            }

            if (!isAdmin)
            {
                var rootId = await GetUserRootDeptIdAsync(userId);
                if (rootId == null)
                {
                    return (true, "获取成功", new List<RoleDto>());
                }
                var allowedDeptIds = await GetDescendantDeptIdsAsync(rootId.Value);
                query = query.Where(r => r.DeptId.HasValue && allowedDeptIds.Contains(r.DeptId.Value));
            }

            var roles = await query
                .Include(r => r.ChildRoleRelations)
                .OrderBy(r => r.Id)
                .Select(r => new RoleDto
                {
                    Id = r.Id,
                    Name = r.Name,
                    Code = GetCodeSuffix(r.Code),
                    FullCode = r.Code,
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
                Code = GetCodeSuffix(role.Code),
                FullCode = role.Code,
                Description = role.Description,
                IsSystem = role.IsSystem,
                CreatedAt = role.CreatedAt,
                DeptId = role.DeptId,
                ChildRoleIds = role.ChildRoleRelations.Select(cr => cr.ChildRoleId).ToList()
            });
        }

        public async Task<(bool Success, string Message)> CreateRoleAsync(CreateRoleDto dto)
        {
            if (string.IsNullOrWhiteSpace(dto.Code))
            {
                return (false, "角色编码必填");
            }
            if (dto.Code.Contains("-"))
            {
                return (false, "角色编码不能包含连字符(-)");
            }
            var prefix = await GetDeptCodePathAsync(dto.DeptId);
            var fullCode = string.IsNullOrEmpty(prefix) ? dto.Code : $"{prefix}-{dto.Code}";
            if (await _context.Roles.AnyAsync(r => r.Code == fullCode))
            {
                return (false, "角色编码已存在(包含部门前缀)");
            }

            var role = new omsapi.Models.Entities.SystemRole
            {
                Name = dto.Name,
                Code = fullCode,
                Description = dto.Description,
                IsSystem = false,
                DeptId = dto.DeptId,
                CreatedAt = DateTime.Now
            };

            var strategy = _context.Database.CreateExecutionStrategy();
            return await strategy.ExecuteAsync(async () =>
            {
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
            });
        }

        public async Task<(bool Success, string Message)> UpdateRoleAsync(long id, UpdateRoleDto dto)
        {
            var role = await _context.Roles.FindAsync(id);
            if (role == null) return (false, "角色不存在");

            if (dto.Name != null) role.Name = dto.Name;
            if (dto.Description != null) role.Description = dto.Description;
            if (dto.DeptId.HasValue) role.DeptId = dto.DeptId.Value;
            
            role.UpdatedAt = DateTime.Now;

            var strategy = _context.Database.CreateExecutionStrategy();
            return await strategy.ExecuteAsync(async () =>
            {
                using var transaction = await _context.Database.BeginTransactionAsync();
                try
                {
                    // Recalculate code if dept or suffix changed
                    if (dto.DeptId.HasValue || dto.ChildRoleIds != null)
                    {
                        // If code suffix provided (not supported in UpdateRoleDto currently), keep existing suffix
                        var suffix = GetCodeSuffix(role.Code);
                        var prefix = await GetDeptCodePathAsync(role.DeptId);
                        var fullCode = string.IsNullOrEmpty(prefix) ? suffix : $"{prefix}-{suffix}";
                        if (fullCode != role.Code)
                        {
                            if (await _context.Roles.AnyAsync(r => r.Code == fullCode && r.Id != id))
                            {
                                return (false, "角色编码已存在(包含部门前缀)");
                            }
                            role.Code = fullCode;
                        }
                    }

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
            });
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

            var strategy = _context.Database.CreateExecutionStrategy();
            return await strategy.ExecuteAsync(async () =>
            {
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
            });
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

            var strategy = _context.Database.CreateExecutionStrategy();
            return await strategy.ExecuteAsync(async () =>
            {
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
