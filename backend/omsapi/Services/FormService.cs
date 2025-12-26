using Microsoft.EntityFrameworkCore;
using omsapi.Data;
using omsapi.Models.Dtos.Forms;
using omsapi.Models.Entities.Forms;
using omsapi.Services.Interfaces;
using omsapi.Infrastructure.Attributes;

namespace omsapi.Services
{
    [AutoInject]
    public class FormService : IFormService
    {
        private readonly OmsContext _context;

        public FormService(OmsContext context)
        {
            _context = context;
        }

        // Category Methods
        public async Task<List<FormCategoryDto>> GetCategoryTreeAsync()
        {
            var categories = await _context.FormCategories
                .OrderBy(c => c.SortOrder)
                .ToListAsync();

            return BuildCategoryTree(categories, null);
        }

        private List<FormCategoryDto> BuildCategoryTree(List<FormCategory> allCategories, long? parentId)
        {
            return allCategories
                .Where(c => c.ParentId == parentId)
                .Select(c => new FormCategoryDto
                {
                    Id = c.Id,
                    Name = c.Name,
                    ParentId = c.ParentId,
                    SortOrder = c.SortOrder,
                    Children = BuildCategoryTree(allCategories, c.Id)
                })
                .ToList();
        }

        public async Task<FormCategoryDto?> GetCategoryByIdAsync(long id)
        {
            var category = await _context.FormCategories.FindAsync(id);
            if (category == null) return null;

            return new FormCategoryDto
            {
                Id = category.Id,
                Name = category.Name,
                ParentId = category.ParentId,
                SortOrder = category.SortOrder
            };
        }

        public async Task<FormCategoryDto> CreateCategoryAsync(CreateFormCategoryDto dto, long userId)
        {
            var category = new FormCategory
            {
                Name = dto.Name,
                ParentId = dto.ParentId,
                SortOrder = dto.SortOrder,
                CreatedBy = userId,
                CreatedAt = DateTime.Now
            };

            _context.FormCategories.Add(category);
            await _context.SaveChangesAsync();

            return new FormCategoryDto
            {
                Id = category.Id,
                Name = category.Name,
                ParentId = category.ParentId,
                SortOrder = category.SortOrder
            };
        }

        public async Task<FormCategoryDto?> UpdateCategoryAsync(long id, UpdateFormCategoryDto dto)
        {
            var category = await _context.FormCategories.FindAsync(id);
            if (category == null) return null;

            category.Name = dto.Name;
            category.SortOrder = dto.SortOrder;

            await _context.SaveChangesAsync();

            return new FormCategoryDto
            {
                Id = category.Id,
                Name = category.Name,
                ParentId = category.ParentId,
                SortOrder = category.SortOrder
            };
        }

        public async Task<bool> DeleteCategoryAsync(long id)
        {
            var category = await _context.FormCategories
                .Include(c => c.Children)
                .Include(c => c.Forms)
                .FirstOrDefaultAsync(c => c.Id == id);

            if (category == null) return false;

            if (category.Children.Any() || category.Forms.Any())
            {
                // Prevent deletion if it has children or forms
                // Or we could implement recursive delete, but usually better to block
                return false;
            }

            _context.FormCategories.Remove(category);
            await _context.SaveChangesAsync();
            return true;
        }

        // Form Definition Methods
        public async Task<List<FormDefinitionDto>> GetFormsAsync(long? categoryId = null)
        {
            var query = _context.FormDefinitions.AsQueryable();

            if (categoryId.HasValue)
            {
                query = query.Where(f => f.CategoryId == categoryId.Value);
            }

            return await query
                .OrderByDescending(f => f.CreatedAt)
                .Select(f => new FormDefinitionDto
                {
                    Id = f.Id,
                    CategoryId = f.CategoryId,
                    Name = f.Name,
                    Code = f.Code,
                    Description = f.Description,
                    FormItems = f.FormItems,
                    IsPublished = f.IsPublished,
                    CreatedAt = f.CreatedAt,
                    UpdatedAt = f.UpdatedAt
                })
                .ToListAsync();
        }

        public async Task<FormDefinitionDto?> GetFormByIdAsync(long id)
        {
            var f = await _context.FormDefinitions.FindAsync(id);
            if (f == null) return null;

            return new FormDefinitionDto
            {
                Id = f.Id,
                CategoryId = f.CategoryId,
                Name = f.Name,
                Code = f.Code,
                Description = f.Description,
                FormItems = f.FormItems,
                IsPublished = f.IsPublished,
                CreatedAt = f.CreatedAt,
                UpdatedAt = f.UpdatedAt
            };
        }

        public async Task<FormDefinitionDto> CreateFormAsync(CreateFormDefinitionDto dto, long userId)
        {
            var form = new FormDefinition
            {
                CategoryId = dto.CategoryId,
                Name = dto.Name,
                Code = dto.Code,
                Description = dto.Description,
                FormItems = dto.FormItems,
                IsPublished = false,
                CreatedBy = userId,
                CreatedAt = DateTime.Now,
                UpdatedAt = DateTime.Now
            };

            _context.FormDefinitions.Add(form);
            await _context.SaveChangesAsync();

            return new FormDefinitionDto
            {
                Id = form.Id,
                CategoryId = form.CategoryId,
                Name = form.Name,
                Code = form.Code,
                Description = form.Description,
                FormItems = form.FormItems,
                IsPublished = form.IsPublished,
                CreatedAt = form.CreatedAt,
                UpdatedAt = form.UpdatedAt
            };
        }

        public async Task<FormDefinitionDto?> UpdateFormAsync(long id, UpdateFormDefinitionDto dto, long userId)
        {
            var form = await _context.FormDefinitions.FindAsync(id);
            if (form == null) return null;

            form.CategoryId = dto.CategoryId;
            form.Name = dto.Name;
            form.Code = dto.Code;
            form.Description = dto.Description;
            form.FormItems = dto.FormItems;
            form.IsPublished = dto.IsPublished;
            form.UpdatedBy = userId;
            form.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();

            return new FormDefinitionDto
            {
                Id = form.Id,
                CategoryId = form.CategoryId,
                Name = form.Name,
                Code = form.Code,
                Description = form.Description,
                FormItems = form.FormItems,
                IsPublished = form.IsPublished,
                CreatedAt = form.CreatedAt,
                UpdatedAt = form.UpdatedAt
            };
        }

        public async Task<bool> DeleteFormAsync(long id)
        {
            var form = await _context.FormDefinitions.FindAsync(id);
            if (form == null) return false;

            _context.FormDefinitions.Remove(form);
            await _context.SaveChangesAsync();
            return true;
        }
    }
}
