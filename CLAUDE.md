# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

OmniSystem (综合信息管理系统) is an enterprise-grade integrated business management platform built with .NET 10 backend and Vue 3 frontend. The system provides modular management for contracts, finance, projects, customers, suppliers, and more, with multi-database support and multi-tenant architecture.

**Key Features**:
- **Multi-Tenant Architecture**: Organization-based data isolation with OrgId filtering
- **Role-Based Access Control (RBAC)**: Comprehensive permission system with role inheritance
- **Dynamic Routing**: Frontend routes generated based on user permissions
- **Multi-Database Support**: MySQL, SQL Server, and PostgreSQL
- **Real-time Communication**: SignalR for live updates
- **Mobile Support**: Dedicated H5 app with Capacitor for native capabilities

## Repository Structure

```
OMS/
├── backend/omsapi/          # .NET 10 Web API
├── frontend/                # Vue 3 + Ant Design Vue (PC)
├── frontend.h5/             # Vue 3 + Vant 4 (Mobile/App)
├── frontend.desktop/        # Desktop client
├── bigview/                 # Data visualization dashboards
├── database/                # SQL migration scripts (mysql/, mssql/, postgresql/)
└── documents/               # Project documentation
```

## Development Commands

### Database Setup

**Development Environment**:
- Database: MySQL
- Host: localhost
- Username: root
- Password: P@ssw0rd
- Database Name: o_dev

Connection string format:
```
Server=localhost;Database=o_dev;User=root;Password=P@ssw0rd;
```

Apply migrations from `database/mysql/` directory in order.

### Backend (.NET 10)
```bash
cd backend/omsapi
dotnet run                   # Start API server (default: http://localhost:5016)
dotnet watch                 # Start with hot reload
dotnet build                 # Build project
```

### Frontend PC (Vue 3 + TypeScript + Ant Design Vue)
```bash
cd frontend
npm install                  # Install dependencies
npm run dev                  # Start dev server (proxies to localhost:5016)
npm run build                # Build for production
npm run preview              # Preview production build
```

### Frontend H5 (Mobile)
```bash
cd frontend.h5
npm install
npm run dev                  # Start mobile dev server
npm run build                # Build for web
npm run build:app            # Build for Capacitor app
npx cap sync                 # Sync to native projects
npx cap open android         # Open in Android Studio
```

### BigView (Data Visualization)
```bash
cd bigview
npm run dev                  # Start dev server
npm run build                # Build for production
npm run lint                 # Run ESLint
npm run lint:fix             # Fix linting issues
npm run new                  # Generate new component
```

## Architecture & Key Patterns

### Backend Architecture

**Multi-Database Support**: The system supports MySQL, SQL Server, and PostgreSQL through separate DbContext implementations:
- `OmsContext` - Main business database (MySQL/MSSQL/PostgreSQL)
- `OmsPgContext` - PostgreSQL with pgvector for AI/knowledge base features

Database type is configured via `appsettings.json` → `DatabaseType` (mysql/mssql/postgresql).

**Service Auto-Registration**: Services use `[AutoInject(ServiceLifetime.Scoped)]` attribute for automatic DI registration. The system scans for this attribute and registers services with their corresponding interfaces (e.g., `AuthService` → `IAuthService`).

**Multi-Tenant Architecture (OrgId Isolation)**:
- **CRITICAL**: DbContext does NOT have global query filters enabled
- All service queries MUST explicitly filter by `OrgId`: `.Where(x => x.OrgId == currentOrgId)`
- Update/Delete operations MUST verify the target entity's `OrgId` matches current user's organization
- Get current OrgId from `HttpContext` via extension methods in `Infrastructure/Extensions/`

**API Response Pattern**: Controllers return `ApiResponse<T>` wrapper for consistent response format.

**Authentication**: JWT-based authentication with sliding expiration via `JwtSlidingExpirationMiddleware`.

