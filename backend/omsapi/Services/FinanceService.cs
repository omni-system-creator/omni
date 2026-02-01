using Microsoft.EntityFrameworkCore;
using omsapi.Data;
using omsapi.Models.Dtos;
using omsapi.Models.Entities.Finance;
using omsapi.Infrastructure.Attributes;
using omsapi.Models.Enums;
using Microsoft.AspNetCore.Hosting;

namespace omsapi.Services
{
    [AutoInject(ServiceLifetime.Scoped)]
    public class FinanceService
    {
        private readonly OmsContext _context;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly IWebHostEnvironment _environment;

        public FinanceService(OmsContext context, IHttpContextAccessor httpContextAccessor, IWebHostEnvironment environment)
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
        
        // --- Subjects ---

        public async Task<List<FinanceSubjectDto>> GetSubjectsAsync(string? direction = null)
        {
            var orgId = await GetCurrentOrgIdAsync();
            var query = _context.FinanceSubjects.AsQueryable();
            
            // Filter by OrgId (Current Org OR Global System Subjects)
            if (orgId.HasValue)
            {
                query = query.Where(s => s.OrgId == orgId || (s.OrgId == null && s.IsSystem));
            }
            else
            {
                // If no org context (e.g. SuperAdmin global view?), maybe return all or just global?
                // For safety, return global only if not logged in (though Authorize should catch this)
                query = query.Where(s => s.OrgId == null);
            }

            if (!string.IsNullOrEmpty(direction))
            {
                query = query.Where(s => s.Direction == direction);
            }
            else
            {
                // Default order or something?
            }

            var list = await query.OrderBy(s => s.Code).ToListAsync();
            return list.Select(s => new FinanceSubjectDto
            {
                Id = s.Id,
                Code = s.Code,
                Name = s.Name,
                ParentId = s.ParentId,
                Direction = s.Direction,
                Description = s.Description,
                IsSystem = s.IsSystem,
                IsActive = s.IsActive,
                CreatedAt = s.CreatedAt
            }).ToList();
        }

        public async Task<(bool Success, string Message)> CreateSubjectAsync(CreateFinanceSubjectDto dto)
        {
            var orgId = await GetCurrentOrgIdAsync();

            if (await _context.FinanceSubjects.AnyAsync(s => s.Code == dto.Code && s.OrgId == orgId))
            {
                return (false, "科目编码已存在");
            }

            if (dto.ParentId.HasValue)
            {
                var parent = await _context.FinanceSubjects.FindAsync(dto.ParentId.Value);
                if (parent == null) return (false, "父级科目不存在");
                if (parent.OrgId != null && parent.OrgId != orgId) return (false, "无法选择其他组织的科目作为父级");
            }

            var subject = new FinanceSubject
            {
                Code = dto.Code,
                Name = dto.Name,
                ParentId = dto.ParentId,
                Direction = dto.Direction,
                Description = dto.Description,
                IsSystem = false,
                IsActive = true,
                OrgId = orgId,
                CreatedAt = DateTime.Now
            };

            _context.FinanceSubjects.Add(subject);
            await _context.SaveChangesAsync();
            return (true, "创建成功");
        }

        public async Task<(bool Success, string Message)> UpdateSubjectAsync(long id, UpdateFinanceSubjectDto dto)
        {
            var orgId = await GetCurrentOrgIdAsync();
            
            var subject = await _context.FinanceSubjects.FindAsync(id);
            if (subject == null) return (false, "科目不存在");
            
            // Check permissions: Can only update own org subjects
            if (subject.OrgId != orgId)
            {
                // Or if it's a system subject? Assuming system subjects cannot be edited by normal users.
                // If orgId is null (superadmin), they can edit system subjects (OrgId=null).
                // If orgId is set, they can only edit their own.
                // Simple logic: must match.
                return (false, "无权修改此科目");
            }

            if (dto.ParentId.HasValue && dto.ParentId != subject.ParentId)
            {
                // Check recursion
                if (dto.ParentId == id) return (false, "不能选择自己作为父级");
                // Check circular dependency if needed, but simple check is ok for now
                
                var parent = await _context.FinanceSubjects.FindAsync(dto.ParentId.Value);
                if (parent == null) return (false, "父级科目不存在");
            }

            subject.Name = dto.Name;
            subject.ParentId = dto.ParentId;
            subject.Direction = dto.Direction;
            subject.Description = dto.Description;
            subject.IsActive = dto.IsActive;
            subject.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();
            return (true, "更新成功");
        }

