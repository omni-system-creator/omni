---
name: add-entity
description: Add a new database entity with migrations for all three databases (MySQL, MSSQL, PostgreSQL)
disable-model-invocation: false
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Add Entity Skill

Add a new database entity to the OMS system with proper multi-database support.

## Instructions

When the user requests to add a new entity (e.g., "add a Product entity"), follow these steps:

### 1. Understand Requirements
- Ask the user for entity properties if not specified
- Confirm the entity name and fields
- Determine if this is a standard business entity (uses OmsContext) or vector/AI entity (uses OmsPgContext)

### 2. Create Entity Class
- Location: `backend/omsapi/Models/Entities/{EntityName}Entity.cs`
- Must inherit from `BaseEntity` (includes Id, CreatedAt, UpdatedAt, OrgId)
- Add XML documentation comments
- Use proper data annotations for validation
- Example structure:
```csharp
namespace omsapi.Models.Entities
{
    /// <summary>
    /// {Entity description}
    /// </summary>
    public class {EntityName}Entity : BaseEntity
    {
        /// <summary>
        /// Property description
        /// </summary>
        public string PropertyName { get; set; } = string.Empty;

        // Add navigation properties if needed
    }
}
```

### 3. Update DbContext
- For standard entities: Add to `backend/omsapi/Data/OmsContext.cs`
- For vector entities: Add to `backend/omsapi/Data/OmsPgContext.cs`
- Add DbSet property: `public DbSet<{EntityName}Entity> {EntityName}s { get; set; }`
- Configure entity in `OnModelCreating` if needed (indexes, relationships, etc.)

### 4. Create Database Migrations
**CRITICAL**: Must create migrations for ALL THREE databases:

#### MySQL Migration
- File: `database/mysql/V{next_version}_Add_{EntityName}_Table.sql`
- Use MySQL syntax (AUTO_INCREMENT, backticks, etc.)

#### SQL Server Migration
- File: `database/mssql/V{next_version}_Add_{EntityName}_Table.sql`
- Use SQL Server syntax (IDENTITY, square brackets, etc.)

#### PostgreSQL Migration
- File: `database/postgresql/V{next_version}_Add_{EntityName}_Table.sql`
- Use PostgreSQL syntax (SERIAL, double quotes if needed, etc.)

**Migration Template**:
```sql
-- MySQL
CREATE TABLE `{table_name}` (
    `Id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `OrgId` BIGINT NOT NULL,
    `CreatedAt` DATETIME(6) NOT NULL,
    `UpdatedAt` DATETIME(6) NOT NULL,
    -- Add custom fields here
    INDEX `IX_{table_name}_OrgId` (`OrgId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- SQL Server
CREATE TABLE [{table_name}] (
    [Id] BIGINT IDENTITY(1,1) PRIMARY KEY,
    [OrgId] BIGINT NOT NULL,
    [CreatedAt] DATETIME2 NOT NULL,
    [UpdatedAt] DATETIME2 NOT NULL,
    -- Add custom fields here
    INDEX [IX_{table_name}_OrgId] ([OrgId])
);

-- PostgreSQL
CREATE TABLE "{table_name}" (
    "Id" BIGSERIAL PRIMARY KEY,
    "OrgId" BIGINT NOT NULL,
    "CreatedAt" TIMESTAMP NOT NULL,
    "UpdatedAt" TIMESTAMP NOT NULL,
    -- Add custom fields here
);
CREATE INDEX "IX_{table_name}_OrgId" ON "{table_name}" ("OrgId");
```

### 5. Determine Next Version Number
- Check existing migration files in each database folder
- Find the highest version number (e.g., V0023)
- Use next sequential number for all three databases

### 6. Verify
- Ensure all three migration files are created
- Check that entity is added to correct DbContext
- Confirm proper inheritance from BaseEntity
- Verify OrgId field and index are included

## Important Notes

- **OrgId is mandatory** for all business entities (multi-tenant isolation)
- **All three databases** must have migrations - no exceptions
- Use consistent version numbers across all three databases
- Follow naming conventions: `{EntityName}Entity` for class, `{table_name}` for database table
- Add XML comments for documentation
- Consider adding indexes for frequently queried fields
