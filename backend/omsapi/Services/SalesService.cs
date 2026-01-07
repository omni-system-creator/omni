using Microsoft.EntityFrameworkCore;
using omsapi.Data;
using omsapi.Models.Common;
using omsapi.Models.Dtos.Sales;
using omsapi.Models.Entities.Sales;
using omsapi.Services.Interfaces;
using omsapi.Infrastructure.Attributes;

namespace omsapi.Services
{
    [AutoInject(ServiceLifetime.Scoped)]
    public class SalesService : ISalesService
    {
        private readonly OmsContext _context;
        private readonly IAiService _aiService;
        private readonly IWebHostEnvironment _environment;

        public SalesService(OmsContext context, IAiService aiService, IWebHostEnvironment environment)
        {
            _context = context;
            _aiService = aiService;
            _environment = environment;
        }

        // --- Customer ---

        public async Task<PagedResult<SalesCustomerDto>> GetCustomersAsync(CustomerSearchParams searchParams)
        {
            var query = _context.SalesCustomers.AsQueryable();

            if (!string.IsNullOrEmpty(searchParams.SearchText))
            {
                query = query.Where(c => c.Name.Contains(searchParams.SearchText) || c.Contact.Contains(searchParams.SearchText));
            }

            if (!string.IsNullOrEmpty(searchParams.Status) && searchParams.Status != "all")
            {
                query = query.Where(c => c.Status == searchParams.Status);
            }

            var total = await query.CountAsync();
            var list = await query.OrderByDescending(c => c.CreatedAt)
                .Skip((searchParams.Page - 1) * searchParams.PageSize)
                .Take(searchParams.PageSize)
                .Select(c => new SalesCustomerDto
                {
                    Id = c.Id,
                    Name = c.Name,
                    Industry = c.Industry,
                    Contact = c.Contact,
                    Phone = c.Phone,
                    Level = c.Level,
                    Status = c.Status,
                    Owner = c.Owner,
                    CreatedAt = c.CreatedAt,
                    UpdatedAt = c.UpdatedAt
                })
                .ToListAsync();

            return new PagedResult<SalesCustomerDto> { Items = list, Total = total, Page = searchParams.Page, PageSize = searchParams.PageSize };
        }

        public async Task<SalesCustomerDto?> GetCustomerAsync(string id)
        {
            var c = await _context.SalesCustomers.FindAsync(id);
            if (c == null) return null;

            return new SalesCustomerDto
            {
                Id = c.Id,
                Name = c.Name,
                Industry = c.Industry,
                Contact = c.Contact,
                Phone = c.Phone,
                Level = c.Level,
                Status = c.Status,
                Owner = c.Owner,
                CreatedAt = c.CreatedAt,
                UpdatedAt = c.UpdatedAt
            };
        }

        public async Task<SalesCustomerDto?> CreateCustomerAsync(CreateCustomerDto dto)
        {
            var entity = new SalesCustomer
            {
                Name = dto.Name,
                Industry = dto.Industry,
                Contact = dto.Contact,
                Phone = dto.Phone,
                Level = dto.Level,
                Status = dto.Status ?? "active",
                Owner = dto.Owner,
                CreatedAt = DateTime.Now
            };

            _context.SalesCustomers.Add(entity);
            await _context.SaveChangesAsync();

            return await GetCustomerAsync(entity.Id);
        }

        public async Task<SalesCustomerDto?> UpdateCustomerAsync(string id, UpdateCustomerDto dto)
        {
            var entity = await _context.SalesCustomers.FindAsync(id);
            if (entity == null) return null;

            entity.Name = dto.Name;
            entity.Industry = dto.Industry;
            entity.Contact = dto.Contact;
            entity.Phone = dto.Phone;
            entity.Level = dto.Level;
            entity.Status = dto.Status ?? entity.Status;
            entity.Owner = dto.Owner;
            entity.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();
            return await GetCustomerAsync(id);
        }

        public async Task<bool> DeleteCustomerAsync(string id)
        {
            var entity = await _context.SalesCustomers.FindAsync(id);
            if (entity == null) return false;

            _context.SalesCustomers.Remove(entity);
            await _context.SaveChangesAsync();
            return true;
        }

        // --- Opportunity ---

