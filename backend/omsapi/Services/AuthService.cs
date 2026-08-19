using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.AspNetCore.Hosting;
using omsapi.Data;
using omsapi.Models.Dtos;
using omsapi.Services.Interfaces;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using omsapi.Infrastructure.Extensions;
using System.Text;

using omsapi.Infrastructure.Attributes;

namespace omsapi.Services
{
    [AutoInject(ServiceLifetime.Scoped)]
    public class AuthService : IAuthService
    {
        private readonly OmsContext _context;
        private readonly IConfiguration _configuration;
        private readonly IAuditLogService _auditLogService;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly IWebHostEnvironment _environment;
        private readonly IAiService _aiService;

        public AuthService(OmsContext context, IConfiguration configuration, IAuditLogService auditLogService, IHttpContextAccessor httpContextAccessor, IWebHostEnvironment environment, IAiService aiService)
        {
            _context = context;
            _configuration = configuration;
            _auditLogService = auditLogService;
            _httpContextAccessor = httpContextAccessor;
            _environment = environment;
            _aiService = aiService;
        }

        public async Task<(bool Success, string Message, LoginResultDto? Data)> LoginAsync(LoginRequest request)
        {
            var startTime = DateTime.Now;
            var ipAddress = _httpContextAccessor.HttpContext?.GetClientIp();
            var userAgent = _httpContextAccessor.HttpContext?.Request?.Headers["User-Agent"].ToString();

            if (string.IsNullOrEmpty(request.Username) || string.IsNullOrEmpty(request.Password))
            {
                await LogLoginAsync(null, request.Username, false, "用户名和密码不能为空", startTime, ipAddress, userAgent);
                return (false, "用户名和密码不能为空", null);
            }

            // 计算密码哈希
            var hashedPassword = ComputeSha256Hash(request.Password);

            // 查询用户
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Username == request.Username && u.Password == hashedPassword);

            if (user == null)
            {
                await LogLoginAsync(null, request.Username, false, "用户名或密码错误", startTime, ipAddress, userAgent);
                return (false, "用户名或密码错误", null);
            }

            if (!user.IsActive)
            {
                await LogLoginAsync(user.Id, user.Username, false, "账号已被禁用", startTime, ipAddress, userAgent);
                return (false, "账号已被禁用", null);
            }

            // 组织启停状态单独存放在注册单状态中。
            // 这里仅拦截“通过注册创建且当前已停用”的组织，不影响用户自身启用停用字段。
            var currentRootOrgId = await GetUserCurrentRootOrgIdAsync(user);
            if (currentRootOrgId.HasValue)
            {
                var orgRegistrationStatus = await GetOrgRegistrationStatusAsync(currentRootOrgId.Value);
                if (orgRegistrationStatus == "disabled")
                {
                    await LogLoginAsync(user.Id, user.Username, false, "所属组织已停用", startTime, ipAddress, userAgent);
                    return (false, "所属组织已停用，暂不允许登录", null);
                }
            }

            // 更新最后登录时间
            user.LastLoginAt = DateTime.Now;
            await _context.SaveChangesAsync();

            var roleIds = await GetEffectiveRoleIdsAsync(user.Id);
            var roleCodes = await _context.Roles.Where(r => roleIds.Contains(r.Id)).Select(r => r.Code).ToListAsync();
            var token = GenerateJwtToken(user.Username, user.Id, roleCodes);
            
            // Check if user is Admin
            var isAdmin = await _context.Roles.AnyAsync(r => roleIds.Contains(r.Id) && r.Code == "SuperAdmin");

            var result = new LoginResultDto
            {
                Token = token,
                User = new UserDto
                {
                    Id = user.Id,
                    Username = user.Username,
                    Nickname = user.Nickname,
                    Email = user.Email,
                    Phone = user.Phone,
                    Avatar = user.Avatar,
                    Roles = roleIds,
                    RoleCodes = roleCodes,
                    DeptId = user.DeptId,
                    IsAdmin = isAdmin
                }
            };

            await LogLoginAsync(user.Id, user.Username, true, "登录成功", startTime, ipAddress, userAgent);
            return (true, "登录成功", result);
        }

