using Microsoft.EntityFrameworkCore;
using omsapi.Data;
using omsapi.Models.Dtos;
using omsapi.Models.Entities.Interfaces;
using omsapi.Services.Interfaces;
using omsapi.Infrastructure.Attributes;
using omsapi.Models.Common;

namespace omsapi.Services
{
    [AutoInject]
    public class InterfaceService : IInterfaceService
    {
        private readonly OmsContext _context;
        private readonly IUserService _userService;

        public InterfaceService(OmsContext context, IUserService userService)
        {
            _context = context;
            _userService = userService;
        }

        // Category Methods
        public async Task<List<InterfaceCategoryDto>> GetCategoryTreeAsync()
        {
            var categories = await _context.InterfaceCategories
                .OrderBy(c => c.SortOrder)
                .ToListAsync();

            return BuildCategoryTree(categories, null);
        }

        private List<InterfaceCategoryDto> BuildCategoryTree(List<InterfaceCategory> allCategories, long? parentId)
        {
            return allCategories
                .Where(c => c.ParentId == parentId)
                .Select(c => new InterfaceCategoryDto
                {
                    Id = c.Id,
                    Name = c.Name,
                    UrlPrefix = c.UrlPrefix,
                    ParentId = c.ParentId,
                    SortOrder = c.SortOrder,
                    Children = BuildCategoryTree(allCategories, c.Id)
                })
                .ToList();
        }

        public async Task<InterfaceCategoryDto?> GetCategoryByIdAsync(long id)
        {
            var category = await _context.InterfaceCategories.FindAsync(id);
            if (category == null) return null;

            return new InterfaceCategoryDto
            {
                Id = category.Id,
                Name = category.Name,
                UrlPrefix = category.UrlPrefix,
                ParentId = category.ParentId,
                SortOrder = category.SortOrder
            };
        }

        public async Task<InterfaceCategoryDto> CreateCategoryAsync(CreateInterfaceCategoryDto dto, long userId)
        {
            var category = new InterfaceCategory
            {
                Name = dto.Name,
                UrlPrefix = dto.UrlPrefix,
                ParentId = dto.ParentId,
                SortOrder = dto.SortOrder,
                CreatedBy = userId,
                CreatedAt = DateTime.Now
            };

            _context.InterfaceCategories.Add(category);
            await _context.SaveChangesAsync();

            return new InterfaceCategoryDto
            {
                Id = category.Id,
                Name = category.Name,
                UrlPrefix = category.UrlPrefix,
                ParentId = category.ParentId,
                SortOrder = category.SortOrder
            };
        }

        public async Task<InterfaceCategoryDto?> UpdateCategoryAsync(long id, UpdateInterfaceCategoryDto dto)
        {
            var category = await _context.InterfaceCategories.FindAsync(id);
            if (category == null) return null;

            // Check for circular dependency
            if (dto.ParentId.HasValue && dto.ParentId.Value == id)
            {
                throw new Exception("Cannot set parent category to itself.");
            }
            if (dto.ParentId.HasValue)
            {
                // Check if new parent is a descendant of current category
                var allCategories = await _context.InterfaceCategories.ToListAsync();
                var descendants = new List<long>();
                GetDescendantCategoryIds(allCategories, id, descendants);
                if (descendants.Contains(dto.ParentId.Value))
                {
                    throw new Exception("Cannot set parent category to one of its descendants.");
                }
            }

            category.Name = dto.Name;
            category.UrlPrefix = dto.UrlPrefix;
            category.ParentId = dto.ParentId;
            category.SortOrder = dto.SortOrder;

            await _context.SaveChangesAsync();

            return new InterfaceCategoryDto
            {
                Id = category.Id,
                Name = category.Name,
                UrlPrefix = category.UrlPrefix,
                ParentId = category.ParentId,
                SortOrder = category.SortOrder
            };
        }

        public async Task<bool> DeleteCategoryAsync(long id)
        {
            var category = await _context.InterfaceCategories
                .Include(c => c.Children)
                .Include(c => c.Interfaces)
                .FirstOrDefaultAsync(c => c.Id == id);

            if (category == null) return false;

            if (category.Children.Any() || category.Interfaces.Any())
            {
                return false;
            }

            _context.InterfaceCategories.Remove(category);
            await _context.SaveChangesAsync();
            return true;
        }