**SignalR Hubs**: Real-time communication via hubs in `/hubs/` endpoints:
- `/hubs/debug` - DebugHub
- `/hubs/project` - ProjectHub
- `/hubs/user` - UserHub

**Database Migrations**: SQL-based migrations in `database/` directory, applied via `SqlMigrationService` on startup. When modifying entities, update migration files for all three databases (MySQL, MSSQL, PostgreSQL).

### Frontend Architecture (PC)

**Tech Stack**: Vue 3 Composition API + TypeScript + Ant Design Vue + Vite + Pinia

**Auto-Imports**:
- Vue APIs (ref, reactive, computed, watch, etc.) via `unplugin-auto-import`
- Ant Design Vue components via `unplugin-vue-components`

**State Management**: Pinia stores in `src/stores/`:
- `user.ts` - User authentication, current organization
- `permission.ts` - Dynamic routes and permissions
- `system.ts` - System configuration
- `tabs.ts` - Tab navigation state

**Routing**: Dynamic routes loaded based on user permissions. Base routes in `src/router/index.ts`, dynamic routes added by permission store.

**API Layer**: API functions in `src/api/{module}.ts` using `request` utility from `src/utils/request.ts`. The request utility handles authentication tokens and error responses.

**Key Components**:
- `SplitLayout` - Resizable split panels with persistence (MUST use for left/right or top/bottom layouts)
- `SmartTable` - Enhanced table component with advanced features
- `UserSelector` - User selection with display data handling
- `DynamicIcon` - Icon component supporting multiple icon libraries
- `DraggableModal` - Draggable and maximizable modals (use `useDraggableModal` composable)

**Canvas Rendering**: Uses Leafer UI for high-performance 2D canvas rendering (contracts, diagrams, etc.). Aliases configured in `vite.config.ts` to ensure single instance.

**Proxy Configuration**: Dev server proxies to backend at `localhost:5016`:
- `/api` → Backend API
- `/hubs` → SignalR hubs (WebSocket)
- `/uploads` → Static file uploads

### Frontend Architecture (H5)

**Tech Stack**: Vue 3 + Vant 4 + Capacitor for native app capabilities

**Build Targets**:
- Web: `npm run build`
- Native app: `npm run build:app` (sets `BUILD_TARGET=app` env var)

## Critical Development Rules

### Backend

1. **OrgId Isolation** (CRITICAL):
   - ALL queries MUST include `.Where(x => x.OrgId == currentOrgId)`
   - ALL Update/Delete operations MUST verify OrgId ownership
   - No global query filters exist - manual filtering is required
   - Get current OrgId from JWT token via `HttpContext` extension methods

2. **Permission Validation** (CRITICAL):
   - Validate user permissions at service level before data operations
   - Use `_userService.GetUserPermissionsAsync(userId)` to get user's roles
   - Check if user is SuperAdmin for system-level operations
   - Filter data based on role assignments for non-admin users:
     ```csharp
     var (isAdmin, roleIds) = await _userService.GetUserPermissionsAsync(userId);

     if (!isAdmin)
     {
         // Filter by user's roles
         query = query.Where(x => roleIds.Contains(x.AssignedRoleId));
     }
     ```
   - Always return appropriate error messages for unauthorized access

3. **Transaction Management**:
   - Multi-table operations MUST use `using var transaction = _context.Database.BeginTransaction()`
   - Commit on success, rollback on exception

4. **Async/Await**:
   - NEVER use `.Result` or `.Wait()` - always use `async/await`
   - All controller actions should be async

5. **Service Pattern**:
   - Services in `Services/` directory with `[AutoInject]` attribute
   - Interface naming: `I{ServiceName}` (e.g., `IAuthService`)
   - Inject `IHttpContextAccessor` to access current user context

6. **Multi-Database Migrations**:
   - When modifying `OmsContext` entities, update migrations in all three database folders: `database/mysql/`, `database/mssql/`, `database/postgresql/`
   - Vector-related entities (`KbNode`, etc.) use `OmsPgContext` - separate migrations