        /// <summary>
        /// 管理员模拟登录指定用户。
        /// 平台管理员可模拟任意非超级管理员；
        /// 组织管理员仅可模拟自己管理范围内的非超级管理员用户。
        /// </summary>
        public async Task<(bool Success, string Message, LoginResultDto? Data)> ImpersonateAsync(long operatorUserId, long targetUserId)
        {
            if (operatorUserId == targetUserId)
            {
                return (false, "无需模拟登录自己", null);
            }

            var operatorUser = await _context.Users.FindAsync(operatorUserId);
            if (operatorUser == null || !operatorUser.IsActive)
            {
                return (false, "当前操作用户无效", null);
            }

            var targetUser = await _context.Users.FindAsync(targetUserId);
            if (targetUser == null)
            {
                return (false, "目标用户不存在", null);
            }

            if (!targetUser.IsActive)
            {
                return (false, "目标用户已被禁用，不能模拟登录", null);
            }

            var operatorRoleIds = await GetEffectiveRoleIdsAsync(operatorUserId);
            var targetRoleIds = await GetEffectiveRoleIdsAsync(targetUserId);

            var operatorIsSuperAdmin = await _context.Roles.AnyAsync(r => operatorRoleIds.Contains(r.Id) && r.Code == "SuperAdmin");
            var targetIsSuperAdmin = await _context.Roles.AnyAsync(r => targetRoleIds.Contains(r.Id) && r.Code == "SuperAdmin");

            if (targetIsSuperAdmin)
            {
                return (false, "不能模拟登录超级管理员", null);
            }

            if (!operatorIsSuperAdmin)
            {
                var operatorIsOrgAdmin = await _context.Roles.AnyAsync(r => operatorRoleIds.Contains(r.Id) && r.Code == "OrgAdmin");
                if (!operatorIsOrgAdmin)
                {
                    return (false, "只有平台管理员或组织管理员可以模拟登录其他用户", null);
                }

                var managedDeptIds = await GetManagedDeptIdsAsync(operatorUserId);
                if (managedDeptIds.Count == 0)
                {
                    return (false, "当前用户没有可管理的组织或部门", null);
                }

                var targetManaged = targetUser.DeptId.HasValue && managedDeptIds.Contains(targetUser.DeptId.Value);
                if (!targetManaged)
                {
                    var targetPostDeptIds = await _context.UserPosts
                        .Where(up => up.UserId == targetUserId)
                        .Select(up => up.DeptId)
                        .Distinct()
                        .ToListAsync();
                    targetManaged = targetPostDeptIds.Any(deptId => managedDeptIds.Contains(deptId));
                }

                if (!targetManaged)
                {
                    return (false, "只能模拟登录自己管理范围内的用户", null);
                }
            }

            var currentRootOrgId = await GetUserCurrentRootOrgIdAsync(targetUser);
            if (currentRootOrgId.HasValue)
            {
                var orgRegistrationStatus = await GetOrgRegistrationStatusAsync(currentRootOrgId.Value);
                if (orgRegistrationStatus == "disabled")
                {
                    return (false, "目标用户所属组织已停用，不能模拟登录", null);
                }
            }

            targetUser.LastLoginAt = DateTime.Now;
            await _context.SaveChangesAsync();

            var targetRoleCodes = await _context.Roles
                .Where(r => targetRoleIds.Contains(r.Id))
                .Select(r => r.Code)
                .ToListAsync();

            var token = GenerateJwtToken(targetUser.Username, targetUser.Id, targetRoleCodes);
            var isAdmin = await _context.Roles.AnyAsync(r => targetRoleIds.Contains(r.Id) && r.Code == "SuperAdmin");
            var result = new LoginResultDto
            {
                Token = token,
                User = new UserDto
                {
                    Id = targetUser.Id,
                    Username = targetUser.Username,
                    Nickname = targetUser.Nickname,
                    Email = targetUser.Email,
                    Phone = targetUser.Phone,
                    Avatar = targetUser.Avatar,
                    Roles = targetRoleIds,
                    RoleCodes = targetRoleCodes,
                    DeptId = targetUser.DeptId,
                    IsAdmin = isAdmin
                }
            };

            var now = DateTime.Now;
            await _auditLogService.LogAsync(new omsapi.Models.Entities.SystemAuditLog
            {
                UserId = operatorUserId,
                UserName = operatorUser.Username,
                Action = "ImpersonateLogin",
                Route = $"/api/auth/impersonate/{targetUserId}",
                Method = "POST",
                IpAddress = _httpContextAccessor.HttpContext?.GetClientIp(),
                UserAgent = _httpContextAccessor.HttpContext?.Request?.Headers["User-Agent"].ToString(),
                IsSuccess = true,
                ExecutionDuration = 0,
                CreatedAt = now,
                Parameters = $"{{\"targetUserId\":{targetUser.Id},\"targetUsername\":\"{targetUser.Username}\"}}"
            });

            return (true, $"已切换为用户【{targetUser.Nickname ?? targetUser.Username}】", result);
        }

