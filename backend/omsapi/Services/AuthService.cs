using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.AspNetCore.Hosting;
using omsapi.Data;
using omsapi.Models.Dtos;
using omsapi.Services.Interfaces;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
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
            var ipAddress = _httpContextAccessor.HttpContext?.Connection?.RemoteIpAddress?.ToString();
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
                    DeptId = user.DeptId,
                    IsAdmin = isAdmin
                }
            };

            await LogLoginAsync(user.Id, user.Username, true, "登录成功", startTime, ipAddress, userAgent);
            return (true, "登录成功", result);
        }

        public async Task<(bool Success, string Message, object? Data)> RegisterAsync(RegisterRequest request)
        {
            var startTime = DateTime.Now;
            var ipAddress = _httpContextAccessor.HttpContext?.Connection?.RemoteIpAddress?.ToString();
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

            // 获取所有权限ID
            var permissionIds = await _context.RolePermissions
                .Where(rp => roleIds.Contains(rp.RoleId))
                .Select(rp => rp.PermissionId)
                .Distinct()
                .ToListAsync();

            // 查询菜单类型的权限
            var menus = await _context.Permissions
                .Where(p => permissionIds.Contains(p.Id) && p.Type == "MENU" && p.IsVisible)
                .OrderBy(p => p.SortOrder)
                .ToListAsync();

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
    }
}