        public async Task<List<SalesOpportunityDto>> GetOpportunitiesAsync(string? stage = null)
        {
            var query = _context.SalesOpportunities.AsQueryable();
            if (!string.IsNullOrEmpty(stage))
            {
                query = query.Where(o => o.Stage == stage);
            }

            return await query.OrderByDescending(o => o.CreatedAt)
                .Select(o => new SalesOpportunityDto
                {
                    Id = o.Id,
                    Title = o.Title,
                    Customer = o.Customer,
                    Amount = o.Amount,
                    Stage = o.Stage,
                    Owner = o.Owner,
                    Date = o.EstimatedCloseDate,
                    CreatedAt = o.CreatedAt
                })
                .ToListAsync();
        }

        public async Task<SalesOpportunityDto> CreateOpportunityAsync(CreateOpportunityDto dto)
        {
            var entity = new SalesOpportunity
            {
                Title = dto.Title,
                Customer = dto.Customer,
                Amount = dto.Amount,
                Stage = dto.Stage,
                Owner = dto.Owner,
                EstimatedCloseDate = dto.Date,
                CreatedAt = DateTime.Now
            };

            _context.SalesOpportunities.Add(entity);
            await _context.SaveChangesAsync();

            return new SalesOpportunityDto
            {
                Id = entity.Id,
                Title = entity.Title,
                Customer = entity.Customer,
                Amount = entity.Amount,
                Stage = entity.Stage,
                Owner = entity.Owner,
                Date = entity.EstimatedCloseDate,
                CreatedAt = entity.CreatedAt
            };
        }

        public async Task<SalesOpportunityDto?> UpdateOpportunityAsync(string id, UpdateOpportunityDto dto)
        {
            var entity = await _context.SalesOpportunities.FindAsync(id);
            if (entity == null) return null;

            entity.Title = dto.Title;
            entity.Customer = dto.Customer;
            entity.Amount = dto.Amount;
            entity.Stage = dto.Stage;
            entity.Owner = dto.Owner;
            entity.EstimatedCloseDate = dto.Date;
            entity.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();

            return new SalesOpportunityDto
            {
                Id = entity.Id,
                Title = entity.Title,
                Customer = entity.Customer,
                Amount = entity.Amount,
                Stage = entity.Stage,
                Owner = entity.Owner,
                Date = entity.EstimatedCloseDate,
                CreatedAt = entity.CreatedAt
            };
        }

        public async Task<bool> DeleteOpportunityAsync(string id)
        {
            var entity = await _context.SalesOpportunities.FindAsync(id);
            if (entity == null) return false;

            _context.SalesOpportunities.Remove(entity);
            await _context.SaveChangesAsync();
            return true;
        }

        // --- Materials ---

