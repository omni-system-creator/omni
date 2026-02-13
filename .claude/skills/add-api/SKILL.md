---
name: add-api
description: Add a new API endpoint with controller, service, and DTOs following OMS patterns
disable-model-invocation: false
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Add API Skill

Add a new API endpoint to the OMS backend following established patterns.

## Instructions

When the user requests to add a new API endpoint, follow these steps:

### 1. Understand Requirements
- Determine the entity/resource name
- Identify required operations (CRUD, custom actions)
- Confirm DTO requirements

### 2. Create DTOs
Location: `backend/omsapi/Models/Dtos/{EntityName}/`

Create necessary DTOs:
- `{EntityName}Dto.cs` - Response DTO
- `Create{EntityName}Dto.cs` - Create request DTO
- `Update{EntityName}Dto.cs` - Update request DTO
- `{EntityName}QueryDto.cs` - Query/filter DTO (if needed)

Example:
```csharp
namespace omsapi.Models.Dtos.{EntityName}
{
    /// <summary>
    /// {EntityName} response DTO
    /// </summary>
    public class {EntityName}Dto
    {
        public long Id { get; set; }
        public long OrgId { get; set; }
        public string PropertyName { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }
}
```

### 3. Create Service Interface
Location: `backend/omsapi/Services/I{EntityName}Service.cs`

```csharp
namespace omsapi.Services
{
    public interface I{EntityName}Service
    {
        Task<List<{EntityName}Dto>> GetListAsync();
        Task<{EntityName}Dto?> GetByIdAsync(long id);
        Task<{EntityName}Dto> CreateAsync(Create{EntityName}Dto dto);
        Task<{EntityName}Dto> UpdateAsync(long id, Update{EntityName}Dto dto);
        Task DeleteAsync(long id);
    }
}
```

### 4. Create Service Implementation
Location: `backend/omsapi/Services/{EntityName}Service.cs`

**CRITICAL Requirements**:
- Add `[AutoInject(ServiceLifetime.Scoped)]` attribute
- Inject `OmsContext` and `IHttpContextAccessor`
- **ALL queries MUST filter by OrgId**: `.Where(x => x.OrgId == currentOrgId)`
- **ALL Update/Delete MUST verify OrgId ownership**
- Use async/await throughout
- Use transactions for multi-table operations
- Add XML documentation comments

Example:
```csharp
using omsapi.Infrastructure.Attributes;
using omsapi.Infrastructure.Extensions;

namespace omsapi.Services
{
    [AutoInject(ServiceLifetime.Scoped)]
    public class {EntityName}Service : I{EntityName}Service
    {
        private readonly OmsContext _context;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public {EntityName}Service(OmsContext context, IHttpContextAccessor httpContextAccessor)
        {
            _context = context;
            _httpContextAccessor = httpContextAccessor;
        }

        public async Task<List<{EntityName}Dto>> GetListAsync()
        {
            var currentOrgId = _httpContextAccessor.HttpContext!.GetCurrentOrgId();

            var entities = await _context.{EntityName}s
                .Where(x => x.OrgId == currentOrgId)  // CRITICAL: OrgId filter
                .OrderByDescending(x => x.CreatedAt)
                .ToListAsync();

            return entities.Select(MapToDto).ToList();
        }

        public async Task<{EntityName}Dto?> GetByIdAsync(long id)
        {
            var currentOrgId = _httpContextAccessor.HttpContext!.GetCurrentOrgId();

            var entity = await _context.{EntityName}s
                .Where(x => x.Id == id && x.OrgId == currentOrgId)  // CRITICAL: OrgId filter
                .FirstOrDefaultAsync();

            return entity == null ? null : MapToDto(entity);
        }

        public async Task<{EntityName}Dto> CreateAsync(Create{EntityName}Dto dto)
        {
            var currentOrgId = _httpContextAccessor.HttpContext!.GetCurrentOrgId();

            var entity = new {EntityName}Entity
            {
                OrgId = currentOrgId,  // CRITICAL: Set OrgId
                // Map properties from dto
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            _context.{EntityName}s.Add(entity);
            await _context.SaveChangesAsync();

            return MapToDto(entity);
        }

        public async Task<{EntityName}Dto> UpdateAsync(long id, Update{EntityName}Dto dto)
        {
            var currentOrgId = _httpContextAccessor.HttpContext!.GetCurrentOrgId();

            var entity = await _context.{EntityName}s
                .Where(x => x.Id == id && x.OrgId == currentOrgId)  // CRITICAL: Verify ownership
                .FirstOrDefaultAsync();

            if (entity == null)
                throw new Exception("{EntityName} not found or access denied");

            // Update properties from dto
            entity.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return MapToDto(entity);
        }

        public async Task DeleteAsync(long id)
        {
            var currentOrgId = _httpContextAccessor.HttpContext!.GetCurrentOrgId();

            var entity = await _context.{EntityName}s
                .Where(x => x.Id == id && x.OrgId == currentOrgId)  // CRITICAL: Verify ownership
                .FirstOrDefaultAsync();

            if (entity == null)
                throw new Exception("{EntityName} not found or access denied");

            _context.{EntityName}s.Remove(entity);
            await _context.SaveChangesAsync();
        }

        private static {EntityName}Dto MapToDto({EntityName}Entity entity)
        {
            return new {EntityName}Dto
            {
                Id = entity.Id,
                OrgId = entity.OrgId,
                // Map properties
                CreatedAt = entity.CreatedAt,
                UpdatedAt = entity.UpdatedAt
            };
        }
    }
}
```