7. **Authorization Flow**:
   - Controllers use `[Authorize]` attribute to require authentication
   - Extract userId from JWT claims: `User.FindFirst("id")`
   - Pass userId to service methods for permission checks
   - Services validate permissions and filter data accordingly

8. **Data Scope Control**:
   - SuperAdmin: Access all data within any organization (system-level)
   - Org Admin: Access all data within their organization
   - Regular User: Access only data assigned to their roles
   - Always respect organization boundaries (OrgId filtering)

### Frontend (PC)

1. **Layout Standards**:
   - MUST use `SplitLayout` for resizable left/right or top/bottom layouts
   - NO manual Flex/Grid layouts for split panels
   - Containers MUST adapt to parent size (`height: 100%` or `flex: 1`)
   - Avoid double scrollbars - only one scrollable container per view

2. **Table Standards**:
   - MUST use `SmartTable` component for paginated data lists
   - Search/filter forms MUST be placed in toolbar (not above table)
   - Toolbar padding MUST be 8px (`:padding="8"`)
   - MUST include row number column on the left
   - Row numbers MUST continue across pages (use pagination offset)
   - Action column MUST be centered
   - Use icons with `title` attribute instead of text for actions
   - More than 3 actions MUST be collapsed into `MoreOutlined` dropdown menu
   - Example structure:
     ```vue
     <SmartTable
       :columns="columns"
       :data-source="dataSource"
       :loading="loading"
       :pagination="pagination"
       @change="handleTableChange"
     >
       <template #toolbar>
         <a-space :style="{ padding: '8px' }">
           <a-input v-model:value="searchForm.keyword" placeholder="搜索..." />
           <a-button type="primary" @click="handleSearch">查询</a-button>
           <a-button @click="handleReset">重置</a-button>
         </a-space>
       </template>
     </SmartTable>
     ```

3. **Modal Standards**:
   - Complex modals MUST support drag and maximize (use `useDraggableModal`)
   - Submit buttons MUST bind to `loading` state
   - `UserSelector` MUST handle `initial-display-data` for proper display

4. **API Calls**:
   - Use `message.error()` from Ant Design Vue for error feedback
   - Handle loading states with reactive `loading` ref
   - Use `@/` alias for imports from `src/`

5. **Type Safety**:
   - Define types in `src/types/` or co-located with components
   - Use strong typing for API responses and DTOs

6. **Icon Usage**:
   - Use `DynamicIcon` component for flexible icon rendering
   - Validate icon names to ensure they exist in the icon library

7. **Permission Control** (CRITICAL):
   - Check permissions before rendering sensitive UI elements:
     ```vue
     <a-button v-if="permissionStore.hasPermission('user:create')" @click="handleCreate">
       Create
     </a-button>
     ```
   - Use `permissionStore.hasMenu()` to check menu access
   - Hide features user doesn't have permission for
   - Always validate on backend even if frontend hides UI

8. **Organization Context**:
   - Current organization available via `userStore.currentOrg`
   - Organization switch triggers route/permission reload
   - All API calls automatically include current OrgId via JWT token

### RBAC & Permissions System

The system implements a comprehensive Role-Based Access Control (RBAC) system with the following architecture:

#### Permission Types

Permissions are categorized into three types (stored in `sys_permission` table):

1. **MENU**: Navigation menu items
   - Defines routes and components
   - Controls menu visibility in frontend
   - Has `path`, `component`, `icon` properties

2. **BUTTON**: UI action buttons/features
   - Controls button visibility and availability
   - Examples: "Create", "Edit", "Delete", "Export"
   - Checked via `hasPermission()` in frontend

3. **API**: Backend API endpoints
   - Controls API access at service/controller level
   - Enforces data scope restrictions
   - Examples: "user:view", "project:create"

#### Role Hierarchy

