using Microsoft.EntityFrameworkCore;
using omsapi.Data;
using omsapi.Models.Dtos;
using omsapi.Models.Entities.Finance;
using omsapi.Infrastructure.Attributes;
using omsapi.Services.Interfaces;
using UglyToad.PdfPig;
using System.Text;
using System.Text.Json;

namespace omsapi.Services
{
    [AutoInject(ServiceLifetime.Scoped)]
    public class FinanceInvoiceService : IFinanceInvoiceService
    {
        private readonly OmsContext _context;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly IWebHostEnvironment _environment;
        private readonly IAiService _aiService;
        private readonly ILogger<FinanceInvoiceService> _logger;
        private readonly IFinanceAttachmentService _attachmentService;

        public FinanceInvoiceService(OmsContext context, IHttpContextAccessor httpContextAccessor, IWebHostEnvironment environment, IAiService aiService, ILogger<FinanceInvoiceService> logger, IFinanceAttachmentService attachmentService)
        {
            _context = context;
            _httpContextAccessor = httpContextAccessor;
            _environment = environment;
            _aiService = aiService;
            _logger = logger;
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

        public async Task<List<FinanceInvoiceDto>> GetInvoicesAsync(string? direction = null, string? type = null, string? status = null, string? keyword = null)
        {
            var orgId = await GetCurrentOrgIdAsync();
            var query = _context.FinanceInvoices.AsQueryable();

            if (orgId.HasValue)
            {
                query = query.Where(x => x.OrgId == orgId);
            }

            if (!string.IsNullOrEmpty(direction))
            {
                query = query.Where(x => x.Direction == direction);
            }

            if (!string.IsNullOrEmpty(type))
            {
                query = query.Where(x => x.Type == type);
            }

            if (!string.IsNullOrEmpty(status))
            {
                query = query.Where(x => x.Status == status);
            }

            if (!string.IsNullOrEmpty(keyword))
            {
                query = query.Where(x => x.InvoiceNo.Contains(keyword) || x.PurchaserName.Contains(keyword) || x.SellerName.Contains(keyword));
            }

            var list = await query.OrderByDescending(x => x.InvoiceDate).ToListAsync();
            var ids = list.Select(x => x.Id).ToList();

            var attachments = await _context.FinanceAttachments
                .Where(x => x.TargetType == "Invoice" && ids.Contains(x.TargetId))
                .ToListAsync();

            return list.Select(x => new FinanceInvoiceDto
            {
                Id = x.Id,
                InvoiceNo = x.InvoiceNo,
                InvoiceCode = x.InvoiceCode,
                PurchaserName = x.PurchaserName,
                PurchaserTaxId = x.PurchaserTaxId,
                SellerName = x.SellerName,
                SellerTaxId = x.SellerTaxId,
                Direction = x.Direction,
                Type = x.Type,
                Amount = x.Amount,
                TaxAmount = x.TaxAmount,
                TotalAmount = x.TotalAmount,
                InvoiceDate = x.InvoiceDate,
                Status = x.Status,
                Remark = x.Remark,
                CreatedAt = x.CreatedAt,
                CreatedBy = x.CreatedBy,
                ContractId = x.ContractId,
                ApArId = x.ApArId,
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

        public async Task<FinanceInvoiceDto?> GetInvoiceByIdAsync(long id)
        {
            var orgId = await GetCurrentOrgIdAsync();
            var entity = await _context.FinanceInvoices.FindAsync(id);
            
            if (entity == null) return null;
            if (orgId.HasValue && entity.OrgId != orgId) return null;

            var attachments = await _context.FinanceAttachments
                .Where(x => x.TargetType == "Invoice" && x.TargetId == id)
                .ToListAsync();

            return new FinanceInvoiceDto
            {
                Id = entity.Id,
                InvoiceNo = entity.InvoiceNo,
                InvoiceCode = entity.InvoiceCode,
                PurchaserName = entity.PurchaserName,
                PurchaserTaxId = entity.PurchaserTaxId,
                SellerName = entity.SellerName,
                SellerTaxId = entity.SellerTaxId,
                Direction = entity.Direction,
                Type = entity.Type,
                Amount = entity.Amount,
                TaxAmount = entity.TaxAmount,
                TotalAmount = entity.TotalAmount,
                InvoiceDate = entity.InvoiceDate,
                Status = entity.Status,
                Remark = entity.Remark,
                CreatedAt = entity.CreatedAt,
                CreatedBy = entity.CreatedBy,
                ContractId = entity.ContractId,
                ApArId = entity.ApArId,
                Attachments = attachments.Select(a => new FinanceAttachmentDto
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
            };
        }

        public async Task<(bool Success, string Message, long Id)> CreateInvoiceAsync(CreateFinanceInvoiceDto dto, List<IFormFile>? attachments = null)
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
                    var entity = new FinanceInvoice
                    {
                        InvoiceNo = dto.InvoiceNo,
                        InvoiceCode = dto.InvoiceCode,
                        PurchaserName = dto.PurchaserName,
                        PurchaserTaxId = dto.PurchaserTaxId,
                        SellerName = dto.SellerName,
                        SellerTaxId = dto.SellerTaxId,
                        Direction = dto.Direction,
                        Type = dto.Type,
                        Amount = dto.Amount,
                        TaxAmount = dto.TaxAmount,
                        TotalAmount = dto.TotalAmount,
                        InvoiceDate = dto.InvoiceDate,
                        Status = "draft",
                        Remark = dto.Remark,
                        OrgId = orgId,
                        CreatedBy = userName,
                        CreatedAt = DateTime.Now,
                        ContractId = dto.ContractId,
                        ApArId = dto.ApArId
                    };

                    _context.FinanceInvoices.Add(entity);
                    await _context.SaveChangesAsync();

                    if (attachments != null && attachments.Any())
                    {
                        foreach (var file in attachments)
                        {
                            var uploadResult = await _attachmentService.UploadInternalAsync(file, "Invoice", entity.Id, orgId.Value, userName);
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
                    _logger.LogError(ex, "创建发票失败");
                    return (false, $"创建失败: {ex.Message}", 0L);
                }
            });
        }

        public async Task<(bool Success, string Message)> UpdateInvoiceAsync(long id, UpdateFinanceInvoiceDto dto, List<IFormFile>? attachments = null)
        {
            var orgId = await GetCurrentOrgIdAsync();
            if (!orgId.HasValue) return (false, "无法获取当前组织信息");

            var userName = _httpContextAccessor.HttpContext?.User?.Identity?.Name;
            var entity = await _context.FinanceInvoices.FindAsync(id);

            if (entity == null) return (false, "发票不存在");
            if (entity.OrgId != orgId) return (false, "无权操作其他组织的数据");

            var strategy = _context.Database.CreateExecutionStrategy();
            return await strategy.ExecuteAsync(async () =>
            {
                using var transaction = await _context.Database.BeginTransactionAsync();
                try
                {
                    if (dto.InvoiceNo != null) entity.InvoiceNo = dto.InvoiceNo;
                    if (dto.InvoiceCode != null) entity.InvoiceCode = dto.InvoiceCode;
                    if (dto.PurchaserName != null) entity.PurchaserName = dto.PurchaserName;
                    if (dto.PurchaserTaxId != null) entity.PurchaserTaxId = dto.PurchaserTaxId;
                    if (dto.SellerName != null) entity.SellerName = dto.SellerName;
                    if (dto.SellerTaxId != null) entity.SellerTaxId = dto.SellerTaxId;
                    if (dto.Direction != null) entity.Direction = dto.Direction;
                    if (dto.Type != null) entity.Type = dto.Type;
                    if (dto.Amount.HasValue) entity.Amount = dto.Amount.Value;
                    if (dto.TaxAmount.HasValue) entity.TaxAmount = dto.TaxAmount.Value;
                    if (dto.TotalAmount.HasValue) entity.TotalAmount = dto.TotalAmount.Value;
                    if (dto.InvoiceDate.HasValue) entity.InvoiceDate = dto.InvoiceDate.Value;
                    if (dto.Status != null) entity.Status = dto.Status;
                    if (dto.Remark != null) entity.Remark = dto.Remark;
                    if (dto.ContractId.HasValue) entity.ContractId = dto.ContractId;
                    if (dto.ApArId.HasValue) entity.ApArId = dto.ApArId;

                    entity.UpdatedAt = DateTime.Now;

                    _context.FinanceInvoices.Update(entity);
                    await _context.SaveChangesAsync();

                    if (attachments != null && attachments.Any())
                    {
                        foreach (var file in attachments)
                        {
                            var uploadResult = await _attachmentService.UploadInternalAsync(file, "Invoice", entity.Id, orgId.Value, userName);
                            if (!uploadResult.Success)
                            {
                                throw new Exception($"附件上传失败: {uploadResult.Message}");
                            }
                        }
                    }

                    await transaction.CommitAsync();
                    return (true, "更新成功");
                }
                catch (Exception ex)
                {
                    await transaction.RollbackAsync();
                    _logger.LogError(ex, "更新发票失败");
                    return (false, $"更新失败: {ex.Message}");
                }
            });
        }

        public async Task<(bool Success, string Message)> DeleteInvoiceAsync(long id)
        {
            var orgId = await GetCurrentOrgIdAsync();
            var entity = await _context.FinanceInvoices.FindAsync(id);
            
            if (entity == null) return (false, "发票不存在");
            if (orgId.HasValue && entity.OrgId != orgId) return (false, "无权操作其他组织的数据");

            var strategy = _context.Database.CreateExecutionStrategy();
            return await strategy.ExecuteAsync(async () =>
            {
                using var transaction = await _context.Database.BeginTransactionAsync();
                try
                {
                    // Delete attachments first
                    await _attachmentService.DeleteAttachmentsByTargetAsync("Invoice", id);

                    _context.FinanceInvoices.Remove(entity);
                    await _context.SaveChangesAsync();
                    
                    await transaction.CommitAsync();
                    return (true, "删除成功");
                }
                catch (Exception ex)
                {
                    await transaction.RollbackAsync();
                    _logger.LogError(ex, "删除发票失败");
                    return (false, $"删除失败: {ex.Message}");
                }
            });
        }

        public async Task<(bool Success, string Message, FinanceInvoiceDto? Data)> RecognizeInvoiceAsync(IFormFile file)
        {
            try
            {
                if (file == null || file.Length == 0) return (false, "文件为空", null);

                var ext = Path.GetExtension(file.FileName).ToLower();
                string content = string.Empty;

                if (ext == ".pdf")
                {
                    using var stream = file.OpenReadStream();
                    using var document = PdfDocument.Open(stream);
                    var sb = new StringBuilder();
                    foreach (var page in document.GetPages())
                    {
                        sb.AppendLine(page.Text);
                    }
                    content = sb.ToString();
                    
                    if (string.IsNullOrWhiteSpace(content))
                    {
                         // If PDF has no text, might be image-only PDF. For now, just return error or try OCR if supported.
                         // Current AI Service supports Image Analysis but not direct PDF-to-Image yet without a library like PDFium.
                         // We will assume text PDF for now.
                         return (false, "无法从PDF提取文本，可能是图片型PDF", null);
                    }
                    
                    var prompt = $@"
你是一个财务助手。请从以下发票文本中提取关键信息，并返回JSON格式。
字段要求：
- InvoiceNo (发票号码)
- InvoiceCode (发票代码)
- PurchaserName (购方名称)
- PurchaserTaxId (购方税号)
- SellerName (销方名称)
- SellerTaxId (销方税号)
- Amount (金额，不含税)
- TaxAmount (税额)
- TotalAmount (价税合计)
- InvoiceDate (开票日期, yyyy-MM-dd)
- Type (发票类型，推测为: vat_spec, vat_normal, vat_spec_e, vat_normal_e)

文本内容：
{content}
";
                    var json = await _aiService.GetChatCompletionAsync(message: prompt, systemPrompt: "请只返回JSON，不要包含markdown格式或其他文字。");
                    return await ParseRecognitionResult(json);
                }
                else if (new[] { ".jpg", ".jpeg", ".png", ".bmp" }.Contains(ext))
                {
                    using var stream = new MemoryStream();
                    await file.CopyToAsync(stream);
                    var bytes = stream.ToArray();
                    
                    var prompt = "请识别这张发票图片，提取以下信息并返回JSON格式：InvoiceNo, InvoiceCode, PurchaserName, PurchaserTaxId, SellerName, SellerTaxId, Amount, TaxAmount, TotalAmount, InvoiceDate, Type (vat_spec, vat_normal, vat_spec_e, vat_normal_e).";
                    var json = await _aiService.GetImageAnalysisAsync(bytes, prompt);
                    return await ParseRecognitionResult(json);
                }
                else
                {
                    return (false, "不支持的文件类型", null);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "发票识别失败");
                return (false, $"识别失败: {ex.Message}", null);
            }
        }

        private async Task<(bool Success, string Message, FinanceInvoiceDto? Data)> ParseRecognitionResult(string json)
        {
            try
            {
                // Clean markdown code blocks if present
                json = json.Replace("```json", "").Replace("```", "").Trim();
                
                var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
                var dto = JsonSerializer.Deserialize<CreateFinanceInvoiceDto>(json, options);

                if (dto == null) return (false, "无法解析识别结果", null);

                // Auto-determine direction
                var orgId = await GetCurrentOrgIdAsync();
                string direction = "input";
                
                if (orgId.HasValue)
                {
                     var org = await _context.Depts.FindAsync(orgId.Value);
                     if (org != null && !string.IsNullOrEmpty(dto.SellerName))
                     {
                         // If SellerName contains OrgName or OrgName contains SellerName, assume Output (Sales)
                         if (dto.SellerName.Contains(org.Name) || org.Name.Contains(dto.SellerName))
                         {
                             direction = "output";
                         }
                     }
                }

                var result = new FinanceInvoiceDto
                {
                    InvoiceNo = dto.InvoiceNo,
                    InvoiceCode = dto.InvoiceCode,
                    PurchaserName = dto.PurchaserName,
                    PurchaserTaxId = dto.PurchaserTaxId,
                    SellerName = dto.SellerName,
                    SellerTaxId = dto.SellerTaxId,
                    Direction = direction,
                    Type = dto.Type,
                    Amount = dto.Amount,
                    TaxAmount = dto.TaxAmount,
                    TotalAmount = dto.TotalAmount,
                    InvoiceDate = dto.InvoiceDate,
                    Status = "draft"
                };

                return (true, "识别成功", result);
            }
            catch (Exception ex)
            {
                return (false, $"解析识别结果失败: {ex.Message}", null);
            }
        }
    }
}
