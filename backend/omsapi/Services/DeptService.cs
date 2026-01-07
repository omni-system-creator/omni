using Microsoft.EntityFrameworkCore;
using omsapi.Data;
using omsapi.Infrastructure.Attributes;
using omsapi.Models.Common;
using omsapi.Models.Dtos;
using omsapi.Models.Entities;
using omsapi.Services.Interfaces;

namespace omsapi.Services
{
    [AutoInject(ServiceLifetime.Scoped)]
    public class DeptService : IDeptService
    {
        private readonly OmsContext _context;

        public DeptService(OmsContext context)
        {
            _context = context;
        }

        private static string GetCodeSuffix(string fullCode)
        {
            if (string.IsNullOrWhiteSpace(fullCode)) return string.Empty;
            var idx = fullCode.LastIndexOf('-');
            return idx >= 0 ? fullCode[(idx + 1)..] : fullCode;
        }

        private async Task<string> BuildFullCodeAsync(long? parentId, string suffix)
        {
            if (string.IsNullOrWhiteSpace(suffix))
            {
                throw new ArgumentException("编码必填");
            }
            if (suffix.Contains('-'))
            {
                throw new ArgumentException("编码不能包含连字符(-)");
            }

            string prefix = string.Empty;
            if (parentId.HasValue && parentId.Value != 0)
            {
                var parent = await _context.Depts.FindAsync(parentId.Value);
                if (parent != null && !string.IsNullOrWhiteSpace(parent.Code))
                {
                    prefix = parent.Code;
                }
            }

            return string.IsNullOrEmpty(prefix) ? suffix : $"{prefix}-{suffix}";
        }

        private async Task CascadeUpdateChildCodesAsync(SystemDept parent)
        {
            // BFS update children codes using current parent's Code as prefix
            var queue = new Queue<SystemDept>();
            queue.Enqueue(parent);
            while (queue.Count > 0)
            {
                var node = queue.Dequeue();
                // Update posts and roles under this node with new prefix
                var nodePrefix = node.Code ?? string.Empty;
                var nodePosts = await _context.Posts.Where(p => p.DeptId == node.Id).ToListAsync();
                foreach (var post in nodePosts)
                {
                    var postSuffix = GetCodeSuffix(post.Code);
                    var newPostCode = string.IsNullOrEmpty(nodePrefix) ? postSuffix : $"{nodePrefix}-{postSuffix}";
                    if (!string.Equals(post.Code, newPostCode, StringComparison.Ordinal))
                    {
                        post.Code = newPostCode;
                        post.UpdatedAt = DateTime.Now;
                    }
                }
                var nodeRoles = await _context.Roles.Where(r => r.DeptId == node.Id).ToListAsync();
                foreach (var role in nodeRoles)
                {
                    var roleSuffix = GetCodeSuffix(role.Code);
                    var newRoleCode = string.IsNullOrEmpty(nodePrefix) ? roleSuffix : $"{nodePrefix}-{roleSuffix}";
                    if (!string.Equals(role.Code, newRoleCode, StringComparison.Ordinal))
                    {
                        role.Code = newRoleCode;
                        role.UpdatedAt = DateTime.Now;
                    }
                }

                var children = await _context.Depts.Where(d => d.ParentId == node.Id).ToListAsync();
                foreach (var child in children)
                {
                    var childSuffix = GetCodeSuffix(child.Code ?? string.Empty);
                    var newChildCode = string.IsNullOrEmpty(node.Code) ? childSuffix : $"{node.Code}-{childSuffix}";
                    if (!string.Equals(child.Code, newChildCode, StringComparison.Ordinal))
                    {
                        child.Code = newChildCode;
                        child.UpdatedAt = DateTime.Now;
                    }
                    queue.Enqueue(child);
                }
            }
        }

