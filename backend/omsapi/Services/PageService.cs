using Microsoft.EntityFrameworkCore;
using omsapi.Data;
using omsapi.Infrastructure.Attributes;
using omsapi.Models.Common;
using omsapi.Models.Dtos;
using omsapi.Models.Entities.Pages;
using omsapi.Services.Interfaces;

namespace omsapi.Services
{
    [AutoInject(ServiceLifetime.Scoped)]
    public class PageService : IPageService
    {
        private readonly OmsContext _context;

        public PageService(OmsContext context)
        {
            _context = context;
        }

        #region Categories

        public async Task<List<PageCategoryDto>> GetCategoriesAsync()
        {
            var categories = await _context.PageCategories
                .OrderBy(c => c.SortOrder)
                .ToListAsync();

            return BuildCategoryTree(categories, null);
        }

        private List<PageCategoryDto> BuildCategoryTree(List<PageCategory> allCategories, long? parentId)
        {
            return allCategories
                .Where(c => c.ParentId == parentId)
                .Select(c => new PageCategoryDto
                {
                    Id = c.Id,
                    Name = c.Name,
                    ParentId = c.ParentId,
                    SortOrder = c.SortOrder,
                    Children = BuildCategoryTree(allCategories, c.Id)
                })
                .ToList();
        }

        public async Task<PageCategoryDto?> CreateCategoryAsync(CreatePageCategoryDto dto)
        {
            var category = new PageCategory
            {
                Name = dto.Name,
                ParentId = dto.ParentId,
                SortOrder = dto.SortOrder
            };

            _context.PageCategories.Add(category);
            await _context.SaveChangesAsync();

            return new PageCategoryDto
            {
                Id = category.Id,
                Name = category.Name,
                ParentId = category.ParentId,
                SortOrder = category.SortOrder
            };
        }

        public async Task<PageCategoryDto?> UpdateCategoryAsync(long id, UpdatePageCategoryDto dto)
        {
            var category = await _context.PageCategories.FindAsync(id);
            if (category == null) return null;

            // Check for circular reference if ParentId is changed
            if (dto.ParentId.HasValue && dto.ParentId != category.ParentId)
            {
                if (dto.ParentId == id) return null; // Cannot be parent of itself
                
                // Deep check for circular dependency
                if (await IsCircularReferenceAsync(id, dto.ParentId.Value))
                {
                    return null;
                }
            }

            category.Name = dto.Name;
            category.ParentId = dto.ParentId; // Fix: Update ParentId
            category.SortOrder = dto.SortOrder;

            await _context.SaveChangesAsync();

            return new PageCategoryDto
            {
                Id = category.Id,
                Name = category.Name,
                ParentId = category.ParentId,
                SortOrder = category.SortOrder
            };
        }

        private async Task<bool> IsCircularReferenceAsync(long currentCategoryId, long newParentId)
        {
            var parentId = newParentId;
            while (true)
            {
                if (parentId == currentCategoryId) return true; // Found cycle

                var parent = await _context.PageCategories
                    .Where(c => c.Id == parentId)
                    .Select(c => new { c.ParentId })
                    .FirstOrDefaultAsync();

                if (parent == null || parent.ParentId == null) return false; // Reached root
                parentId = parent.ParentId.Value;
            }
        }

        public async Task<bool> DeleteCategoryAsync(long id)
        {
            var category = await _context.PageCategories.FindAsync(id);
            if (category == null) return false;

            // Check if has children
            var hasChildren = await _context.PageCategories.AnyAsync(c => c.ParentId == id);
            if (hasChildren) return false;

            // Check if has pages
            var hasPages = await _context.PageDefinitions.AnyAsync(p => p.CategoryId == id);
            if (hasPages) return false;

            _context.PageCategories.Remove(category);
            await _context.SaveChangesAsync();
            return true;
        }

        #endregion

        #region Pages

        private void GetDescendantIds(long parentId, List<PageCategory> allCategories, List<long> result)
        {
            result.Add(parentId);
            var children = allCategories.Where(c => c.ParentId == parentId);
            foreach (var child in children)
            {
                GetDescendantIds(child.Id, allCategories, result);
            }
        }

        public async Task<PagedResult<PageDefinitionDto>> GetPagesAsync(long? categoryId, string? keyword, int page, int pageSize)
        {
            var query = _context.PageDefinitions.AsQueryable();

            if (categoryId.HasValue)
            {
                var allCategories = await _context.PageCategories.ToListAsync();
                var categoryIds = new List<long>();
                GetDescendantIds(categoryId.Value, allCategories, categoryIds);
                query = query.Where(p => p.CategoryId.HasValue && categoryIds.Contains(p.CategoryId.Value));
            }

            if (!string.IsNullOrEmpty(keyword))
            {
                query = query.Where(p => p.Name.Contains(keyword) || (p.Description != null && p.Description.Contains(keyword)));
            }

            var total = await query.CountAsync();
            var items = await query
                .OrderByDescending(p => p.UpdatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(p => new PageDefinitionDto
                {
                    Id = p.Id,
                    Name = p.Name,
                    CategoryId = p.CategoryId,
                    Code = p.Code,
                    // Don't fetch Config/ApiBindings for list view to save bandwidth
                    Description = p.Description,
                    CreatedAt = p.CreatedAt,
                    UpdatedAt = p.UpdatedAt
                })
                .ToListAsync();

            return new PagedResult<PageDefinitionDto>(items, total, page, pageSize);
        }

        public async Task<PageDefinitionDto?> GetPageByIdAsync(long id)
        {
            var p = await _context.PageDefinitions.FindAsync(id);
            if (p == null) return null;

            return new PageDefinitionDto
            {
                Id = p.Id,
                Name = p.Name,
                CategoryId = p.CategoryId,
                Code = p.Code,
                Config = p.Config,
                ApiBindings = p.ApiBindings,
                Description = p.Description,
                CreatedAt = p.CreatedAt,
                UpdatedAt = p.UpdatedAt
            };
        }

        public async Task<PageDefinitionDto> CreatePageAsync(CreatePageDefinitionDto dto)
        {
            var page = new PageDefinition
            {
                Name = dto.Name,
                CategoryId = dto.CategoryId,
                Code = dto.Code,
                Config = dto.Config,
                ApiBindings = dto.ApiBindings,
                Description = dto.Description,
                CreatedAt = DateTime.Now,
                UpdatedAt = DateTime.Now
            };

            _context.PageDefinitions.Add(page);
            await _context.SaveChangesAsync();

            return await GetPageByIdAsync(page.Id) ?? throw new Exception("Failed to create page");
        }

        public async Task<PageDefinitionDto?> UpdatePageAsync(long id, UpdatePageDefinitionDto dto)
        {
            var page = await _context.PageDefinitions.FindAsync(id);
            if (page == null) return null;

            page.Name = dto.Name;
            page.CategoryId = dto.CategoryId;
            page.Code = dto.Code;
            page.Config = dto.Config;
            page.ApiBindings = dto.ApiBindings;
            page.Description = dto.Description;
            page.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();

            return await GetPageByIdAsync(id);
        }

        public async Task<bool> DeletePageAsync(long id)
        {
            var page = await _context.PageDefinitions.FindAsync(id);
            if (page == null) return false;

            _context.PageDefinitions.Remove(page);
            await _context.SaveChangesAsync();
            return true;
        }

        #endregion
    }
}