        // Interface Methods
        public async Task<PagedResult<InterfaceDefinitionDto>> GetInterfacesAsync(long? categoryId = null, string? keyword = null, int page = 1, int pageSize = 10)
        {
            var query = _context.InterfaceDefinitions.AsQueryable();

            // Build full path map for all categories to avoid N+1 queries
            // In a large system, we might want to cache this or use CTE
            var allCategories = await _context.InterfaceCategories.ToListAsync();
            var categoryPathMap = BuildCategoryPathMap(allCategories);

            if (categoryId.HasValue)
            {
                // Recursive fetch of category IDs
                var categoryIds = new List<long> { categoryId.Value };
                GetDescendantCategoryIds(allCategories, categoryId.Value, categoryIds);

                query = query.Where(f => categoryIds.Contains(f.CategoryId));
            }

            if (!string.IsNullOrEmpty(keyword))
            {
                query = query.Where(f => f.Name.Contains(keyword) || f.Path.Contains(keyword));
            }

            query = query.OrderByDescending(f => f.UpdatedAt);

            var total = await query.CountAsync();
            
            // Fetch category names map
            var allCategoryNames = await _context.InterfaceCategories
                .ToDictionaryAsync(c => c.Id, c => c.Name);

            // Fetch category hierarchy for relative path calculation if needed
            // But requirement says: "show category name starting from current selected category"
            // If categoryId is null (All), show full category path? Or just direct category name?
            // User said: "Show relative category path starting from current selected category"
            // Let's build a map of Id -> RelativePath based on selected categoryId
            
            // To fix the client evaluation error, we should fetch raw data first, then map to DTO in memory.
            var rawItems = await query
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync(); // Fetch entities to memory

            var items = rawItems.Select(f => new InterfaceDefinitionDto
            {
                    Id = f.Id,
                    CategoryId = f.CategoryId,
                    Name = f.Name,
                    Path = f.Path,
                    // FullPath will be calculated below
                    Method = f.Method,
                    Description = f.Description,
                    FlowConfig = f.FlowConfig,
                    IsPublished = f.IsPublished,
                    RequiresAuth = f.RequiresAuth,
                    ViewRoles = ParseRoles(f.ViewRoles),
                    CallRoles = ParseRoles(f.CallRoles),
                    ManageRoles = ParseRoles(f.ManageRoles),
                    CreatedAt = f.CreatedAt,
                    UpdatedAt = f.UpdatedAt,
                    CreatedBy = f.CreatedBy,
                    UpdatedBy = f.UpdatedBy
            }).ToList();
            
            // Fill FullPath and CategoryName (Relative)
            const string GlobalPrefix = "/api/data";
            
            // Re-fetch all categories with ParentId to build name hierarchy
            // We already fetched allCategories earlier for Descendant check if categoryId was set.
            // If not, we need to fetch them.
            if (!categoryId.HasValue) 
            {
                // allCategories variable scope issue, let's just use the list we have or fetch if needed
                // Optimizing: We can fetch only related categories, but fetching all is easier for now (assuming not huge amount)
            }
            
            var catIdMap = allCategories.ToDictionary(c => c.Id);
            
            foreach (var item in items)
            {
                // 1. Calculate Full URL Path
                string categoryPath = categoryPathMap.ContainsKey(item.CategoryId) ? categoryPathMap[item.CategoryId] : "";
                item.FullPath = CombinePaths(GlobalPrefix, categoryPath, item.Path);
                
                // 2. Calculate Relative Category Name Path
                var names = new List<string>();
                var currentId = item.CategoryId;
                
                while (catIdMap.ContainsKey(currentId))
                {
                    if (categoryId.HasValue && currentId == categoryId.Value)
                    {
                        // Reached the selected root, stop (don't include root name? or include?)
                        // "Show relative category path starting from current selected category's children"
                        // Usually this means if I selected "System", and item is in "System > User", I show "User".
                        // If item is directly in "System", show "-".
                        break; 
                    }
                    
                    var cat = catIdMap[currentId];
                    names.Insert(0, cat.Name);
                    
                    if (cat.ParentId.HasValue)
                        currentId = cat.ParentId.Value;
                    else
                        break; // Reached absolute root
                }
                
                item.CategoryName = names.Any() ? string.Join(" / ", names) : (categoryId.HasValue ? "-" : allCategoryNames.ContainsKey(item.CategoryId) ? allCategoryNames[item.CategoryId] : "");
                
                // If no category selected (All), show full path?
                if (!categoryId.HasValue && names.Count == 0 && catIdMap.ContainsKey(item.CategoryId))
                {
                     // Recalculate full path for "All" view
                     var tempNames = new List<string>();
                     var tempId = item.CategoryId;
                     while(catIdMap.ContainsKey(tempId)) {
                         var c = catIdMap[tempId];
                         tempNames.Insert(0, c.Name);
                         if(c.ParentId.HasValue) tempId = c.ParentId.Value;
                         else break;
                     }
                     item.CategoryName = string.Join(" / ", tempNames);
                }
            }

            return new PagedResult<InterfaceDefinitionDto>(items, total, page, pageSize);
        }
        