        public async Task<List<DeptTreeDto>> GetDeptTreeAsync(long userId, long? rootId = null)
        {
            // 1. Check if user is Admin
            var userRoles = await _context.UserRoles
                .Where(ur => ur.UserId == userId)
                .Include(ur => ur.Role)
                .ToListAsync();
            var isAdmin = userRoles.Any(ur => ur.Role.Code == "SuperAdmin");

            // 2. Prepare data
            var allDepts = await _context.Depts.OrderBy(d => d.SortOrder).ToListAsync();
            var deptDtos = allDepts.Select(MapToTreeDto).ToList();
            var tree = BuildTree(deptDtos, null);

            // 3. Apply logic
            if (isAdmin)
            {
                if (rootId.HasValue)
                {
                    var node = FindNode(tree, rootId.Value);
                    return node != null ? new List<DeptTreeDto> { node } : new List<DeptTreeDto>();
                }
                return tree;
            }
            else
            {
                // Normal user: Only see their own root organization
                var user = await _context.Users.FindAsync(userId);
                if (user?.DeptId == null) return new List<DeptTreeDto>();

                var userRootId = await GetRootDeptIdAsync(user.DeptId.Value);
                if (userRootId == null) return new List<DeptTreeDto>();

                var node = FindNode(tree, userRootId.Value);
                return node != null ? new List<DeptTreeDto> { node } : new List<DeptTreeDto>();
            }
        }

        private DeptTreeDto? FindNode(List<DeptTreeDto> nodes, long id)
        {
            foreach (var node in nodes)
            {
                if (node.Id == id) return node;
                if (node.Children != null)
                {
                    var found = FindNode(node.Children, id);
                    if (found != null) return found;
                }
            }
            return null;
        }

        public async Task<List<DeptTreeDto>> GetRootDeptsAsync()
        {
            var roots = await _context.Depts
                .Where(d => d.ParentId == null || d.ParentId == 0)
                .OrderBy(d => d.SortOrder)
                .ToListAsync();
            return roots.Select(MapToTreeDto).ToList();
        }

        public async Task<long?> GetRootDeptIdAsync(long deptId)
        {
            var current = await _context.Depts.FindAsync(deptId);
            while (current != null && current.ParentId != null && current.ParentId != 0)
            {
                current = await _context.Depts.FindAsync(current.ParentId);
            }
            return current?.Id;
        }

        private List<DeptTreeDto> BuildTree(List<DeptTreeDto> allDepts, long? parentId)
        {
            return allDepts
                .Where(d => d.ParentId == parentId)
                .Select(d =>
                {
                    d.Children = BuildTree(allDepts, d.Id);
                    if (d.Children.Count == 0)
                        d.Children = null;
                    return d;
                })
                .ToList();
        }

        public async Task<DeptTreeDto?> GetDeptByIdAsync(long id)
        {
            var dept = await _context.Depts.FindAsync(id);
            if (dept == null)
                return null;
            return MapToTreeDto(dept);
        }

        public async Task<DeptTreeDto> CreateDeptAsync(CreateDeptDto dto)
        {
            // Build full code from parent and suffix
            var fullCode = await BuildFullCodeAsync(dto.ParentId, dto.Code ?? string.Empty);
            // Uniqueness
            if (await _context.Depts.AnyAsync(d => d.Code == fullCode))
            {
                throw new ArgumentException("编码已存在(包含上级前缀)");
            }

            var dept = new SystemDept
            {
                ParentId = (dto.ParentId == 0) ? null : dto.ParentId,
                Name = dto.Name,
                Code = fullCode,
                Type = dto.Type,
                Leader = dto.Leader,
                Phone = dto.Phone,
                Email = dto.Email,
                SortOrder = dto.SortOrder,
                IsActive = dto.IsActive,
                X = dto.X,
                Y = dto.Y,
                CreatedAt = DateTime.Now
            };

            _context.Depts.Add(dept);
            await _context.SaveChangesAsync();
            return MapToTreeDto(dept);
        }