        public async Task<(bool Success, string Message, object? Data)> RegisterAsync(RegisterRequest request)
        {
            var startTime = DateTime.Now;
            var ipAddress = _httpContextAccessor.HttpContext?.GetClientIp();
            var userAgent = _httpContextAccessor.HttpContext?.Request?.Headers["User-Agent"].ToString();

            if (string.IsNullOrEmpty(request.OrgName) || string.IsNullOrEmpty(request.Username) || string.IsNullOrEmpty(request.Password))
            {
                return (false, "组织名称、用户名和密码不能为空", null);
            }

            // 1. Check if username exists in System Users (even if pending, we should probably check, 
            // but for now pending registrations are separate. However, if a user exists in main table, we can't use that username?)
            // Actually, if we store in SysOrgRegistration, we check there too?
            // Let's check both SystemUser and SysOrgRegistration for username uniqueness to avoid conflicts later.
            if (await _context.Users.AnyAsync(u => u.Username == request.Username))
            {
                return (false, "用户名已存在", null);
            }
            if (await _context.OrgRegistrations.AnyAsync(r => r.AdminUsername == request.Username && r.Status == "pending"))
            {
                return (false, "用户名已被注册（审核中）", null);
            }

            // 2. Check if Org Name exists
            if (await _context.Depts.AnyAsync(d => d.Name == request.OrgName))
            {
                return (false, "组织名称已存在", null);
            }
            if (await _context.OrgRegistrations.AnyAsync(r => r.OrgName == request.OrgName && r.Status == "pending"))
            {
                return (false, "组织名称已被注册（审核中）", null);
            }

            // 3. Create Registration Record
            var hashedPassword = ComputeSha256Hash(request.Password);
            var registration = new omsapi.Models.Entities.System.SysOrgRegistration
            {
                OrgName = request.OrgName,
                OrgShortName = request.OrgShortName,
                OrgAbbr = request.OrgAbbr,
                LicenseCode = request.LicenseCode,
                LicenseFileUrl = request.LicenseFileUrl,
                AuthLetterFileUrl = request.AuthLetterFileUrl,
                ContactName = request.ContactName,
                ContactPhone = request.ContactPhone,
                ContactEmail = request.ContactEmail,
                AdminUsername = request.Username,
                AdminPassword = hashedPassword,
                Status = "pending",
                CreatedAt = DateTime.Now
            };

            _context.OrgRegistrations.Add(registration);
            await _context.SaveChangesAsync();

            // Return success but NO token (because they are not active yet)
            return (true, "注册申请已提交，请等待审核", new { RegistrationId = registration.Id });
        }

        public async Task<(bool Success, string Message, string? Url)> UploadRegistrationFileAsync(Microsoft.AspNetCore.Http.IFormFile file)
        {
             if (file == null || file.Length == 0)
            {
                return (false, "请选择文件", null);
            }

            // 验证文件类型 (Images + PDF?)
            var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".pdf" };
            var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
            if (!allowedExtensions.Contains(extension))
            {
                return (false, "仅支持 jpg, jpeg, png, pdf 格式的文件", null);
            }

            try
            {
                // Store in uploads/registration
                var uploadPath = Path.Combine(_environment.WebRootPath, "uploads", "registration");

                if (!Directory.Exists(uploadPath))
                {
                    Directory.CreateDirectory(uploadPath);
                }

                // Generate unique filename
                var fileName = $"{Guid.NewGuid()}{extension}";
                var filePath = Path.Combine(uploadPath, fileName);

                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await file.CopyToAsync(stream);
                }

