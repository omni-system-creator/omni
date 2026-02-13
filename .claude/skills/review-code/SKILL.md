---
name: review-code
description: Review code changes for OMS-specific patterns, security issues, and best practices
disable-model-invocation: false
allowed-tools: Read, Grep, Glob
---

# Code Review Skill

Perform comprehensive code review for OMS project following established patterns and security requirements.

## Review Checklist

### Backend (C#) Review

#### 1. Security & Architecture
- [ ] **OrgId Isolation**: All queries filter by OrgId
- [ ] **Ownership Verification**: Update/Delete verify OrgId ownership
- [ ] **Authorization**: Controllers have `[Authorize]` attribute
- [ ] **Input Validation**: DTOs have proper validation attributes
- [ ] **SQL Injection**: No string concatenation in queries
- [ ] **XSS Prevention**: Output encoding for user-generated content

#### 2. Service Layer
- [ ] **AutoInject**: Service has `[AutoInject(ServiceLifetime.Scoped)]`
- [ ] **Interface**: Service implements I{ServiceName} interface
- [ ] **Async/Await**: No `.Result` or `.Wait()` calls
- [ ] **Transaction**: Multi-table operations use `BeginTransaction()`
- [ ] **Error Handling**: Proper exception handling with meaningful messages
- [ ] **Null Checks**: Proper null handling for nullable types

#### 3. Controller Layer
- [ ] **ApiResponse**: Returns `ApiResponse<T>` wrapper
- [ ] **HTTP Methods**: Correct HTTP verbs (GET, POST, PUT, DELETE)
- [ ] **Route Naming**: Follows convention `api/[controller]`
- [ ] **XML Comments**: Public methods have XML documentation
- [ ] **Model Binding**: Proper use of `[FromBody]`, `[FromQuery]`, etc.

#### 4. Data Layer
- [ ] **Entity Naming**: Ends with `Entity` suffix
- [ ] **BaseEntity**: Inherits from BaseEntity (Id, OrgId, timestamps)
- [ ] **Navigation Properties**: Properly configured relationships
- [ ] **Indexes**: OrgId and frequently queried fields have indexes

#### 5. Code Quality
- [ ] **Naming Conventions**: PascalCase for public, camelCase for private
- [ ] **Single Responsibility**: Methods do one thing well
- [ ] **DRY**: No code duplication
- [ ] **Magic Numbers**: Constants instead of hardcoded values
- [ ] **Comments**: Complex logic is documented

### Frontend (Vue 3) Review

#### 1. UI Standards
- [ ] **SplitLayout**: Uses `SplitLayout` for resizable panels (not manual Flex/Grid)
- [ ] **Table Row Numbers**: Tables have row number column with pagination offset
- [ ] **Action Column**: Centered, uses icons with tooltips (not text)
- [ ] **Action Overflow**: More than 3 actions use `MoreOutlined` dropdown
- [ ] **Modal Draggable**: Complex modals use `useDraggableModal`
- [ ] **Container Sizing**: Containers adapt to parent (no double scrollbars)

#### 2. Component Structure
- [ ] **Script Setup**: Uses `<script setup lang="ts">`
- [ ] **Composition API**: Uses Composition API patterns
- [ ] **Auto Imports**: Relies on auto-imported Vue APIs and components
- [ ] **TypeScript**: Proper type definitions for props, emits, data
- [ ] **Props/Emits**: Defined with TypeScript types

#### 3. State Management
- [ ] **Reactive State**: Uses `ref`, `reactive` appropriately
- [ ] **Computed**: Derived state uses `computed`
- [ ] **Watchers**: Side effects use `watch` or `watchEffect`
- [ ] **Pinia Stores**: Complex state uses Pinia stores
- [ ] **Store Access**: Stores accessed via composition API

