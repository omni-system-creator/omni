using Microsoft.EntityFrameworkCore;
using omsapi.Data;
using omsapi.Models.Dtos.System;
using omsapi.Models.Entities.Dict;
using omsapi.Services.Interfaces;
using omsapi.Infrastructure.Attributes;

namespace omsapi.Services
{
    [AutoInject(ServiceLifetime.Scoped)]
    public class DictService : IDictService
    {
        private readonly OmsContext _context;

        public DictService(OmsContext context)
        {
            _context = context;
        }

        // --- Category ---

        public async Task<List<DictCategoryDto>> GetCategoryTreeAsync()
        {
            var categories = await _context.DictCategories
                .OrderBy(c => c.Sort)
                .ToListAsync();

            var dtos = categories.Select(MapToDto).ToList();
            return BuildCategoryTree(dtos, null);
        }

        private List<DictCategoryDto> BuildCategoryTree(List<DictCategoryDto> all, long? parentId)
        {
            return all.Where(c => c.ParentId == parentId)
                .Select(c => {
                    c.Children = BuildCategoryTree(all, c.Id);
                    return c;
                })
                .ToList();
        }

        public async Task<DictCategoryDto?> GetCategoryAsync(long id)
        {
            var entity = await _context.DictCategories.FindAsync(id);
            return entity == null ? null : MapToDto(entity);
        }

        public async Task<DictCategoryDto> CreateCategoryAsync(CreateDictCategoryDto dto)
        {
            var entity = new SysDictCategory
            {
                ParentId = dto.ParentId,
                Name = dto.Name,
                Code = dto.Code,
                Sort = dto.Sort,
                Remark = dto.Remark,
                CreatedAt = DateTime.Now
            };
            _context.DictCategories.Add(entity);
            await _context.SaveChangesAsync();
            return MapToDto(entity);
        }

        public async Task<DictCategoryDto?> UpdateCategoryAsync(long id, UpdateDictCategoryDto dto)
        {
            var entity = await _context.DictCategories.FindAsync(id);
            if (entity == null) return null;

            entity.Name = dto.Name;
            entity.Code = dto.Code;
            entity.Sort = dto.Sort;
            entity.Remark = dto.Remark;
            entity.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();
            return MapToDto(entity);
        }

        public async Task<bool> DeleteCategoryAsync(long id)
        {
            var entity = await _context.DictCategories.FindAsync(id);
            if (entity == null) return false;

            // Check if has children or types? 
            // For now, let's just delete or restrict. 
            // Restrict is safer.
            if (await _context.DictCategories.AnyAsync(c => c.ParentId == id))
                throw new InvalidOperationException("Cannot delete category with sub-categories.");
            
            if (await _context.DictTypes.AnyAsync(t => t.CategoryId == id))
                throw new InvalidOperationException("Cannot delete category with dictionary types.");

            _context.DictCategories.Remove(entity);
            await _context.SaveChangesAsync();
            return true;
        }

        // --- Type ---

        public async Task<List<DictTypeDto>> GetTypesAsync(long? categoryId = null, string? name = null, string? code = null)
        {
            var query = _context.DictTypes.AsQueryable();

            if (categoryId.HasValue)
                query = query.Where(t => t.CategoryId == categoryId);
            
            if (!string.IsNullOrWhiteSpace(name))
                query = query.Where(t => t.Name.Contains(name));

            if (!string.IsNullOrWhiteSpace(code))
                query = query.Where(t => t.Code.Contains(code));

            var list = await query.OrderByDescending(t => t.CreatedAt).ToListAsync();
            return list.Select(MapToDto).ToList();
        }

        public async Task<DictTypeDto?> GetTypeAsync(long id)
        {
            var entity = await _context.DictTypes.FindAsync(id);
            return entity == null ? null : MapToDto(entity);
        }

        public async Task<DictTypeDto?> GetTypeByCodeAsync(string code)
        {
            var entity = await _context.DictTypes.FirstOrDefaultAsync(t => t.Code == code);
            return entity == null ? null : MapToDto(entity);
        }

        public async Task<DictTypeDto> CreateTypeAsync(CreateDictTypeDto dto)
        {
            // Check code unique
            if (await _context.DictTypes.AnyAsync(t => t.Code == dto.Code))
                throw new InvalidOperationException($"Dictionary Type Code '{dto.Code}' already exists.");

            var entity = new SysDictType
            {
                CategoryId = dto.CategoryId,
                Name = dto.Name,
                Code = dto.Code,
                Status = dto.Status,
                Remark = dto.Remark,
                CreatedAt = DateTime.Now
            };
            _context.DictTypes.Add(entity);
            await _context.SaveChangesAsync();
            return MapToDto(entity);
        }

