using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using omsapi.Data;
using omsapi.Infrastructure.Attributes;
using omsapi.Models.Dtos;
using omsapi.Models.Entities.Finance;
using omsapi.Models.Enums;
using System.Security.Claims;

using omsapi.Services.Interfaces;

namespace omsapi.Services
{
    [AutoInject(ServiceLifetime.Scoped)]
    public class FinanceApArService : IFinanceApArService
    {
        private readonly OmsContext _context;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly IFinanceAttachmentService _attachmentService;

        public FinanceApArService(OmsContext context, IHttpContextAccessor httpContextAccessor, IFinanceAttachmentService attachmentService)
        {
            _context = context;
            _httpContextAccessor = httpContextAccessor;
            _attachmentService = attachmentService;
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
                        Status = FinanceBillStatus.Pending,
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
                            var uploadResult = await _attachmentService.UploadInternalAsync(file, FinanceTargetType.ApAr, entity.Id, orgId.Value, userName);
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
                    var uploadResult = await _attachmentService.UploadInternalAsync(file, FinanceTargetType.ApAr, entity.Id, orgId.Value, userName);
                    if (!uploadResult.Success)
                    {
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
            return $"{type}{DateTime.Now:yyyyMMdd}{new Random().Next(1000, 9999)}";
        }
    }
}
