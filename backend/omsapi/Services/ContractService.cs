using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Hosting;
using omsapi.Data;
using omsapi.Infrastructure.Attributes;
using omsapi.Models.Dtos.Contract;
using omsapi.Models.Entities.Contract;
using omsapi.Services.Interfaces;

namespace omsapi.Services
{
    [AutoInject(ServiceLifetime.Scoped)]
    public class ContractService : IContractService
    {
        private readonly OmsContext _context;
        private readonly IWebHostEnvironment _environment;

        public ContractService(OmsContext context, IWebHostEnvironment environment)
        {
            _context = context;
            _environment = environment;
        }

        // --- Contracts ---

        public async Task<IEnumerable<ContractDto>> GetContractsAsync(string? type = null, string? keyword = null, string? expiryStatus = null)
        {
            var query = _context.Contracts.AsQueryable();

            if (!string.IsNullOrEmpty(type))
            {
                query = query.Where(c => c.Type == type);
            }

            if (!string.IsNullOrEmpty(keyword))
            {
                query = query.Where(c => c.ContractName.Contains(keyword) || c.ContractNo.Contains(keyword) || c.PartnerName.Contains(keyword));
            }

            if (!string.IsNullOrEmpty(expiryStatus))
            {
                var today = DateTime.Today;
                var next7 = today.AddDays(7);

                if (expiryStatus == "expired")
                {
                    query = query.Where(c => c.EndDate != null && c.EndDate < today);
                }
                else if (expiryStatus == "within7")
                {
                    query = query.Where(c => c.EndDate != null && c.EndDate >= today && c.EndDate <= next7);
                }
                else if (expiryStatus == "notExpired")
                {
                    query = query.Where(c => c.EndDate == null || c.EndDate > next7);
                }
            }

            var entities = await query.OrderByDescending(c => c.CreatedAt).ToListAsync();

            return entities.Select(MapToDto);
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

        public async Task<ContractDto> CreateContractAsync(CreateContractDto dto)
        {
            var entity = new ContractMain
            {
                ContractNo = !string.IsNullOrWhiteSpace(dto.ContractNo) 
                    ? dto.ContractNo 
                    : "CNT-" + DateTime.Now.ToString("yyyyMMddHHmmss"),
                ContractName = dto.ContractName,
                Type = dto.Type,
                PartnerName = dto.PartnerName,
                SignDate = dto.SignDate,
                StartDate = dto.StartDate,
                EndDate = dto.EndDate,
                Manager = dto.Manager,
                TotalAmount = dto.TotalAmount,
                Currency = dto.Currency,
                PaymentMethod = dto.PaymentMethod,
                TaxId = dto.TaxId,
                Description = dto.Description,
                Files = dto.Files,
                LifecycleStatus = dto.LifecycleStatus ?? "draft",
                PricingType = dto.PricingType ?? "fixed",
                CreatedAt = DateTime.Now
            };

            _context.Contracts.Add(entity);
            await _context.SaveChangesAsync();

            return MapToDto(entity);
        }

        public async Task<ContractDto?> UpdateContractAsync(long id, UpdateContractDto dto)
        {
            var entity = await _context.Contracts.FindAsync(id);
            if (entity == null) return null;

            entity.ContractName = dto.ContractName;
            entity.Type = dto.Type;
            entity.PartnerName = dto.PartnerName;
            entity.SignDate = dto.SignDate;
            entity.StartDate = dto.StartDate;
            entity.EndDate = dto.EndDate;
            entity.Manager = dto.Manager;
            entity.TotalAmount = dto.TotalAmount;
            entity.Currency = dto.Currency;
            entity.PaymentMethod = dto.PaymentMethod;
            entity.TaxId = dto.TaxId;
            entity.Description = dto.Description;
            entity.Files = dto.Files;
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
                Status = dto.Status
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
                AttachmentFileName = invoice.AttachmentFileName
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
                AttachmentFileName = invoice.AttachmentFileName
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
                AttachmentFileName = invoice.AttachmentFileName
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

        private static ContractDto MapToDto(ContractMain entity)
        {
            return new ContractDto
            {
                Id = entity.Id,
                ContractNo = entity.ContractNo,
                ContractName = entity.ContractName,
                Type = entity.Type,
                PartnerName = entity.PartnerName,
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
                Files = entity.Files,
                CreatedAt = entity.CreatedAt,
                UpdatedAt = entity.UpdatedAt
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
                    AttachmentFileName = i.AttachmentFileName
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