        public async Task<(bool Success, string Message)> DeleteSubjectAsync(long id)
        {
            var orgId = await GetCurrentOrgIdAsync();
            var subject = await _context.FinanceSubjects.FindAsync(id);
            if (subject == null) return (false, "科目不存在");
            
            if (subject.OrgId != orgId) return (false, "无权删除此科目");
            if (subject.IsSystem) return (false, "系统科目无法删除");

            // Check usage
            if (await _context.FinanceApArs.AnyAsync(x => x.SubjectId == id))
            {
                return (false, "该科目已被使用，无法删除");
            }

            if (await _context.FinanceSubjects.AnyAsync(x => x.ParentId == id))
            {
                return (false, "该科目包含子科目，无法删除");
            }

            _context.FinanceSubjects.Remove(subject);
            await _context.SaveChangesAsync();
            return (true, "删除成功");
        }

        // --- AP/AR ---

        public async Task<List<FinanceApArDto>> GetApArListAsync(string type, string? status = null, string? partner = null)
        {
            var orgId = await GetCurrentOrgIdAsync();
            var query = _context.FinanceApArs
                .Include(x => x.Subject)
                .Where(x => x.Type == type);

            if (orgId.HasValue)
            {
                query = query.Where(x => x.OrgId == orgId);
            }
            else
            {
                return new List<FinanceApArDto>();
            }

            if (!string.IsNullOrEmpty(status))
            {
                if (int.TryParse(status, out int statusVal))
                {
                    // Assuming statusVal corresponds to FinanceBillStatus enum int value
                    query = query.Where(x => (int)x.Status == statusVal);
                }
            }

            if (!string.IsNullOrEmpty(partner))
            {
                query = query.Where(x => x.PartnerName != null && x.PartnerName.Contains(partner));
            }

            var list = await query.OrderByDescending(x => x.DueDate).ToListAsync();
            var ids = list.Select(x => x.Id).ToList();

            // Fetch attachments
            var attachments = await _context.FinanceAttachments
                .Where(x => x.TargetType == "ApAr" && ids.Contains(x.TargetId))
                .ToListAsync();

            return list.Select(x => new FinanceApArDto
            {
                Id = x.Id,
                BillNo = x.BillNo,
                Type = x.Type,
                SubjectId = x.SubjectId,
                SubjectName = x.Subject?.Name,
                Amount = x.Amount,
                DueDate = x.DueDate,
                PartnerName = x.PartnerName ?? string.Empty,
                PartnerId = x.PartnerId,
                Status = (int)x.Status,
                SourceType = x.SourceType,
                SourceId = x.SourceId,
                Description = x.Description,
                CreatedAt = x.CreatedAt,
                CreatedBy = x.CreatedBy,
                OverdueDays = x.Status == FinanceBillStatus.Paid || x.Status == FinanceBillStatus.Cancelled ? 0 : (x.DueDate.HasValue && x.DueDate.Value < DateTime.Now ? (DateTime.Now - x.DueDate.Value).Days : 0),
                Attachments = attachments.Where(a => a.TargetId == x.Id).Select(a => new FinanceAttachmentDto
                {
                    Id = a.Id,
                    TargetType = a.TargetType,
                    TargetId = a.TargetId,
                    FileName = a.FileName,
                    FilePath = a.FilePath,
                    Size = a.Size,
                    ContentType = a.ContentType,
                    UploadDate = a.UploadDate,
                    Uploader = a.Uploader
                }).ToList()
            }).ToList();
        }