#### 4. API Integration
- [ ] **API Module**: API calls in `src/api/{module}.ts`
- [ ] **Request Utility**: Uses `request` from `@/utils/request`
- [ ] **Loading State**: Async operations have loading indicators
- [ ] **Error Handling**: Uses `message.error()` for user feedback
- [ ] **Success Feedback**: Uses `message.success()` for confirmations

#### 5. User Experience
- [ ] **Loading States**: Buttons show loading during async operations
- [ ] **Confirmation Dialogs**: Destructive actions require confirmation
- [ ] **Form Validation**: Forms have validation rules
- [ ] **Error Messages**: Clear, user-friendly error messages
- [ ] **Accessibility**: Proper labels, ARIA attributes where needed

#### 6. Code Quality
- [ ] **Naming**: PascalCase for components, camelCase for variables
- [ ] **Single Quotes**: Uses single quotes (Prettier config)
- [ ] **No Semicolons**: Follows no-semicolon style
- [ ] **2-Space Indent**: Consistent indentation
- [ ] **120 Char Width**: Lines under 120 characters
- [ ] **No Console**: No `console.log` in production code

### Database Migration Review

#### 1. Multi-Database Support
- [ ] **All Three DBs**: Migrations exist for MySQL, MSSQL, PostgreSQL
- [ ] **Same Version**: All three use the same version number
- [ ] **Correct Syntax**: Each uses database-specific syntax

#### 2. Schema Design
- [ ] **OrgId Field**: Business tables include OrgId
- [ ] **OrgId Index**: Index created on OrgId
- [ ] **Timestamps**: CreatedAt and UpdatedAt fields
- [ ] **Primary Key**: Auto-increment/identity/serial primary key
- [ ] **Data Types**: Appropriate types for each database

#### 3. Migration Quality
- [ ] **Idempotent**: Safe to run multiple times (IF NOT EXISTS)
- [ ] **Backward Compatible**: Doesn't break existing code
- [ ] **Data Migration**: Includes data updates if needed
- [ ] **Comments**: Complex migrations are documented

### Common Issues to Flag

#### Critical Issues (Must Fix)
1. Missing OrgId filter in queries
2. Update/Delete without OrgId verification
3. Using `.Result` or `.Wait()` on async calls
4. SQL injection vulnerabilities
5. Missing authorization checks
6. Hardcoded credentials or secrets

#### High Priority Issues
1. Missing transaction for multi-table operations
2. No error handling for API calls
3. Missing loading states
4. No form validation
5. Manual layout instead of SplitLayout
6. Missing row numbers in tables

#### Medium Priority Issues
1. Missing XML documentation
2. Code duplication
3. Magic numbers
4. Poor naming conventions
5. Missing TypeScript types
6. Console.log statements

#### Low Priority Issues
1. Minor style inconsistencies
2. Missing comments for complex logic
3. Could use more descriptive variable names
4. Could extract to helper function

## Review Process

1. **Identify Changed Files**: Determine which files were modified
2. **Categorize Changes**: Backend, frontend, database, config, etc.
3. **Apply Relevant Checklist**: Use appropriate checklist for each file type
4. **Flag Issues**: List all issues found with severity level
5. **Provide Recommendations**: Suggest specific fixes for each issue
6. **Highlight Good Practices**: Note what was done well

## Output Format

```
Code Review Report
==================

Summary:
- Files reviewed: X
- Critical issues: X
- High priority: X
- Medium priority: X
- Low priority: X

Critical Issues:
1. [File:Line] Issue description
   Recommendation: Specific fix

High Priority Issues:
1. [File:Line] Issue description
   Recommendation: Specific fix

Good Practices:
- What was done well
- Patterns followed correctly

Overall Assessment:
[Summary of code quality and readiness]
```

## Auto-Fix Capability

For simple, safe fixes, offer to automatically fix:
- Add missing OrgId filters
- Add XML documentation
- Fix formatting issues
- Add missing validation attributes
- Remove console.log statements

Always ask for confirmation before modifying code.