### 5. Create Controller
Location: `backend/omsapi/Controllers/{EntityName}Controller.cs`

```csharp
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace omsapi.Controllers
{
    /// <summary>
    /// {EntityName} management API
    /// </summary>
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class {EntityName}Controller : ControllerBase
    {
        private readonly I{EntityName}Service _service;

        public {EntityName}Controller(I{EntityName}Service service)
        {
            _service = service;
        }

        /// <summary>
        /// Get {entity} list
        /// </summary>
        [HttpGet]
        public async Task<ApiResponse<List<{EntityName}Dto>>> GetList()
        {
            var data = await _service.GetListAsync();
            return ApiResponse<List<{EntityName}Dto>>.Success(data);
        }

        /// <summary>
        /// Get {entity} by ID
        /// </summary>
        [HttpGet("{id}")]
        public async Task<ApiResponse<{EntityName}Dto>> GetById(long id)
        {
            var data = await _service.GetByIdAsync(id);
            if (data == null)
                return ApiResponse<{EntityName}Dto>.Error("Not found");
            return ApiResponse<{EntityName}Dto>.Success(data);
        }

        /// <summary>
        /// Create {entity}
        /// </summary>
        [HttpPost]
        public async Task<ApiResponse<{EntityName}Dto>> Create([FromBody] Create{EntityName}Dto dto)
        {
            var data = await _service.CreateAsync(dto);
            return ApiResponse<{EntityName}Dto>.Success(data);
        }

        /// <summary>
        /// Update {entity}
        /// </summary>
        [HttpPut("{id}")]
        public async Task<ApiResponse<{EntityName}Dto>> Update(long id, [FromBody] Update{EntityName}Dto dto)
        {
            var data = await _service.UpdateAsync(id, dto);
            return ApiResponse<{EntityName}Dto>.Success(data);
        }

        /// <summary>
        /// Delete {entity}
        /// </summary>
        [HttpDelete("{id}")]
        public async Task<ApiResponse<object>> Delete(long id)
        {
            await _service.DeleteAsync(id);
            return ApiResponse<object>.Success(null);
        }
    }
}
```

### 6. Verify
- Service has `[AutoInject]` attribute
- All queries filter by OrgId
- All Update/Delete verify OrgId ownership
- DTOs are properly structured
- Controller returns `ApiResponse<T>`
- XML documentation is added
- No `.Result` or `.Wait()` calls

## Security Checklist

- [ ] Service filters all queries by OrgId
- [ ] Update/Delete operations verify ownership
- [ ] Controller has `[Authorize]` attribute
- [ ] No SQL injection vulnerabilities
- [ ] Input validation on DTOs
- [ ] Proper error handling
