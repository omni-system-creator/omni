---
name: check-orgid
description: Audit backend code to ensure all queries properly filter by OrgId for multi-tenant security
disable-model-invocation: false
allowed-tools: Read, Grep, Glob
---

# Check OrgId Security Skill

Audit backend services to ensure proper OrgId filtering for multi-tenant data isolation.

## Instructions

This skill performs a security audit to verify that all database queries properly filter by OrgId.

### What to Check

1. **Service Files**: All files in `backend/omsapi/Services/` ending with `Service.cs`
2. **Query Methods**: Methods that query the database (GetList, GetById, etc.)
3. **Update/Delete Methods**: Methods that modify or delete data

### Security Requirements

**CRITICAL**: The OmsContext does NOT have global query filters enabled. All queries MUST manually filter by OrgId.

#### Query Methods (Get/List)
Must include: `.Where(x => x.OrgId == currentOrgId)`

Example:
```csharp
public async Task<List<EntityDto>> GetListAsync()
{
    var currentOrgId = _httpContextAccessor.HttpContext!.GetCurrentOrgId();

    var entities = await _context.Entities
        .Where(x => x.OrgId == currentOrgId)  // ✓ REQUIRED
        .ToListAsync();

    return entities.Select(MapToDto).ToList();
}
```

#### Update/Delete Methods
Must verify OrgId ownership before modification:

```csharp
public async Task<EntityDto> UpdateAsync(long id, UpdateEntityDto dto)
{
    var currentOrgId = _httpContextAccessor.HttpContext!.GetCurrentOrgId();

    var entity = await _context.Entities
        .Where(x => x.Id == id && x.OrgId == currentOrgId)  // ✓ REQUIRED
        .FirstOrDefaultAsync();

    if (entity == null)
        throw new Exception("Entity not found or access denied");

    // Update logic...
}
```

### Audit Process

1. **Find all service files**:
   ```
   Glob pattern: backend/omsapi/Services/*Service.cs
   ```

2. **For each service file**:
   - Read the file content
   - Identify all methods that query `_context`
   - Check if they filter by OrgId

3. **Look for violations**:
   - Queries without `.Where(x => x.OrgId == currentOrgId)`
   - Update/Delete without OrgId verification
   - Direct `.Find()` or `.FirstOrDefault()` without OrgId filter

4. **Report findings**:
   - List files with violations
   - Show specific line numbers
   - Provide fix recommendations

### Common Violations

❌ **Missing OrgId filter**:
```csharp
var entities = await _context.Entities.ToListAsync();  // WRONG!
```

✓ **Correct**:
```csharp
var currentOrgId = _httpContextAccessor.HttpContext!.GetCurrentOrgId();
var entities = await _context.Entities
    .Where(x => x.OrgId == currentOrgId)
    .ToListAsync();
```

❌ **Update without verification**:
```csharp
var entity = await _context.Entities.FindAsync(id);  // WRONG!
```

✓ **Correct**:
```csharp
var currentOrgId = _httpContextAccessor.HttpContext!.GetCurrentOrgId();
var entity = await _context.Entities
    .Where(x => x.Id == id && x.OrgId == currentOrgId)
    .FirstOrDefaultAsync();
```

### Exceptions

Some services may legitimately skip OrgId filtering:
- **AuthService**: Handles authentication across organizations
- **OrgService**: Manages organizations themselves
- **SystemConfigService**: May need cross-org access for SuperAdmin
- **UserService**: Some methods may need cross-org for admin features

For these exceptions, verify they have proper role-based authorization checks.

### Output Format

Provide a report with:
1. **Summary**: Total services checked, violations found
2. **Violations**: List each file and method with issues
3. **Recommendations**: Specific fixes for each violation
4. **Severity**: Critical (data leak risk) vs Warning (needs review)

Example:
```
OrgId Security Audit Report
===========================

Summary:
- Services checked: 15
- Violations found: 3
- Critical issues: 2
- Warnings: 1

Critical Issues:
1. ProductService.cs:45 - GetListAsync()
   Missing OrgId filter on query
   Fix: Add .Where(x => x.OrgId == currentOrgId)

2. OrderService.cs:78 - DeleteAsync()
   No OrgId verification before delete
   Fix: Add OrgId check in Where clause

Warnings:
1. UserService.cs:120 - GetAllUsersAsync()
   Cross-org query detected - verify authorization
```

### Automated Fix

If user approves, can automatically add OrgId filters to violations:
1. Identify the query location
2. Add `var currentOrgId = _httpContextAccessor.HttpContext!.GetCurrentOrgId();` if missing
3. Add `.Where(x => x.OrgId == currentOrgId)` to the query
4. Update the file

Always ask for confirmation before modifying code.