        private string CombinePaths(params string[] paths)
        {
            string result = "";
            foreach (var path in paths)
            {
                if (string.IsNullOrEmpty(path)) continue;
                string p = path.Trim();
                if (string.IsNullOrEmpty(p)) continue;
                
                if (!p.StartsWith("/")) p = "/" + p;
                if (p.EndsWith("/")) p = p.TrimEnd('/');
                
                result += p;
            }
            return result;
        }

        private Dictionary<long, string> BuildCategoryPathMap(List<InterfaceCategory> categories)
        {
            var map = new Dictionary<long, string>();
            var lookup = categories.ToDictionary(c => c.Id);

            foreach (var cat in categories)
            {
                var path = "";
                var current = cat;
                while (current != null)
                {
                    // Prepend current prefix
                    var prefix = current.UrlPrefix?.Trim();
                    if (!string.IsNullOrEmpty(prefix))
                    {
                        if (!prefix.StartsWith("/")) prefix = "/" + prefix;
                        if (prefix.EndsWith("/")) prefix = prefix.TrimEnd('/');
                        path = prefix + path;
                    }
                    
                    if (current.ParentId.HasValue && lookup.ContainsKey(current.ParentId.Value))
                    {
                        current = lookup[current.ParentId.Value];
                    }
                    else
                    {
                        current = null;
                    }
                }
                map[cat.Id] = path;
            }
            return map;
        }

        private void GetDescendantCategoryIds(List<InterfaceCategory> allCategories, long parentId, List<long> result)
        {
            var children = allCategories.Where(c => c.ParentId == parentId);
            foreach (var child in children)
            {
                result.Add(child.Id);
                GetDescendantCategoryIds(allCategories, child.Id, result);
            }
        }

        private List<long> ParseRoles(string? roles)
        {
            if (string.IsNullOrEmpty(roles)) return new List<long>();
            return roles.Split(',', StringSplitOptions.RemoveEmptyEntries)
                .Select(s => long.TryParse(s, out var id) ? id : 0)
                .Where(id => id > 0)
                .ToList();
        }

        private string JoinRoles(List<long>? roles)
        {
            if (roles == null || !roles.Any()) return string.Empty;
            return string.Join(",", roles);
        }

        public async Task<InterfaceDefinitionDto?> GetInterfaceByIdAsync(long id)
        {
            var f = await _context.InterfaceDefinitions.FindAsync(id);
            if (f == null) return null;

            return new InterfaceDefinitionDto
            {
                Id = f.Id,
                CategoryId = f.CategoryId,
                Name = f.Name,
                Path = f.Path,
                Method = f.Method,
                Description = f.Description,
                FlowConfig = f.FlowConfig,
                IsPublished = f.IsPublished,
                RequiresAuth = f.RequiresAuth,
                ViewRoles = ParseRoles(f.ViewRoles),
                CallRoles = ParseRoles(f.CallRoles),
                ManageRoles = ParseRoles(f.ManageRoles),
                CreatedAt = f.CreatedAt,
                UpdatedAt = f.UpdatedAt,
                CreatedBy = f.CreatedBy,
                UpdatedBy = f.UpdatedBy
            };
        }

        public async Task<InterfaceDefinitionDto> CreateInterfaceAsync(CreateInterfaceDto dto, long userId)
        {
            var iface = new InterfaceDefinition
            {
                CategoryId = dto.CategoryId,
                Name = dto.Name,
                Path = dto.Path,
                Method = dto.Method,
                Description = dto.Description,
                RequiresAuth = dto.RequiresAuth,
                IsPublished = false,
                ViewRoles = "", // Default no restriction? Or empty means unrestricted? User didn't specify. Assuming empty is unrestricted or let logic handle it.
                CallRoles = "",
                ManageRoles = "",
                CreatedBy = userId,
                CreatedAt = DateTime.Now,
                UpdatedAt = DateTime.Now
            };

            _context.InterfaceDefinitions.Add(iface);
            await _context.SaveChangesAsync();

            return await GetInterfaceByIdAsync(iface.Id) ?? throw new Exception("Failed to create interface");
        }