        public async Task<List<SalesScriptDto>> GetSalesScriptsAsync()
        {
            // Mock data for initial implementation if DB is empty, or fetch from DB
            if (!await _context.SalesScripts.AnyAsync())
            {
                return new List<SalesScriptDto>
                {
                    new SalesScriptDto
                    {
                        Id = "1",
                        Title = "初次接触话术",
                        Content = "[销售] 您好，我是XX公司的销售顾问小李，冒昧打扰您几分钟，请问您现在方便吗？\n[客户] 有什么事请说。\n[销售] 我们了解到贵公司最近在寻求提升供应链效率的解决方案，我希望能和您分享一下我们最新的系统如何帮助贵公司降低30%的库存成本。\n[客户] 30%？听起来有点夸张，你们是怎么做到的？\n[销售] 我们系统采用智能预测算法，结合历史数据和市场需求趋势，可以精准预测销量，避免库存积压。同时支持多仓库协同管理，提高调拨效率。我可以给您看几个同行业客户的案例。\n[客户] 那你们的系统费用大概是多少？\n[销售] 这需要根据贵公司的具体业务规模和功能需求来定制。我可以安排一次免费的产品演示，您看这周还是下周比较方便？\n[客户] 下周吧，周三下午。\n[销售] 好的，周三下午3点我发个会议邀请给您，期待和您进一步沟通。",
                        Category = "General",
                        Description = "适用于电话或面谈初次接触客户，建立信任并激发兴趣"
                    },
                    new SalesScriptDto
                    {
                        Id = "2",
                        Title = "异议处理-价格谈判",
                        Content = "[客户] 你们的价格比竞争对手高太多了。\n[销售] 我理解价格是您考虑的重要因素。不过我们来看看产品的整体价值。我们的系统不仅功能更全面，还包括24小时技术支持、定期免费升级和专业的培训服务。这些都为您节省了大量隐形成本。\n[客户] 但我们预算确实有限。\n[销售] 没关系，我们可以根据您的核心需求推出一个分阶段实施的方案。先部署最关键的功能模块，其他功能后续逐步添加。这样既能控制初期投入，又不会影响核心业务的改善。\n[客户] 这个方案听起来可行，能具体说说吗？\n[销售] 第一阶段先上订单管理和库存模块，费用可以降低40%，效果立竿见影。第二阶段再上采购和财务模块。而且第一阶段投入的费用可以在第二阶段抵扣。我给您做个详细的对比方案，您看可以吗？\n[客户] 好的，你发给我看看。\n[销售] 没问题，我今天就发给您。另外，如果本月签约还能享受95折优惠。",
                        Category = "Objection",
                        Description = "应对客户对价格敏感的异议，提供分期实施等灵活方案"
                    },
                    new SalesScriptDto
                    {
                        Id = "3",
                        Title = "产品介绍-核心功能",
                        Content = "[销售] 我为您介绍下我们系统的核心功能。首先是智能报表模块，它可以自动生成各类业务报表，支持多维度数据分析，帮助您快速洞察业务状况。\n[客户] 这个报表可以自定义吗？\n[销售] 当然！系统提供了丰富的模板，您也可以拖拽字段自由组合，还支持Excel导出和定时推送功能。每天早上上班就能看到昨天的经营数据，非常方便。\n[客户] 那移动端呢？我们经常外出办公。\n[销售] 我们的移动端APP功能非常完善，支持订单录入、库存查询、审批流程等核心业务。而且有离线模式，在没有网络的情况下也可以正常操作，联网后自动同步。\n[客户] 安全性怎么保障？\n[销售] 这一点您完全放心。我们采用银行级加密技术，数据多重备份，所有操作都有完整的审计日志。而且我们通过了ISO27001信息安全认证，保障您的数据安全。",
                        Category = "Product",
                        Description = "详细介绍产品的核心功能和优势，回答客户常见问题"
                    },
                    new SalesScriptDto
                    {
                        Id = "4",
                        Title = "成交促成",
                        Content = "[销售] 经过这几次沟通，您对我们的产品应该有了全面的了解。我看您对核心功能都比较满意，是有什么顾虑吗？\n[客户] 我担心上线后员工接受度不高，培训成本会很大。\n[销售] 这个您不用担心。我们提供三步培训计划：上线前对管理员进行深度培训，上线时安排现场指导，上线后一个月内提供7x24小时在线支持。而且系统界面设计得很直观，员工上手很快。我们上个月刚上线的一家公司，三天内所有员工都能独立操作了。\n[客户] 那实施周期要多久？\n[销售] 标准周期是6周，包括需求调研、系统配置、数据迁移、培训和测试。我们可以安排项目经理全程跟进，确保按时交付。合同里也会明确时间节点和违约责任。\n[客户] 听起来还不错。\n[销售] 那我们今天就签合同怎么样？我可以立即启动项目排期。而且本月签约的话，还可以享受优先安排实施团队的优惠。",
                        Category = "Closing",
                        Description = "最后阶段的成交技巧，消除客户顾虑，促成签约"
                    }
                };
            }

            return await _context.SalesScripts.Select(s => new SalesScriptDto
            {
                Id = s.Id,
                Title = s.Title,
                Content = s.Content,
                Category = s.Category,
                Description = s.Description
            }).ToListAsync();
        }

        public async Task<SalesScriptDto> CreateSalesScriptAsync(CreateSalesScriptDto dto)
        {
            var script = new SalesScript
            {
                Id = Guid.NewGuid().ToString("N"),
                Title = dto.Title,
                Content = dto.Content,
                Category = dto.Category ?? "General",
                Description = dto.Description ?? "",
                CreatedAt = DateTime.Now
            };

            _context.SalesScripts.Add(script);
            await _context.SaveChangesAsync();

            return new SalesScriptDto
            {
                Id = script.Id,
                Title = script.Title,
                Content = script.Content,
                Category = script.Category,
                Description = script.Description
            };
        }

