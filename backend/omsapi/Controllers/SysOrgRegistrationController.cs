using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using omsapi.Data;
using omsapi.Models.Entities;
using omsapi.Models.Entities.System;
using omsapi.Models.Enums;

namespace omsapi.Controllers
{
    [Route("api/sys/org-registration")]
    [ApiController]
    // [Authorize] // Temporarily comment out if auth is not fully set up or for testing, but typically this should be admin only
    public class SysOrgRegistrationController : ControllerBase
    {
        private readonly OmsContext _context;
        private readonly IWebHostEnvironment _env;

        public SysOrgRegistrationController(OmsContext context, IWebHostEnvironment env)
        {
            _context = context;
            _env = env;
        }

        [HttpGet("list")]
        public async Task<IActionResult> GetList([FromQuery] string? status, [FromQuery] string? keyword, [FromQuery] int page = 1, [FromQuery] int pageSize = 10)
        {
            var query = _context.OrgRegistrations.AsQueryable();

            if (!string.IsNullOrEmpty(status))
            {
                query = query.Where(r => r.Status == status);
            }

            if (!string.IsNullOrEmpty(keyword))
            {
                query = query.Where(r => r.OrgName.Contains(keyword) || r.ContactName.Contains(keyword) || r.ContactPhone.Contains(keyword));
            }

            var total = await query.CountAsync();
            var list = await query.OrderByDescending(r => r.CreatedAt)
                                  .Skip((page - 1) * pageSize)
                                  .Take(pageSize)
                                  .ToListAsync();

            return Ok(new
            {
                total,
                items = list
            });
        }

        [HttpPost("approve/{id}")]
        public async Task<IActionResult> Approve(long id)
        {
            var strategy = _context.Database.CreateExecutionStrategy();
            return await strategy.ExecuteAsync(async () =>
            {
                // Clear ChangeTracker to prevent state corruption on retry
                _context.ChangeTracker.Clear();

                using var transaction = await _context.Database.BeginTransactionAsync();
                try
                {
                    var registration = await _context.OrgRegistrations.FindAsync(id);
                    if (registration == null)
                    {
                        return NotFound("申请不存在");
                    }

                    if (registration.Status != "pending")
                    {
                        return BadRequest("该申请已被处理");
                    }

                    // 1. Create Organization (Dept)
                    var dept = new SystemDept
                    {
                        Name = registration.OrgName,
                        OrgAbbr = registration.OrgAbbr ?? string.Empty,
                        Code = registration.OrgAbbr, // Use abbreviation as code if available
                        Type = DeptType.Company,
                        Leader = registration.ContactName,
                        Phone = registration.ContactPhone,
                        Email = registration.ContactEmail,
                        ParentId = null, // Top level company
                        IsActive = true,
                        CreatedAt = DateTime.Now
                    };
                    _context.Depts.Add(dept);
                    await _context.SaveChangesAsync();

                    // 2. Ensure Org Admin Role
                    var orgAdminRole = await EnsureOrgAdminRoleAsync(dept, registration);

                    // 3. Create Admin User
                    // Note: dept.Id is generated after SaveChangesAsync
                    var user = new SystemUser
                    {
                        Username = registration.AdminUsername,
                        Password = registration.AdminPassword, // Already hashed
                        Nickname = registration.ContactName,
                        Phone = registration.ContactPhone,
                        Email = registration.ContactEmail,
                        DeptId = dept.Id,
                        CurrentOrgId = dept.Id, // Set current org to the new company
                        IsActive = true,
                        CreatedAt = DateTime.Now,
                        Status = "active"
                    };
                    _context.Users.Add(user);
                    await _context.SaveChangesAsync();

                    // 4. Bind Admin User To Org Admin Role
                    await EnsureUserInRoleAsync(user.Id, orgAdminRole.Id);

                    // 5. Update Registration Status
                    registration.Status = "approved";
                    registration.UpdatedAt = DateTime.Now;
                    // registration is already tracked (re-fetched after Clear)
                    
                    await _context.SaveChangesAsync();

                    await transaction.CommitAsync();

                    return Ok("审核通过");
                }
                catch (Exception ex)
                {
                    await transaction.RollbackAsync();
                    return StatusCode(500, $"审核失败: {ex.Message}");
                }
            });
        }

        [HttpPost("reject/{id}")]
        public async Task<IActionResult> Reject(long id, [FromBody] RejectRequest request)
        {
            var registration = await _context.OrgRegistrations.FindAsync(id);
            if (registration == null)
            {
                return NotFound("申请不存在");
            }

            if (registration.Status != "pending")
            {
                return BadRequest("该申请已被处理");
            }

            registration.Status = "rejected";
            registration.RejectReason = request.Reason;
            registration.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();

            return Ok("已拒绝");
        }