**System Roles**:
- `SuperAdmin`: Global super administrator with all permissions across all organizations
- `{OrgCode}-Admin`: Organization administrator (e.g., `ORGA-Admin`) with full access within their organization
- Custom roles: Organization-specific roles with tailored permissions

**Role Inheritance**:
- Roles can inherit permissions from parent roles via `sys_role_inheritance` table
- When a user has Role A (parent), they automatically get permissions from Role B (child) if A includes B
- Inheritance is resolved recursively in `GetEffectiveRoleIdsAsync()`

**Role Assignment**:
- Users can have multiple roles via `sys_user_role` table
- Effective permissions = union of all assigned roles + inherited roles
- SuperAdmin bypasses all permission checks and gets all permissions

#### Frontend Permission Control

**1. Dynamic Route Generation**:
```typescript
// In permission.ts store
const generateRoutes = async () => {
  const res = await getRoutes(); // Fetches MENU-type permissions from backend
  const backendRoutes = filterAsyncRoutes(res);
  routes.value = backendRoutes;
  return backendRoutes;
}
```

**2. Menu Visibility**:
- Only MENU permissions assigned to user's roles are returned by `/api/auth/routes`
- Frontend dynamically builds navigation menu from these permissions
- Hidden menus (`IsVisible = false`) are excluded

**3. Button/Feature Control**:
```vue
<template>
  <!-- Check permission before showing button -->
  <a-button v-if="permissionStore.hasPermission('user:create')" @click="handleCreate">
    Create User
  </a-button>
</template>

<script setup lang="ts">
import { usePermissionStore } from '@/stores/permission'

const permissionStore = usePermissionStore()

// Or use computed for complex checks
const canEdit = computed(() => permissionStore.hasPermission('user:edit'))
</script>
```

**4. Permission Store API**:
```typescript
// Check if user has specific permission
permissionStore.hasPermission('user:create') // Returns boolean

// Check if user has access to menu
permissionStore.hasMenu('UserManagement') // Returns boolean

// Get all user permissions
permissionStore.permissions // Array of permission codes
```

#### Backend Permission Control

**1. Service-Level Permission Checks**:
```csharp
// Get user's roles and admin status
var (isAdmin, roleIds) = await _userService.GetUserPermissionsAsync(userId);

// Check if user has permission for specific data
if (!isAdmin && !form.RoleIds.Split(',').Any(r => roleIds.Contains(long.Parse(r))))
{
    return (false, "无权访问此表单", null);
}
```

**2. Data Scope Filtering**:
```csharp
// SuperAdmin sees all data in organization
if (isSuperAdmin)
{
    query = _context.Projects.Where(p => p.OrgId == currentOrgId);
}
// Regular users see only data assigned to their roles
else
{
    query = _context.Projects
        .Where(p => p.OrgId == currentOrgId && roleIds.Contains(p.AssignedRoleId));
}
```

**3. Permission Attribute** (for future use):
```csharp
[Permission("user:create")]
[HttpPost]
public async Task<ApiResponse<object>> CreateUser([FromBody] CreateUserDto dto)
{
    // Implementation
}
```

**4. Permission Resolution Flow**:
```
User Login
    ↓
Get User's Direct Roles (sys_user_role)
    ↓
Resolve Role Inheritance (sys_role_inheritance)
    ↓
Get Effective Role IDs
    ↓
Check if SuperAdmin → Grant All Permissions
    ↓
Otherwise: Get Permissions from sys_role_permission
    ↓
Return Permission Codes to Frontend
```

#### Organization-Level Isolation

**Critical Rules**:
1. **All data queries MUST filter by OrgId** - ensures multi-tenant isolation
2. **SuperAdmin has cross-org access** - can manage system-level configurations
3. **Org Admins have org-scoped access** - full control within their organization
4. **Regular users have role-scoped access** - limited by assigned roles and permissions

**Permission Scope Hierarchy**:
```
SuperAdmin (System Level)
    ↓
Organization Admin (Organization Level)
    ↓
Department Manager (Department Level)
    ↓
Regular User (Role Level)
```

