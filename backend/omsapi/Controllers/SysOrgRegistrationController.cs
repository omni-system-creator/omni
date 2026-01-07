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

                // 2. Create Admin User
                var user = new SystemUser
                {
                    Username = registration.AdminUsername,
                    Password = registration.AdminPassword, // Already hashed
                    Nickname = registration.ContactName,
                    Phone = registration.ContactPhone,
                    Email = registration.ContactEmail,
                    DeptId = dept.Id,
                    IsActive = true,
                    CreatedAt = DateTime.Now,
                    Status = "active"
                };
                _context.Users.Add(user);
                await _context.SaveChangesAsync();

                // 3. Update Registration Status
                registration.Status = "approved";
                registration.UpdatedAt = DateTime.Now;
                await _context.SaveChangesAsync();

                await transaction.CommitAsync();

                return Ok("审核通过");
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                return StatusCode(500, $"审核失败: {ex.Message}");
            }
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

        public class RejectRequest
        {
            public string Reason { get; set; } = string.Empty;
        }
    }
}