        public async Task<DictTypeDto?> UpdateTypeAsync(long id, UpdateDictTypeDto dto)
        {
            var entity = await _context.DictTypes.FindAsync(id);
            if (entity == null) return null;

            if (entity.Code != dto.Code && await _context.DictTypes.AnyAsync(t => t.Code == dto.Code))
                 throw new InvalidOperationException($"Dictionary Type Code '{dto.Code}' already exists.");

            entity.CategoryId = dto.CategoryId;
            entity.Name = dto.Name;
            entity.Code = dto.Code;
            entity.Status = dto.Status;
            entity.Remark = dto.Remark;
            entity.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();
            return MapToDto(entity);
        }

        public async Task<bool> DeleteTypeAsync(long id)
        {
            var entity = await _context.DictTypes.FindAsync(id);
            if (entity == null) return false;

            // Delete datas? Or restrict?
            // Usually cascade delete or restrict. Let's delete datas for convenience or restrict.
            // Restrict safer.
            // But user might want to delete a type and all its data.
            // Let's delete datas.
            var datas = await _context.DictDatas.Where(d => d.DictTypeId == id).ToListAsync();
            _context.DictDatas.RemoveRange(datas);

            _context.DictTypes.Remove(entity);
            await _context.SaveChangesAsync();
            return true;
        }

        // --- Data ---

        public async Task<List<DictDataDto>> GetDataListAsync(long? typeId = null, string? typeCode = null)
        {
            var query = _context.DictDatas.AsQueryable();

            if (typeId.HasValue)
                query = query.Where(d => d.DictTypeId == typeId);
            else if (!string.IsNullOrWhiteSpace(typeCode))
            {
                var type = await _context.DictTypes.FirstOrDefaultAsync(t => t.Code == typeCode);
                if (type != null)
                    query = query.Where(d => d.DictTypeId == type.Id);
                else
                    return new List<DictDataDto>();
            }

            var list = await query.OrderBy(d => d.Sort).ToListAsync();
            return list.Select(MapToDto).ToList();
        }

        public async Task<DictDataDto?> GetDataAsync(long id)
        {
            var entity = await _context.DictDatas.FindAsync(id);
            return entity == null ? null : MapToDto(entity);
        }

        public async Task<DictDataDto> CreateDataAsync(CreateDictDataDto dto)
        {
            var entity = new SysDictData
            {
                DictTypeId = dto.DictTypeId,
                Label = dto.Label,
                Value = dto.Value,
                Sort = dto.Sort,
                Status = dto.Status,
                IsDefault = dto.IsDefault,
                CssClass = dto.CssClass,
                ListClass = dto.ListClass,
                Remark = dto.Remark,
                CreatedAt = DateTime.Now
            };
            _context.DictDatas.Add(entity);
            await _context.SaveChangesAsync();
            return MapToDto(entity);
        }

        public async Task<DictDataDto?> UpdateDataAsync(long id, UpdateDictDataDto dto)
        {
            var entity = await _context.DictDatas.FindAsync(id);
            if (entity == null) return null;

            entity.Label = dto.Label;
            entity.Value = dto.Value;
            entity.Sort = dto.Sort;
            entity.Status = dto.Status;
            entity.IsDefault = dto.IsDefault;
            entity.CssClass = dto.CssClass;
            entity.ListClass = dto.ListClass;
            entity.Remark = dto.Remark;
            entity.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();
            return MapToDto(entity);
        }

        public async Task<bool> DeleteDataAsync(long id)
        {
            var entity = await _context.DictDatas.FindAsync(id);
            if (entity == null) return false;

            _context.DictDatas.Remove(entity);
            await _context.SaveChangesAsync();
            return true;
        }

        // --- Mappers ---

        private static DictCategoryDto MapToDto(SysDictCategory entity)
        {
            return new DictCategoryDto
            {
                Id = entity.Id,
                ParentId = entity.ParentId,
                Name = entity.Name,
                Code = entity.Code,
                Sort = entity.Sort,
                Remark = entity.Remark,
                CreatedAt = entity.CreatedAt
            };
        }

        private static DictTypeDto MapToDto(SysDictType entity)
        {
            return new DictTypeDto
            {
                Id = entity.Id,
                CategoryId = entity.CategoryId,
                Name = entity.Name,
                Code = entity.Code,
                Status = entity.Status,
                Remark = entity.Remark,
                CreatedAt = entity.CreatedAt
            };
        }

        private static DictDataDto MapToDto(SysDictData entity)
        {
            return new DictDataDto
            {
                Id = entity.Id,
                DictTypeId = entity.DictTypeId,
                Label = entity.Label,
                Value = entity.Value,
                Sort = entity.Sort,
                Status = entity.Status,
                IsDefault = entity.IsDefault,
                CssClass = entity.CssClass,
                ListClass = entity.ListClass,
                Remark = entity.Remark
            };
        }
    }
}