        public async Task<(bool Success, string Message, long Id)> CreateApArAsync(CreateFinanceApArDto dto, List<IFormFile>? attachments = null)
        {
            var orgId = await GetCurrentOrgIdAsync();
            if (!orgId.HasValue) return (false, "无法获取当前组织信息", 0);

            var userId = GetCurrentUserId();
            var userName = _httpContextAccessor.HttpContext?.User?.Identity?.Name;

            var strategy = _context.Database.CreateExecutionStrategy();
            return await strategy.ExecuteAsync(async () =>
            {
                using var transaction = await _context.Database.BeginTransactionAsync();
                try
                {
                    var entity = new FinanceApAr
                    {
                        BillNo = GenerateBillNo(dto.Type),
                        Type = dto.Type,
                        SubjectId = dto.SubjectId,
                        Amount = dto.Amount,
                        DueDate = dto.DueDate,
                        PartnerName = dto.PartnerName,
                        PartnerId = dto.PartnerId,
                        Status = FinanceBillStatus.Pending, // Pending
                        SourceType = "Manual",
                        Description = dto.Description,
                        OrgId = orgId,
                        CreatedBy = userName,
                        CreatedAt = DateTime.Now
                    };

                    _context.FinanceApArs.Add(entity);
                    await _context.SaveChangesAsync();

                    // Handle Attachments
                    if (attachments != null && attachments.Any())
                    {
                        foreach (var file in attachments)
                        {
                            var uploadResult = await UploadAttachmentInternalAsync(file, FinanceTargetType.ApAr, entity.Id, orgId.Value, userName);
                            if (!uploadResult.Success)
                            {
                                throw new Exception($"附件上传失败: {uploadResult.Message}");
                            }
                        }
                    }

                    await transaction.CommitAsync();
                    return (true, "创建成功", entity.Id);
                }
                catch (Exception ex)
                {
                    await transaction.RollbackAsync();
                    // Log exception
                    return (false, $"创建失败: {ex.Message}", 0L);
                }
            });
        }

        public async Task<FinanceStatsDto> GetStatsAsync()
        {
            var orgId = await GetCurrentOrgIdAsync();
            if (!orgId.HasValue) return new FinanceStatsDto();

            var query = _context.FinanceApArs
                .Where(x => x.OrgId == orgId.Value && x.Status != FinanceBillStatus.Cancelled);

            var list = await query.Select(x => new { x.Type, x.Status, x.Amount, x.DueDate }).ToListAsync();

            return new FinanceStatsDto
            {
                TotalReceivables = list.Where(x => x.Type == FinanceBillType.AR && x.Status != FinanceBillStatus.Paid).Sum(x => x.Amount),
                TotalPayables = list.Where(x => x.Type == FinanceBillType.AP && x.Status != FinanceBillStatus.Paid).Sum(x => x.Amount),
                OverdueReceivables = list.Where(x => x.Type == FinanceBillType.AR && x.Status != FinanceBillStatus.Paid && x.DueDate.HasValue && x.DueDate.Value < DateTime.Now).Sum(x => x.Amount),
                OverduePayables = list.Where(x => x.Type == FinanceBillType.AP && x.Status != FinanceBillStatus.Paid && x.DueDate.HasValue && x.DueDate.Value < DateTime.Now).Sum(x => x.Amount)
            };
        }

        // Internal method for uploading without redundant checks (reused by public method)
        private async Task<(bool Success, string Message, FinanceAttachmentDto? Data)> UploadAttachmentInternalAsync(IFormFile file, string targetType, long targetId, long orgId, string? uploader)
        {
             if (file == null || file.Length == 0)
                return (false, "文件为空", null);

            var uploadPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "finance");
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

        public async Task<(bool Success, string Message)> UpdateApArAsync(long id, UpdateFinanceApArDto dto, List<IFormFile>? attachments = null)
        {
            var orgId = await GetCurrentOrgIdAsync();
            if (!orgId.HasValue) return (false, "无法获取当前组织信息");

            var userId = GetCurrentUserId();
            var userName = _httpContextAccessor.HttpContext?.User?.Identity?.Name;

            var entity = await _context.FinanceApArs.FindAsync(id);
            if (entity == null) return (false, "记录不存在");
            if (entity.OrgId != orgId) return (false, "无权操作其他组织的数据");

            if (dto.SubjectId.HasValue) entity.SubjectId = dto.SubjectId;
            if (dto.Amount.HasValue) entity.Amount = dto.Amount.Value;
            if (dto.DueDate.HasValue) entity.DueDate = dto.DueDate.Value;
            if (dto.PartnerName != null) entity.PartnerName = dto.PartnerName;
            if (dto.PartnerId != null) entity.PartnerId = dto.PartnerId;
            if (dto.Status.HasValue) entity.Status = (FinanceBillStatus)dto.Status.Value;
            if (dto.Description != null) entity.Description = dto.Description;

            entity.UpdatedAt = DateTime.Now;
            
            // Handle Attachments
            if (attachments != null && attachments.Any())
            {
                foreach (var file in attachments)
                {
                    var uploadResult = await UploadAttachmentInternalAsync(file, FinanceTargetType.ApAr, entity.Id, orgId.Value, userName);
                    if (!uploadResult.Success)
                    {
                        // Note: If upload fails, we might want to return error or just log it. 
                        // For now, let's treat it as non-fatal but maybe return a warning? 
                        // Or simple: fail the whole update? 
                        // To be consistent with Create, let's throw or return failure.
                        // But we already updated entity fields in memory (not saved yet).
                        // Let's return failure.
                        return (false, $"附件上传失败: {uploadResult.Message}");
                    }
                }
            }

            await _context.SaveChangesAsync();
            return (true, "更新成功");
        }

