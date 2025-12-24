using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
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

        public AuthService(OmsContext context, IConfiguration configuration, IAuditLogService auditLogService, IHttpContextAccessor httpContextAccessor)
        {
            _context = context;
            _configuration = configuration;
            _auditLogService = auditLogService;
            _httpContextAccessor = httpContextAccessor;
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

            var token = GenerateJwtToken(user.Username, user.Id);

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
                    Avatar = user.Avatar
                }
            };

            await LogLoginAsync(user.Id, user.Username, true, "登录成功", startTime, ipAddress, userAgent);
            return (true, "登录成功", result);
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

        private string GenerateJwtToken(string username, long userId)
        {
            var key = _configuration["Jwt:Key"] ?? throw new InvalidOperationException("Jwt:Key is missing");
            var securityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key));
            var credentials = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256);

            var claims = new[]
            {
                new Claim(JwtRegisteredClaimNames.Sub, username),
                new Claim("id", userId.ToString()),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
            };

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