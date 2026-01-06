using Microsoft.EntityFrameworkCore;
using omsapi.Data;
using omsapi.Infrastructure.Attributes;
using omsapi.Models.Dtos;
using omsapi.Models.Entities;
using omsapi.Services.Interfaces;

namespace omsapi.Services
{
    [AutoInject(ServiceLifetime.Scoped)]
    public class PostService : IPostService
    {
        private readonly OmsContext _context;

        public PostService(OmsContext context)
        {
            _context = context;
        }

        public async Task<(bool Success, string Message, List<PostDto>? Data)> GetAllPostsAsync(long userId, long? deptId = null)
        {
            // Permission scope
            var isAdmin = await _context.UserRoles
                .Where(ur => ur.UserId == userId)
                .Include(ur => ur.Role)
                .AnyAsync(ur => ur.Role.Code == "SuperAdmin");

            var query = _context.Posts.AsQueryable();

            if (isAdmin)
            {
                if (deptId.HasValue)
                {
                    query = query.Where(p => p.DeptId == deptId);
                }
            }
            else
            {
                var user = await _context.Users.FindAsync(userId);
                if (user?.DeptId == null)
                {
                    return (true, "获取成功", new List<PostDto>());
                }
                var allowedDeptIds = await GetDescendantDeptIdsAsync(user.DeptId.Value);
                if (deptId.HasValue)
                {
                    // If a specific dept is requested, ensure it's within allowed scope
                    if (!allowedDeptIds.Contains(deptId.Value))
                    {
                        // Outside scope: return empty
                        return (true, "获取成功", new List<PostDto>());
                    }
                    query = query.Where(p => p.DeptId == deptId);
                }
                else
                {
                    query = query.Where(p => p.DeptId.HasValue && allowedDeptIds.Contains(p.DeptId.Value));
                }
            }

            var posts = await query
                .Include(p => p.Dept)
                .OrderBy(p => p.SortOrder)
                .Select(p => new PostDto
                {
                    Id = p.Id,
                    Code = p.Code.Contains("-") ? p.Code.Substring(p.Code.LastIndexOf("-") + 1) : p.Code,
                    FullCode = p.Code,
                    Name = p.Name,
                    SortOrder = p.SortOrder,
                    IsActive = p.IsActive,
                    Remark = p.Remark,
                    DeptId = p.DeptId,
                    DeptName = p.Dept != null ? p.Dept.Name : null,
                    CreatedAt = p.CreatedAt
                })
                .ToListAsync();
            
            return (true, "获取成功", posts);
        }

        public async Task<(bool Success, string Message, PostDto? Data)> GetPostByIdAsync(long userId, long id)
        {
            var post = await _context.Posts
                .Include(p => p.Dept)
                .FirstOrDefaultAsync(p => p.Id == id);
            
            if (post == null) return (false, "岗位不存在", null);

            // Non-admin can only access posts within their dept subtree
            var isAdmin = await _context.UserRoles
                .Where(ur => ur.UserId == userId)
                .Include(ur => ur.Role)
                .AnyAsync(ur => ur.Role.Code == "SuperAdmin");
            if (!isAdmin)
            {
                var user = await _context.Users.FindAsync(userId);
                if (user?.DeptId == null) return (false, "无权限", null);
                var allowed = await GetDescendantDeptIdsAsync(user.DeptId.Value);
                if (!post.DeptId.HasValue || !allowed.Contains(post.DeptId.Value))
                {
                    return (false, "无权限", null);
                }
            }

            return (true, "获取成功", new PostDto
            {
                Id = post.Id,
                Code = post.Code.Contains("-") ? post.Code.Substring(post.Code.LastIndexOf("-") + 1) : post.Code,
                FullCode = post.Code,
                Name = post.Name,
                SortOrder = post.SortOrder,
                IsActive = post.IsActive,
                Remark = post.Remark,
                DeptId = post.DeptId,
                DeptName = post.Dept != null ? post.Dept.Name : null,
                CreatedAt = post.CreatedAt
            });
        }