        public async Task<(bool Success, string Message)> DeleteApArAsync(long id)
        {
            var orgId = await GetCurrentOrgIdAsync();
            if (!orgId.HasValue) return (false, "无法获取当前组织信息");

            var entity = await _context.FinanceApArs.FindAsync(id);
            if (entity == null) return (false, "记录不存在");
            if (entity.OrgId != orgId) return (false, "无权操作其他组织的数据");

            if (entity.SourceType == "Contract")
            {
                return (false, "无法删除合同关联的账款记录，请在合同模块操作");
            }

            _context.FinanceApArs.Remove(entity);
            await _context.SaveChangesAsync();
            return (true, "删除成功");
        }

        private string GenerateBillNo(string type)
        {
            // Simple generation: TYPE + yyyyMMdd + Random
            return $"{type}{DateTime.Now:yyyyMMdd}{new Random().Next(1000, 9999)}";
        }

        // --- Attachments ---

        public async Task<(bool Success, string Message, FinanceAttachmentDto? Data)> UploadAttachmentAsync(IFormFile file, string targetType, long targetId)
        {
            var orgId = await GetCurrentOrgIdAsync();
            if (!orgId.HasValue) return (false, "无法获取当前组织信息", null);

            if (file == null || file.Length == 0)
                return (false, "文件为空", null);

            // Verify Target Existence and Permission
            if (targetType == FinanceTargetType.ApAr)
            {
                var target = await _context.FinanceApArs.FindAsync(targetId);
                if (target == null) return (false, "目标记录不存在", null);
                if (target.OrgId != orgId) return (false, "无权操作其他组织的数据", null);
            }
            // Add other types here as needed

            // Save file
            var uploadPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "finance");
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
                Uploader = _httpContextAccessor.HttpContext?.User?.Identity?.Name
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
            if (attachment == null) return (false, "文件不存在");

            // Verify Ownership via Target
            if (attachment.TargetType == "ApAr")
            {
                var target = await _context.FinanceApArs.FindAsync(attachment.TargetId);
                // If target is missing, maybe allow delete to clean up? Or deny?
                // Safe default: deny if exists and not match. If target missing, assume orphan and maybe allow?
                // Let's be strict: if target exists, check org.
                if (target != null && target.OrgId != orgId) return (false, "无权操作其他组织的数据");
            }

            // Delete physical file
            if (!string.IsNullOrEmpty(attachment.FilePath))
            {
                var fullPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", attachment.FilePath.TrimStart('/'));
                if (File.Exists(fullPath))
                {
                    File.Delete(fullPath);
                }
            }

            _context.FinanceAttachments.Remove(attachment);
            await _context.SaveChangesAsync();
            return (true, "删除成功");
        }

        public async Task<(bool Success, string Message, FinanceAttachment? FileInfo, Stream? Stream)> GetAttachmentStreamAsync(long id)
        {
            var attachment = await _context.FinanceAttachments.FindAsync(id);
            if (attachment == null) return (false, "文件不存在", null, null);

            var path = attachment.FilePath;
            if (string.IsNullOrEmpty(path)) return (false, "文件路径为空", null, null);

            var webRoot = _environment.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
            // path is like "/uploads/finance/..."
            var relativePath = path.TrimStart('/', '\\');
            var physicalPath = Path.Combine(webRoot, relativePath);
            
            if (!System.IO.File.Exists(physicalPath))
            {
                 return (false, "文件未找到", null, null);
            }

            var stream = new FileStream(physicalPath, FileMode.Open, FileAccess.Read);
            return (true, "", attachment, stream);
        }

        private string FormatSize(long bytes)
        {
            string[] sizes = { "B", "KB", "MB", "GB", "TB" };
            int order = 0;
            double len = bytes;
            while (len >= 1024 && order < sizes.Length - 1)
            {
                order++;
                len = len / 1024;
            }
            return $"{len:0.##} {sizes[order]}";
        }
    }
}
