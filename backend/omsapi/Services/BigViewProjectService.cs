using Microsoft.EntityFrameworkCore;
using omsapi.Data;
using omsapi.Infrastructure.Attributes;
using omsapi.Models.Dtos.BigView;
using omsapi.Models.Entities.BigView;
using omsapi.Services.Interfaces;
using System.Text.Json;

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
            
            query = query.Where(p => p.IsDelete != "1");

            var total = await query.CountAsync();
            var entities = await query.OrderBy(p => p.CreateTime)
                                   .Skip((page - 1) * limit)
                                   .Take(limit)
                                   .ToListAsync();

            var items = entities.Select(p => new BigViewProjectDto
            {
                Id = p.Id,
                ProjectName = p.ProjectName,
                State = p.State,
                CreateTime = p.CreateTime,
                CreateBy = p.CreateBy,
                IsDelete = p.IsDelete,
                IndexImage = p.IndexImage,
                // List view usually doesn't need full content, setting to null to save bandwidth
                Content = null, 
                Remarks = p.Remarks
            }).ToList();

            return (true, "Success", items, total);
        }

        public async Task<(bool Success, string Message, BigViewProjectDto? Data)> GetByIdAsync(long id)
        {
            var p = await _context.BigViewProjects.FindAsync(id);
            if (p == null || p.IsDelete == "1")
            {
                return (false, "Project not found", null);
            }

            object? contentObj = null;
            if (!string.IsNullOrEmpty(p.Content))
            {
                try
                {
                    contentObj = JsonSerializer.Deserialize<object>(p.Content);
                }
                catch
                {
                    contentObj = p.Content; // Fallback to string if not valid JSON
                }
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
                Content = contentObj,
                Remarks = p.Remarks
            };

            return (true, "Success", dto);
        }

        public async Task<(bool Success, string Message, long Id)> CreateAsync(CreateBigViewProjectDto dto, long userId)
        {
            var user = await _context.Users.FindAsync(userId);
            string createBy = user?.Nickname ?? user?.Username ?? userId.ToString();

            string? contentStr = null;
            if (dto.Content != null)
            {
                 if (dto.Content is string strContent)
                 {
                     contentStr = strContent;
                 }
                 else if (dto.Content is JsonElement jsonElement && jsonElement.ValueKind == JsonValueKind.String)
                 {
                     contentStr = jsonElement.GetString();
                 }
                 else
                 {
                     contentStr = JsonSerializer.Serialize(dto.Content);
                 }
            }

            var entity = new BigViewProject
            {
                ProjectName = dto.ProjectName,
                State = dto.State ?? "0", // Default to unreleased
                CreateTime = DateTime.Now,
                CreateBy = createBy,
                IsDelete = "0",
                IndexImage = dto.IndexImage,
                Content = contentStr,
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
            
            if (dto.Content != null)
            {
                 entity.Content = JsonSerializer.Serialize(dto.Content);
            }
            
            if (dto.Remarks != null) entity.Remarks = dto.Remarks;

            await _context.SaveChangesAsync();
            return (true, "Updated successfully");
        }

        public async Task<(bool Success, string Message)> DeleteAsync(string ids)
        {
            if (string.IsNullOrEmpty(ids))
            {
                return (false, "IDs cannot be empty");
            }

            var idList = new List<long>();
            foreach (var idStr in ids.Split(','))
            {
                if (long.TryParse(idStr, out var id))
                {
                    idList.Add(id);
                }
            }

            if (!idList.Any())
            {
                return (false, "No valid IDs provided");
            }

            var entities = await _context.BigViewProjects
                                         .Where(p => idList.Contains(p.Id))
                                         .ToListAsync();

            if (!entities.Any())
            {
                return (false, "Projects not found");
            }

            foreach (var entity in entities)
            {
                entity.IsDelete = "1";
            }

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
