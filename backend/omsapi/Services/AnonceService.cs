using Microsoft.EntityFrameworkCore;
using omsapi.Data;
using omsapi.Infrastructure.Attributes;
using omsapi.Models.Common;
using omsapi.Models.Dtos.System;
using omsapi.Models.Entities.System;
using omsapi.Services.Interfaces;

namespace omsapi.Services
{
    [AutoInject(ServiceLifetime.Scoped)]
    public class AnonceService : IAnonceService
    {
        private readonly OmsContext _context;

        public AnonceService(OmsContext context)
        {
            _context = context;
        }

        public async Task<PagedResult<AnonceDto>> GetListAsync(AnonceQueryDto query)
        {
            var dbQuery = _context.Anonces.AsQueryable();

            if (!string.IsNullOrEmpty(query.Title))
            {
                dbQuery = dbQuery.Where(x => x.Title.Contains(query.Title));
            }
            if (!string.IsNullOrEmpty(query.Type))
            {
                dbQuery = dbQuery.Where(x => x.Type == query.Type);
            }
            if (!string.IsNullOrEmpty(query.Status))
            {
                dbQuery = dbQuery.Where(x => x.Status == query.Status);
            }

            var total = await dbQuery.CountAsync();
            var items = await dbQuery
                .OrderByDescending(x => x.CreatedAt)
                .Skip((query.Page - 1) * query.PageSize)
                .Take(query.PageSize)
                .Select(x => new AnonceDto
                {
                    Id = x.Id,
                    Title = x.Title,
                    // Content is too large for list view
                    Type = x.Type,
                    Status = x.Status,
                    Priority = x.Priority,
                    PublishTime = x.PublishTime,
                    CreatedAt = x.CreatedAt,
                    UpdatedAt = x.UpdatedAt,
                    CreatedBy = x.CreatedBy
                })
                .ToListAsync();

            return new PagedResult<AnonceDto>(items, total, query.Page, query.PageSize);
        }

        public async Task<AnonceDto?> GetByIdAsync(long id)
        {
            var entity = await _context.Anonces.FindAsync(id);
            if (entity == null) return null;

            return new AnonceDto
            {
                Id = entity.Id,
                Title = entity.Title,
                Content = entity.Content,
                Type = entity.Type,
                Status = entity.Status,
                Priority = entity.Priority,
                PublishTime = entity.PublishTime,
                CreatedAt = entity.CreatedAt,
                UpdatedAt = entity.UpdatedAt,
                CreatedBy = entity.CreatedBy
            };
        }

        public async Task<AnonceDto> CreateAsync(CreateAnonceDto dto, long userId)
        {
            var entity = new SystemAnonce
            {
                Title = dto.Title,
                Content = dto.Content,
                Type = dto.Type,
                Priority = dto.Priority ?? "normal",
                Status = "draft",
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow,
                CreatedBy = userId
            };

            _context.Anonces.Add(entity);
            await _context.SaveChangesAsync();

            return await GetByIdAsync(entity.Id) ?? throw new Exception("Failed to create anonce");
        }

        public async Task<AnonceDto?> UpdateAsync(long id, UpdateAnonceDto dto, long userId)
        {
            var entity = await _context.Anonces.FindAsync(id);
            if (entity == null) return null;

            if (dto.Title != null) entity.Title = dto.Title;
            if (dto.Content != null) entity.Content = dto.Content;
            if (dto.Type != null) entity.Type = dto.Type;
            if (dto.Priority != null) entity.Priority = dto.Priority;

            entity.UpdatedAt = DateTime.UtcNow;
            entity.UpdatedBy = userId;

            await _context.SaveChangesAsync();
            return await GetByIdAsync(id);
        }

        public async Task<bool> DeleteAsync(long id)
        {
            var entity = await _context.Anonces.FindAsync(id);
            if (entity == null) return false;

            _context.Anonces.Remove(entity);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> PublishAsync(long id, bool isPublish)
        {
            var entity = await _context.Anonces.FindAsync(id);
            if (entity == null) return false;

            entity.Status = isPublish ? "published" : "revoked";
            if (isPublish)
            {
                entity.PublishTime = DateTime.UtcNow;
            }
            entity.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return true;
        }
    }
}