#### Common Permission Patterns

**1. Admin Check**:
```typescript
// Frontend
const isAdmin = computed(() => userStore.isAdmin)

// Backend
var isSuperAdmin = await _context.Roles.AnyAsync(r =>
    roleIds.Contains(r.Id) && r.Code == "SuperAdmin");
```

**2. Feature-Specific Permissions**:
```typescript
// Knowledge Base Admin
const isKBAdmin = computed(() => permissionStore.hasPermission('KBAdmin'))

// Sales Registration Admin
const isSalesAdmin = computed(() =>
    permissionStore.hasPermission('SalesRegistration:Admin'))
```

**3. Conditional UI Rendering**:
```vue
<template>
  <div>
    <!-- Show for all users -->
    <a-button @click="handleView">View</a-button>

    <!-- Show only if has edit permission -->
    <a-button
      v-if="permissionStore.hasPermission('project:edit')"
      @click="handleEdit">
      Edit
    </a-button>

    <!-- Show only for admins -->
    <a-button
      v-if="userStore.isAdmin"
      type="danger"
      @click="handleDelete">
      Delete
    </a-button>
  </div>
</template>
```

#### Permission Management

**Creating Permissions**:
1. Add permission record to `sys_permission` table via migration or admin UI
2. Assign permission to roles via `sys_role_permission` table
3. Frontend automatically receives updated permissions on next login/org switch

**Permission Naming Convention**:
- Format: `{module}:{action}` (e.g., `user:create`, `project:view`)
- Special permissions: `SuperAdmin`, `KBAdmin`, `SalesRegistration:Admin`
- Menu keys: Use descriptive names (e.g., `UserManagement`, `ProjectList`)

**Best Practices**:
1. Always check permissions before showing sensitive UI elements
2. Backend MUST validate permissions even if frontend hides UI
3. Use granular permissions for better control (separate view/create/edit/delete)
4. Document permission requirements in API comments
5. Test with different roles to ensure proper access control

## Code Style

### Backend (C#)
- Async/await for all async operations
- XML comments on public APIs
- ImplicitUsings and nullable reference types enabled
- Naming: `{Entity}Controller`, `{Entity}Service`, `{Name}Dto`, `{Name}Entity`

### Frontend (TypeScript/Vue 3)
- Single quotes, no semicolons, 2-space indentation
- 120 character line width
- PascalCase for component files and usage
- `<script setup lang="ts">` for all components
- Composition API with Pinia stores

## Testing

No automated test framework is configured. Verify changes manually by:
1. Running the backend and frontend dev servers
2. Testing affected features in the browser
3. Checking console for errors
4. Verifying database changes if applicable

## Common Pitfalls

1. **Forgetting OrgId filtering** - Most common security issue, can leak data across organizations
2. **Not validating permissions on backend** - Frontend hiding UI is not enough, backend MUST validate
3. **Forgetting role-based data filtering** - Non-admin users should only see data assigned to their roles
4. **Not using transactions** - Can cause data inconsistency in multi-table operations
5. **Manual layout instead of SplitLayout** - Loses resize/persistence features
6. **Double scrollbars** - Container sizing issues, ensure only one scrollable container
7. **Missing row numbers in tables** - UX requirement for all data tables
8. **Forgetting to update all three database migrations** - Breaks multi-DB support
9. **Using .Result on async calls** - Can cause deadlocks in ASP.NET
10. **Not checking SuperAdmin status** - SuperAdmin should bypass normal permission checks
11. **Hardcoding organization logic** - Always use current user's OrgId from context
12. **Exposing sensitive actions without permission checks** - Always validate before delete/update operations

## Database Schema

### Core Permission Tables

