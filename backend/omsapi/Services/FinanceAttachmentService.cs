using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using omsapi.Data;
using omsapi.Infrastructure.Attributes;
using omsapi.Models.Dtos;
using omsapi.Models.Entities.Finance;
using System.Security.Claims;

using omsapi.Services.Interfaces;

namespace omsapi.Services
{
    [AutoInject(ServiceLifetime.Scoped)]
    public class FinanceAttachmentService : IFinanceAttachmentService
    {
        private readonly OmsContext _context;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly IWebHostEnvironment _environment;

        public FinanceAttachmentService(OmsContext context, IHttpContextAccessor httpContextAccessor, IWebHostEnvironment environment)
        {
            _context = context;
            _httpContextAccessor = httpContextAccessor;
            _environment = environment;
        }

        private long? GetCurrentUserId()
        {
            var userIdStr = _httpContextAccessor.HttpContext?.User?.FindFirst("id")?.Value;
            if (long.TryParse(userIdStr, out var userId))
            {
                return userId;
            }
            return null;
        }

        private async Task<long?> GetCurrentOrgIdAsync()
        {
            var userId = GetCurrentUserId();
            if (userId.HasValue)
            {
                var user = await _context.Users.FindAsync(userId.Value);
                return user?.CurrentOrgId;
            }
            return null;
        }

        private string FormatSize(long bytes)
        {
            string[] suffixes = { "B", "KB", "MB", "GB", "TB" };
            int counter = 0;
            decimal number = (decimal)bytes;
            while (Math.Round(number / 1024) >= 1)
            {
                number = number / 1024;
                counter++;
            }
            return string.Format("{0:n1}{1}", number, suffixes[counter]);
        }

        public async Task<(bool Success, string Message, FinanceAttachmentDto? Data)> UploadAttachmentAsync(IFormFile file, string targetType, long targetId)
        {
            var orgId = await GetCurrentOrgIdAsync();
            if (!orgId.HasValue) return (false, "无法获取当前组织信息", null);

            var userName = _httpContextAccessor.HttpContext?.User?.Identity?.Name;

            // Verify Target Permission (Generic check based on OrgId if possible, or skip strict check here relying on Service layer to call this responsibly)
            // However, since this is a public API method too, we should verify target ownership if possible.
            // But doing it generically is hard without reflection or switch case.
            // For now, let's assume the caller (Service or Controller) has checked basic permissions, 
            // OR we check known types.
            
            bool hasPermission = true;
            if (targetType == "ApAr")
            {
                var target = await _context.FinanceApArs.FindAsync(targetId);
                if (target == null || target.OrgId != orgId) hasPermission = false;
            }
            else if (targetType == "Invoice")
            {
                var target = await _context.FinanceInvoices.FindAsync(targetId);
                if (target == null || target.OrgId != orgId) hasPermission = false;
            }
            
            if (!hasPermission) return (false, "目标记录不存在或无权操作", null);

            return await UploadInternalAsync(file, targetType, targetId, orgId.Value, userName);
        }