        [HttpPost("disable/{id}")]
        public async Task<IActionResult> Disable(long id)
        {
            var registration = await _context.OrgRegistrations.FindAsync(id);
            if (registration == null)
            {
                return NotFound("申请不存在");
            }

            if (registration.Status != "approved")
            {
                return BadRequest("仅已通过的组织可停用");
            }

            // 组织停用状态单独存放在注册单状态中，不影响组织下用户自身启用停用字段。
            registration.Status = "disabled";
            registration.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();

            return Ok("已停用");
        }

        [HttpPost("enable/{id}")]
        public async Task<IActionResult> Enable(long id)
        {
            var strategy = _context.Database.CreateExecutionStrategy();
            return await strategy.ExecuteAsync(async () =>
            {
                _context.ChangeTracker.Clear();

                using var transaction = await _context.Database.BeginTransactionAsync();
                try
                {
                    var registration = await _context.OrgRegistrations.FindAsync(id);
                    if (registration == null)
                    {
                        return NotFound("申请不存在");
                    }

                    if (registration.Status != "disabled")
                    {
                        return BadRequest("仅已停用的组织可启用");
                    }

                    var dept = await FindOrgRootDeptAsync(registration);
                    if (dept == null)
                    {
                        return BadRequest("未找到对应组织，无法启用");
                    }

                    // 重新启用时也要像审核通过一样，补齐管理员角色和用户绑定，
                    // 避免角色被删或用户角色关系丢失后启用成功但管理员依旧无菜单。
                    var orgAdminRole = await EnsureOrgAdminRoleAsync(dept, registration);
                    var adminUser = await _context.Users.FirstOrDefaultAsync(u => u.Username == registration.AdminUsername);
                    if (adminUser == null)
                    {
                        return BadRequest("未找到组织管理员账号，无法启用");
                    }

                    await EnsureUserInRoleAsync(adminUser.Id, orgAdminRole.Id);

                    // 启用时恢复为已通过，继续沿用注册单状态作为组织启停来源。
                    registration.Status = "approved";
                    registration.UpdatedAt = DateTime.Now;

                    await _context.SaveChangesAsync();
                    await transaction.CommitAsync();

                    return Ok("已启用");
                }
                catch (Exception ex)
                {
                    await transaction.RollbackAsync();
                    return StatusCode(500, $"启用失败: {ex.Message}");
                }
            });
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(long id)
        {
            var registration = await _context.OrgRegistrations.FindAsync(id);
            if (registration == null)
            {
                return NotFound("申请不存在");
            }

            // Delete files
            DeleteFile(registration.LicenseFileUrl);
            DeleteFile(registration.AuthLetterFileUrl);

            _context.OrgRegistrations.Remove(registration);
            await _context.SaveChangesAsync();

            return Ok("删除成功");
        }

        private void DeleteFile(string? fileUrl)
        {
            if (string.IsNullOrEmpty(fileUrl)) return;

            try
            {
                // Assuming fileUrl is like "/uploads/xxx.jpg" or full URL
                // If it's a full URL, we need to extract the relative path
                var relativePath = fileUrl;
                if (fileUrl.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                {
                    var uri = new Uri(fileUrl);
                    relativePath = uri.AbsolutePath;
                }

                // Remove leading slash if present
                if (relativePath.StartsWith("/"))
                {
                    relativePath = relativePath.Substring(1);
                }

                var filePath = Path.Combine(_env.WebRootPath, relativePath);
                if (System.IO.File.Exists(filePath))
                {
                    System.IO.File.Delete(filePath);
                }
            }
            catch (Exception ex)
            {
                // Log error but don't stop deletion of record
                Console.WriteLine($"Error deleting file {fileUrl}: {ex.Message}");
            }
        }

        /// <summary>
        /// 确保组织管理员角色存在，并挂接到全局 OrgAdmin 模板角色。
        /// </summary>
        private async Task<SystemRole> EnsureOrgAdminRoleAsync(SystemDept dept, SysOrgRegistration registration)
        {
            var roleCodePrefix = !string.IsNullOrWhiteSpace(dept.Code) ? dept.Code! : $"ORG{dept.Id}";
            var orgAdminRoleCode = $"{roleCodePrefix}-Admin";
            var orgAdminRole = await _context.Roles.FirstOrDefaultAsync(r => r.Code == orgAdminRoleCode);
            if (orgAdminRole == null)
            {
                orgAdminRole = new SystemRole
                {
                    Name = $"{registration.OrgName}管理员",
                    Code = orgAdminRoleCode,
                    Description = $"{registration.OrgName}组织管理员，负责本组织及下级组织的管理",
                    IsSystem = true,
                    DeptId = dept.Id,
                    CreatedAt = DateTime.Now
                };
                _context.Roles.Add(orgAdminRole);
                await _context.SaveChangesAsync();
            }
            else if (orgAdminRole.DeptId != dept.Id || orgAdminRole.Name != $"{registration.OrgName}管理员")
            {
                orgAdminRole.DeptId = dept.Id;
                orgAdminRole.Name = $"{registration.OrgName}管理员";
                orgAdminRole.Description = $"{registration.OrgName}组织管理员，负责本组织及下级组织的管理";
                orgAdminRole.UpdatedAt = DateTime.Now;
                await _context.SaveChangesAsync();
            }

            await EnsureOrgAdminTemplateRelationAsync(orgAdminRole.Id);
            return orgAdminRole;
        }

        /// <summary>
        /// 确保全局 OrgAdmin 模板角色为系统内置角色，并且不可删除。
        /// </summary>
        private async Task<SystemRole?> EnsureBuiltInOrgAdminTemplateAsync()
        {
            var orgAdminTemplateRole = await _context.Roles
                .Where(r => r.Code == "OrgAdmin" && r.DeptId == null)
                .OrderBy(r => r.Id)
                .FirstOrDefaultAsync();

            if (orgAdminTemplateRole == null)
            {
                return null;
            }

            if (!orgAdminTemplateRole.IsSystem)
            {
                orgAdminTemplateRole.IsSystem = true;
                orgAdminTemplateRole.UpdatedAt = DateTime.Now;
                await _context.SaveChangesAsync();
            }

            return orgAdminTemplateRole;
        }

        /// <summary>
        /// 让组织管理员角色继承全局 OrgAdmin 模板角色，统一复用模板权限。
        /// </summary>
        private async Task EnsureOrgAdminTemplateRelationAsync(long roleId)
        {
            var orgAdminTemplateRole = await EnsureBuiltInOrgAdminTemplateAsync();
            if (orgAdminTemplateRole == null || orgAdminTemplateRole.Id == roleId)
            {
                return;
            }

            var relationExists = await _context.RoleInheritances.AnyAsync(ri =>
                ri.ParentRoleId == roleId && ri.ChildRoleId == orgAdminTemplateRole.Id);

            if (relationExists)
            {
                return;
            }

            _context.RoleInheritances.Add(new SystemRoleInheritance
            {
                ParentRoleId = roleId,
                ChildRoleId = orgAdminTemplateRole.Id
            });
            await _context.SaveChangesAsync();
        }

        /// <summary>
        /// 确保管理员用户已加入组织管理员角色。
        /// </summary>
        private async Task EnsureUserInRoleAsync(long userId, long roleId)
        {
            var userRoleExists = await _context.UserRoles.AnyAsync(ur => ur.UserId == userId && ur.RoleId == roleId);
            if (userRoleExists)
            {
                return;
            }

            _context.UserRoles.Add(new SystemUserRole
            {
                UserId = userId,
                RoleId = roleId,
                CreatedAt = DateTime.Now
            });
            await _context.SaveChangesAsync();
        }

        /// <summary>
        /// 根据注册记录反查对应根组织，优先从管理员账号当前所属组织定位，回退到组织名称匹配。
        /// </summary>
        private async Task<SystemDept?> FindOrgRootDeptAsync(SysOrgRegistration registration)
        {
            var adminUser = await _context.Users.FirstOrDefaultAsync(u => u.Username == registration.AdminUsername);
            if (adminUser != null)
            {
                var deptId = adminUser.CurrentOrgId ?? adminUser.DeptId;
                if (deptId.HasValue)
                {
                    var dept = await _context.Depts.FindAsync(deptId.Value);
                    while (dept?.ParentId != null)
                    {
                        dept = await _context.Depts.FindAsync(dept.ParentId.Value);
                    }

                    if (dept != null)
                    {
                        return dept;
                    }
                }
            }

            return await _context.Depts
                .Where(d => d.ParentId == null && d.Name == registration.OrgName)
                .OrderByDescending(d => d.Id)
                .FirstOrDefaultAsync();
        }

        public class RejectRequest
        {
            public string Reason { get; set; } = string.Empty;
        }
    }
}