**sys_permission** - Permission definitions
- `Id`: Primary key
- `ParentId`: Parent permission ID (for tree structure)
- `Name`: Display name (e.g., "用户管理")
- `Code`: Unique permission code (e.g., "system:user:view")
- `Type`: Permission type - "MENU", "BUTTON", or "API"
- `Path`: Route path (for MENU type)
- `Component`: Frontend component path (for MENU type)
- `Query`: Query parameters to pass to component
- `Icon`: Icon name (for MENU type)
- `SortOrder`: Display order
- `IsVisible`: Whether to show in menu

**sys_role** - Role definitions
- `Id`: Primary key
- `Name`: Role display name (e.g., "管理员")
- `Code`: Unique role code (e.g., "ADMIN", "SuperAdmin")
- `Description`: Role description
- `IsSystem`: Whether it's a system built-in role (cannot be deleted)
- `DeptId`: Department ID (for department-level roles)

**sys_role_permission** - Role-Permission mapping
- `RoleId`: Foreign key to sys_role
- `PermissionId`: Foreign key to sys_permission
- Composite primary key: (RoleId, PermissionId)

**sys_user_role** - User-Role mapping
- `UserId`: Foreign key to sys_user
- `RoleId`: Foreign key to sys_role
- Composite primary key: (UserId, RoleId)

**sys_role_inheritance** - Role inheritance relationships
- `ParentRoleId`: Parent role that includes child role
- `ChildRoleId`: Child role that is included by parent
- Composite primary key: (ParentRoleId, ChildRoleId)
- When user has ParentRole, they automatically get ChildRole's permissions

### Multi-Tenant Tables

**sys_organization** - Organization/Tenant definitions
- `Id`: Primary key (0 = Demo organization)
- `Name`: Organization full name
- `Code`: Unique organization code (e.g., "ORGA")
- `Abbr`: Organization abbreviation
- `Type`: Organization type
- `Status`: Active/Inactive status

**sys_user_org** - User-Organization mapping
- `UserId`: Foreign key to sys_user
- `OrgId`: Foreign key to sys_organization
- `IsCurrent`: Whether this is user's current active organization
- Users can belong to multiple organizations

### Key Relationships

```
sys_user
  ├─→ sys_user_role ─→ sys_role
  │                      ├─→ sys_role_permission ─→ sys_permission
  │                      └─→ sys_role_inheritance (parent/child)
  └─→ sys_user_org ─→ sys_organization

Business Tables (Projects, Contracts, etc.)
  ├─→ OrgId (foreign key to sys_organization)
  └─→ RoleIds (comma-separated role IDs for access control)
```

### Permission Resolution Query Flow

1. Get user's direct roles from `sys_user_role`
2. Recursively resolve inherited roles from `sys_role_inheritance`
3. Check if any role is "SuperAdmin" → grant all permissions
4. Otherwise, get permissions from `sys_role_permission` for all effective roles
5. Return distinct permission codes to frontend

### Data Isolation Strategy

- **Organization Level**: All business data has `OrgId` column
- **Role Level**: Business data has `RoleIds` column (comma-separated)
- **Query Pattern**:
  ```csharp
  // Step 1: Filter by organization
  query = query.Where(x => x.OrgId == currentOrgId);

  // Step 2: Filter by role (if not admin)
  if (!isAdmin)
  {
      query = query.Where(x => roleIds.Any(rid => x.RoleIds.Contains(rid.ToString())));
  }
  ```

## Important Files

- `backend/omsapi/Program.cs` - Application startup and configuration
- `backend/omsapi/Data/OmsContext.cs` - Main database context
- `backend/omsapi/Services/AuthService.cs` - Authentication and permission resolution
- `backend/omsapi/Infrastructure/Extensions/ServiceCollectionExtensions.cs` - Service auto-registration
- `frontend/src/stores/user.ts` - User authentication and organization state
- `frontend/src/stores/permission.ts` - Dynamic routing and permissions
- `frontend/src/utils/request.ts` - HTTP client with auth handling
- `frontend/vite.config.ts` - Build configuration and dev proxy