                var url = $"/uploads/registration/{fileName}";
                return (true, "上传成功", url);
            }
            catch (Exception ex)
            {
                return (false, $"上传失败: {ex.Message}", null);
            }
        }

        /// <summary>
        /// 删除组织注册时上传但最终未保存的临时文件（营业执照、授权书）。
        /// 严格限制只能删除 wwwroot/uploads/registration 目录下的文件，防止路径穿越。
        /// </summary>
        public Task<(bool Success, string Message)> DeleteRegistrationFileAsync(string fileUrl)
        {
            if (string.IsNullOrWhiteSpace(fileUrl))
            {
                return Task.FromResult((true, "文件路径为空，无需删除"));
            }

            try
            {
                // 将完整 URL（如 http://xxx/uploads/registration/xxx.png）统一转换成相对路径
                var relativePath = fileUrl;
                if (fileUrl.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                {
                    if (Uri.TryCreate(fileUrl, UriKind.Absolute, out var uri))
                    {
                        relativePath = uri.AbsolutePath;
                    }
                }

                // 去掉开头斜杠，便于 Path.Combine 正常拼接
                if (relativePath.StartsWith("/"))
                {
                    relativePath = relativePath.Substring(1);
                }

                // 归一化目录分隔符，替换 URL 中的 '/' 为本地 OS 分隔符
                relativePath = relativePath.Replace('/', Path.DirectorySeparatorChar);

                // 白名单：只有以 "uploads{分隔符}registration{分隔符}" 开头的相对路径才允许删除
                var allowedPrefix = $"uploads{Path.DirectorySeparatorChar}registration{Path.DirectorySeparatorChar}";
                if (!relativePath.StartsWith(allowedPrefix, StringComparison.OrdinalIgnoreCase))
                {
                    return Task.FromResult((false, "非法的文件路径，仅允许删除注册上传目录下的文件"));
                }

                // 基于 WebRootPath 得到完整物理路径，再用 GetFullPath 归一化防止 `../` 路径穿越
                var basePath = Path.GetFullPath(_environment.WebRootPath.TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar);
                var candidatePath = Path.GetFullPath(Path.Combine(_environment.WebRootPath, relativePath));

                // 必须位于 WebRootPath 以内
                if (!candidatePath.StartsWith(basePath, StringComparison.OrdinalIgnoreCase))
                {
                    return Task.FromResult((false, "非法的文件路径，路径越界"));
                }

                if (System.IO.File.Exists(candidatePath))
                {
                    System.IO.File.Delete(candidatePath);
                }

                return Task.FromResult((true, "删除成功"));
            }
            catch (Exception ex)
            {
                return Task.FromResult((false, $"删除失败: {ex.Message}"));
            }
        }

        public async Task<(bool Success, string Message, object? Data)> RecognizeLicenseAsync(IFormFile file)
        {
            if (file == null || file.Length == 0)
            {
                return (false, "请选择文件", null);
            }

            var allowedExtensions = new[] { ".jpg", ".jpeg", ".png" }; // Only images for vision model
            var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
            if (!allowedExtensions.Contains(extension))
            {
                return (false, "OCR识别仅支持 jpg, jpeg, png 格式的图片", null);
            }

            try
            {
                using var stream = new MemoryStream();
                await file.CopyToAsync(stream);
                var imageBytes = stream.ToArray();

                var (orgName, licenseCode, orgShortName, orgAbbr) = await _aiService.OcrLicenseAsync(imageBytes, file.ContentType);

                if (string.IsNullOrEmpty(orgName) && string.IsNullOrEmpty(licenseCode))
                {
                    // Even if null, return success=false or just empty data?
                    // User expects recognition.
                    return (false, "未能识别出组织全称或证照编码，请手动填写", null);
                }

                return (true, "识别成功", new { orgName = orgName, licenseCode = licenseCode, orgShortName = orgShortName, orgAbbr = orgAbbr });
            }
            catch (Exception ex)
            {
                return (false, $"识别失败: {ex.Message}", null);
            }
        }

        public async Task<(bool Success, string Message, List<MenuItemDto>? Data)> GetUserRoutesAsync(long userId)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null) return (false, "用户不存在", null);

            // 获取用户所有角色ID (包括继承的角色)
            var roleIds = await GetEffectiveRoleIdsAsync(userId);

            if (!roleIds.Any()) return (true, "获取成功", new List<MenuItemDto>());

            // Check if SuperAdmin
            var isSuperAdmin = await _context.Roles.AnyAsync(r => roleIds.Contains(r.Id) && r.Code == "SuperAdmin");

            List<omsapi.Models.Entities.SystemPermission> menus;

            if (isSuperAdmin)
            {
                // SuperAdmin gets all visible menus
                menus = await _context.Permissions
                    .Where(p => p.Type == "MENU" && p.IsVisible)
                    .OrderBy(p => p.SortOrder)
                    .ToListAsync();
            }
            else
            {
                // 获取所有权限ID
                var permissionIds = await _context.RolePermissions
                    .Where(rp => roleIds.Contains(rp.RoleId))
                    .Select(rp => rp.PermissionId)
                    .Distinct()
                    .ToListAsync();

                // 查询菜单类型的权限
                menus = await _context.Permissions
                    .Where(p => permissionIds.Contains(p.Id) && p.Type == "MENU" && p.IsVisible)
                    .OrderBy(p => p.SortOrder)
                    .ToListAsync();
            }

            // 构建树形结构
            var menuTree = BuildMenuTree(menus, null);

            return (true, "获取成功", menuTree);
        }

        public async Task<(bool Success, string Message, List<string>? Data)> GetUserPermissionsAsync(long userId)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null) return (false, "用户不存在", null);

            // 获取用户所有角色ID (包括继承的角色)
            var roleIds = await GetEffectiveRoleIdsAsync(userId);

            if (!roleIds.Any()) return (true, "获取成功", new List<string>());

            // Check if SuperAdmin
            var isSuperAdmin = await _context.Roles.AnyAsync(r => roleIds.Contains(r.Id) && r.Code == "SuperAdmin");

            if (isSuperAdmin)
            {
                // SuperAdmin gets all permissions
                var allPermissions = await _context.Permissions
                    .Select(p => p.Code)
                    .Distinct()
                    .ToListAsync();
                return (true, "获取成功", allPermissions);
            }

            // 获取所有权限编码
            var permissions = await _context.RolePermissions
                .Where(rp => roleIds.Contains(rp.RoleId))
                .Join(_context.Permissions,
                    rp => rp.PermissionId,
                    p => p.Id,
                    (rp, p) => p.Code)
                .Distinct()
                .ToListAsync();

            return (true, "获取成功", permissions);
        }

        private async Task<List<long>> GetEffectiveRoleIdsAsync(long userId)
        {
            // 1. Get direct roles
            var userRoleIds = await _context.UserRoles
                .Where(ur => ur.UserId == userId)
                .Select(ur => ur.RoleId)
                .ToListAsync();

            if (!userRoleIds.Any()) return new List<long>();

            // 2. Get all inheritance relationships
            // Note: In a large system, this should be cached or optimized. 
            // For now, assuming role hierarchy is small enough.
            var allInheritances = await _context.RoleInheritances.ToListAsync();

            // 3. Expand roles
            var effectiveRoleIds = new HashSet<long>(userRoleIds);
            bool changed = true;
            while (changed)
            {
                changed = false;
                // Find children of current roles that are not yet in the set
                // Logic: If I have Role A (Parent), and A includes B (Child), then I have B.
                var newChildren = allInheritances
                    .Where(ri => effectiveRoleIds.Contains(ri.ParentRoleId) && !effectiveRoleIds.Contains(ri.ChildRoleId))
                    .Select(ri => ri.ChildRoleId)
                    .ToList();

                if (newChildren.Any())
                {
                    foreach (var id in newChildren) effectiveRoleIds.Add(id);
                    changed = true;
                }
            }

            return effectiveRoleIds.ToList();
        }

        /// <summary>
        /// 获取当前用户可管理的部门范围。
        /// 超级管理员无需使用此方法，组织管理员默认可管理所在根组织及下级部门。
        /// </summary>
        private async Task<HashSet<long>> GetManagedDeptIdsAsync(long userId)
        {
            var managed = new HashSet<long>();
            var user = await _context.Users.FindAsync(userId);
            if (user == null)
            {
                return managed;
            }

            if (!string.IsNullOrWhiteSpace(user.Username))
            {
                var leaderDeptIds = await _context.Depts
                    .Where(d => d.Leader == user.Username)
                    .Select(d => d.Id)
                    .ToListAsync();

                foreach (var deptId in leaderDeptIds)
                {
                    var descendants = await GetDescendantDeptIdsAsync(deptId);
                    foreach (var id in descendants)
                    {
                        managed.Add(id);
                    }
                }
            }

            if (managed.Count == 0 && user.DeptId.HasValue)
            {
                var rootId = await GetDeptRootIdAsync(user.DeptId.Value);
                if (rootId.HasValue)
                {
                    var descendants = await GetDescendantDeptIdsAsync(rootId.Value);
                    foreach (var id in descendants)
                    {
                        managed.Add(id);
                    }
                }
            }

            return managed;
        }

        /// <summary>
        /// 获取指定部门及其全部下级部门。
        /// </summary>
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

                foreach (var childId in children)
                {
                    if (result.Contains(childId))
                    {
                        continue;
                    }

                    result.Add(childId);
                    queue.Enqueue(childId);
                }
            }

            return result;
        }

        private List<MenuItemDto> BuildMenuTree(List<omsapi.Models.Entities.SystemPermission> allMenus, long? parentId)
        {
            return allMenus
                .Where(m => m.ParentId == parentId)
                .Select(m => new MenuItemDto
                {
                    Key = m.Code,
                    Title = m.Name,
                    Icon = m.Icon,
                    Path = m.Path,
                    Component = m.Component,
                    Query = m.Query,
                    Children = BuildMenuTree(allMenus, m.Id)
                })
                .ToList();
        }

        private async Task LogLoginAsync(long? userId, string? username, bool isSuccess, string message, DateTime startTime, string? ipAddress, string? userAgent)
        {
            var duration = (long)(DateTime.Now - startTime).TotalMilliseconds;
            var log = new omsapi.Models.Entities.SystemAuditLog
            {
                UserId = userId,
                UserName = username,
                Action = "Login",
                Route = "/api/auth/login",
                Method = "POST",
                IpAddress = ipAddress,
                UserAgent = userAgent,
                IsSuccess = isSuccess,
                ErrorMessage = isSuccess ? null : message,
                ExecutionDuration = duration,
                CreatedAt = DateTime.Now
            };
            await _auditLogService.LogAsync(log);
        }

        private string GenerateJwtToken(string username, long userId, List<string> roleCodes)
        {
            var key = _configuration["Jwt:Key"] ?? throw new InvalidOperationException("Jwt:Key is missing");
            var securityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key));
            var credentials = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256);

            var claims = new List<Claim>
            {
                new Claim(JwtRegisteredClaimNames.Sub, username),
                new Claim(ClaimTypes.Name, username),
                new Claim("id", userId.ToString()),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
            };

            foreach (var code in roleCodes)
            {
                claims.Add(new Claim(ClaimTypes.Role, code));
            }

            var token = new JwtSecurityToken(
                issuer: _configuration["Jwt:Issuer"],
                audience: _configuration["Jwt:Audience"],
                claims: claims,
                expires: DateTime.Now.AddMinutes(120), // 2 hours expiration
                signingCredentials: credentials);

            return new JwtSecurityTokenHandler().WriteToken(token);
        }

        private static string ComputeSha256Hash(string rawData)
        {
            using (SHA256 sha256Hash = SHA256.Create())
            {
                byte[] bytes = sha256Hash.ComputeHash(Encoding.UTF8.GetBytes(rawData));

                StringBuilder builder = new StringBuilder();
                for (int i = 0; i < bytes.Length; i++)
                {
                    builder.Append(bytes[i].ToString("x2"));
                }
                return builder.ToString();
            }
        }

        /// <summary>
        /// 从任意部门向上回溯，获取根组织 ID。
        /// </summary>
        private async Task<long?> GetDeptRootIdAsync(long deptId)
        {
            var currentDept = await _context.Depts.FindAsync(deptId);
            if (currentDept == null)
            {
                return null;
            }

            while (currentDept.ParentId.HasValue)
            {
                var parentDept = await _context.Depts.FindAsync(currentDept.ParentId.Value);
                if (parentDept == null)
                {
                    break;
                }

                currentDept = parentDept;
            }

            return currentDept.Id;
        }

        /// <summary>
        /// 获取用户当前所属的根组织 ID，优先使用 CurrentOrgId，缺失时回退到 DeptId 反查。
        /// </summary>
        private async Task<long?> GetUserCurrentRootOrgIdAsync(omsapi.Models.Entities.SystemUser user)
        {
            var deptId = user.CurrentOrgId ?? user.DeptId;
            if (!deptId.HasValue)
            {
                return null;
            }

            var currentDept = await _context.Depts.FindAsync(deptId.Value);
            if (currentDept == null)
            {
                return null;
            }

            while (currentDept.ParentId.HasValue)
            {
                var parentDept = await _context.Depts.FindAsync(currentDept.ParentId.Value);
                if (parentDept == null)
                {
                    break;
                }

                currentDept = parentDept;
            }

            return currentDept.Id;
        }

        /// <summary>
        /// 通过根组织名称匹配注册记录，返回组织注册状态。
        /// 对于非注册流程创建的组织，返回 null，保持原有登录行为不变。
        /// </summary>
        private async Task<string?> GetOrgRegistrationStatusAsync(long rootOrgId)
        {
            var rootOrg = await _context.Depts.FindAsync(rootOrgId);
            if (rootOrg == null)
            {
                return null;
            }

            return await _context.OrgRegistrations
                .Where(r => r.OrgName == rootOrg.Name)
                .OrderByDescending(r => r.Id)
                .Select(r => r.Status)
                .FirstOrDefaultAsync();
        }
    }
}