        public async Task<InterfaceDefinitionDto?> UpdateInterfaceAsync(long id, UpdateInterfaceDto dto, long userId)
        {
            var iface = await _context.InterfaceDefinitions.FindAsync(id);
            if (iface == null) return null;

            // Check if published
            if (iface.IsPublished)
            {
                // User said: "Published interfaces cannot be modified"
                // But we should allow modifying "IsPublished" status (offline) or specific fields?
                // The requirement says "Published interfaces cannot be modified". 
                // Usually this means core logic. But let's apply strictly first.
                // Exception: unpublishing is handled by PublishInterfaceAsync.
                // Here is UpdateInterfaceAsync.
                // We should probably check if dto.IsPublished is being changed to false.
                // But UpdateInterfaceDto has IsPublished nullable.
                
                // If the user tries to update a published interface, we should block unless they are unpublishing it?
                // Or maybe just block any update if IsPublished is true in DB.
                // Let's block if DB is true, unless we are unpublishing (which might come via this API or separate one).
                // But wait, PublishInterfaceAsync is separate. 
                // So if IsPublished is true, we throw exception.
                
                // However, user might want to update "Description" or "Roles" even if published? 
                // "已上线接口不能修改" usually implies version control or strict stability.
                // Let's strictly block.
                throw new Exception("已发布接口禁止修改，请先下线后再进行操作。");
            }

            if (dto.CategoryId.HasValue) iface.CategoryId = dto.CategoryId.Value;
            if (dto.Name != null) iface.Name = dto.Name;
            if (dto.Path != null) iface.Path = dto.Path;
            if (dto.Method != null) iface.Method = dto.Method;
            if (dto.Description != null) iface.Description = dto.Description;
            if (dto.FlowConfig != null) iface.FlowConfig = dto.FlowConfig;
            if (dto.RequiresAuth.HasValue) iface.RequiresAuth = dto.RequiresAuth.Value;
            // IsPublished can be updated here? Use dedicated endpoint for state change usually.
            // if (dto.IsPublished.HasValue) iface.IsPublished = dto.IsPublished.Value; 
            
            if (dto.ViewRoles != null) iface.ViewRoles = JoinRoles(dto.ViewRoles);
            if (dto.CallRoles != null) iface.CallRoles = JoinRoles(dto.CallRoles);
            if (dto.ManageRoles != null) iface.ManageRoles = JoinRoles(dto.ManageRoles);

            iface.UpdatedBy = userId;
            iface.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();

            return await GetInterfaceByIdAsync(id);
        }

        public async Task<bool> DeleteInterfaceAsync(long id, long userId)
        {
            var iface = await _context.InterfaceDefinitions.FindAsync(id);
            if (iface == null) return false;

            _context.InterfaceDefinitions.Remove(iface);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> PublishInterfaceAsync(long id, bool isPublished, long userId)
        {
            var iface = await _context.InterfaceDefinitions.FindAsync(id);
            if (iface == null) return false;

            iface.IsPublished = isPublished;
            iface.UpdatedBy = userId;
            iface.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();
            return true;
        }
        public async Task<InterfaceDefinitionDto?> GetInterfaceByPathAsync(string path)
        {
            if (string.IsNullOrEmpty(path)) return null;

            // Normalize path
            var normalizedPath = path.Trim();
            if (!normalizedPath.StartsWith("/")) normalizedPath = "/" + normalizedPath;
            if (normalizedPath.EndsWith("/")) normalizedPath = normalizedPath.TrimEnd('/');

            // NOTE: This implementation is slow because it iterates over all interfaces.
            // In production, we should cache the route map or store FullPath in DB.
            // For MVP, we load all and match.

            // Fetch all interfaces (including unpublished, so controller can return explicit 'not published' error)
            // Optimizing: Select only needed fields
            var allInterfaces = await _context.InterfaceDefinitions
                .Select(i => new { i.Id, i.CategoryId, i.Path })
                .ToListAsync();

            var allCategories = await _context.InterfaceCategories.ToListAsync();
            var categoryPathMap = BuildCategoryPathMap(allCategories);

            // const string GlobalPrefix = "/api/data"; // Removed unused variable
            // The controller receives "user/detail", excluding "api/data".
            // So we should match against CategoryPath + InterfacePath.
            
            // Let's assume path passed here is "user/detail".

            foreach (var iface in allInterfaces)
            {
                var catPath = categoryPathMap.ContainsKey(iface.CategoryId) ? categoryPathMap[iface.CategoryId] : "";
                
                // Construct relative path: /cat/subcat/interface
                var fullRelativePath = CombinePaths(catPath, iface.Path);
                
                // Compare (case-insensitive?)
                if (string.Equals(fullRelativePath, normalizedPath, StringComparison.OrdinalIgnoreCase))
                {
                    return await GetInterfaceByIdAsync(iface.Id);
                }
            }

            return null;
        }
    }
}