        public async Task<bool> UpdateDeptAsync(long id, UpdateDeptDto dto)
        {
            var dept = await _context.Depts.FindAsync(id);
            if (dept == null)
                return false;

            if (dto.ParentId.HasValue && dto.ParentId.Value == id)
            {
                throw new ArgumentException("Cannot set parent to self");
            }

            var strategy = _context.Database.CreateExecutionStrategy();
            await strategy.ExecuteAsync(async () =>
            {
                using var transaction = await _context.Database.BeginTransactionAsync();
                try
                {
                    bool needRecalcCode = false;
                    long? newParentId = dept.ParentId;
                    if (dto.ParentId.HasValue)
                    {
                        newParentId = (dto.ParentId.Value == 0) ? null : dto.ParentId.Value;
                        dept.ParentId = newParentId;
                        needRecalcCode = true;
                    }

                    if (dto.Name != null)
                        dept.Name = dto.Name;
                    if (dto.Type.HasValue)
                        dept.Type = dto.Type.Value;
                    if (dto.Leader != null)
                        dept.Leader = dto.Leader;
                    if (dto.Phone != null)
                        dept.Phone = dto.Phone;
                    if (dto.Email != null)
                        dept.Email = dto.Email;
                    if (dto.SortOrder != null)
                        dept.SortOrder = dto.SortOrder.Value;
                    if (dto.IsActive != null)
                        dept.IsActive = dto.IsActive.Value;

                    // Code suffix change triggers recalculation
                    if (dto.Code != null)
                    {
                        needRecalcCode = true;
                    }

                    if (needRecalcCode)
                    {
                        var suffix = dto.Code ?? GetCodeSuffix(dept.Code ?? string.Empty);
                        var fullCode = await BuildFullCodeAsync(newParentId, suffix);
                        if (!string.Equals(fullCode, dept.Code, StringComparison.Ordinal))
                        {
                            if (await _context.Depts.AnyAsync(d => d.Code == fullCode && d.Id != id))
                            {
                                throw new ArgumentException("编码已存在(包含上级前缀)");
                            }
                            dept.Code = fullCode;
                            // Cascade update children full codes
                            await CascadeUpdateChildCodesAsync(dept);
                        }
                    }

                    if (dto.ResetPosition == true)
                    {
                        dept.X = null;
                        dept.Y = null;
                    }
                    else
                    {
                        if (dto.X != null)
                            dept.X = dto.X.Value;
                        if (dto.Y != null)
                            dept.Y = dto.Y.Value;
                    }

                    dept.UpdatedAt = DateTime.Now;

                    await _context.SaveChangesAsync();
                    await transaction.CommitAsync();
                }
                catch
                {
                    await transaction.RollbackAsync();
                    throw;
                }
            });

            return true;
        }

        public async Task<bool> DeleteDeptAsync(long id)
        {
            var dept = await _context
                .Depts.Include(d => d.Children)
                .Include(d => d.Users)
                .FirstOrDefaultAsync(d => d.Id == id);

            if (dept == null)
                return false;

            if (dept.Children.Any())
            {
                throw new InvalidOperationException(
                    "Cannot delete department with sub-departments."
                );
            }

            if (dept.Users.Any())
            {
                throw new InvalidOperationException("Cannot delete department with users.");
            }

            _context.Depts.Remove(dept);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> BatchUpdateStructureAsync(List<UpdateDeptStructureDto> dtos)
        {
            var strategy = _context.Database.CreateExecutionStrategy();
            await strategy.ExecuteAsync(async () =>
            {
                using var transaction = await _context.Database.BeginTransactionAsync();
                try
                {
                    foreach (var item in dtos)
                    {
                        var dept = await _context.Depts.FindAsync(item.Id);
                        if (dept != null)
                        {
                            dept.ParentId = (item.ParentId == 0) ? null : item.ParentId;
                            dept.SortOrder = item.SortOrder;
                            dept.UpdatedAt = DateTime.Now;
                        }
                    }
                    await _context.SaveChangesAsync();
                    await transaction.CommitAsync();
                }
                catch
                {
                    await transaction.RollbackAsync();
                    throw;
                }
            });
            return true;
        }

        public async Task<PagedResult<DeptTreeDto>> GetDeptListAsync(string? keyword, int page, int pageSize)
        {
            var query = _context.Depts.AsQueryable();

            if (!string.IsNullOrWhiteSpace(keyword))
            {
                query = query.Where(d => d.Name.Contains(keyword) || (d.Code != null && d.Code.Contains(keyword)));
            }

            query = query.Where(d => d.IsActive);

            var total = await query.CountAsync();
            var items = await query
                .OrderBy(d => d.SortOrder)
                .ThenBy(d => d.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            var dtos = items.Select(MapToTreeDto).ToList();

            return new PagedResult<DeptTreeDto>(dtos, total, page, pageSize);
        }

        private DeptTreeDto MapToTreeDto(SystemDept dept)
        {
            return new DeptTreeDto
            {
                Id = dept.Id,
                ParentId = dept.ParentId == 0 ? null : dept.ParentId,
                Name = dept.Name,
                Code = GetCodeSuffix(dept.Code ?? string.Empty),
                FullCode = dept.Code,
                Type = dept.Type,
                Leader = dept.Leader,
                Phone = dept.Phone,
                Email = dept.Email,
                SortOrder = dept.SortOrder,
                IsActive = dept.IsActive,
                X = dept.X,
                Y = dept.Y,
                CreatedAt = dept.CreatedAt
            };
        }
    }
}