        // Internal method to be used by other services (e.g. during creation transaction)
        public async Task<(bool Success, string Message, FinanceAttachmentDto? Data)> UploadInternalAsync(IFormFile file, string targetType, long targetId, long orgId, string? uploader)
        {
            if (file == null || file.Length == 0)
                return (false, "文件为空", null);

            var webRoot = _environment.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
            var uploadPath = Path.Combine(webRoot, "uploads", "finance");
            if (!Directory.Exists(uploadPath)) Directory.CreateDirectory(uploadPath);

            var fileName = $"{Guid.NewGuid()}{Path.GetExtension(file.FileName)}";
            var filePath = Path.Combine(uploadPath, fileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            var attachment = new FinanceAttachment
            {
                TargetType = targetType,
                TargetId = targetId,
                FileName = file.FileName,
                FilePath = $"/uploads/finance/{fileName}",
                Size = FormatSize(file.Length),
                ContentType = file.ContentType,
                UploadDate = DateTime.Now,
                Uploader = uploader
            };

            _context.FinanceAttachments.Add(attachment);
            await _context.SaveChangesAsync();

            return (true, "上传成功", new FinanceAttachmentDto
            {
                Id = attachment.Id,
                TargetType = attachment.TargetType,
                TargetId = attachment.TargetId,
                FileName = attachment.FileName,
                FilePath = attachment.FilePath,
                Size = attachment.Size,
                ContentType = attachment.ContentType,
                UploadDate = attachment.UploadDate,
                Uploader = attachment.Uploader
            });
        }

        public async Task<(bool Success, string Message)> DeleteAttachmentAsync(long id)
        {
            var orgId = await GetCurrentOrgIdAsync();
            if (!orgId.HasValue) return (false, "无法获取当前组织信息");

            var attachment = await _context.FinanceAttachments.FindAsync(id);
            if (attachment == null) return (false, "附件不存在");

            // We need to verify if the user owns the target object of this attachment.
            // Since we don't store OrgId on Attachment directly (it relies on Target), we must check Target.
            // For now, let's check based on TargetType.
            
            bool hasPermission = false;
            if (attachment.TargetType == "ApAr")
            {
                var target = await _context.FinanceApArs.FindAsync(attachment.TargetId);
                if (target != null && target.OrgId == orgId) hasPermission = true;
            }
            else if (attachment.TargetType == "Invoice")
            {
                var target = await _context.FinanceInvoices.FindAsync(attachment.TargetId);
                if (target != null && target.OrgId == orgId) hasPermission = true;
            }

            if (!hasPermission) return (false, "无权删除此附件");

            // Delete file from disk
            try
            {
                if (string.IsNullOrEmpty(attachment.FilePath)) return (false, "文件路径为空");

                var webRoot = _environment.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
                var relativePath = attachment.FilePath.TrimStart('/').Replace("/", Path.DirectorySeparatorChar.ToString());
                var fullPath = Path.Combine(webRoot, relativePath);
                
                if (File.Exists(fullPath))
                {
                    File.Delete(fullPath);
                }
            }
            catch (Exception)
            {
                // Log warning but continue to delete record
            }

            _context.FinanceAttachments.Remove(attachment);
            await _context.SaveChangesAsync();
            return (true, "删除成功");
        }

        public async Task<(bool Success, string Message)> DeleteAttachmentsByTargetAsync(string targetType, long targetId)
        {
            var attachments = await _context.FinanceAttachments
                .Where(x => x.TargetType == targetType && x.TargetId == targetId)
                .ToListAsync();

            if (!attachments.Any()) return (true, "无附件需删除");

            var webRoot = _environment.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");

            foreach (var attachment in attachments)
            {
                try
                {
                    if (!string.IsNullOrEmpty(attachment.FilePath))
                    {
                        var relativePath = attachment.FilePath.TrimStart('/').Replace("/", Path.DirectorySeparatorChar.ToString());
                        var fullPath = Path.Combine(webRoot, relativePath);
                        if (File.Exists(fullPath))
                        {
                            File.Delete(fullPath);
                        }
                    }
                }
                catch
                {
                    // Log error but continue
                    // _logger.LogError(ex, "删除文件失败"); 
                }
            }

            _context.FinanceAttachments.RemoveRange(attachments);
            await _context.SaveChangesAsync();
            
            return (true, "批量删除成功");
        }

        public async Task<(bool Success, string Message, FinanceAttachmentDto? FileInfo, Stream? Stream)> GetAttachmentStreamAsync(long id)
        {
             var orgId = await GetCurrentOrgIdAsync();
            // Allow download if logged in? Or check permissions?
            // Usually check permissions.

            var attachment = await _context.FinanceAttachments.FindAsync(id);
            if (attachment == null) return (false, "附件不存在", null, null);

             bool hasPermission = false;
            if (attachment.TargetType == "ApAr")
            {
                var target = await _context.FinanceApArs.FindAsync(attachment.TargetId);
                if (target != null && target.OrgId == orgId) hasPermission = true;
            }
            else if (attachment.TargetType == "Invoice")
            {
                var target = await _context.FinanceInvoices.FindAsync(attachment.TargetId);
                if (target != null && target.OrgId == orgId) hasPermission = true;
            }
            
            if (!hasPermission) return (false, "无权下载此附件", null, null);

            if (string.IsNullOrEmpty(attachment.FilePath)) return (false, "文件路径为空", null, null);

            var webRoot = _environment.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
            var relativePath = attachment.FilePath.TrimStart('/').Replace("/", Path.DirectorySeparatorChar.ToString());
            var fullPath = Path.Combine(webRoot, relativePath);

            if (!File.Exists(fullPath)) return (false, "文件物理路径不存在", null, null);

            var stream = new FileStream(fullPath, FileMode.Open, FileAccess.Read);
            var dto = new FinanceAttachmentDto
            {
                Id = attachment.Id,
                FileName = attachment.FileName,
                ContentType = attachment.ContentType
            };

            return (true, "获取成功", dto, stream);
        }
    }
}
