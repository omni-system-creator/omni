using Microsoft.EntityFrameworkCore;
using omsapi.Data;
using omsapi.Models.Dtos;
using omsapi.Services.Interfaces;
using omsapi.Models.Common;
using omsapi.Models.Enums;

using omsapi.Infrastructure.Attributes;

namespace omsapi.Services
{
    [AutoInject(ServiceLifetime.Scoped)]
    public class UserService : IUserService
    {
        private readonly OmsContext _context;
        private readonly IWebHostEnvironment _environment;
        private readonly ILogger<UserService> _logger;

        public UserService(OmsContext context, IWebHostEnvironment environment, ILogger<UserService> logger)
        {
            _context = context;
            _environment = environment;
            _logger = logger;
        }

        public async Task<(bool Success, string Message, string? AvatarUrl)> UploadAvatarAsync(long userId, IFormFile file)
        {
            if (file == null || file.Length == 0)
            {
                return (false, "请选择文件", null);
            }

            // 验证文件类型
            var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".gif", ".webp" };
            var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
            if (!allowedExtensions.Contains(extension))
            {
                return (false, "仅支持 jpg, jpeg, png, gif, webp 格式的图片", null);
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
                            _logger.LogWarning(deleteEx, "删除旧头像失败");
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
                _logger.LogError(ex, "上传头像失败");
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
                Avatar = user.Avatar,
                Status = user.Status
            };

            return (true, "获取成功", userDto);
        }
        public async Task<List<UserOrgDto>> GetUserOrganizationsAsync(long userId)
        {
            var result = new List<UserOrgDto>();
            
            var user = await _context.Users
                .Include(u => u.Dept)
                .Include(u => u.UserPosts)
                    .ThenInclude(up => up.Dept)
                .FirstOrDefaultAsync(u => u.Id == userId);

            if (user == null) return result;

            // 1. Add Demo Org (Find by Code = "DEMO")
            var demoOrg = await _context.Depts.FirstOrDefaultAsync(d => d.Code == "DEMO");
            if (demoOrg != null)
            {
                result.Add(new UserOrgDto
                {
                    Id = demoOrg.Id,
                    Name = demoOrg.Name, // Should be "演示组织"
                    Type = "Demo",
                    IsCurrent = user.CurrentOrgId == demoOrg.Id
                });
            }
            else
            {
                // Fallback if no DEMO org in DB, maybe just skip or add a fake one?
                // User instruction says "Query Code is DEMO". If not found, we probably shouldn't show it or should create it?
                // For safety, let's keep the fake one if not found, but with ID=0? 
                // No, better to stick to DB. If not found, maybe just don't add. 
                // But for development, I'll add a check. If not found, I won't add it to avoid confusion with ID 0.
            }

            // 2. Check if SuperAdmin - return ALL active root organizations
            if (await IsAdminAsync(userId))
            {
                var rootDepts = await _context.Depts
                    .Where(d => d.ParentId == null && d.IsActive)
                    .OrderBy(d => d.SortOrder)
                    .Take(11)
                    .ToListAsync();

                // Find root of current org to mark IsCurrent correctly
                long? currentRootId = null;
                if (user.CurrentOrgId.HasValue)
                {
                     var cOrg = await _context.Depts.FindAsync(user.CurrentOrgId.Value);
                     if (cOrg != null)
                     {
                         var temp = cOrg;
                         while(temp.ParentId != null)
                         {
                             var p = await _context.Depts.FindAsync(temp.ParentId);
                             if (p == null) break;
                             temp = p;
                         }
                         currentRootId = temp.Id;
                     }
                }

                foreach (var root in rootDepts)
                {
                     if (!result.Any(r => r.Id == root.Id))
                     {
                        result.Add(new UserOrgDto
                        {
                            Id = root.Id,
                            Name = root.Name,
                            Type = root.Type.ToString(),
                            IsCurrent = currentRootId == root.Id
                        });
                     }
                }
                
                return result;
            }

            var deptIds = new HashSet<long>();
            if (user.DeptId.HasValue) deptIds.Add(user.DeptId.Value);
            
            foreach(var post in user.UserPosts)
            {
                deptIds.Add(post.DeptId);
            }

            if (deptIds.Count > 0)
            {
                foreach(var deptId in deptIds)
                {
                    var currentDept = await _context.Depts.FindAsync(deptId);
                    if (currentDept == null) continue;
                    
                    // Climb up
                    var root = currentDept;
                    while(root.ParentId != null)
                    {
                        var parent = await _context.Depts.FindAsync(root.ParentId);
                        if (parent == null) break;
                        root = parent;
                    }
                    
                    // Add if not exists
                    if (!result.Any(r => r.Id == root.Id))
                    {
                        if (result.Count >= 11) break;
                        result.Add(new UserOrgDto
                        {
                            Id = root.Id,
                            Name = root.Name,
                            Type = root.Type.ToString(),
                            IsCurrent = user.CurrentOrgId == root.Id
                        });
                    }
                }
            }

            // 3. Ensure CurrentOrg is in the list (for SuperAdmin switching to non-member orgs)
            if (user.CurrentOrgId.HasValue && !result.Any(r => r.Id == user.CurrentOrgId.Value))
            {
                var currentOrg = await _context.Depts.FindAsync(user.CurrentOrgId.Value);
                if (currentOrg != null)
                {
                     result.Add(new UserOrgDto
                     {
                         Id = currentOrg.Id,
                         Name = currentOrg.Name,
                         Type = currentOrg.Type.ToString(),
                         IsCurrent = true
                     });
                }
            }

            return result;
        }