        private async Task<string> GetDeptCodePathAsync(long deptId)
        {
            var codes = new List<string>();
            var currentId = (long?)deptId;
            
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

        public async Task<(bool Success, string Message)> CreatePostAsync(long userId, CreatePostDto dto)
        {
            if (string.IsNullOrWhiteSpace(dto.Code))
            {
                return (false, "岗位编码必填");
            }

            if (dto.Code.Contains("-"))
            {
                return (false, "岗位编码不能包含连字符(-)");
            }

            if (!dto.DeptId.HasValue)
            {
                return (false, "所属部门必填");
            }

            // Generate full code with prefix
            var prefix = await GetDeptCodePathAsync(dto.DeptId.Value);
            var fullCode = string.IsNullOrEmpty(prefix) ? dto.Code : $"{prefix}-{dto.Code}";

            if (await _context.Posts.AnyAsync(p => p.Code == fullCode))
            {
                return (false, "岗位编码已存在(包含部门前缀)");
            }

            // Validate permission
            var isAdmin = await _context.UserRoles
                .Where(ur => ur.UserId == userId)
                .Include(ur => ur.Role)
                .AnyAsync(ur => ur.Role.Code == "SuperAdmin");
            if (!isAdmin)
            {
                var user = await _context.Users.FindAsync(userId);
                if (user?.DeptId == null) return (false, "无权限");
                var allowed = await GetDescendantDeptIdsAsync(user.DeptId.Value);
                if (!allowed.Contains(dto.DeptId.Value))
                {
                    return (false, "无权限在该部门创建岗位");
                }
            }

            var post = new SystemPost
            {
                Code = fullCode,
                Name = dto.Name,
                SortOrder = dto.SortOrder,
                IsActive = dto.IsActive,
                Remark = dto.Remark,
                DeptId = dto.DeptId,
                CreatedAt = DateTime.Now
            };

            _context.Posts.Add(post);
            await _context.SaveChangesAsync();
            return (true, "创建成功");
        }

        public async Task<(bool Success, string Message)> UpdatePostAsync(long userId, long id, UpdatePostDto dto)
        {
            var post = await _context.Posts.FindAsync(id);
            if (post == null) return (false, "岗位不存在");

            // Permission check
            var isAdmin = await _context.UserRoles
                .Where(ur => ur.UserId == userId)
                .Include(ur => ur.Role)
                .AnyAsync(ur => ur.Role.Code == "SuperAdmin");
            if (!isAdmin)
            {
                var user = await _context.Users.FindAsync(userId);
                if (user?.DeptId == null) return (false, "无权限");
                var allowed = await GetDescendantDeptIdsAsync(user.DeptId.Value);
                // Existing post must be within allowed scope
                if (!post.DeptId.HasValue || !allowed.Contains(post.DeptId.Value))
                {
                    return (false, "无权限修改该岗位");
                }
                // If changing dept, ensure target within scope
                if (dto.DeptId.HasValue && !allowed.Contains(dto.DeptId.Value))
                {
                    return (false, "无权限转移到该部门");
                }
            }

            if (dto.Name != null) post.Name = dto.Name;
            if (dto.Remark != null) post.Remark = dto.Remark;
            if (dto.SortOrder.HasValue) post.SortOrder = dto.SortOrder.Value;
            if (dto.IsActive.HasValue) post.IsActive = dto.IsActive.Value;
            
            // Handle Code/Dept changes
            if (dto.Code != null || dto.DeptId.HasValue)
            {
                var newDeptId = dto.DeptId ?? post.DeptId;
                if (!newDeptId.HasValue) return (false, "所属部门必填");

                var suffix = dto.Code;
                if (suffix == null)
                {
                    // If code not provided, extract suffix from existing full code
                    suffix = post.Code.Contains("-") ? post.Code.Substring(post.Code.LastIndexOf("-") + 1) : post.Code;
                }
                else
                {
                    if (string.IsNullOrWhiteSpace(suffix)) return (false, "岗位编码不能为空");
                    if (suffix.Contains("-")) return (false, "岗位编码不能包含连字符(-)");
                }

                // Re-calculate full code
                var prefix = await GetDeptCodePathAsync(newDeptId.Value);
                var fullCode = string.IsNullOrEmpty(prefix) ? suffix : $"{prefix}-{suffix}";

                // Check uniqueness if code changed
                if (fullCode != post.Code)
                {
                    if (await _context.Posts.AnyAsync(p => p.Code == fullCode && p.Id != id))
                    {
                        return (false, "岗位编码已存在(包含部门前缀)");
                    }
                    post.Code = fullCode;
                }

                if (dto.DeptId.HasValue) post.DeptId = dto.DeptId.Value;
            }

            post.UpdatedAt = DateTime.Now;
            await _context.SaveChangesAsync();
            return (true, "更新成功");
        }

        public async Task<(bool Success, string Message)> DeletePostAsync(long userId, long id)
        {
            var post = await _context.Posts.FindAsync(id);
            if (post == null) return (false, "岗位不存在");

            // Permission check
            var isAdmin = await _context.UserRoles
                .Where(ur => ur.UserId == userId)
                .Include(ur => ur.Role)
                .AnyAsync(ur => ur.Role.Code == "SuperAdmin");
            if (!isAdmin)
            {
                var user = await _context.Users.FindAsync(userId);
                if (user?.DeptId == null) return (false, "无权限");
                var allowed = await GetDescendantDeptIdsAsync(user.DeptId.Value);
                if (!post.DeptId.HasValue || !allowed.Contains(post.DeptId.Value))
                {
                    return (false, "无权限删除该岗位");
                }
            }

            // Check if users are assigned to this post
            if (await _context.UserPosts.AnyAsync(up => up.PostId == id))
            {
                return (false, "该岗位下存在用户，无法删除");
            }

            _context.Posts.Remove(post);
            await _context.SaveChangesAsync();
            return (true, "删除成功");
        }

        private async Task<List<long>> GetDescendantDeptIdsAsync(long deptId)
        {
            var allDepts = await _context.Depts.Select(d => new { d.Id, d.ParentId }).ToListAsync();
            var result = new List<long> { deptId };
            var stack = new Stack<long>();
            stack.Push(deptId);
            while (stack.Count > 0)
            {
                var currentId = stack.Pop();
                foreach (var child in allDepts.Where(d => d.ParentId == currentId))
                {
                    result.Add(child.Id);
                    stack.Push(child.Id);
                }
            }
            return result;
        }
    }
}
