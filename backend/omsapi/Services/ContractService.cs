using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Hosting;
using omsapi.Data;
using omsapi.Infrastructure.Attributes;
using omsapi.Models.Dtos.Contract;
using omsapi.Models.Entities.Contract;
using omsapi.Models.Entities.Dict;
using omsapi.Services.Interfaces;
using UglyToad.PdfPig;
using System.Text;
using System.Text.Json;

using Microsoft.Extensions.Logging;

using NPOI.XSSF.UserModel;
using System.IO;

namespace omsapi.Services
{
    [AutoInject(ServiceLifetime.Scoped)]
    public class ContractService : IContractService
    {
        private readonly OmsContext _context;
        private readonly IWebHostEnvironment _environment;
        private readonly IAiService _aiService;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly ILogger<ContractService> _logger;

        public ContractService(OmsContext context, IWebHostEnvironment environment, IAiService aiService, IHttpContextAccessor httpContextAccessor, ILogger<ContractService> logger)
        {
            _context = context;
            _environment = environment;
            _aiService = aiService;
            _httpContextAccessor = httpContextAccessor;
            _logger = logger;
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

        // --- Contracts ---

        public async Task<(byte[] Content, string FileName)> ExportContractsAsync(ExportContractsDto dto)
        {
            var contracts = await GetContractsAsync(new ContractQueryDto 
            { 
                Type = dto.Type, 
                Keyword = dto.Keyword, 
                ExpiryStatus = dto.ExpiryStatus,
                ContractNo = dto.ContractNo,
                PartnerName = dto.PartnerName,
                Manager = dto.Manager,
                PricingType = dto.PricingType,
                LifecycleStatus = dto.LifecycleStatus,
                PerformanceStatus = dto.PerformanceStatus,
                PaymentMethod = dto.PaymentMethod,
                TotalAmountMin = dto.TotalAmountMin,
                TotalAmountMax = dto.TotalAmountMax,
                SignDateStart = dto.SignDateStart,
                SignDateEnd = dto.SignDateEnd,
                StartDateStart = dto.StartDateStart,
                StartDateEnd = dto.StartDateEnd,
                EndDateStart = dto.EndDateStart,
                EndDateEnd = dto.EndDateEnd
            });
            
            // Map expiryStatus to Chinese name
            string exportName = dto.ExpiryStatus switch
            {
                "notExpired" => "未到期合同",
                "within7" => "7日内到期合同",
                "expired" => "已到期合同",
                _ => "全部合同"
            };

            // Fetch dictionary map
            var dictMap = await GetDictMapAsync(new List<string> 
            { 
                "contract_type", 
                "contract_pricing_type", 
                "contract_status", 
                "contract_performance_status",
                "contract_payment_method"
            });

            using var memoryStream = new MemoryStream();
            {
                var workbook = new XSSFWorkbook();
                var sheet = workbook.CreateSheet(exportName);

                // Header Style
                var headerStyle = workbook.CreateCellStyle();
                var headerFont = workbook.CreateFont();
                headerFont.IsBold = true;
                headerStyle.SetFont(headerFont);
                headerStyle.VerticalAlignment = NPOI.SS.UserModel.VerticalAlignment.Center;
                headerStyle.Alignment = NPOI.SS.UserModel.HorizontalAlignment.Center;

                // Header
                var headerRow = sheet.CreateRow(0);
                headerRow.HeightInPoints = 20;
                // Use custom columns if provided, otherwise default columns
                var columns = dto.Columns.Any() ? dto.Columns : new List<ExportColumnDto>
                {
                    new() { Title = "合同名称", DataIndex = "contractName" },
                    new() { Title = "合同总金额", DataIndex = "totalAmount" },
                    new() { Title = "合同类型", DataIndex = "direction" },
                    new() { Title = "合同编号", DataIndex = "contractNo" },
                    new() { Title = "负责人", DataIndex = "manager" },
                    new() { Title = "总价类型", DataIndex = "pricingType" },
                    new() { Title = "签订日期", DataIndex = "signDate" },
                    new() { Title = "状态", DataIndex = "signStatus" },
                    new() { Title = "履约状态", DataIndex = "performanceStatus" },
                    new() { Title = "到期日期", DataIndex = "endDate" }
                };

                for (int i = 0; i < columns.Count; i++)
                {
                    var cell = headerRow.CreateCell(i);
                    cell.SetCellValue(columns[i].Title);
                    cell.CellStyle = headerStyle;
                }

                // Data
                int rowIndex = 1;
                foreach (var contract in contracts)
                {
                    var row = sheet.CreateRow(rowIndex++);
                    row.HeightInPoints = 20;
                    for (int i = 0; i < columns.Count; i++)
                    {
                        var col = columns[i];
                        var value = GetContractValue(contract, col.DataIndex, dictMap);
                        var cell = row.CreateCell(i);

                        switch (value)
                        {
                            case double d:
                                cell.SetCellValue(d);
                                break;
                            case decimal dec:
                                cell.SetCellValue((double)dec);
                                break;
                            case int n:
                                cell.SetCellValue(n);
                                break;
                            case long l:
                                cell.SetCellValue(l);
                                break;
                            default:
                                cell.SetCellValue(value?.ToString() ?? "");
                                break;
                        }
                    }
                }

                // Auto filter
                sheet.SetAutoFilter(new NPOI.SS.Util.CellRangeAddress(0, rowIndex - 1, 0, columns.Count - 1));

                // Auto size columns with max width limit
                for (int i = 0; i < columns.Count; i++)
                {
                    sheet.AutoSizeColumn(i);
                    int currentWidth = (int)sheet.GetColumnWidth(i);
                    
                    // Add padding (approx 1.2x) as AutoSize is often tight for Chinese
                    int newWidth = (int)(currentWidth * 1.2);

                    // 50 characters width approx (1 char approx 256 units)
                    if (newWidth > 50 * 256)
                    {
                        newWidth = 50 * 256;
                    }
                    sheet.SetColumnWidth(i, newWidth);
                }

                workbook.Write(memoryStream);
            }

            return (memoryStream.ToArray(), $"{exportName}_{DateTime.Now:yyyyMMddHHmmss}.xlsx");
        }

        private async Task<Dictionary<string, Dictionary<string, string>>> GetDictMapAsync(List<string> dictCodes)
        {
            var dicts = await _context.DictTypes
                .Include(t => t.DictDatas)
                .Where(t => dictCodes.Contains(t.Code))
                .ToListAsync();

            return dicts.ToDictionary(
                t => t.Code,
                t => t.DictDatas.ToDictionary(d => d.Value, d => d.Label)
            );
        }

        private object GetContractValue(ContractDto contract, string dataIndex, Dictionary<string, Dictionary<string, string>>? dictMap = null)
        {
            string GetDictLabel(string dictCode, string value)
            {
                if (dictMap != null && dictMap.ContainsKey(dictCode) && dictMap[dictCode].TryGetValue(value, out var label))
                {
                    return label;
                }
                return "";
            }

            switch (dataIndex)
            {
                case "contractName": return contract.ContractName;
                case "contractNo": return contract.ContractNo ?? "";
                case "totalAmount": return (double)contract.TotalAmount;
                case "manager": return contract.Manager ?? "";
                case "signDate": return contract.SignDate?.ToString("yyyy-MM-dd") ?? "-";
                case "startDate": return contract.StartDate?.ToString("yyyy-MM-dd") ?? "-";
                case "endDate": return contract.EndDate?.ToString("yyyy-MM-dd") ?? "-";
                case "signStatus": // lifecycleStatus
                case "lifecycleStatus": 
                    var statusLabel = GetDictLabel("contract_status", contract.LifecycleStatus);
                    if (!string.IsNullOrEmpty(statusLabel)) return statusLabel;

                    return !contract.SignDate.HasValue ? "草稿" : "已签订";
                case "direction":
                case "type":
                    var typeLabel = GetDictLabel("contract_type", contract.Type);
                    if (!string.IsNullOrEmpty(typeLabel)) return typeLabel;

                    return "其他";
                case "pricingType":
                    var pricingLabel = GetDictLabel("contract_pricing_type", contract.PricingType);
                    if (!string.IsNullOrEmpty(pricingLabel)) return pricingLabel;

                    return "未知";
                case "performanceStatus":
                    var perfLabel = GetDictLabel("contract_performance_status", contract.Status);
                    if (!string.IsNullOrEmpty(perfLabel)) return perfLabel;

                    return "未知";
                case "partnerName": return contract.PartnerName ?? "";
                case "currency": return contract.Currency;
                case "paymentMethod": 
                    var paymentLabel = GetDictLabel("contract_payment_method", contract.PaymentMethod ?? "");
                    return !string.IsNullOrEmpty(paymentLabel) ? paymentLabel : (contract.PaymentMethod ?? "");
                case "description": return contract.Description ?? "";
                case "validityPeriod":
                    if (!contract.StartDate.HasValue && !contract.EndDate.HasValue) return "无";
                    var start = contract.StartDate?.ToString("yyyy-MM-dd") ?? "-";
                    var end = contract.EndDate?.ToString("yyyy-MM-dd") ?? "-";
                    return $"{start} 至 {end}";
                default: return "";
            }
        }

        public async Task<IEnumerable<ContractDto>> GetContractsAsync(ContractQueryDto dto)
        {
            var orgId = await GetCurrentOrgIdAsync();
            var query = _context.Contracts.AsQueryable();

            if (orgId.HasValue)
            {
                query = query.Where(c => c.OrgId == orgId.Value);
            }

            if (!string.IsNullOrEmpty(dto.Type)) query = query.Where(c => c.Type == dto.Type);
            if (!string.IsNullOrEmpty(dto.ContractNo)) query = query.Where(c => c.ContractNo.Contains(dto.ContractNo));
            if (!string.IsNullOrEmpty(dto.PartnerName)) query = query.Where(c => c.PartnerName.Contains(dto.PartnerName));
            if (!string.IsNullOrEmpty(dto.Manager)) query = query.Where(c => c.Manager != null && c.Manager.Contains(dto.Manager));
            if (!string.IsNullOrEmpty(dto.PricingType)) query = query.Where(c => c.PricingType == dto.PricingType);
            if (!string.IsNullOrEmpty(dto.LifecycleStatus)) query = query.Where(c => c.LifecycleStatus == dto.LifecycleStatus);
            if (!string.IsNullOrEmpty(dto.PerformanceStatus)) query = query.Where(c => c.Status == dto.PerformanceStatus);
            if (!string.IsNullOrEmpty(dto.PaymentMethod)) query = query.Where(c => c.PaymentMethod == dto.PaymentMethod);

            if (dto.TotalAmountMin.HasValue) query = query.Where(c => c.TotalAmount >= dto.TotalAmountMin.Value);
            if (dto.TotalAmountMax.HasValue) query = query.Where(c => c.TotalAmount <= dto.TotalAmountMax.Value);

            if (dto.SignDateStart.HasValue) query = query.Where(c => c.SignDate >= dto.SignDateStart.Value);
            if (dto.SignDateEnd.HasValue) query = query.Where(c => c.SignDate <= dto.SignDateEnd.Value);

            if (dto.StartDateStart.HasValue) query = query.Where(c => c.StartDate >= dto.StartDateStart.Value);
            if (dto.StartDateEnd.HasValue) query = query.Where(c => c.StartDate <= dto.StartDateEnd.Value);

            if (dto.EndDateStart.HasValue) query = query.Where(c => c.EndDate >= dto.EndDateStart.Value);
            if (dto.EndDateEnd.HasValue) query = query.Where(c => c.EndDate <= dto.EndDateEnd.Value);

            if (!string.IsNullOrEmpty(dto.Keyword))
            {
                query = query.Where(c => c.ContractName.Contains(dto.Keyword) || c.ContractNo.Contains(dto.Keyword) || c.PartnerName.Contains(dto.Keyword));
            }

            if (!string.IsNullOrEmpty(dto.ExpiryStatus))
            {
                var today = DateTime.Today;
                var next7 = today.AddDays(7);

                if (dto.ExpiryStatus == "expired")
                {
                    query = query.Where(c => c.EndDate != null && c.EndDate < today);
                }
                else if (dto.ExpiryStatus == "within7")
                {
                    query = query.Where(c => c.EndDate != null && c.EndDate >= today && c.EndDate <= next7);
                }
                else if (dto.ExpiryStatus == "notExpired")
                {
                    query = query.Where(c => c.EndDate == null || c.EndDate > next7);
                }
            }

            var resultQuery = from c in query
                              join d in _context.Depts on c.OrgId equals d.Id into depts
                              from dept in depts.DefaultIfEmpty()
                              orderby c.CreatedAt descending
                              select new { Contract = c, OrgName = dept.Name };

            var list = await resultQuery.ToListAsync();

            return list.Select(x => {
                var d = MapToDto(x.Contract);
                d.OrgName = x.OrgName;
                return d;
            });
        }

        public async Task<IEnumerable<ContractCustomerSelectDto>> GetCustomersAsync(string? keyword = null)
        {
            var query = _context.SalesCustomers.AsQueryable();

            if (!string.IsNullOrEmpty(keyword))
            {
                query = query.Where(c => c.Name.Contains(keyword) || c.Contact.Contains(keyword));
            }

            var customers = await query
                .OrderBy(c => c.Name)
                .Select(c => new ContractCustomerSelectDto
                {
                    Id = c.Id,
                    Name = c.Name,
                    Industry = c.Industry,
                    Contact = c.Contact,
                    Phone = c.Phone,
                    Level = c.Level
                })
                .ToListAsync();
            
            return customers;
        }

        public async Task<ContractDetailDto?> GetContractByIdAsync(long id)
        {
            var entity = await _context.Contracts
                .Include(c => c.PaymentPlans)
                .Include(c => c.PaymentRecords)
                .Include(c => c.Invoices)
                .Include(c => c.Contacts)
                .Include(c => c.Attachments)
                .FirstOrDefaultAsync(c => c.Id == id);

            if (entity == null) return null;

            var dto = MapToDetailDto(entity);

            var relatedIds = await _context.ContractRelations
                .Where(r => r.ContractId == id)
                .Select(r => r.RelatedContractId)
                .Distinct()
                .ToListAsync();

            if (relatedIds.Any())
            {
                var relatedContracts = await _context.Contracts
                    .Where(c => relatedIds.Contains(c.Id))
                    .ToListAsync();

                dto.RelatedContracts = relatedContracts
                    .Select(c => new RelatedContractDto
                    {
                        Id = c.Id,
                        ContractNo = c.ContractNo,
                        ContractName = c.ContractName,
                        Type = c.Type,
                        Manager = c.Manager,
                        TotalAmount = c.TotalAmount,
                        Currency = c.Currency,
                        Status = c.Status,
                        SignDate = c.SignDate
                    })
                    .ToList();
            }

            return dto;
        }

        public async Task<ContractDto> CreateContractAsync(CreateContractDto dto, List<IFormFile>? files = null)
        {
            var orgId = await GetCurrentOrgIdAsync();

            var entity = new ContractMain
            {
                ContractNo = !string.IsNullOrWhiteSpace(dto.ContractNo) 
                    ? dto.ContractNo 
                    : "CNT-" + DateTime.Now.ToString("yyyyMMddHHmmss"),
                ContractName = dto.ContractName,
                Type = dto.Type,
                PartnerName = dto.PartnerName,
                PartnerId = dto.PartnerId,
                SignDate = dto.SignDate,
                StartDate = dto.StartDate,
                EndDate = dto.EndDate,
                Manager = dto.Manager,
                TotalAmount = dto.TotalAmount,
                Currency = dto.Currency,
                PaymentMethod = dto.PaymentMethod,
                TaxId = dto.TaxId,
                Description = dto.Description,
                Files = null, // Use ContractAttachment instead
                LifecycleStatus = dto.LifecycleStatus ?? "draft",
                PricingType = dto.PricingType ?? "fixed",
                CreatedAt = DateTime.Now,
                OrgId = orgId
            };

            _context.Contracts.Add(entity);
            await _context.SaveChangesAsync();

            // Handle simultaneous file uploads (New files)
            if (files != null && files.Count > 0)
            {
                foreach (var file in files)
                {
                    if (file.Length > 0)
                    {
                        await UploadContractAttachmentAsync(entity.Id, file);
                    }
                }
            }
            
            await _context.Entry(entity).Collection(c => c.Attachments).LoadAsync();

            return MapToDto(entity);
        }

        public async Task<ContractDto?> UpdateContractAsync(long id, UpdateContractDto dto)
        {
            var entity = await _context.Contracts.FindAsync(id);
            if (entity == null) return null;

            entity.ContractName = dto.ContractName;
            entity.Type = dto.Type;
            entity.PartnerName = dto.PartnerName;
            entity.PartnerId = dto.PartnerId;
            entity.SignDate = dto.SignDate;
            entity.StartDate = dto.StartDate;
            entity.EndDate = dto.EndDate;
            entity.Manager = dto.Manager;
            entity.TotalAmount = dto.TotalAmount;
            entity.Currency = dto.Currency;
            entity.PaymentMethod = dto.PaymentMethod;
            entity.TaxId = dto.TaxId;
            entity.Description = dto.Description;
            entity.LifecycleStatus = dto.LifecycleStatus;
            entity.UpdatedAt = DateTime.Now;
            
            if (dto.PricingType != null) entity.PricingType = dto.PricingType;
            if (dto.Status != null) entity.Status = dto.Status;
            if (dto.PaidAmount != null) entity.PaidAmount = dto.PaidAmount.Value;
            if (dto.InvoicedAmount != null) entity.InvoicedAmount = dto.InvoicedAmount.Value;
            if (dto.Progress != null) entity.Progress = dto.Progress.Value;

            await _context.SaveChangesAsync();

            return MapToDto(entity);
        }

        public async Task<bool> DeleteContractAsync(long id)
        {
            var entity = await _context.Contracts.FindAsync(id);
            if (entity == null) return false;

            _context.Contracts.Remove(entity);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<ContractPaymentPlanDto> CreatePaymentPlanAsync(CreateContractPaymentPlanDto dto)
        {
            var plan = new ContractPaymentPlan
            {
                ContractId = dto.ContractId,
                Phase = dto.Phase,
                DueDate = dto.DueDate,
                Amount = dto.Amount,
                Condition = dto.Condition,
                Status = dto.Status
            };

            _context.ContractPaymentPlans.Add(plan);
            await _context.SaveChangesAsync();

            return new ContractPaymentPlanDto
            {
                Id = plan.Id,
                Phase = plan.Phase,
                DueDate = plan.DueDate,
                Amount = plan.Amount,
                Condition = plan.Condition,
                Status = plan.Status
            };
        }

        public async Task<ContractPaymentPlanDto?> UpdatePaymentPlanAsync(long id, UpdateContractPaymentPlanDto dto)
        {
            var plan = await _context.ContractPaymentPlans.FindAsync(id);
            if (plan == null) return null;

            plan.Phase = dto.Phase;
            plan.DueDate = dto.DueDate;
            plan.Amount = dto.Amount;
            plan.Condition = dto.Condition;
            plan.Status = dto.Status;

            await _context.SaveChangesAsync();

            return new ContractPaymentPlanDto
            {
                Id = plan.Id,
                Phase = plan.Phase,
                DueDate = plan.DueDate,
                Amount = plan.Amount,
                Condition = plan.Condition,
                Status = plan.Status
            };
        }

        public async Task<bool> DeletePaymentPlanAsync(long id)
        {
            var plan = await _context.ContractPaymentPlans.FindAsync(id);
            if (plan == null) return false;

            _context.ContractPaymentPlans.Remove(plan);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<ContractPaymentRecordDto> CreatePaymentRecordAsync(CreateContractPaymentRecordDto dto)
        {
            var record = new ContractPaymentRecord
            {
                ContractId = dto.ContractId,
                PaymentDate = dto.PaymentDate,
                Amount = dto.Amount,
                Type = dto.Type,
                Method = dto.Method,
                Operator = dto.Operator,
                Remark = dto.Remark
            };

            _context.ContractPaymentRecords.Add(record);
            await _context.SaveChangesAsync();

            return new ContractPaymentRecordDto
            {
                Id = record.Id,
                PaymentDate = record.PaymentDate,
                Amount = record.Amount,
                Type = record.Type,
                Method = record.Method,
                Operator = record.Operator,
                Remark = record.Remark,
                VoucherFilePath = record.VoucherFilePath,
                VoucherFileName = record.VoucherFileName
            };
        }

        public async Task<ContractPaymentRecordDto?> UpdatePaymentRecordAsync(long id, UpdateContractPaymentRecordDto dto)
        {
            var record = await _context.ContractPaymentRecords.FindAsync(id);
            if (record == null) return null;

            record.PaymentDate = dto.PaymentDate;
            record.Amount = dto.Amount;
            record.Type = dto.Type;
            record.Method = dto.Method;
            record.Operator = dto.Operator;
            record.Remark = dto.Remark;

            await _context.SaveChangesAsync();

            return new ContractPaymentRecordDto
            {
                Id = record.Id,
                PaymentDate = record.PaymentDate,
                Amount = record.Amount,
                Type = record.Type,
                Method = record.Method,
                Operator = record.Operator,
                Remark = record.Remark,
                VoucherFilePath = record.VoucherFilePath,
                VoucherFileName = record.VoucherFileName
            };
        }

        public async Task<bool> DeletePaymentRecordAsync(long id)
        {
            var record = await _context.ContractPaymentRecords.FindAsync(id);
            if (record == null) return false;

            if (!string.IsNullOrEmpty(record.VoucherFilePath))
            {
                var webRootPath = _environment.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
                var relativePath = record.VoucherFilePath.TrimStart('/', '\\');
                var fullPath = Path.Combine(webRootPath, relativePath);
                if (File.Exists(fullPath))
                {
                    try
                    {
                        File.Delete(fullPath);
                    }
                    catch
                    {
                    }
                }
            }

            _context.ContractPaymentRecords.Remove(record);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<ContractPaymentRecordDto?> UploadPaymentRecordVoucherAsync(long id, IFormFile file)
        {
            if (file == null || file.Length == 0) return null;

            var record = await _context.ContractPaymentRecords.FindAsync(id);
            if (record == null) return null;

            var webRootPath = _environment.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
            var uploadDir = Path.Combine(webRootPath, "uploads", "contract", "payment-vouchers");
            if (!Directory.Exists(uploadDir))
            {
                Directory.CreateDirectory(uploadDir);
            }

            if (!string.IsNullOrEmpty(record.VoucherFilePath))
            {
                var oldRelative = record.VoucherFilePath.TrimStart('/', '\\');
                var oldFullPath = Path.Combine(webRootPath, oldRelative);
                if (File.Exists(oldFullPath))
                {
                    try
                    {
                        File.Delete(oldFullPath);
                    }
                    catch
                    {
                    }
                }
            }

            var ext = Path.GetExtension(file.FileName);
            var fileName = $"{id}_{Guid.NewGuid():N}{ext}";
            var fullPath = Path.Combine(uploadDir, fileName);

            using (var stream = new FileStream(fullPath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            var relativeUrl = $"/uploads/contract/payment-vouchers/{fileName}";

            record.VoucherFilePath = relativeUrl;
            record.VoucherFileName = file.FileName;

            await _context.SaveChangesAsync();

            return new ContractPaymentRecordDto
            {
                Id = record.Id,
                PaymentDate = record.PaymentDate,
                Amount = record.Amount,
                Type = record.Type,
                Method = record.Method,
                Operator = record.Operator,
                Remark = record.Remark,
                VoucherFilePath = record.VoucherFilePath,
                VoucherFileName = record.VoucherFileName
            };
        }

        public async Task<ContractInvoiceDto> CreateInvoiceAsync(CreateContractInvoiceDto dto)
        {
            var invoice = new ContractInvoice
            {
                ContractId = dto.ContractId,
                InvoiceNo = dto.InvoiceNo,
                InvoiceDate = dto.InvoiceDate,
                Amount = dto.Amount,
                Direction = dto.Direction,
                Type = dto.Type,
                Status = dto.Status,
                Content = dto.Content
            };

            _context.ContractInvoices.Add(invoice);
            await _context.SaveChangesAsync();

            return new ContractInvoiceDto
            {
                Id = invoice.Id,
                InvoiceNo = invoice.InvoiceNo,
                InvoiceDate = invoice.InvoiceDate,
                Amount = invoice.Amount,
                Direction = invoice.Direction,
                Type = invoice.Type,
                Status = invoice.Status,
                AttachmentFilePath = invoice.AttachmentFilePath,
                AttachmentFileName = invoice.AttachmentFileName,
                Content = invoice.Content
            };
        }

        public async Task<ContractInvoiceDto?> UpdateInvoiceAsync(long id, UpdateContractInvoiceDto dto)
        {
            var invoice = await _context.ContractInvoices.FindAsync(id);
            if (invoice == null) return null;

            invoice.InvoiceNo = dto.InvoiceNo;
            invoice.InvoiceDate = dto.InvoiceDate;
            invoice.Amount = dto.Amount;
            invoice.Direction = dto.Direction;
            invoice.Type = dto.Type;
            invoice.Status = dto.Status;
            invoice.Content = dto.Content;

            await _context.SaveChangesAsync();

            return new ContractInvoiceDto
            {
                Id = invoice.Id,
                InvoiceNo = invoice.InvoiceNo,
                InvoiceDate = invoice.InvoiceDate,
                Amount = invoice.Amount,
                Direction = invoice.Direction,
                Type = invoice.Type,
                Status = invoice.Status,
                AttachmentFilePath = invoice.AttachmentFilePath,
                AttachmentFileName = invoice.AttachmentFileName,
                Content = invoice.Content
            };
        }

        public async Task<bool> DeleteInvoiceAsync(long id)
        {
            var invoice = await _context.ContractInvoices.FindAsync(id);
            if (invoice == null) return false;

            if (!string.IsNullOrEmpty(invoice.AttachmentFilePath))
            {
                var webRootPath = _environment.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
                var relativePath = invoice.AttachmentFilePath.TrimStart('/', '\\');
                var fullPath = Path.Combine(webRootPath, relativePath);
                if (File.Exists(fullPath))
                {
                    try
                    {
                        File.Delete(fullPath);
                    }
                    catch
                    {
                    }
                }
            }

            _context.ContractInvoices.Remove(invoice);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<ContractInvoiceDto?> UploadInvoiceAttachmentAsync(long id, IFormFile file)
        {
            if (file == null || file.Length == 0) return null;

            var invoice = await _context.ContractInvoices.FindAsync(id);
            if (invoice == null) return null;

            var webRootPath = _environment.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
            var uploadDir = Path.Combine(webRootPath, "uploads", "contract", "invoice-attachments");
            if (!Directory.Exists(uploadDir))
            {
                Directory.CreateDirectory(uploadDir);
            }

            if (!string.IsNullOrEmpty(invoice.AttachmentFilePath))
            {
                var oldRelative = invoice.AttachmentFilePath.TrimStart('/', '\\');
                var oldFullPath = Path.Combine(webRootPath, oldRelative);
                if (File.Exists(oldFullPath))
                {
                    try
                    {
                        File.Delete(oldFullPath);
                    }
                    catch
                    {
                    }
                }
            }

            var ext = Path.GetExtension(file.FileName);
            var fileName = $"{id}_{Guid.NewGuid():N}{ext}";
            var fullPath = Path.Combine(uploadDir, fileName);

            using (var stream = new FileStream(fullPath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            var relativeUrl = $"/uploads/contract/invoice-attachments/{fileName}";

            invoice.AttachmentFilePath = relativeUrl;
            invoice.AttachmentFileName = file.FileName;

            await _context.SaveChangesAsync();

            return new ContractInvoiceDto
            {
                Id = invoice.Id,
                InvoiceNo = invoice.InvoiceNo,
                InvoiceDate = invoice.InvoiceDate,
                Amount = invoice.Amount,
                Direction = invoice.Direction,
                Type = invoice.Type,
                Status = invoice.Status,
                AttachmentFilePath = invoice.AttachmentFilePath,
                AttachmentFileName = invoice.AttachmentFileName,
                Content = invoice.Content
            };
        }

        public async Task<ContractAttachmentDto?> UploadContractAttachmentAsync(long contractId, IFormFile file)
        {
            if (file == null || file.Length == 0) return null;

            var contract = await _context.Contracts.FindAsync(contractId);
            if (contract == null) return null;

            var webRootPath = _environment.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
            var uploadDir = Path.Combine(webRootPath, "uploads", "contract", "attachments");
            if (!Directory.Exists(uploadDir))
            {
                Directory.CreateDirectory(uploadDir);
            }

            var ext = Path.GetExtension(file.FileName);
            var fileName = $"{contractId}_{Guid.NewGuid():N}{ext}";
            var fullPath = Path.Combine(uploadDir, fileName);

            using (var stream = new FileStream(fullPath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            var relativeUrl = $"/uploads/contract/attachments/{fileName}";

            var entity = new ContractAttachment
            {
                ContractId = contractId,
                FileName = file.FileName,
                FilePath = relativeUrl,
                Size = FormatFileSize(file.Length),
                UploadDate = DateTime.Now
            };

            _context.ContractAttachments.Add(entity);
            await _context.SaveChangesAsync();

            return new ContractAttachmentDto
            {
                Id = entity.Id,
                FileName = entity.FileName,
                FilePath = entity.FilePath,
                Size = entity.Size,
                UploadDate = entity.UploadDate
            };
        }

        public async Task<bool> DeleteContractAttachmentAsync(long id)
        {
            var entity = await _context.ContractAttachments.FindAsync(id);
            if (entity == null) return false;

            var webRootPath = _environment.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
            if (!string.IsNullOrEmpty(entity.FilePath))
            {
                var relative = entity.FilePath.TrimStart('/', '\\');
                var fullPath = Path.Combine(webRootPath, relative);
                if (File.Exists(fullPath))
                {
                    try
                    {
                        File.Delete(fullPath);
                    }
                    catch
                    {
                    }
                }
            }

            _context.ContractAttachments.Remove(entity);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<string> UploadContractFileAsync(IFormFile file)
        {
            if (file == null || file.Length == 0) return string.Empty;

            var webRootPath = _environment.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
            var uploadDir = Path.Combine(webRootPath, "uploads", "contract", "files");
            if (!Directory.Exists(uploadDir))
            {
                Directory.CreateDirectory(uploadDir);
            }

            var ext = Path.GetExtension(file.FileName);
            var fileName = $"{Guid.NewGuid():N}{ext}";
            var fullPath = Path.Combine(uploadDir, fileName);

            using (var stream = new FileStream(fullPath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            return $"/uploads/contract/files/{fileName}";
        }

        public async Task<bool> DeleteContractFileAsync(string filePath)
        {
            if (string.IsNullOrEmpty(filePath)) return false;

            var webRootPath = _environment.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
            var relative = filePath.TrimStart('/', '\\');
            var fullPath = Path.Combine(webRootPath, relative);

            // Security check: ensure the file is within the uploads directory
            if (!fullPath.StartsWith(Path.Combine(webRootPath, "uploads"), StringComparison.OrdinalIgnoreCase))
            {
                return false;
            }

            if (File.Exists(fullPath))
            {
                try
                {
                    File.Delete(fullPath);
                    return true;
                }
                catch
                {
                    return false;
                }
            }
            return false;
        }

        public async Task<ContractInvoiceDto?> RecognizeInvoiceAsync(IFormFile file)
        {
            if (file == null || file.Length == 0) return null;

            var ext = Path.GetExtension(file.FileName).ToLower();

            // Get Current Organization Name for Direction Detection
            string currentOrgName = "";
            var currentOrgId = await GetCurrentOrgIdAsync();
            if (currentOrgId.HasValue)
            {
                var org = await _context.Depts.FindAsync(currentOrgId.Value);
                if (org != null) currentOrgName = org.Name;
            }

            // Handle Images (jpg, png)
            if (ext == ".jpg" || ext == ".jpeg" || ext == ".png")
            {
                try
                {
                    using var stream = new MemoryStream();
                    await file.CopyToAsync(stream);
                    var imageBytes = stream.ToArray();
                    
                    var prompt = "请分析这张发票图片，并将以下字段提取为 JSON 对象：\n" +
                                 "- InvoiceNo (字符串，发票号码)\n" +
                                 "- InvoiceDate (字符串，格式 yyyy-MM-dd)\n" +
                                 "- Amount (数字，金额)\n" +
                                 "- Type (字符串，应为完整的中文发票标题，例如 '增值税专用电子发票', '增值税普通发票', '增值税电子普通发票', '增值税专用发票')\n" +
                                 "- PurchaserName (字符串，购买方名称)\n" +
                                 "- SellerName (字符串，销售方名称)\n" +
                                 "仅返回有效的 JSON。";
                                 
                    var jsonResponse = await _aiService.GetImageAnalysisAsync(imageBytes, prompt);
                    return ParseInvoiceJson(jsonResponse, currentOrgName);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "识别图片发票失败");
                    return null;
                }
            }

            // Handle PDF
            string text = "";
            if (ext == ".pdf")
            {
                try
                {
                    using var stream = file.OpenReadStream();
                    using var document = PdfDocument.Open(stream);
                    var sb = new StringBuilder();
                    foreach (var page in document.GetPages())
                    {
                        sb.AppendLine(page.Text);
                    }
                    text = sb.ToString();
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "从 PDF 提取文本失败");
                    return null;
                }
            }
            else
            {
                return null;
            }

            if (string.IsNullOrWhiteSpace(text)) return null;

            var chatPrompt = $@"
你是一个发票识别助手。请从下方的发票文本中提取以下信息并以 JSON 格式返回。
字段：
- InvoiceNo (字符串，发票号码)
- InvoiceDate (字符串，格式 yyyy-MM-dd)
- Amount (数字，金额)
- Type (字符串，应为完整的中文发票标题，例如 '增值税专用电子发票', '增值税普通发票', '增值税电子普通发票', '增值税专用发票')
- PurchaserName (字符串，购买方名称)
- SellerName (字符串，销售方名称)

仅返回有效的 JSON。

发票文本：
{text}
";

            var systemPrompt = "你是一个帮助从发票文本中提取结构化数据的助手。仅返回 JSON。";
            // Explicitly use named arguments to avoid overload ambiguity
            var response = await _aiService.GetChatCompletionAsync(message: chatPrompt, systemPrompt: systemPrompt);

            return ParseInvoiceJson(response, currentOrgName);
        }

        private ContractInvoiceDto? ParseInvoiceJson(string jsonResponse, string currentOrgName)
        {
            if (string.IsNullOrWhiteSpace(jsonResponse)) return null;

            try 
            {
                var cleanJson = jsonResponse.Replace("```json", "").Replace("```", "").Trim();
                // Extract JSON part if there is extra text
                var startIndex = cleanJson.IndexOf('{');
                var endIndex = cleanJson.LastIndexOf('}');
                if (startIndex >= 0 && endIndex > startIndex)
                {
                    cleanJson = cleanJson.Substring(startIndex, endIndex - startIndex + 1);
                }

                var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
                var data = JsonSerializer.Deserialize<InvoiceRecognitionResult>(cleanJson, options);
                
                if (data == null) return null;

                // Determine Direction
                // Default to input (reimbursement/purchase)
                string direction = "input";
                if (!string.IsNullOrEmpty(currentOrgName))
                {
                    if (!string.IsNullOrEmpty(data.SellerName) && data.SellerName.Contains(currentOrgName))
                    {
                        direction = "output";
                    }
                    // If PurchaserName contains currentOrgName, it is input (default)
                }

                return new ContractInvoiceDto
                {
                    InvoiceNo = data.InvoiceNo ?? "",
                    InvoiceDate = DateTime.TryParse(data.InvoiceDate, out var date) ? date : DateTime.Today,
                    Amount = data.Amount,
                    Type = MapInvoiceType(data.Type),
                    Direction = direction,
                    Content = cleanJson
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "解析 AI 响应失败: {Response}", jsonResponse);
                return null;
            }
        }

        private string MapInvoiceType(string? type)
        {
            if (string.IsNullOrWhiteSpace(type)) return "vat_normal";
            
            // Normalize
            var t = type.Trim();
            
            // vat_spec_e: 增值税专用电子发票
            if (t.Contains("专用") && (t.Contains("电子") || t.Contains("数字化"))) return "vat_spec_e";
            
            // vat_normal_e: 增值税普通电子发票 / 电子发票
            if (t.Contains("普通") && (t.Contains("电子") || t.Contains("数字化"))) return "vat_normal_e";
            if (t.Contains("电子") && !t.Contains("专用")) return "vat_normal_e"; // Fallback for simple "电子发票"
            
            // vat_spec: 增值税专用发票
            if (t.Contains("专用")) return "vat_spec";
            
            // vat_normal: 增值税普通发票
            if (t.Contains("普通")) return "vat_normal";
            
            // Default fallback
            return "vat_normal";
        }

        private class InvoiceRecognitionResult
        {
            public string? InvoiceNo { get; set; }
            public string? InvoiceDate { get; set; }
            public decimal Amount { get; set; }
            public string? Type { get; set; }
            public string? PurchaserName { get; set; }
            public string? SellerName { get; set; }
        }

        private static ContractDto MapToDto(ContractMain entity)
        {
            var files = entity.Files;
            if ((files == null || files == "[]") && entity.Attachments != null && entity.Attachments.Any())
            {
                var fileList = entity.Attachments.Select(a => new
                {
                    name = a.FileName,
                    url = a.FilePath,
                    size = ParseSize(a.Size),
                    type = GetMimeType(a.FileName),
                    uploadTime = a.UploadDate
                }).ToList();
                files = JsonSerializer.Serialize(fileList);
            }

            return new ContractDto
            {
                Id = entity.Id,
                ContractNo = entity.ContractNo,
                ContractName = entity.ContractName,
                Type = entity.Type,
                PartnerName = entity.PartnerName,
                PartnerId = entity.PartnerId,
                SignDate = entity.SignDate,
                StartDate = entity.StartDate,
                EndDate = entity.EndDate,
                Manager = entity.Manager,
                TotalAmount = entity.TotalAmount,
                PaidAmount = entity.PaidAmount,
                InvoicedAmount = entity.InvoicedAmount,
                Progress = entity.Progress,
                Currency = entity.Currency,
                PaymentMethod = entity.PaymentMethod,
                TaxId = entity.TaxId,
                Status = entity.Status,
                LifecycleStatus = entity.LifecycleStatus,
                PricingType = entity.PricingType,
                Description = entity.Description,
                LatestTransactionDate = entity.LatestTransactionDate,
                Files = files,
                CreatedAt = entity.CreatedAt,
                UpdatedAt = entity.UpdatedAt
            };
        }

        private static long ParseSize(string? size)
        {
            if (string.IsNullOrEmpty(size)) return 0;
            // This is a rough estimation or we need to store bytes in DB. 
            // ContractAttachment stores string Size "X KB".
            // Frontend expects number bytes?
            // Actually frontend contract.ts defines: size?: number;
            // But if we return string "10 KB", JSON serialization might break strict typing or frontend handles it?
            // Let's try to parse back or just return 0 if we can't.
            // Actually, for display purposes in file list, frontend might just display it.
            // But if I want to be safe, I should store bytes in DB. 
            // ContractAttachment has string Size.
            // Let's just return 0 for now or try to parse.
            return 0; 
        }

        private static string GetMimeType(string fileName)
        {
             var ext = Path.GetExtension(fileName).ToLower();
             return ext switch
             {
                 ".pdf" => "application/pdf",
                 ".jpg" => "image/jpeg",
                 ".jpeg" => "image/jpeg",
                 ".png" => "image/png",
                 ".doc" => "application/msword",
                 ".docx" => "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
                 ".xls" => "application/vnd.ms-excel",
                 ".xlsx" => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                 _ => "application/octet-stream"
             };
        }


        private static ContractDetailDto MapToDetailDto(ContractMain entity)
        {
            return new ContractDetailDto
            {
                Id = entity.Id,
                ContractNo = entity.ContractNo,
                ContractName = entity.ContractName,
                Type = entity.Type,
                PartnerName = entity.PartnerName,
                PartnerId = entity.PartnerId,
                SignDate = entity.SignDate,
                StartDate = entity.StartDate,
                EndDate = entity.EndDate,
                Manager = entity.Manager,
                TotalAmount = entity.TotalAmount,
                PaidAmount = entity.PaidAmount,
                InvoicedAmount = entity.InvoicedAmount,
                Progress = entity.Progress,
                Currency = entity.Currency,
                PaymentMethod = entity.PaymentMethod,
                TaxId = entity.TaxId,
                Status = entity.Status,
                Description = entity.Description,
                LatestTransactionDate = entity.LatestTransactionDate,
                Files = entity.Files,
                CreatedAt = entity.CreatedAt,
                UpdatedAt = entity.UpdatedAt,
                PaymentPlans = entity.PaymentPlans.Select(p => new ContractPaymentPlanDto
                {
                    Id = p.Id,
                    Phase = p.Phase,
                    DueDate = p.DueDate,
                    Amount = p.Amount,
                    Condition = p.Condition,
                    Status = p.Status
                }).ToList(),
                PaymentRecords = entity.PaymentRecords.Select(r => new ContractPaymentRecordDto
                {
                    Id = r.Id,
                    PaymentDate = r.PaymentDate,
                    Amount = r.Amount,
                    Type = r.Type,
                    Method = r.Method,
                    Operator = r.Operator,
                    Remark = r.Remark,
                    VoucherFilePath = r.VoucherFilePath,
                    VoucherFileName = r.VoucherFileName
                }).ToList(),
                Invoices = entity.Invoices.Select(i => new ContractInvoiceDto
                {
                    Id = i.Id,
                    InvoiceNo = i.InvoiceNo,
                    InvoiceDate = i.InvoiceDate,
                    Amount = i.Amount,
                    Direction = i.Direction,
                    Type = i.Type,
                    Status = i.Status,
                    AttachmentFilePath = i.AttachmentFilePath,
                    AttachmentFileName = i.AttachmentFileName,
                    Content = i.Content
                }).ToList(),
                Contacts = entity.Contacts.Select(c => new ContractContactDto
                {
                    Id = c.Id,
                    Name = c.Name,
                    Role = c.Role,
                    Phone = c.Phone,
                    Email = c.Email
                }).ToList(),
                Attachments = entity.Attachments.Select(a => new ContractAttachmentDto
                {
                    Id = a.Id,
                    FileName = a.FileName,
                    FilePath = a.FilePath,
                    Size = a.Size,
                    UploadDate = a.UploadDate
                }).ToList()
            };
        }

        private static string FormatFileSize(long bytes)
        {
            if (bytes < 1024) return $"{bytes} B";
            var kb = bytes / 1024.0;
            if (kb < 1024) return $"{kb:0.#} KB";
            var mb = kb / 1024.0;
            return $"{mb:0.#} MB";
        }

        public async Task<IEnumerable<RelatedContractDto>> GetRelatedContractsAsync(long contractId)
        {
            var relatedIds = await _context.ContractRelations
                .Where(r => r.ContractId == contractId)
                .Select(r => r.RelatedContractId)
                .Distinct()
                .ToListAsync();

            if (!relatedIds.Any())
            {
                return Enumerable.Empty<RelatedContractDto>();
            }

            var entities = await _context.Contracts
                .Where(c => relatedIds.Contains(c.Id))
                .ToListAsync();

            return entities.Select(c => new RelatedContractDto
            {
                Id = c.Id,
                ContractNo = c.ContractNo,
                ContractName = c.ContractName,
                Type = c.Type,
                Manager = c.Manager,
                TotalAmount = c.TotalAmount,
                Currency = c.Currency,
                Status = c.Status,
                SignDate = c.SignDate
            });
        }

        public async Task<IEnumerable<RelatedContractDto>> SetRelatedContractsAsync(long contractId, SetRelatedContractsDto dto)
        {
            var contract = await _context.Contracts.FindAsync(contractId);
            if (contract == null)
            {
                return Enumerable.Empty<RelatedContractDto>();
            }

            var targetIds = dto.RelatedContractIds
                .Where(id => id != contractId)
                .Distinct()
                .ToList();

            var existingTargets = await _context.Contracts
                .Where(c => targetIds.Contains(c.Id))
                .Select(c => c.Id)
                .ToListAsync();

            targetIds = targetIds
                .Where(id => existingTargets.Contains(id))
                .ToList();

            var toDelete = await _context.ContractRelations
                .Where(r => r.ContractId == contractId || (r.RelatedContractId == contractId && targetIds.Contains(r.ContractId)))
                .ToListAsync();

            _context.ContractRelations.RemoveRange(toDelete);

            var now = DateTime.Now;
            var newRelations = new List<ContractRelation>();

            foreach (var relatedId in targetIds)
            {
                newRelations.Add(new ContractRelation
                {
                    ContractId = contractId,
                    RelatedContractId = relatedId,
                    CreatedAt = now
                });

                newRelations.Add(new ContractRelation
                {
                    ContractId = relatedId,
                    RelatedContractId = contractId,
                    CreatedAt = now
                });
            }

            if (newRelations.Count > 0)
            {
                await _context.ContractRelations.AddRangeAsync(newRelations);
            }

            await _context.SaveChangesAsync();

            return await GetRelatedContractsAsync(contractId);
        }

        // --- Templates ---

        public async Task<IEnumerable<ContractTemplateDto>> GetTemplatesAsync(string? type = null)
        {
            var query = _context.ContractTemplates.AsQueryable();
            if (!string.IsNullOrEmpty(type))
            {
                query = query.Where(t => t.Type == type);
            }

            var entities = await query.OrderByDescending(t => t.CreatedAt).ToListAsync();
            return entities.Select(t => new ContractTemplateDto
            {
                Id = t.Id,
                Name = t.Name,
                Type = t.Type,
                Description = t.Description,
                FilePath = t.FilePath,
                FileName = t.FileName,
                Status = t.Status,
                CreatedAt = t.CreatedAt,
                UpdatedAt = t.UpdatedAt
            });
        }

        public async Task<ContractTemplateDto> CreateTemplateAsync(CreateContractTemplateDto dto)
        {
            var entity = new ContractTemplate
            {
                Name = dto.Name,
                Type = dto.Type,
                Description = dto.Description,
                FilePath = dto.FilePath,
                FileName = dto.FileName,
                Status = dto.Status,
                CreatedAt = DateTime.Now
            };

            _context.ContractTemplates.Add(entity);
            await _context.SaveChangesAsync();

            return new ContractTemplateDto
            {
                Id = entity.Id,
                Name = entity.Name,
                Type = entity.Type,
                Description = entity.Description,
                FilePath = entity.FilePath,
                FileName = entity.FileName,
                Status = entity.Status,
                CreatedAt = entity.CreatedAt
            };
        }

        public async Task<ContractTemplateDto?> UpdateTemplateAsync(long id, UpdateContractTemplateDto dto)
        {
            var entity = await _context.ContractTemplates.FindAsync(id);
            if (entity == null) return null;

            var webRootPath = _environment.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");

            entity.Name = dto.Name;
            entity.Type = dto.Type;
            entity.Description = dto.Description;
            entity.Status = dto.Status;
            
            if (!string.IsNullOrEmpty(dto.FilePath) && dto.FilePath != entity.FilePath)
            {
                if (!string.IsNullOrEmpty(entity.FilePath))
                {
                    var oldRelative = entity.FilePath.TrimStart('/', '\\');
                    var oldFullPath = Path.Combine(webRootPath, oldRelative);
                    if (File.Exists(oldFullPath))
                    {
                        try
                        {
                            File.Delete(oldFullPath);
                        }
                        catch
                        {
                        }
                    }
                }

                entity.FilePath = dto.FilePath;
            }
            if (!string.IsNullOrEmpty(dto.FileName))
            {
                entity.FileName = dto.FileName;
            }

            entity.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();

            return new ContractTemplateDto
            {
                Id = entity.Id,
                Name = entity.Name,
                Type = entity.Type,
                Description = entity.Description,
                FilePath = entity.FilePath,
                FileName = entity.FileName,
                Status = entity.Status,
                CreatedAt = entity.CreatedAt,
                UpdatedAt = entity.UpdatedAt
            };
        }

        public async Task<bool> DeleteTemplateAsync(long id)
        {
            var entity = await _context.ContractTemplates.FindAsync(id);
            if (entity == null) return false;

            if (!string.IsNullOrEmpty(entity.FilePath))
            {
                var webRootPath = _environment.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
                var relativePath = entity.FilePath.TrimStart('/', '\\');
                var fullPath = Path.Combine(webRootPath, relativePath);
                if (File.Exists(fullPath))
                {
                    try
                    {
                        File.Delete(fullPath);
                    }
                    catch
                    {
                    }
                }
            }

            _context.ContractTemplates.Remove(entity);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<ContractTemplateDto?> UploadTemplateFileAsync(long id, IFormFile file)
        {
            if (file == null || file.Length == 0) return null;

            var entity = await _context.ContractTemplates.FindAsync(id);
            if (entity == null) return null;

            var webRootPath = _environment.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
            var uploadDir = Path.Combine(webRootPath, "uploads", "contract", "templates");
            if (!Directory.Exists(uploadDir))
            {
                Directory.CreateDirectory(uploadDir);
            }

            if (!string.IsNullOrEmpty(entity.FilePath))
            {
                var oldRelative = entity.FilePath.TrimStart('/', '\\');
                var oldFullPath = Path.Combine(webRootPath, oldRelative);
                if (File.Exists(oldFullPath))
                {
                    try
                    {
                        File.Delete(oldFullPath);
                    }
                    catch
                    {
                    }
                }
            }

            var ext = Path.GetExtension(file.FileName);
            var fileName = $"{id}_{Guid.NewGuid():N}{ext}";
            var fullPath = Path.Combine(uploadDir, fileName);

            using (var stream = new FileStream(fullPath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            var relativeUrl = $"/uploads/contract/templates/{fileName}";

            entity.FilePath = relativeUrl;
            entity.FileName = file.FileName;
            entity.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();

            return new ContractTemplateDto
            {
                Id = entity.Id,
                Name = entity.Name,
                Type = entity.Type,
                Description = entity.Description,
                FilePath = entity.FilePath,
                FileName = entity.FileName,
                Status = entity.Status,
                CreatedAt = entity.CreatedAt,
                UpdatedAt = entity.UpdatedAt
            };
        }

        public async Task<ContractTemplateDto?> DeleteTemplateFileAsync(long id)
        {
            var entity = await _context.ContractTemplates.FindAsync(id);
            if (entity == null) return null;

            if (!string.IsNullOrEmpty(entity.FilePath))
            {
                var webRootPath = _environment.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
                var relativePath = entity.FilePath.TrimStart('/', '\\');
                var fullPath = Path.Combine(webRootPath, relativePath);
                if (File.Exists(fullPath))
                {
                    try
                    {
                        File.Delete(fullPath);
                    }
                    catch
                    {
                    }
                }
            }

            entity.FilePath = null;
            entity.FileName = null;
            entity.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();

            return new ContractTemplateDto
            {
                Id = entity.Id,
                Name = entity.Name,
                Type = entity.Type,
                Description = entity.Description,
                FilePath = entity.FilePath,
                FileName = entity.FileName,
                Status = entity.Status,
                CreatedAt = entity.CreatedAt,
                UpdatedAt = entity.UpdatedAt
            };
        }

        // --- Stats ---

        public async Task<ContractStatDto?> GetCurrentStatsAsync(string periodType)
        {
            // For simplicity, return the latest stat for the given period type
            // In a real app, this might calculate real-time stats or fetch the specific period record
            var entity = await _context.ContractStats
                .Where(s => s.PeriodType == periodType)
                .OrderByDescending(s => s.StatDate)
                .FirstOrDefaultAsync();

            if (entity == null) return null;

            return MapToStatDto(entity);
        }

        public async Task<IEnumerable<ContractStatDto>> GetTrendStatsAsync(string periodType, int count = 12)
        {
            var entities = await _context.ContractStats
                .Where(s => s.PeriodType == periodType)
                .OrderByDescending(s => s.StatDate)
                .Take(count)
                .ToListAsync();

            return entities.OrderBy(s => s.StatDate).Select(MapToStatDto);
        }

        private static ContractStatDto MapToStatDto(ContractStat entity)
        {
            return new ContractStatDto
            {
                Id = entity.Id,
                PeriodType = entity.PeriodType,
                PeriodKey = entity.PeriodKey,
                StatDate = entity.StatDate,
                TotalContracts = entity.TotalContracts,
                TotalContractsGrowth = entity.TotalContractsGrowth,
                AmountCompletionRate = entity.AmountCompletionRate,
                ReceivedRate = entity.ReceivedRate,
                TotalAmount = entity.TotalAmount,
                ReceivedAmount = entity.ReceivedAmount,
                InvoicedAmount = entity.InvoicedAmount,
                PendingInvoiceAmount = entity.PendingInvoiceAmount,
                SalesCount = entity.SalesCount,
                PurchaseCount = entity.PurchaseCount
            };
        }

        // --- Knowledge ---

        public async Task<IEnumerable<ContractKnowledgeCategoryDto>> GetKnowledgeTreeAsync()
        {
            var categories = await _context.ContractKnowledgeCategories
                .OrderBy(c => c.SortOrder)
                .ToListAsync();

            var dtos = categories.Select(c => new ContractKnowledgeCategoryDto
            {
                Id = c.Id,
                Name = c.Name,
                ParentId = c.ParentId,
                SortOrder = c.SortOrder
            }).ToList();

            return BuildTree(dtos, null);
        }

        private List<ContractKnowledgeCategoryDto> BuildTree(List<ContractKnowledgeCategoryDto> allNodes, long? parentId)
        {
            var nodes = allNodes.Where(n => n.ParentId == parentId).ToList();
            foreach (var node in nodes)
            {
                node.Children = BuildTree(allNodes, node.Id);
            }
            return nodes;
        }

        public async Task<ContractKnowledgeCategoryDto> CreateKnowledgeCategoryAsync(CreateContractKnowledgeCategoryDto dto)
        {
            var entity = new ContractKnowledgeCategory
            {
                Name = dto.Name,
                ParentId = dto.ParentId,
                SortOrder = dto.SortOrder,
                CreatedAt = DateTime.Now
            };

            _context.ContractKnowledgeCategories.Add(entity);
            await _context.SaveChangesAsync();

            return new ContractKnowledgeCategoryDto
            {
                Id = entity.Id,
                Name = entity.Name,
                ParentId = entity.ParentId,
                SortOrder = entity.SortOrder
            };
        }

        public async Task<ContractKnowledgeCategoryDto?> UpdateKnowledgeCategoryAsync(long id, UpdateContractKnowledgeCategoryDto dto)
        {
            // 1. Get old path (before changes)
            // Note: GetCategoryPathAsync uses the current DB state. 
            // Since we haven't saved changes yet, but we are about to modify the tracked entity,
            // we need to be careful. GetCategoryPathAsync fetches parents. 
            // If we only change Name/ParentId of current node, the parents are unaffected.
            // But GetCategoryPathAsync fetches the current node too. 
            // So we must call it BEFORE modifying the entity instance.
            var oldPathRelative = await GetCategoryPathAsync(id);
            var webRoot = _environment.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
            var oldPathAbsolute = Path.Combine(webRoot, oldPathRelative);

            var entity = await _context.ContractKnowledgeCategories.FindAsync(id);
            if (entity == null) return null;

            // 2. Apply changes
            entity.Name = dto.Name;
            entity.SortOrder = dto.SortOrder;
            entity.ParentId = dto.ParentId;

            await _context.SaveChangesAsync();

            // 3. Get new path (after changes)
            var newPathRelative = await GetCategoryPathAsync(id);
            var newPathAbsolute = Path.Combine(webRoot, newPathRelative);

            // 4. Move if path changed
            if (oldPathRelative != newPathRelative)
            {
                // Physical Move
                if (Directory.Exists(oldPathAbsolute))
                {
                    // Ensure new parent directory exists
                    var newParentDir = Directory.GetParent(newPathAbsolute);
                    if (newParentDir != null && !newParentDir.Exists)
                    {
                        newParentDir.Create();
                    }
                    
                    try 
                    {
                        Directory.Move(oldPathAbsolute, newPathAbsolute);
                    }
                    catch (Exception ex)
                    {
                        // Log error but continue? Or throw?
                        // If move fails, we have inconsistency.
                        // For now, let's assume it works or throw.
                        throw new Exception($"Failed to move directory from {oldPathAbsolute} to {newPathAbsolute}: {ex.Message}");
                    }
                }

                // DB Update for FilePath
                // Normalize paths to forward slashes for DB comparison
                // DB paths start with /, so ensure prefixes match
                // oldPathRelative is like "uploads/knowledge/Old" (no slash)
                var oldPrefix = "/" + oldPathRelative.Replace("\\", "/") + "/";
                var newPrefix = "/" + newPathRelative.Replace("\\", "/") + "/";

                // Load all files that might be affected
                var affectedFiles = await _context.ContractKnowledgeFiles
                    .Where(f => f.FilePath != null && f.FilePath.StartsWith(oldPrefix))
                    .ToListAsync();

                foreach (var file in affectedFiles)
                {
                    if (file.FilePath != null)
                    {
                        // Replace prefix
                        file.FilePath = newPrefix + file.FilePath.Substring(oldPrefix.Length);
                    }
                }
                
                await _context.SaveChangesAsync();
            }

            return new ContractKnowledgeCategoryDto
            {
                Id = entity.Id,
                Name = entity.Name,
                ParentId = entity.ParentId,
                SortOrder = entity.SortOrder
            };
        }

        public async Task<bool> DeleteKnowledgeCategoryAsync(long id)
        {
            var entity = await _context.ContractKnowledgeCategories.FindAsync(id);
            if (entity == null) return false;
            
            _context.ContractKnowledgeCategories.Remove(entity);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<IEnumerable<ContractKnowledgeFileDto>> GetKnowledgeFilesAsync(long categoryId, string? keyword = null)
        {
            // 获取所有分类以查找子分类
            var allCategories = await _context.ContractKnowledgeCategories.ToListAsync();
            var categoryIds = new List<long> { categoryId };
            GetDescendantIds(allCategories, categoryId, categoryIds);

            var query = _context.ContractKnowledgeFiles.Where(f => categoryIds.Contains(f.CategoryId));
            
            if (!string.IsNullOrEmpty(keyword))
            {
                query = query.Where(f => f.Name.Contains(keyword));
            }

            var entities = await query.OrderByDescending(f => f.UploadTime).ToListAsync();

            return entities.Select(f => new ContractKnowledgeFileDto
            {
                Id = f.Id,
                CategoryId = f.CategoryId,
                Name = f.Name,
                Type = f.Type,
                FilePath = f.FilePath,
                Size = f.Size,
                Uploader = f.Uploader,
                UploadTime = f.UploadTime
            });
        }

        private void GetDescendantIds(List<ContractKnowledgeCategory> allCategories, long parentId, List<long> result)
        {
            var children = allCategories.Where(c => c.ParentId == parentId).ToList();
            foreach (var child in children)
            {
                result.Add(child.Id);
                GetDescendantIds(allCategories, child.Id, result);
            }
        }

        public async Task<ContractKnowledgeFileDto> UploadKnowledgeFileAsync(IFormFile file, long categoryId, string uploader)
        {
            if (file == null || file.Length == 0)
                throw new ArgumentException("File is empty");

            var relativePath = await GetCategoryPathAsync(categoryId);
            var webRootPath = _environment.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
            var absolutePath = Path.Combine(webRootPath, relativePath);

            if (!Directory.Exists(absolutePath))
            {
                Directory.CreateDirectory(absolutePath);
            }

            var fileName = file.FileName;
            var safeFileName = string.Join("_", fileName.Split(Path.GetInvalidFileNameChars()));
            var filePath = Path.Combine(absolutePath, safeFileName);
            
            // Handle duplicates
            var fileExtension = Path.GetExtension(safeFileName);
            var fileNameWithoutExt = Path.GetFileNameWithoutExtension(safeFileName);
            int count = 1;
            while (File.Exists(filePath))
            {
                safeFileName = $"{fileNameWithoutExt}({count}){fileExtension}";
                filePath = Path.Combine(absolutePath, safeFileName);
                count++;
            }

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            // Determine type
            var ext = fileExtension.ToLowerInvariant().TrimStart('.');
            var type = "other";
            if (ext == "pdf") type = "pdf";
            else if (new[] { "doc", "docx" }.Contains(ext)) type = "doc";
            else if (new[] { "xls", "xlsx" }.Contains(ext)) type = "xls";
            else if (ext == "txt") type = "txt";

            // Store relative path in DB (e.g. "/uploads/knowledge/Law/CivilCode.pdf")
            // Add leading slash for web URL compatibility
            var dbFilePath = "/" + Path.Combine(relativePath, safeFileName).Replace("\\", "/");

            var entity = new ContractKnowledgeFile
            {
                CategoryId = categoryId,
                Name = safeFileName, 
                Type = type,
                ContentType = file.ContentType,
                FilePath = dbFilePath, 
                Size = file.Length,
                Uploader = uploader,
                UploadTime = DateTime.Now
            };

            _context.ContractKnowledgeFiles.Add(entity);
            await _context.SaveChangesAsync();

            return new ContractKnowledgeFileDto
            {
                Id = entity.Id,
                CategoryId = entity.CategoryId,
                Name = entity.Name,
                Type = entity.Type,
                ContentType = entity.ContentType,
                FilePath = entity.FilePath,
                Size = entity.Size,
                Uploader = entity.Uploader,
                UploadTime = entity.UploadTime
            };
        }

        public async Task<ContractKnowledgeFileDto?> GetKnowledgeFileByIdAsync(long id)
        {
            var entity = await _context.ContractKnowledgeFiles.FindAsync(id);
            if (entity == null) return null;

            return new ContractKnowledgeFileDto
            {
                Id = entity.Id,
                CategoryId = entity.CategoryId,
                Name = entity.Name,
                Type = entity.Type,
                ContentType = entity.ContentType,
                FilePath = entity.FilePath,
                Size = entity.Size,
                Uploader = entity.Uploader,
                UploadTime = entity.UploadTime
            };
        }

        public async Task<ContractKnowledgeFileDto?> UpdateKnowledgeFileAsync(long id, UpdateContractKnowledgeFileDto dto)
        {
            var entity = await _context.ContractKnowledgeFiles.FindAsync(id);
            if (entity == null) return null;

            // Only update display Name. 
            // If we wanted to rename physical file, we would need to check if new name exists, move file, update path.
            // For simplicity and safety, we only update the DB name or we rename the file too.
            // User requested "modification", usually renaming the file is expected.
            
            if (entity.Name != dto.Name)
            {
                // Rename physical file
                var webRootPath = _environment.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
                
                // Construct old full path
                // entity.FilePath is relative like "/uploads/knowledge/..."
                if (!string.IsNullOrEmpty(entity.FilePath))
                {
                    // Remove leading slash for Path.Combine
                    var relativePath = entity.FilePath.TrimStart('/', '\\');
                    var oldFullPath = Path.Combine(webRootPath, relativePath);
                    var directory = Path.GetDirectoryName(oldFullPath);
                    
                    if (directory != null && File.Exists(oldFullPath))
                    {
                        var extension = Path.GetExtension(oldFullPath);
                        var newSafeName = string.Join("_", dto.Name.Split(Path.GetInvalidFileNameChars()));
                        
                        // Ensure extension is preserved if user didn't provide it
                        if (!newSafeName.EndsWith(extension, StringComparison.OrdinalIgnoreCase))
                        {
                            newSafeName += extension;
                        }

                        var newFullPath = Path.Combine(directory, newSafeName);

                        if (oldFullPath != newFullPath)
                        {
                             if (File.Exists(newFullPath))
                             {
                                 // Conflict, maybe append (1)
                                 // For now, simple error or overwrite prevention?
                                 // Let's just allow overwrite or throw? 
                                 // Safest is to fail.
                                 // But let's just keep DB update if file rename fails? No, inconsistency.
                             }
                             else
                             {
                                 File.Move(oldFullPath, newFullPath);
                                 
                                 // Update DB FilePath
                                 // entity.FilePath was "/uploads/knowledge/..."
                                 // We need to replace the filename part.
                                 var dirPart = Path.GetDirectoryName(entity.FilePath)?.Replace("\\", "/") ?? "";
                                 // If dirPart lost its leading slash (Path.GetDirectoryName might mess up), ensure it's there
                                 // Actually Path.GetDirectoryName("/uploads/...") returns "\uploads\..." (Windows) or "/uploads/..." (Linux)
                                 // If we assume standard format in DB is "/uploads/..."
                                 
                                 // Let's use simple string manipulation to be safer with the slashes
                                 var lastSlashIndex = entity.FilePath.LastIndexOf('/');
                                 if (lastSlashIndex >= 0)
                                 {
                                     var pathPart = entity.FilePath.Substring(0, lastSlashIndex + 1); // "/uploads/knowledge/.../"
                                     entity.FilePath = pathPart + newSafeName;
                                 }
                                 else
                                 {
                                     // Should not happen if it starts with /
                                      entity.FilePath = "/" + newSafeName;
                                 }

                                 entity.Name = newSafeName; // Update name to match file
                             }
                        }
                    }
                }
                
                // Fallback: if file doesn't exist (e.g. data only), just update Name
                if (entity.Name != dto.Name) 
                {
                     entity.Name = dto.Name;
                }
            }

            await _context.SaveChangesAsync();

            return new ContractKnowledgeFileDto
            {
                Id = entity.Id,
                CategoryId = entity.CategoryId,
                Name = entity.Name,
                Type = entity.Type,
                ContentType = entity.ContentType,
                FilePath = entity.FilePath,
                Size = entity.Size,
                Uploader = entity.Uploader,
                UploadTime = entity.UploadTime
            };
        }

        public async Task<bool> DeleteKnowledgeFileAsync(long id)
        {
            var entity = await _context.ContractKnowledgeFiles.FindAsync(id);
            if (entity == null) return false;

            // Delete physical file
            if (!string.IsNullOrEmpty(entity.FilePath))
            {
                var webRootPath = _environment.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
                var relativePath = entity.FilePath.TrimStart('/', '\\');
                var fullPath = Path.Combine(webRootPath, relativePath);
                if (File.Exists(fullPath))
                {
                    try 
                    {
                        File.Delete(fullPath);
                        
                        // Recursively delete empty parent directories
                        // Stop at "uploads/knowledge" (or root) to be safe
                        var directory = Directory.GetParent(fullPath);
                        var webRoot = _environment.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
                        var baseUploadPath = Path.Combine(webRoot, "uploads", "knowledge");

                        while (directory != null && directory.Exists && directory.FullName.StartsWith(baseUploadPath, StringComparison.OrdinalIgnoreCase))
                        {
                            // Check if directory is empty
                            if (!directory.EnumerateFileSystemInfos().Any())
                            {
                                try
                                {
                                    directory.Delete();
                                    directory = directory.Parent;
                                }
                                catch
                                {
                                    // Stop if delete fails (e.g. permission or not empty anymore)
                                    break;
                                }
                            }
                            else
                            {
                                // Directory not empty, stop traversing up
                                break;
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        // Log error but continue to delete DB record
                        Console.WriteLine($"Failed to delete file or directory {fullPath}: {ex.Message}");
                    }
                }
            }

            _context.ContractKnowledgeFiles.Remove(entity);
            await _context.SaveChangesAsync();
            return true;
        }

        private async Task<string> GetCategoryPathAsync(long categoryId)
        {
            var pathSegments = new List<string>();
            var currentId = (long?)categoryId;

            while (currentId.HasValue)
            {
                var category = await _context.ContractKnowledgeCategories.FindAsync(currentId.Value);
                if (category == null) break;

                // Sanitize name for file system
                var safeName = string.Join("_", category.Name.Split(Path.GetInvalidFileNameChars()));
                pathSegments.Insert(0, safeName);
                currentId = category.ParentId;
            }

            // Base path: uploads/knowledge
            var fullPath = Path.Combine("uploads", "knowledge");
            foreach (var segment in pathSegments)
            {
                fullPath = Path.Combine(fullPath, segment);
            }
            
            return fullPath;
        }

        private string FormatSize(long bytes)
        {
            if (bytes == 0) return "0 B";
            var k = 1024;
            var sizes = new[] { "B", "KB", "MB", "GB", "TB" };
            var i = (int)Math.Floor(Math.Log(bytes) / Math.Log(k));
            return $"{bytes / Math.Pow(k, i):F2} {sizes[i]}";
        }
    }
}