        public async Task<(bool Success, string Message)> SwitchOrganizationAsync(long userId, long orgId)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null) return (false, "用户不存在");

            // Verify orgId is valid (exists in DB)
            // Note: If orgId is 0 (fake demo), we might have issues if we moved to DB based DEMO.
            // But now we use DB ID.
            
            var org = await _context.Depts.FindAsync(orgId);
            if (org == null)
            {
                 // Maybe it is the fake ID 0? If we removed fake ID 0 logic, we expect real ID.
                 return (false, "组织不存在");
            }

            user.CurrentOrgId = orgId;
            await _context.SaveChangesAsync();
            
            return (true, "切换成功");
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

        public async Task<(bool Success, string Message, List<UserListDto>? Data)> GetAllUsersAsync(long userId, long? deptId = null, string? keyword = null)
        {
            var isAdmin = await IsAdminAsync(userId);

            IQueryable<omsapi.Models.Entities.SystemUser> query = _context.Users
                .AsSplitQuery()
                .Include(u => u.Dept)
                .Include(u => u.UserRoles)
                .ThenInclude(ur => ur.Role)
                .Include(u => u.UserPosts)
                .ThenInclude(up => up.Post)
                .Include(u => u.UserPosts)
                .ThenInclude(up => up.Dept);

            if (deptId.HasValue)
            {
                query = query.Where(u => u.DeptId == deptId.Value || u.UserPosts.Any(up => up.DeptId == deptId.Value));
            }

            if (!string.IsNullOrWhiteSpace(keyword))
            {
                query = query.Where(u => u.Username.Contains(keyword) || (u.Nickname != null && u.Nickname.Contains(keyword)));
            }

            if (!isAdmin)
            {
                var rootId = await GetUserRootDeptIdAsync(userId);
                if (rootId == null)
                {
                    return (true, "获取成功", new List<UserListDto>());
                }
                var allowedDeptIds = await GetDescendantDeptIdsAsync(rootId.Value);
                query = query.Where(u => u.DeptId.HasValue && allowedDeptIds.Contains(u.DeptId.Value));
            }

            var users = await query
                .Select(u => new UserListDto
                {
                    Id = u.Id,
                    Username = u.Username,
                    Nickname = u.Nickname,
                    Email = u.Email,
                    Phone = u.Phone,
                    Avatar = u.Avatar,
                    Status = u.Status,
                    IsActive = u.IsActive,
                    CreatedAt = u.CreatedAt,
                    LastLoginAt = u.LastLoginAt,
                    Roles = u.UserRoles.Select(ur => ur.Role.Name).ToList(),
                    Posts = u.UserPosts.Select(up => new UserPostDto
                    {
                        PostId = up.PostId,
                        PostName = up.Post.Name,
                        DeptId = up.DeptId,
                        DeptName = up.Dept.Name
                    }).ToList(),
                    Dept = u.Dept != null ? new DeptDto
                    {
                        Id = u.Dept.Id,
                        Name = u.Dept.Name,
                        Code = u.Dept.Code,
                        ParentId = u.Dept.ParentId,
                        SortOrder = u.Dept.SortOrder,
                        IsActive = u.Dept.IsActive,
                        CreatedAt = u.Dept.CreatedAt
                    } : null
                })
                .ToListAsync();

            return (true, "获取成功", users);
        }

        public async Task<(bool Success, string Message, UserListDto? Data)> GetUserByIdAsync(long id)
        {
            var user = await _context.Users
                .AsSplitQuery()
                .Include(u => u.Dept)
                .Include(u => u.UserRoles)
                .ThenInclude(ur => ur.Role)
                .Include(u => u.UserPosts)
                .ThenInclude(up => up.Post)
                .Include(u => u.UserPosts)
                .ThenInclude(up => up.Dept)
                .FirstOrDefaultAsync(u => u.Id == id);

            if (user == null)
            {
                return (false, "用户不存在", null);
            }

            var dto = new UserListDto
            {
                Id = user.Id,
                Username = user.Username,
                Nickname = user.Nickname,
                Email = user.Email,
                Phone = user.Phone,
                Avatar = user.Avatar,
                Status = user.Status,
                IsActive = user.IsActive,
                CreatedAt = user.CreatedAt,
                LastLoginAt = user.LastLoginAt,
                Roles = user.UserRoles.Select(ur => ur.Role.Name).ToList(),
                Posts = user.UserPosts.Select(up => new UserPostDto
                {
                    PostId = up.PostId,
                    PostName = up.Post.Name,
                    DeptId = up.DeptId,
                    DeptName = up.Dept.Name
                }).ToList(),
                Dept = user.Dept != null ? new DeptDto
                {
                    Id = user.Dept.Id,
                    Name = user.Dept.Name,
                    Code = user.Dept.Code,
                    ParentId = user.Dept.ParentId,
                    SortOrder = user.Dept.SortOrder,
                    IsActive = user.Dept.IsActive,
                    CreatedAt = user.Dept.CreatedAt
                } : null
            };

            return (true, "获取成功", dto);
        }

        public async Task<(bool Success, string Message)> CreateUserAsync(CreateUserDto dto)
        {
            if (await _context.Users.AnyAsync(u => u.Username == dto.Username))
            {
                return (false, "用户名已存在");
            }

            var user = new omsapi.Models.Entities.SystemUser
            {
                Username = dto.Username,
                Password = ComputeSha256Hash(dto.Password),
                Nickname = dto.Nickname,
                DeptId = dto.DeptId,
                CreatedAt = DateTime.Now,
                IsActive = true
            };

            var strategy = _context.Database.CreateExecutionStrategy();
            return await strategy.ExecuteAsync(async () =>
            {
                using var transaction = await _context.Database.BeginTransactionAsync();
                try
                {
                    _context.Users.Add(user);
                    await _context.SaveChangesAsync();

                    if (dto.RoleIds != null && dto.RoleIds.Any())
                    {
                        foreach (var roleId in dto.RoleIds)
                        {
                            _context.UserRoles.Add(new omsapi.Models.Entities.SystemUserRole
                            {
                                UserId = user.Id,
                                RoleId = roleId
                            });
                        }
                    }

                    if (dto.PostRelations != null && dto.PostRelations.Any())
                    {
                        foreach (var rel in dto.PostRelations)
                        {
                            _context.UserPosts.Add(new omsapi.Models.Entities.SystemUserPost
                            {
                                UserId = user.Id,
                                PostId = rel.PostId,
                                DeptId = rel.DeptId
                            });
                        }
                    }

                    await _context.SaveChangesAsync();
                    await transaction.CommitAsync();
                    return (true, "创建成功");
                }
                catch (Exception ex)
                {
                    await transaction.RollbackAsync();
                    _logger.LogError(ex, "CreateUserAsync failed");
                    return (false, "创建失败: " + ex.Message);
                }
            });
        }

        public async Task<(bool Success, string Message)> UpdateUserAsync(long id, UpdateUserDto dto)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null)
            {
                return (false, "用户不存在");
            }

            if (user.Username == "admin" && dto.IsActive == false)
            {
                return (false, "不能禁用超级管理员");
            }

            if (dto.Nickname != null) user.Nickname = dto.Nickname;
            if (dto.Email != null) user.Email = dto.Email;
            if (dto.Phone != null) user.Phone = dto.Phone;
            if (dto.IsActive.HasValue) user.IsActive = dto.IsActive.Value;
            if (dto.DeptId.HasValue) user.DeptId = dto.DeptId.Value;

            var strategy = _context.Database.CreateExecutionStrategy();
            return await strategy.ExecuteAsync(async () =>
            {
                using var transaction = await _context.Database.BeginTransactionAsync();
                try
                {
                    if (dto.RoleIds != null)
                    {
                        // 移除旧角色
                        var oldRoles = await _context.UserRoles.Where(ur => ur.UserId == id).ToListAsync();
                        _context.UserRoles.RemoveRange(oldRoles);

                        // 添加新角色
                        foreach (var roleId in dto.RoleIds)
                        {
                            _context.UserRoles.Add(new omsapi.Models.Entities.SystemUserRole
                            {
                                UserId = id,
                                RoleId = roleId
                            });
                        }
                    }

                    if (dto.PostRelations != null)
                    {
                        // 移除旧岗位关联
                        var oldPosts = await _context.UserPosts.Where(up => up.UserId == id).ToListAsync();
                        _context.UserPosts.RemoveRange(oldPosts);

                        // 添加新岗位关联
                        foreach (var rel in dto.PostRelations)
                        {
                            _context.UserPosts.Add(new omsapi.Models.Entities.SystemUserPost
                            {
                                UserId = id,
                                PostId = rel.PostId,
                                DeptId = rel.DeptId
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
                    _logger.LogError(ex, "UpdateUserAsync failed");
                    return (false, "更新失败: " + ex.Message);
                }
            });
        }

        public async Task<(bool Success, string Message)> DeleteUserAsync(long id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null)
            {
                return (false, "用户不存在");
            }

            if (user.Username == "admin")
            {
                return (false, "不能删除超级管理员");
            }

            // 软删除或硬删除，这里演示硬删除，实际项目建议软删除 (IsDeleted)
            // 先删除关联的角色
            var roles = await _context.UserRoles.Where(ur => ur.UserId == id).ToListAsync();
            _context.UserRoles.RemoveRange(roles);

            // 删除关联的岗位
            var posts = await _context.UserPosts.Where(up => up.UserId == id).ToListAsync();
            _context.UserPosts.RemoveRange(posts);
            
            _context.Users.Remove(user);
            await _context.SaveChangesAsync();
            return (true, "删除成功");
        }

        public async Task<(bool Success, string Message)> ResetPasswordAsync(long id, string newPassword)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null)
            {
                return (false, "用户不存在");
            }

            user.Password = ComputeSha256Hash(newPassword);
            await _context.SaveChangesAsync();
            return (true, "重置密码成功");
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
            if (dto.Status != null) user.Status = dto.Status;

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

        public async Task<(bool IsAdmin, List<long> RoleIds)> GetUserPermissionsAsync(long? userId)
        {
            if (!userId.HasValue) return (false, new List<long>());

            // Check if user is Admin
            // Assuming Admin role code is "ADMIN"
            var userRoles = await _context.UserRoles
                .Where(ur => ur.UserId == userId.Value)
                .Include(ur => ur.Role)
                .ToListAsync();

            var roleIds = userRoles.Select(ur => ur.RoleId).ToList();
            var isAdmin = userRoles.Any(ur => ur.Role.Code == "SuperAdmin");

            return (isAdmin, roleIds);
        }
        public async Task<PagedResult<DeptTreeDto>> GetMyOrganizationsPagedAsync(long userId, string? keyword, int page, int pageSize)
        {
            // 1. Get User
            var user = await _context.Users
                .Include(u => u.Dept)
                .Include(u => u.UserPosts)
                .FirstOrDefaultAsync(u => u.Id == userId);

            if (user == null) return new PagedResult<DeptTreeDto>();

            var rootIds = new HashSet<long>();

            // 2. Demo Org
            var demoOrg = await _context.Depts.FirstOrDefaultAsync(d => d.Code == "DEMO");
            if (demoOrg != null) rootIds.Add(demoOrg.Id);

            // 3. User Depts (Climb to root)
            var deptIds = new HashSet<long>();
            if (user.DeptId.HasValue) deptIds.Add(user.DeptId.Value);
            foreach (var post in user.UserPosts) deptIds.Add(post.DeptId);

            foreach (var deptId in deptIds)
            {
                var current = await _context.Depts.FindAsync(deptId);
                if (current == null) continue;
                
                var root = current;
                while (root.ParentId != null)
                {
                    var parent = await _context.Depts.FindAsync(root.ParentId);
                    if (parent == null) break;
                    root = parent;
                }
                rootIds.Add(root.Id);
            }

            // 4. Query
            var query = _context.Depts.Where(d => rootIds.Contains(d.Id));

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

        private DeptTreeDto MapToTreeDto(omsapi.Models.Entities.SystemDept d)
        {
            return new DeptTreeDto
            {
                Id = d.Id,
                Name = d.Name,
                Code = d.Code,
                Type = d.Type,
                Leader = d.Leader,
                Phone = d.Phone,
                Email = d.Email,
                IsActive = d.IsActive,
                SortOrder = d.SortOrder,
                CreatedAt = d.CreatedAt,
                Children = new List<DeptTreeDto>()
            };
        }
    }
}