        public async Task<SalesScriptDto?> UpdateSalesScriptAsync(string id, UpdateSalesScriptDto dto)
        {
            var script = await _context.SalesScripts.FindAsync(id);
            if (script == null) return null;

            if (!string.IsNullOrEmpty(dto.Title)) script.Title = dto.Title;
            if (!string.IsNullOrEmpty(dto.Content)) script.Content = dto.Content;
            if (!string.IsNullOrEmpty(dto.Category)) script.Category = dto.Category;
            if (!string.IsNullOrEmpty(dto.Description)) script.Description = dto.Description;

            await _context.SaveChangesAsync();

            return new SalesScriptDto
            {
                Id = script.Id,
                Title = script.Title,
                Content = script.Content,
                Category = script.Category,
                Description = script.Description
            };
        }

        public async Task<string> GenerateScriptFieldAsync(GenerateScriptFieldRequest request)
        {
            var prompt = "";
            var systemPrompt = "你是一个专业的销售话术编写助手。";

            switch (request.TargetField.ToLower())
            {
                case "title":
                    prompt = $"请根据以下销售场景描述和对话内容，生成一个简短精炼的场景标题（不超过15个字），只返回标题本身，不要包含引号或其他说明：\n\n描述：{request.Description}\n\n对话内容：{request.Content}";
                    break;
                case "description":
                    prompt = $"请根据以下场景标题和对话内容，生成一段简洁的场景描述（50字以内），说明该场景的适用情况和目的，只返回描述内容：\n\n标题：{request.Title}\n\n对话内容：{request.Content}";
                    break;
                case "content":
                    prompt = $"请根据以下场景标题和描述，生成一段初始的销售对话脚本。格式要求：\n1. 使用[销售]和[客户]作为角色标识。\n2. 每行一段对话，不要包含空行。\n3. 内容要自然、专业。\n4. 直接返回对话内容，不要包含其他解释。\n\n标题：{request.Title}\n\n描述：{request.Description}";
                    break;
                default:
                    return "Invalid target field";
            }

            return await _aiService.GetChatCompletionAsync(prompt, systemPrompt, request.Model);
        }

        public async IAsyncEnumerable<string> GenerateScriptFieldStreamAsync(GenerateScriptFieldRequest request)
        {
            var prompt = "";
            var systemPrompt = "你是一个专业的销售话术编写助手。";

            switch (request.TargetField.ToLower())
            {
                case "title":
                    prompt = $"请根据以下销售场景描述和对话内容，生成一个简短精炼的场景标题（不超过15个字），只返回标题本身，不要包含引号或其他说明：\n\n描述：{request.Description}\n\n对话内容：{request.Content}";
                    break;
                case "description":
                    prompt = $"请根据以下场景标题和对话内容，生成一段简洁的场景描述（50字以内），说明该场景的适用情况和目的，只返回描述内容：\n\n标题：{request.Title}\n\n对话内容：{request.Content}";
                    break;
                case "content":
                    prompt = $"请根据以下场景标题和描述，生成一段初始的销售对话脚本。格式要求：\n1. 使用[销售]和[客户]作为角色标识。\n2. 每行一段对话，不要包含空行。\n3. 内容要自然、专业。\n4. 直接返回对话内容，不要包含其他解释。\n\n标题：{request.Title}\n\n描述：{request.Description}";
                    break;
                default:
                    yield return "Invalid target field";
                    yield break;
            }

            await foreach (var chunk in _aiService.GetChatCompletionStreamAsync(prompt, systemPrompt, request.Model))
            {
                yield return chunk;
            }
        }

