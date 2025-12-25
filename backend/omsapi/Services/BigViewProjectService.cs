using Microsoft.EntityFrameworkCore;
using omsapi.Data;
using omsapi.Infrastructure.Attributes;
using omsapi.Models.Dtos.BigView;
using omsapi.Models.Entities.BigView;
using omsapi.Services.Interfaces;

namespace omsapi.Services
{
    [AutoInject(ServiceLifetime.Scoped)]
    public class BigViewProjectService : IBigViewProjectService
    {
        private readonly OmsContext _context;

        public BigViewProjectService(OmsContext context)
        {
            _context = context;
        }

        public async Task<(bool Success, string Message, IEnumerable<BigViewProjectDto>? Data, int Total)> GetListAsync(int page, int limit, string? keyword)
        {
            var query = _context.BigViewProjects.AsQueryable();

            if (!string.IsNullOrEmpty(keyword))
            {
                query = query.Where(p => p.ProjectName != null && p.ProjectName.Contains(keyword));
            }
            
            // Filter out deleted items if needed. The SQL says `is_delete` varchar(1).
            // Usually '1' means deleted, '0' or null means not deleted.
            // Let's assume '1' is deleted.
            query = query.Where(p => p.IsDelete != "1");

            var total = await query.CountAsync();
            var items = await query.OrderByDescending(p => p.CreateTime)
                                   .Skip((page - 1) * limit)
                                   .Take(limit)
                                   .Select(p => new BigViewProjectDto
                                   {
                                       Id = p.Id,
                                       ProjectName = p.ProjectName,
                                       State = p.State,
                                       CreateTime = p.CreateTime,
                                       CreateBy = p.CreateBy,
                                       IsDelete = p.IsDelete,
                                       IndexImage = p.IndexImage,
                                       Content = p.Content,
                                       Remarks = p.Remarks
                                   })
                                   .ToListAsync();

            return (true, "Success", items, total);
        }

        public async Task<(bool Success, string Message, BigViewProjectDto? Data)> GetByIdAsync(long id)
        {
            var p = await _context.BigViewProjects.FindAsync(id);
            if (p == null || p.IsDelete == "1")
            {
                return (false, "Project not found", null);
            }

            var dto = new BigViewProjectDto
            {
                Id = p.Id,
                ProjectName = p.ProjectName,
                State = p.State,
                CreateTime = p.CreateTime,
                CreateBy = p.CreateBy,
                IsDelete = p.IsDelete,
                IndexImage = p.IndexImage,
                Content = p.Content,
                Remarks = p.Remarks
            };

            return (true, "Success", dto);
        }

        public async Task<(bool Success, string Message, long Id)> CreateAsync(CreateBigViewProjectDto dto, long userId)
        {
            // Fetch user name if possible, or just use userId as placeholder if we don't have user info handy
            // For now, let's assume we can get user name from somewhere else or just store string
            var user = await _context.Users.FindAsync(userId);
            string createBy = user?.Nickname ?? user?.Username ?? userId.ToString();

            var entity = new BigViewProject
            {
                ProjectName = dto.ProjectName,
                State = dto.State ?? "-1", // Default to unreleased
                CreateTime = DateTime.Now,
                CreateBy = createBy,
                IsDelete = "0",
                IndexImage = dto.IndexImage,
                Content = dto.Content,
                Remarks = dto.Remarks
            };

            _context.BigViewProjects.Add(entity);
            await _context.SaveChangesAsync();

            return (true, "Created successfully", entity.Id);
        }

        public async Task<(bool Success, string Message)> UpdateAsync(UpdateBigViewProjectDto dto)
        {
            var entity = await _context.BigViewProjects.FindAsync(dto.Id);
            if (entity == null || entity.IsDelete == "1")
            {
                return (false, "Project not found");
            }

            if (dto.ProjectName != null) entity.ProjectName = dto.ProjectName;
            if (dto.State != null) entity.State = dto.State;
            if (dto.IndexImage != null) entity.IndexImage = dto.IndexImage;
            if (dto.Content != null) entity.Content = dto.Content;
            if (dto.Remarks != null) entity.Remarks = dto.Remarks;

            await _context.SaveChangesAsync();
            return (true, "Updated successfully");
        }

        public async Task<(bool Success, string Message)> DeleteAsync(long id)
        {
            var entity = await _context.BigViewProjects.FindAsync(id);
            if (entity == null)
            {
                return (false, "Project not found");
            }

            // Soft delete
            entity.IsDelete = "1";
            await _context.SaveChangesAsync();
            return (true, "Deleted successfully");
        }

        public async Task<(bool Success, string Message)> ChangeReleaseStateAsync(long id, string state)
        {
            var entity = await _context.BigViewProjects.FindAsync(id);
            if (entity == null || entity.IsDelete == "1")
            {
                return (false, "Project not found");
            }

            entity.State = state;
            await _context.SaveChangesAsync();
            return (true, "State updated successfully");
        }
    }
}
