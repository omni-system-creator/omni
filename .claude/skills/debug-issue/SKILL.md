---
name: debug-issue
description: Debug and troubleshoot issues in the OMS system with systematic approach
disable-model-invocation: false
allowed-tools: Read, Grep, Glob, Bash
---

# Debug Issue Skill

Systematically debug and troubleshoot issues in the OMS system.

## Instructions

When the user reports an issue or error, follow this systematic debugging approach:

### 1. Gather Information

Ask the user for:
- **Error message**: Exact error text or screenshot
- **When it occurs**: What action triggers the issue
- **Environment**: Frontend (PC/H5), Backend, Database
- **Recent changes**: Any recent code changes
- **Reproducibility**: Can it be reproduced consistently?

### 2. Identify the Layer

Determine which layer has the issue:

#### Frontend Issues
- UI not displaying correctly
- JavaScript errors in console
- API calls failing
- State management issues
- Routing problems

#### Backend Issues
- API endpoint errors (4xx, 5xx)
- Database query failures
- Authentication/authorization issues
- Service exceptions
- Performance problems

#### Database Issues
- Migration failures
- Query timeouts
- Data inconsistencies
- Connection issues

### 3. Check Common Issues First

#### OrgId-Related Issues
Most common issue in OMS - missing OrgId filtering:

```bash
# Search for queries without OrgId filter
grep -r "ToListAsync()" backend/omsapi/Services/ | grep -v "OrgId"
```

Check:
- [ ] Query filters by OrgId
- [ ] Update/Delete verifies OrgId ownership
- [ ] Current user's OrgId is correctly retrieved

#### Authentication Issues
```bash
# Check JWT token handling
grep -r "GetCurrentUserId\|GetCurrentOrgId" backend/omsapi/
```

Check:
- [ ] Token is being sent in request headers
- [ ] Token is not expired
- [ ] User has correct permissions
- [ ] OrgId is in token claims

#### API Response Issues
Check:
- [ ] Controller returns `ApiResponse<T>`
- [ ] Error handling catches exceptions
- [ ] HTTP status codes are correct
- [ ] CORS is configured properly

#### Frontend State Issues
Check:
- [ ] Pinia store is properly initialized
- [ ] Reactive state is used correctly
- [ ] API responses are handled
- [ ] Error messages are displayed

### 4. Systematic Investigation

#### For Frontend Issues

1. **Check Browser Console**:
   - Look for JavaScript errors
   - Check network tab for failed requests
   - Verify API responses

2. **Check Component State**:
   - Use Vue DevTools to inspect component state
   - Verify props and emits
   - Check computed properties

3. **Check API Integration**:
   ```typescript
   // Add console.log to debug
   const res = await api.getData()
   console.log('API Response:', res)
   ```

4. **Check Routing**:
   - Verify route is registered
   - Check route guards
   - Verify navigation logic

#### For Backend Issues

1. **Check Logs**:
   ```bash
   # View backend logs
   cd backend/omsapi
   dotnet run
   # Watch for errors in console
   ```

2. **Check Service Layer**:
   - Read the service file
   - Verify OrgId filtering
   - Check for null reference exceptions
   - Verify async/await usage

3. **Check Database Queries**:
   - Enable SQL logging in `appsettings.json`:
   ```json
   "Logging": {
     "LogLevel": {
       "Microsoft.EntityFrameworkCore.Database.Command": "Information"
     }
   }
   ```

4. **Check Authorization**:
   - Verify `[Authorize]` attribute
   - Check permission requirements
   - Verify user roles

#### For Database Issues

1. **Check Migrations**:
   ```bash
   # List migration files
   ls database/mysql/
   ls database/mssql/
   ls database/postgresql/
   ```

2. **Check Connection**:
   - Verify connection string in `appsettings.json`
   - Test database connectivity
   - Check database type configuration

3. **Check Schema**:
   - Verify table exists
   - Check column names and types
   - Verify indexes

### 5. Common Error Patterns

#### "Entity not found or access denied"
**Cause**: OrgId mismatch
**Fix**: Verify OrgId filtering in query

#### "Object reference not set to an instance of an object"
**Cause**: Null reference
**Fix**: Add null checks, use nullable types

#### "Cannot access a disposed object"
**Cause**: DbContext disposed too early
**Fix**: Ensure proper async/await, avoid `.Result`

#### "A second operation started on this context"
**Cause**: Concurrent DbContext access
**Fix**: Use proper async/await, avoid parallel queries on same context

#### "401 Unauthorized"
**Cause**: Missing or invalid token
**Fix**: Check token in request headers, verify token expiration

#### "403 Forbidden"
**Cause**: Insufficient permissions
**Fix**: Check user roles and permissions

#### "CORS policy error"
**Cause**: CORS not configured
**Fix**: Add CORS policy in `Program.cs`

#### "Network Error" (Frontend)
**Cause**: Backend not running or wrong URL
**Fix**: Verify backend is running, check proxy configuration

### 6. Debugging Tools

#### Backend
- **Logging**: Add `_logger.LogInformation()` statements
- **Breakpoints**: Use Visual Studio debugger
- **SQL Profiler**: Monitor database queries
- **Postman**: Test API endpoints directly

#### Frontend
- **Vue DevTools**: Inspect component state
- **Browser DevTools**: Check console and network
- **React DevTools**: For debugging (if applicable)
- **Console.log**: Add debug statements

### 7. Fix and Verify

1. **Implement Fix**: Make the necessary code changes
2. **Test Locally**: Verify the fix works
3. **Check Side Effects**: Ensure no new issues introduced
4. **Document**: Add comments explaining the fix
5. **Commit**: Create a commit with clear message

### 8. Prevention

After fixing, consider:
- [ ] Add validation to prevent similar issues
- [ ] Add error handling
- [ ] Add logging for debugging
- [ ] Update documentation
- [ ] Add to common pitfalls list

## Debug Checklist Template

```
Issue: [Brief description]
Environment: [Frontend PC/H5/Backend/Database]
Error Message: [Exact error]

Investigation:
1. [ ] Checked logs
2. [ ] Verified OrgId filtering
3. [ ] Checked authentication
4. [ ] Tested API endpoint
5. [ ] Reviewed recent changes

Root Cause:
[What caused the issue]

Fix Applied:
[What was changed]

Verification:
[How it was tested]

Prevention:
[How to prevent in future]
```

## Example Debugging Session

**Issue**: "Product list is empty but products exist in database"

**Investigation**:
1. Check browser console - no errors
2. Check network tab - API returns empty array
3. Check backend logs - no errors
4. Check ProductService.cs - Found missing OrgId filter!

**Root Cause**:
```csharp
// WRONG - no OrgId filter
var products = await _context.Products.ToListAsync();
```

**Fix**:
```csharp
// CORRECT - with OrgId filter
var currentOrgId = _httpContextAccessor.HttpContext!.GetCurrentOrgId();
var products = await _context.Products
    .Where(x => x.OrgId == currentOrgId)
    .ToListAsync();
```

**Verification**: Product list now shows correct products for current organization.