        public async Task<List<ProductDocDto>> GetProductDocsAsync()
        {
            if (!await _context.SalesProductDocs.AnyAsync())
            {
                // Seed data with folders
                var folder1 = new SalesProductDoc { Id = "1", Title = "产品手册", Type = "folder", UploadDate = DateTime.Now };
                var folder2 = new SalesProductDoc { Id = "2", Title = "技术文档", Type = "folder", UploadDate = DateTime.Now };
                
                _context.SalesProductDocs.AddRange(folder1, folder2);
                
                _context.SalesProductDocs.Add(new SalesProductDoc { Id = "3", Title = "产品白皮书.pdf", Size = "2.5MB", Url = "http://file.keking.cn/demo/20151125/aaa.pdf", Type = "file", ParentId = "1", UploadDate = DateTime.Now });
                _context.SalesProductDocs.Add(new SalesProductDoc { Id = "4", Title = "功能清单.xlsx", Size = "1.2MB", Url = "http://file.keking.cn/demo/20151125/aaa.xlsx", Type = "file", ParentId = "1", UploadDate = DateTime.Now });
                _context.SalesProductDocs.Add(new SalesProductDoc { Id = "5", Title = "架构设计.pptx", Size = "3.5MB", Url = "http://file.keking.cn/demo/20151125/aaa.pptx", Type = "file", ParentId = "2", UploadDate = DateTime.Now });

                await _context.SaveChangesAsync();
            }

            var allDocs = await _context.SalesProductDocs.Select(d => new ProductDocDto
            {
                Id = d.Id,
                Title = d.Title,
                Size = d.Size,
                Url = d.Url,
                Type = d.Type,
                ParentId = d.ParentId,
                UploadDate = d.UploadDate
            }).ToListAsync();

            // Build Tree
            var lookup = allDocs.ToDictionary(x => x.Id);
            var roots = new List<ProductDocDto>();

            foreach (var doc in allDocs)
            {
                if (string.IsNullOrEmpty(doc.ParentId) || !lookup.ContainsKey(doc.ParentId))
                {
                    roots.Add(doc);
                }
                else
                {
                    lookup[doc.ParentId].Children.Add(doc);
                }
            }

            return roots;
        }

        public async Task<ProductDocDto> CreateProductDocAsync(CreateProductDocDto dto)
        {
            var doc = new SalesProductDoc
            {
                Id = Guid.NewGuid().ToString("N"),
                Title = dto.Title,
                Size = dto.Size,
                Url = dto.Url,
                Type = dto.Type,
                ParentId = dto.ParentId,
                UploadDate = DateTime.Now
            };

            _context.SalesProductDocs.Add(doc);
            await _context.SaveChangesAsync();

            return new ProductDocDto
            {
                Id = doc.Id,
                Title = doc.Title,
                Size = doc.Size,
                Url = doc.Url,
                Type = doc.Type,
                ParentId = doc.ParentId,
                UploadDate = doc.UploadDate
            };
        }

