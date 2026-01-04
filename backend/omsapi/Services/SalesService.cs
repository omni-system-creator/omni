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

        public SalesService(OmsContext context)
        {
            _context = context;
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
                    new SalesScriptDto { Id = "1", Title = "初次接触话术", Content = "适用于电话或面谈初次接触客户...", Category = "General" },
                    new SalesScriptDto { Id = "2", Title = "产品介绍话术", Content = "针对不同痛点的产品价值阐述...", Category = "Product" }
                };
            }

            return await _context.SalesScripts.Select(s => new SalesScriptDto
            {
                Id = s.Id,
                Title = s.Title,
                Content = s.Content,
                Category = s.Category
            }).ToListAsync();
        }

        public async Task<List<ProductDocDto>> GetProductDocsAsync()
        {
            // Mock data or DB
             if (!await _context.SalesProductDocs.AnyAsync())
            {
                return new List<ProductDocDto>
                {
                    new ProductDocDto { Id = "1", Title = "产品白皮书.pdf", Size = "2.5MB", Url = "#", UploadDate = DateTime.Now },
                    new ProductDocDto { Id = "2", Title = "功能清单.pdf", Size = "1.2MB", Url = "#", UploadDate = DateTime.Now }
                };
            }

            return await _context.SalesProductDocs.Select(d => new ProductDocDto
            {
                Id = d.Id,
                Title = d.Title,
                Size = d.Size,
                Url = d.Url,
                UploadDate = d.UploadDate
            }).ToListAsync();
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
    }
}
