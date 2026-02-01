using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using omsapi.Data;
using omsapi.Infrastructure.Attributes;
using omsapi.Models.Dtos;
using omsapi.Models.Entities.Finance;
using System.Security.Claims;

using omsapi.Services.Interfaces;

namespace omsapi.Services
{
    [AutoInject(ServiceLifetime.Scoped)]
    public class FinanceSubjectService : IFinanceSubjectService
    {
        private readonly OmsContext _context;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public FinanceSubjectService(OmsContext context, IHttpContextAccessor httpContextAccessor)
        {
            _context = context;
            _httpContextAccessor = httpContextAccessor;
        }

        private async Task<long?> GetCurrentOrgIdAsync()
        {
            var userIdStr = _httpContextAccessor.HttpContext?.User?.FindFirst("id")?.Value;
            if (long.TryParse(userIdStr, out var userId))
            {
                var user = await _context.Users.FindAsync(userId);
                return user?.CurrentOrgId;
            }
            return null;
        }

        public async Task<List<FinanceSubjectDto>> GetSubjectsAsync(string? direction = null)
        {
            var orgId = await GetCurrentOrgIdAsync();
            var query = _context.FinanceSubjects.AsQueryable();
            
            // Filter by OrgId (Current Org OR Global System Subjects)
            if (orgId.HasValue)
            {
                query = query.Where(s => s.OrgId == orgId || (s.OrgId == null && s.IsSystem));
            }
            else
            {
                query = query.Where(s => s.OrgId == null);
            }

            if (!string.IsNullOrEmpty(direction))
            {
                query = query.Where(s => s.Direction == direction);
            }

            var list = await query.OrderBy(s => s.Code).ToListAsync();
            return list.Select(s => new FinanceSubjectDto
            {
                Id = s.Id,
                Code = s.Code,
                Name = s.Name,
                ParentId = s.ParentId,
                Direction = s.Direction,
                Description = s.Description,
                IsSystem = s.IsSystem,
                IsActive = s.IsActive,
                CreatedAt = s.CreatedAt
            }).ToList();
        }

        public async Task<(bool Success, string Message)> CreateSubjectAsync(CreateFinanceSubjectDto dto)
        {
            var orgId = await GetCurrentOrgIdAsync();

            if (await _context.FinanceSubjects.AnyAsync(s => s.Code == dto.Code && s.OrgId == orgId))
            {
                return (false, "科目编码已存在");
            }

            if (dto.ParentId.HasValue)
            {
                var parent = await _context.FinanceSubjects.FindAsync(dto.ParentId.Value);
                if (parent == null) return (false, "父级科目不存在");
                if (parent.OrgId != null && parent.OrgId != orgId) return (false, "无法选择其他组织的科目作为父级");
            }

            var subject = new FinanceSubject
            {
                Code = dto.Code,
                Name = dto.Name,
                ParentId = dto.ParentId,
                Direction = dto.Direction,
                Description = dto.Description,
                IsSystem = false,
                IsActive = true,
                OrgId = orgId,
                CreatedAt = DateTime.Now
            };

            _context.FinanceSubjects.Add(subject);
            await _context.SaveChangesAsync();
            return (true, "创建成功");
        }

        public async Task<(bool Success, string Message)> UpdateSubjectAsync(long id, UpdateFinanceSubjectDto dto)
        {
            var orgId = await GetCurrentOrgIdAsync();
            
            var subject = await _context.FinanceSubjects.FindAsync(id);
            if (subject == null) return (false, "科目不存在");
            
            if (subject.OrgId != orgId)
            {
                return (false, "无权修改此科目");
            }

            if (dto.ParentId.HasValue && dto.ParentId != subject.ParentId)
            {
                if (dto.ParentId == id) return (false, "不能选择自己作为父级");
                
                var parent = await _context.FinanceSubjects.FindAsync(dto.ParentId.Value);
                if (parent == null) return (false, "父级科目不存在");
            }

            subject.Name = dto.Name;
            subject.ParentId = dto.ParentId;
            subject.Direction = dto.Direction;
            subject.Description = dto.Description;
            subject.IsActive = dto.IsActive;
            subject.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();
            return (true, "更新成功");
        }

        public async Task<(bool Success, string Message)> DeleteSubjectAsync(long id)
        {
            var orgId = await GetCurrentOrgIdAsync();
            var subject = await _context.FinanceSubjects.FindAsync(id);
            if (subject == null) return (false, "科目不存在");
            
            if (subject.OrgId != orgId) return (false, "无权删除此科目");
            if (subject.IsSystem) return (false, "系统科目无法删除");

            if (await _context.FinanceApArs.AnyAsync(x => x.SubjectId == id))
            {
                return (false, "该科目已被使用，无法删除");
            }

            if (await _context.FinanceSubjects.AnyAsync(x => x.ParentId == id))
            {
                return (false, "该科目包含子科目，无法删除");
            }

            _context.FinanceSubjects.Remove(subject);
            await _context.SaveChangesAsync();
            return (true, "删除成功");
        }
    }
}
