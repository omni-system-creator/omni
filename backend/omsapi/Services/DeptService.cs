using Microsoft.EntityFrameworkCore;
using omsapi.Data;
using omsapi.Infrastructure.Attributes;
using omsapi.Models.Dtos;
using omsapi.Models.Entities;
using omsapi.Services.Interfaces;

namespace omsapi.Services
{
    [AutoInject(ServiceLifetime.Scoped)]
    public class DeptService : IDeptService
    {
        private readonly OmsContext _context;

        public DeptService(OmsContext context)
        {
            _context = context;
        }

        public async Task<List<DeptTreeDto>> GetDeptTreeAsync()
        {
            var allDepts = await _context.Depts
                .OrderBy(d => d.SortOrder)
                .ToListAsync();

            var deptDtos = allDepts.Select(MapToTreeDto).ToList();
            return BuildTree(deptDtos, null);
        }

        private List<DeptTreeDto> BuildTree(List<DeptTreeDto> allDepts, long? parentId)
        {
            return allDepts
                .Where(d => d.ParentId == parentId)
                .Select(d => {
                    d.Children = BuildTree(allDepts, d.Id);
                    if (d.Children.Count == 0) d.Children = null;
                    return d;
                })
                .ToList();
        }

        public async Task<DeptTreeDto?> GetDeptByIdAsync(long id)
        {
            var dept = await _context.Depts.FindAsync(id);
            if (dept == null) return null;
            return MapToTreeDto(dept);
        }

        public async Task<DeptTreeDto> CreateDeptAsync(CreateDeptDto dto)
        {
            var dept = new SystemDept
            {
                ParentId = (dto.ParentId == 0) ? null : dto.ParentId,
                Name = dto.Name,
                Code = dto.Code,
                Type = dto.Type,
                Leader = dto.Leader,
                Phone = dto.Phone,
                Email = dto.Email,
                SortOrder = dto.SortOrder,
                IsActive = dto.IsActive,
                X = dto.X,
                Y = dto.Y,
                CreatedAt = DateTime.Now
            };

            _context.Depts.Add(dept);
            await _context.SaveChangesAsync();
            return MapToTreeDto(dept);
        }

        public async Task<bool> UpdateDeptAsync(long id, UpdateDeptDto dto)
        {
            var dept = await _context.Depts.FindAsync(id);
            if (dept == null) return false;

            if (dto.ParentId.HasValue && dto.ParentId.Value == id)
            {
                throw new ArgumentException("Cannot set parent to self");
            }

            if (dto.ParentId.HasValue) 
            {
                dept.ParentId = (dto.ParentId.Value == 0) ? null : dto.ParentId.Value;
            }
            
            if (dto.Name != null) dept.Name = dto.Name;
            if (dto.Code != null) dept.Code = dto.Code;
            if (dto.Type.HasValue) dept.Type = dto.Type.Value;
            if (dto.Leader != null) dept.Leader = dto.Leader;
            if (dto.Phone != null) dept.Phone = dto.Phone;
            if (dto.Email != null) dept.Email = dto.Email;
            if (dto.SortOrder != null) dept.SortOrder = dto.SortOrder.Value;
            if (dto.IsActive != null) dept.IsActive = dto.IsActive.Value;
            
            if (dto.X != null) dept.X = dto.X.Value;
            if (dto.Y != null) dept.Y = dto.Y.Value;

            dept.UpdatedAt = DateTime.Now;
            
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> DeleteDeptAsync(long id)
        {
            var dept = await _context.Depts
                .Include(d => d.Children)
                .Include(d => d.Users)
                .FirstOrDefaultAsync(d => d.Id == id);

            if (dept == null) return false;

            if (dept.Children.Any())
            {
                throw new InvalidOperationException("Cannot delete department with sub-departments.");
            }

            if (dept.Users.Any())
            {
                throw new InvalidOperationException("Cannot delete department with users.");
            }

            _context.Depts.Remove(dept);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> BatchUpdateStructureAsync(List<UpdateDeptStructureDto> dtos)
        {
             using var transaction = await _context.Database.BeginTransactionAsync();
             try
             {
                 foreach (var item in dtos)
                 {
                     var dept = await _context.Depts.FindAsync(item.Id);
                     if (dept != null)
                     {
                         dept.ParentId = (item.ParentId == 0) ? null : item.ParentId;
                         dept.SortOrder = item.SortOrder;
                         dept.UpdatedAt = DateTime.Now;
                     }
                 }
                 await _context.SaveChangesAsync();
                 await transaction.CommitAsync();
                 return true;
             }
             catch
             {
                 await transaction.RollbackAsync();
                 throw;
             }
        }

        private DeptTreeDto MapToTreeDto(SystemDept dept)
        {
            return new DeptTreeDto
            {
                Id = dept.Id,
                ParentId = dept.ParentId == 0 ? null : dept.ParentId,
                Name = dept.Name,
                Code = dept.Code,
                Type = dept.Type,
                Leader = dept.Leader,
                Phone = dept.Phone,
                Email = dept.Email,
                SortOrder = dept.SortOrder,
                IsActive = dept.IsActive,
                X = dept.X,
                Y = dept.Y,
                CreatedAt = dept.CreatedAt
            };
        }
    }
}