        public async Task<ProductDocDto> UploadProductDocAsync(IFormFile file, string? parentId)
        {
            if (file == null || file.Length == 0)
                throw new ArgumentException("File is empty");

            // 1. Save File
            var webRootPath = _environment.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
            var uploadDir = Path.Combine(webRootPath, "uploads", "sales", "docs", DateTime.Now.ToString("yyyyMM"));
            if (!Directory.Exists(uploadDir))
                Directory.CreateDirectory(uploadDir);

            var ext = Path.GetExtension(file.FileName).ToLowerInvariant();
            var fileName = $"{Guid.NewGuid():N}{ext}";
            var filePath = Path.Combine(uploadDir, fileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            var url = $"/uploads/sales/docs/{DateTime.Now:yyyyMM}/{fileName}";
            var size = FormatFileSize(file.Length);

            // 2. Create DB Record
            var doc = new SalesProductDoc
            {
                Id = Guid.NewGuid().ToString("N"),
                Title = file.FileName,
                Size = size,
                Url = url,
                Type = "file",
                ParentId = parentId,
                UploadDate = DateTime.Now
            };

            _context.SalesProductDocs.Add(doc);
            await _context.SaveChangesAsync();

            return new ProductDocDto
            {
                Id = doc.Id,
                Title = doc.Title,
                Size = doc.Size,
                Url = doc.Url,
                Type = doc.Type,
                ParentId = doc.ParentId,
                UploadDate = doc.UploadDate
            };
        }

        public async Task<bool> DeleteProductDocAsync(string id)
        {
            var doc = await _context.SalesProductDocs.FindAsync(id);
            if (doc == null) return false;

            // Fetch all to find descendants
            var allDocs = await _context.SalesProductDocs.ToListAsync();
            var toDelete = new List<SalesProductDoc> { doc };
            
            void AddChildren(string parentId)
            {
                var children = allDocs.Where(d => d.ParentId == parentId).ToList();
                foreach (var child in children)
                {
                    toDelete.Add(child);
                    AddChildren(child.Id);
                }
            }
            
            AddChildren(id);
            
            _context.SalesProductDocs.RemoveRange(toDelete);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> RenameProductDocAsync(string id, string newName)
        {
            var doc = await _context.SalesProductDocs.FindAsync(id);
            if (doc == null) return false;
            
            doc.Title = newName;
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> MoveProductDocAsync(string id, string? newParentId)
        {
            var doc = await _context.SalesProductDocs.FindAsync(id);
            if (doc == null) return false;
            
            // Prevent moving folder into itself or its children
            if (doc.Type == "folder" && !string.IsNullOrEmpty(newParentId))
            {
                 // Check if newParentId is a child of id
                 var allDocs = await _context.SalesProductDocs.ToListAsync();
                 var current = allDocs.FirstOrDefault(d => d.Id == newParentId);
                 while (current != null)
                 {
                     if (current.Id == id) return false; // Circular reference
                     if (string.IsNullOrEmpty(current.ParentId)) break;
                     current = allDocs.FirstOrDefault(d => d.Id == current.ParentId);
                 }
            }

            doc.ParentId = newParentId;
            await _context.SaveChangesAsync();
            return true;
        }

        private string FormatFileSize(long bytes)
        {
            string[] sizes = { "B", "KB", "MB", "GB", "TB" };
            double len = bytes;
            int order = 0;
            while (len >= 1024 && order < sizes.Length - 1)
            {
                order++;
                len = len / 1024;
            }
            return $"{len:0.##} {sizes[order]}";
        }

        public async Task<List<ProcessRuleDto>> GetProcessRulesAsync()
        {
             // Mock data or DB
             if (!await _context.SalesProcessRules.AnyAsync())
            {
                return new List<ProcessRuleDto>
                {
                    new ProcessRuleDto { Id = "1", Title = "销售提成制度", Content = "详细的销售提成计算规则..." },
                    new ProcessRuleDto { Id = "2", Title = "合同审批流程", Content = "合同审批的各级节点和要求..." }
                };
            }

            return await _context.SalesProcessRules.Select(r => new ProcessRuleDto
            {
                Id = r.Id,
                Title = r.Title,
                Content = r.Content
            }).ToListAsync();
        }

        public async Task<SalesScriptChatResponseDto> SalesScriptChatAsync(SalesScriptChatDto dto)
        {
            // 获取话术内容
            var script = await _context.SalesScripts.FindAsync(dto.ScriptId);
            if (script == null)
            {
                throw new Exception("Sales script not found");
            }

            // 构建系统提示词
            var aiRole = dto.UserRole == "salesman" ? "customer" : "salesman";
            var systemPrompt = dto.UserRole == "salesman"
                ? $"你是一个挑剔但专业的客户，正在与销售人员讨论{script.Title}的场景。请以客户的身份回应销售人员的话，提出合理的问题或异议，保持自然和真实的对话风格。场景背景：{script.Description ?? script.Title}"
                : $"你是一个经验丰富的销售人员，正在与客户讨论{script.Title}的场景。请以专业销售人员的身份回应客户的问题或需求，保持友好、专业且有说服力的对话风格。场景背景：{script.Description ?? script.Title}";

            // 调用AI服务
            var response = await _aiService.GetChatCompletionAsync(dto.Message, systemPrompt, dto.Model);

            return new SalesScriptChatResponseDto
            {
                Content = response,
                Role = aiRole
            };
        }

        public async IAsyncEnumerable<SalesScriptChatResponseDto> SalesScriptChatStreamAsync(SalesScriptChatDto dto)
        {
            // 获取话术内容
            var script = await _context.SalesScripts.FindAsync(dto.ScriptId);
            if (script == null)
            {
                throw new Exception("Sales script not found");
            }

            // 构建系统提示词
            var aiRole = dto.UserRole == "salesman" ? "customer" : "salesman";
            var systemPrompt = dto.UserRole == "salesman"
                ? $"你是一个挑剔但专业的客户，正在与销售人员讨论{script.Title}的场景。请以客户的身份回应销售人员的话，提出合理的问题或异议，保持自然和真实的对话风格。场景背景：{script.Description ?? script.Title}"
                : $"你是一个经验丰富的销售人员，正在与客户讨论{script.Title}的场景。请以专业销售人员的身份回应客户的问题或需求，保持友好、专业且有说服力的对话风格。场景背景：{script.Description ?? script.Title}";

            // 调用AI服务
            await foreach (var chunk in _aiService.GetChatCompletionStreamAsync(dto.Message, systemPrompt, dto.Model))
            {
                yield return new SalesScriptChatResponseDto
                {
                    Content = chunk,
                    Role = aiRole
                };
            }
        }

        // --- Stats ---

        public async Task<SalesDashboardStatsDto> GetDashboardStatsAsync()
        {
            var now = DateTime.Now;
            var startOfMonth = new DateTime(now.Year, now.Month, 1);
            
            // For demo, we fetch all. In production, filter by date range first.
            var opps = await _context.SalesOpportunities.ToListAsync();

            var newOppsCount = opps.Count(o => o.CreatedAt >= startOfMonth);
            
            // Calculate won amount for this month
            var wonAmount = opps
                .Where(o => o.Stage == "won" && o.UpdatedAt >= startOfMonth)
                .Sum(o => o.Amount);
            
            // Calculate win rate (Won / (Won + Lost))
            var closedOpps = opps.Where(o => o.Stage == "won" || o.Stage == "lost").ToList();
            var winRate = closedOpps.Any() 
                ? (double)closedOpps.Count(o => o.Stage == "won") / closedOpps.Count * 100 
                : 0;

            return new SalesDashboardStatsDto
            {
                MonthlyTarget = 1000000, // Hardcoded target
                MonthlyProgress = (int)((wonAmount / 1000000m) * 100),
                QuarterlyProgress = 65, // Mock
                NewOpportunities = newOppsCount,
                NewOpportunitiesGrowth = 20, // Mock
                WinRate = Math.Round(winRate, 1),
                WinRateGrowth = 5 // Mock
            };
        }

        public async Task<List<TeamRankingDto>> GetTeamRankingAsync()
        {
            // Group by Owner and sum Amount
            var ranking = await _context.SalesOpportunities
                .GroupBy(o => o.Owner)
                .Select(g => new 
                { 
                    Owner = g.Key, 
                    Amount = g.Sum(o => o.Amount) 
                })
                .OrderByDescending(x => x.Amount)
                .ToListAsync();

            // Transform to Dto
            // Note: In real app, join with Users table to get Nickname
            return ranking.Select((r, index) => new TeamRankingDto
            {
                Rank = index + 1,
                Name = r.Owner == "admin" ? "超级管理员" : r.Owner,
                Amount = r.Amount,
                Rate = 0 // Target not defined per user yet
            }).ToList();
        }

        // --- Targets ---

        public async Task<SalesTargetResultDto> GetSalesTargetsAsync(SalesTargetSearchParams searchParams)
        {
            // Auto-seed if empty
            if (!await _context.SalesTargets.AnyAsync())
            {
                await SeedSalesTargetsAsync();
            }

            var query = _context.SalesTargets.AsQueryable();

            if (!string.IsNullOrEmpty(searchParams.Period))
            {
                query = query.Where(t => t.Period == searchParams.Period);
            }
            
            // Calculate overview
            var totalTarget = await query.SumAsync(t => t.TargetAmount);
            var completedAmount = await query.SumAsync(t => t.CompletedAmount);
            var progressRate = totalTarget > 0 ? (completedAmount / totalTarget) * 100 : 0;
            
            var total = await query.CountAsync();
            var items = await query.OrderByDescending(t => t.CreatedAt)
                .Skip((searchParams.Page - 1) * searchParams.PageSize)
                .Take(searchParams.PageSize)
                .Select(t => new SalesTargetDto
                {
                    Id = t.Id,
                    Period = t.Period,
                    TargetType = t.TargetType,
                    TargetId = t.TargetId,
                    TargetName = t.TargetName,
                    TargetAmount = t.TargetAmount,
                    CompletedAmount = t.CompletedAmount,
                    Status = t.Status,
                    StartDate = t.StartDate,
                    EndDate = t.EndDate
                })
                .ToListAsync();

            // Mock remaining days for now
            var deadline = DateTime.Now.AddDays(45);
            
            return new SalesTargetResultDto
            {
                Overview = new SalesTargetOverviewDto
                {
                    TotalTarget = totalTarget,
                    CompletedAmount = completedAmount,
                    ProgressRate = Math.Round(progressRate, 1),
                    RemainingDays = (int)(deadline - DateTime.Now).TotalDays,
                    Deadline = deadline.ToString("yyyy-MM-dd")
                },
                Items = items,
                Total = total
            };
        }

        private async Task SeedSalesTargetsAsync()
        {
             var targets = new List<SalesTarget>();
             var random = new Random();
             var groups = new[] { "华东大区", "华北大区", "华南大区", "西南大区" };
             var products = new[] { "云服务", "大数据平台", "AI解决方案", "咨询服务" };
             var industries = new[] { "金融", "制造", "零售", "医疗" };

             // --- Quarter Data (Current) ---
             foreach (var group in groups)
             {
                 var target = 1000000 + random.Next(500) * 10000;
                 var completed = target * (random.NextDouble() * 0.8 + 0.1); 
                 targets.Add(new SalesTarget
                 {
                     Period = "quarter",
                     TargetType = "group",
                     TargetId = Guid.NewGuid().ToString("N"),
                     TargetName = group,
                     TargetAmount = target,
                     CompletedAmount = (decimal)completed,
                     Status = completed >= target ? "completed" : "in_progress",
                     StartDate = new DateTime(DateTime.Now.Year, 1, 1),
                     EndDate = new DateTime(DateTime.Now.Year, 3, 31)
                 });
             }

             foreach (var p in products)
             {
                 var target = 800000 + random.Next(300) * 10000;
                 var completed = target * (random.NextDouble() * 0.8 + 0.1); 
                 targets.Add(new SalesTarget
                 {
                     Period = "quarter",
                     TargetType = "product",
                     TargetId = Guid.NewGuid().ToString("N"),
                     TargetName = p,
                     TargetAmount = target,
                     CompletedAmount = (decimal)completed,
                     Status = completed >= target ? "completed" : "in_progress",
                     StartDate = new DateTime(DateTime.Now.Year, 1, 1),
                     EndDate = new DateTime(DateTime.Now.Year, 3, 31)
                 });
             }

             foreach (var i in industries)
             {
                 var target = 1200000 + random.Next(400) * 10000;
                 var completed = target * (random.NextDouble() * 0.8 + 0.1); 
                 targets.Add(new SalesTarget
                 {
                     Period = "quarter",
                     TargetType = "industry",
                     TargetId = Guid.NewGuid().ToString("N"),
                     TargetName = i,
                     TargetAmount = target,
                     CompletedAmount = (decimal)completed,
                     Status = completed >= target ? "completed" : "in_progress",
                     StartDate = new DateTime(DateTime.Now.Year, 1, 1),
                     EndDate = new DateTime(DateTime.Now.Year, 3, 31)
                 });
             }

             // --- Year Data ---
             foreach (var group in groups)
             {
                 var target = 4000000 + random.Next(2000) * 10000;
                 var completed = target * (random.NextDouble() * 0.3 + 0.1); // Early in year
                 targets.Add(new SalesTarget
                 {
                     Period = "year",
                     TargetType = "group",
                     TargetId = Guid.NewGuid().ToString("N"),
                     TargetName = group,
                     TargetAmount = target,
                     CompletedAmount = (decimal)completed,
                     Status = "in_progress",
                     StartDate = new DateTime(DateTime.Now.Year, 1, 1),
                     EndDate = new DateTime(DateTime.Now.Year, 12, 31)
                 });
             }
             
             // --- Month Data ---
             foreach (var group in groups)
             {
                 var target = 300000 + random.Next(100) * 10000;
                 var completed = target * (random.NextDouble() * 0.9 + 0.1); 
                 targets.Add(new SalesTarget
                 {
                     Period = "month",
                     TargetType = "group",
                     TargetId = Guid.NewGuid().ToString("N"),
                     TargetName = group,
                     TargetAmount = target,
                     CompletedAmount = (decimal)completed,
                     Status = completed >= target ? "completed" : "in_progress",
                     StartDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1),
                     EndDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, DateTime.DaysInMonth(DateTime.Now.Year, DateTime.Now.Month))
                 });
             }

             _context.SalesTargets.AddRange(targets);
             await _context.SaveChangesAsync();
        }
    }
}
