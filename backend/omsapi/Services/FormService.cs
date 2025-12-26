using Microsoft.EntityFrameworkCore;
using omsapi.Data;
using omsapi.Models.Dtos.Forms;
using omsapi.Models.Entities.Forms;
using omsapi.Services.Interfaces;
using omsapi.Infrastructure.Attributes;
using omsapi.Models.Common;

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

        private void GetDescendantCategoryIds(List<FormCategory> allCategories, long parentId, List<long> result)
        {
            var children = allCategories.Where(c => c.ParentId == parentId);
            foreach (var child in children)
            {
                result.Add(child.Id);
                GetDescendantCategoryIds(allCategories, child.Id, result);
            }
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
        public async Task<PagedResult<FormDefinitionDto>> GetFormsAsync(long? categoryId = null, string? sortBy = null, bool isDescending = true, int page = 1, int pageSize = 10)
        {
            var query = _context.FormDefinitions.AsQueryable();

            if (categoryId.HasValue)
            {
                var allCategories = await _context.FormCategories.ToListAsync();
                var categoryIds = new List<long> { categoryId.Value };
                GetDescendantCategoryIds(allCategories, categoryId.Value, categoryIds);

                query = query.Where(f => categoryIds.Contains(f.CategoryId));
            }

            // Sorting
            if (string.IsNullOrEmpty(sortBy))
            {
                // Default sort by UpdatedAt descending as requested
                query = query.OrderByDescending(f => f.UpdatedAt);
            }
            else
            {
                switch (sortBy.ToLower())
                {
                    case "name":
                        query = isDescending ? query.OrderByDescending(f => f.Name) : query.OrderBy(f => f.Name);
                        break;
                    case "createdat":
                        query = isDescending ? query.OrderByDescending(f => f.CreatedAt) : query.OrderBy(f => f.CreatedAt);
                        break;
                    case "updatedat":
                        query = isDescending ? query.OrderByDescending(f => f.UpdatedAt) : query.OrderBy(f => f.UpdatedAt);
                        break;
                    default:
                        query = isDescending ? query.OrderByDescending(f => f.UpdatedAt) : query.OrderBy(f => f.UpdatedAt);
                        break;
                }
            }

            var total = await query.CountAsync();
            var items = await query
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(f => new FormDefinitionDto
                {
                    Id = f.Id,
                    CategoryId = f.CategoryId,
                    Name = f.Name,
                    Code = f.Code,
                    Description = f.Description,
                    FormItems = f.FormItems,
                    IsPublished = f.IsPublished,
                    RequiresLogin = f.RequiresLogin,
                    LimitOnePerUser = f.LimitOnePerUser,
                    CreatedAt = f.CreatedAt,
                    UpdatedAt = f.UpdatedAt
                })
                .ToListAsync();

            return new PagedResult<FormDefinitionDto>(items, total, page, pageSize);
        }

        public async Task<FormDefinitionDto?> GetFormByIdAsync(long id, string? submittedBy = null)
        {
            var f = await _context.FormDefinitions.FindAsync(id);
            if (f == null) return null;

            bool hasSubmitted = false;
            string? submittedData = null;
            if (f.LimitOnePerUser && !string.IsNullOrEmpty(submittedBy))
            {
                var submission = await _context.FormResults
                    .Where(r => r.FormId == id && r.SubmittedBy == submittedBy)
                    .OrderByDescending(r => r.SubmittedAt)
                    .FirstOrDefaultAsync();

                if (submission != null)
                {
                    hasSubmitted = true;
                    submittedData = submission.Data;
                }
            }

            return new FormDefinitionDto
            {
                Id = f.Id,
                CategoryId = f.CategoryId,
                Name = f.Name,
                Code = f.Code,
                Description = f.Description,
                FormItems = f.FormItems,
                IsPublished = f.IsPublished,
                RequiresLogin = f.RequiresLogin,
                LimitOnePerUser = f.LimitOnePerUser,
                HasSubmitted = hasSubmitted,
                SubmittedData = submittedData,
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
                RequiresLogin = dto.RequiresLogin,
                LimitOnePerUser = dto.LimitOnePerUser,
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
                RequiresLogin = form.RequiresLogin,
                LimitOnePerUser = form.LimitOnePerUser,
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
            if (dto.FormItems != null)
            {
                form.FormItems = dto.FormItems;
            }
            form.RequiresLogin = dto.RequiresLogin;
            form.LimitOnePerUser = dto.LimitOnePerUser;
            if (dto.IsPublished.HasValue)
            {
                form.IsPublished = dto.IsPublished.Value;
            }
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
                RequiresLogin = form.RequiresLogin,
                LimitOnePerUser = form.LimitOnePerUser,
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

        // Form Submission
        public async Task<FormResultDto> SubmitFormAsync(CreateFormResultDto dto)
        {
            var form = await _context.FormDefinitions.FindAsync(dto.FormId);
            if (form == null)
            {
                throw new Exception("表单不存在");
            }
            if (!form.IsPublished)
            {
                throw new Exception("表单未发布或已停止收集");
            }

            if (form.LimitOnePerUser)
            {
                // If SubmittedBy is "Anonymous", we can't really limit unless we use IP or something, 
                // but usually LimitOnePerUser implies RequiresLogin.
                // Assuming SubmittedBy is unique per user (e.g. username).
                bool hasSubmitted = await _context.FormResults.AnyAsync(r => r.FormId == dto.FormId && r.SubmittedBy == dto.SubmittedBy);
                if (hasSubmitted)
                {
                    throw new Exception("您已填写过此表单，不可重复提交");
                }
            }

            var result = new FormResult
            {
                FormId = dto.FormId,
                Data = dto.Data,
                SubmittedBy = dto.SubmittedBy,
                SubmittedAt = DateTime.Now
            };
            _context.FormResults.Add(result);
            await _context.SaveChangesAsync();

            return new FormResultDto
            {
                Id = result.Id,
                FormId = result.FormId,
                Data = result.Data,
                SubmittedBy = result.SubmittedBy,
                SubmittedAt = result.SubmittedAt
            };
        }

        public async Task<PagedResult<FormResultDto>> GetFormResultsAsync(long formId, int page = 1, int pageSize = 10)
        {
            var query = _context.FormResults
                .Where(r => r.FormId == formId);

            var total = await query.CountAsync();

            var items = await query
                .OrderByDescending(r => r.SubmittedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(r => new FormResultDto
                {
                    Id = r.Id,
                    FormId = r.FormId,
                    Data = r.Data,
                    SubmittedBy = r.SubmittedBy,
                    SubmittedAt = r.SubmittedAt
                })
                .ToListAsync();

            return new PagedResult<FormResultDto>
            {
                Items = items,
                Total = total,
                Page = page,
                PageSize = pageSize
            };
        }
    }
}
