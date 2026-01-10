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
    public class SalesBidProjectService : ISalesBidProjectService
    {
        private readonly OmsContext _context;

        public SalesBidProjectService(OmsContext context)
        {
            _context = context;
        }

        public async Task<PagedResult<SalesBidProjectDto>> GetListAsync(int page, int pageSize, string? keyword = null, string? region = null, string? type = null, string? status = null)
        {
            var query = _context.SalesBidProjects.AsQueryable();

            if (!string.IsNullOrWhiteSpace(keyword))
            {
                query = query.Where(p => p.Name.Contains(keyword) || p.Code.Contains(keyword) || (p.Customer != null && p.Customer.Contains(keyword)));
            }

            if (!string.IsNullOrWhiteSpace(region))
            {
                query = query.Where(p => p.Region == region);
            }

            if (!string.IsNullOrWhiteSpace(type))
            {
                query = query.Where(p => p.Type == type);
            }

            if (!string.IsNullOrWhiteSpace(status))
            {
                query = query.Where(p => p.Status == status);
            }

            var total = await query.CountAsync();
            var items = await query
                .OrderByDescending(p => p.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(p => new SalesBidProjectDto
                {
                    Id = p.Id,
                    Code = p.Code,
                    Name = p.Name,
                    Customer = p.Customer,
                    Region = p.Region,
                    Type = p.Type,
                    Budget = p.Budget,
                    BidTime = p.BidTime,
                    Leader = p.Leader,
                    Status = p.Status,
                    Description = p.Description,
                    CreatedAt = p.CreatedAt,
                    UpdatedAt = p.UpdatedAt
                })
                .ToListAsync();

            return new PagedResult<SalesBidProjectDto>
            {
                Items = items,
                Total = total,
                Page = page,
                PageSize = pageSize
            };
        }

        public async Task<SalesBidProjectDto?> GetByIdAsync(string id)
        {
            var p = await _context.SalesBidProjects.FindAsync(id);
            if (p == null) return null;

            return new SalesBidProjectDto
            {
                Id = p.Id,
                Code = p.Code,
                Name = p.Name,
                Customer = p.Customer,
                Region = p.Region,
                Type = p.Type,
                Budget = p.Budget,
                BidTime = p.BidTime,
                Leader = p.Leader,
                Status = p.Status,
                Description = p.Description,
                CreatedAt = p.CreatedAt,
                UpdatedAt = p.UpdatedAt
            };
        }

        public async Task<SalesBidProjectDto> CreateAsync(CreateSalesBidProjectDto dto)
        {
            var entity = new SalesBidProject
            {
                Code = dto.Code,
                Name = dto.Name,
                Customer = dto.Customer,
                Region = dto.Region,
                Type = dto.Type,
                Budget = dto.Budget,
                BidTime = dto.BidTime,
                Leader = dto.Leader,
                Status = dto.Status ?? "进行中",
                Description = dto.Description
            };

            _context.SalesBidProjects.Add(entity);
            await _context.SaveChangesAsync();

            return await GetByIdAsync(entity.Id) ?? throw new Exception("Failed to create bid project");
        }

        public async Task<SalesBidProjectDto?> UpdateAsync(string id, UpdateSalesBidProjectDto dto)
        {
            var entity = await _context.SalesBidProjects.FindAsync(id);
            if (entity == null) return null;

            if (dto.Name != null) entity.Name = dto.Name;
            if (dto.Customer != null) entity.Customer = dto.Customer;
            if (dto.Region != null) entity.Region = dto.Region;
            if (dto.Type != null) entity.Type = dto.Type;
            if (dto.Budget != null) entity.Budget = dto.Budget;
            if (dto.BidTime.HasValue) entity.BidTime = dto.BidTime;
            if (dto.Leader != null) entity.Leader = dto.Leader;
            if (dto.Status != null) entity.Status = dto.Status;
            if (dto.Description != null) entity.Description = dto.Description;

            entity.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();

            return await GetByIdAsync(id);
        }

        public async Task<bool> DeleteAsync(string id)
        {
            var entity = await _context.SalesBidProjects.FindAsync(id);
            if (entity == null) return false;

            _context.SalesBidProjects.Remove(entity);
            await _context.SaveChangesAsync();
            return true;
        }
    }
}
