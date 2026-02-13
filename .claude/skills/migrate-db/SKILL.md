---
name: migrate-db
description: Create database migration files for all three databases (MySQL, MSSQL, PostgreSQL) when schema changes are needed
disable-model-invocation: false
allowed-tools: Read, Write, Glob, Bash
---

# Database Migration Skill

Create SQL migration files for all three supported databases when schema changes are needed.

## Instructions

When the user requests a database schema change (add table, add column, modify column, etc.), create migration files for all three databases.

### 1. Determine Next Version Number

Check existing migrations to find the next version:

```bash
# Check MySQL migrations
ls database/mysql/

# Check MSSQL migrations
ls database/mssql/

# Check PostgreSQL migrations
ls database/postgresql/
```

Find the highest version number (e.g., V0023) and use the next sequential number (V0024).

### 2. Create Migration Files

**CRITICAL**: Must create migration files for ALL THREE databases with the SAME version number.

File naming pattern: `V{version}_{description}.sql`

Example:
- `database/mysql/V0024_Add_Product_Table.sql`
- `database/mssql/V0024_Add_Product_Table.sql`
- `database/postgresql/V0024_Add_Product_Table.sql`

### 3. Database-Specific Syntax

Each database has different SQL syntax. Use the correct syntax for each:

#### MySQL Syntax
```sql
-- Auto-increment primary key
CREATE TABLE `table_name` (
    `Id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `OrgId` BIGINT NOT NULL,
    `Name` VARCHAR(200) NOT NULL,
    `Description` TEXT,
    `Price` DECIMAL(18,2),
    `IsActive` TINYINT(1) DEFAULT 1,
    `CreatedAt` DATETIME(6) NOT NULL,
    `UpdatedAt` DATETIME(6) NOT NULL,
    INDEX `IX_table_name_OrgId` (`OrgId`),
    INDEX `IX_table_name_Name` (`Name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Add column
ALTER TABLE `table_name` ADD COLUMN `NewColumn` VARCHAR(100) NULL;

-- Modify column
ALTER TABLE `table_name` MODIFY COLUMN `ExistingColumn` VARCHAR(200) NOT NULL;

-- Add index
CREATE INDEX `IX_table_name_Column` ON `table_name` (`Column`);

-- Drop column
ALTER TABLE `table_name` DROP COLUMN `OldColumn`;
```

#### SQL Server Syntax
```sql
-- Identity primary key
CREATE TABLE [table_name] (
    [Id] BIGINT IDENTITY(1,1) PRIMARY KEY,
    [OrgId] BIGINT NOT NULL,
    [Name] NVARCHAR(200) NOT NULL,
    [Description] NVARCHAR(MAX),
    [Price] DECIMAL(18,2),
    [IsActive] BIT DEFAULT 1,
    [CreatedAt] DATETIME2 NOT NULL,
    [UpdatedAt] DATETIME2 NOT NULL,
    INDEX [IX_table_name_OrgId] ([OrgId]),
    INDEX [IX_table_name_Name] ([Name])
);

-- Add column
ALTER TABLE [table_name] ADD [NewColumn] NVARCHAR(100) NULL;

-- Modify column
ALTER TABLE [table_name] ALTER COLUMN [ExistingColumn] NVARCHAR(200) NOT NULL;

-- Add index
CREATE INDEX [IX_table_name_Column] ON [table_name] ([Column]);

-- Drop column
ALTER TABLE [table_name] DROP COLUMN [OldColumn];
```

#### PostgreSQL Syntax
```sql
-- Serial primary key
CREATE TABLE "table_name" (
    "Id" BIGSERIAL PRIMARY KEY,
    "OrgId" BIGINT NOT NULL,
    "Name" VARCHAR(200) NOT NULL,
    "Description" TEXT,
    "Price" DECIMAL(18,2),
    "IsActive" BOOLEAN DEFAULT true,
    "CreatedAt" TIMESTAMP NOT NULL,
    "UpdatedAt" TIMESTAMP NOT NULL
);

CREATE INDEX "IX_table_name_OrgId" ON "table_name" ("OrgId");
CREATE INDEX "IX_table_name_Name" ON "table_name" ("Name");

-- Add column
ALTER TABLE "table_name" ADD COLUMN "NewColumn" VARCHAR(100) NULL;

-- Modify column
ALTER TABLE "table_name" ALTER COLUMN "ExistingColumn" TYPE VARCHAR(200);
ALTER TABLE "table_name" ALTER COLUMN "ExistingColumn" SET NOT NULL;

-- Add index
CREATE INDEX "IX_table_name_Column" ON "table_name" ("Column");

-- Drop column
ALTER TABLE "table_name" DROP COLUMN "OldColumn";
```

### 4. Common Data Type Mappings

| C# Type | MySQL | SQL Server | PostgreSQL |
|---------|-------|------------|------------|
| long | BIGINT | BIGINT | BIGINT |
| int | INT | INT | INTEGER |
| string | VARCHAR(n) | NVARCHAR(n) | VARCHAR(n) |
| string (long) | TEXT | NVARCHAR(MAX) | TEXT |
| decimal | DECIMAL(18,2) | DECIMAL(18,2) | DECIMAL(18,2) |
| bool | TINYINT(1) | BIT | BOOLEAN |
| DateTime | DATETIME(6) | DATETIME2 | TIMESTAMP |
| Guid | CHAR(36) | UNIQUEIDENTIFIER | UUID |

### 5. Standard Fields

All business entities should include:
- `Id` - Primary key (auto-increment/identity/serial)
- `OrgId` - Organization ID for multi-tenant isolation (REQUIRED)
- `CreatedAt` - Creation timestamp
- `UpdatedAt` - Last update timestamp

Always add an index on `OrgId` for query performance.

### 6. Migration Best Practices

1. **Idempotent**: Migrations should be safe to run multiple times
   - Use `IF NOT EXISTS` for CREATE TABLE
   - Check column existence before ALTER TABLE ADD COLUMN

2. **Backward Compatible**: Avoid breaking changes
   - Add columns as NULL first, then update data, then set NOT NULL
   - Don't drop columns that might be in use

3. **Data Migration**: If changing data structure
   - Include UPDATE statements to migrate existing data
   - Test with sample data first

4. **Indexes**: Add indexes for:
   - Foreign keys
   - Frequently queried columns
   - OrgId (always)

5. **Comments**: Add comments explaining complex migrations

### 7. Example: Complete Migration

**Scenario**: Add a new Product table

**MySQL** (`database/mysql/V0024_Add_Product_Table.sql`):
```sql
-- Add Product table for product management
CREATE TABLE IF NOT EXISTS `products` (
    `Id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `OrgId` BIGINT NOT NULL,
    `Name` VARCHAR(200) NOT NULL,
    `Code` VARCHAR(50) NOT NULL,
    `Description` TEXT,
    `Price` DECIMAL(18,2) NOT NULL DEFAULT 0,
    `Stock` INT NOT NULL DEFAULT 0,
    `IsActive` TINYINT(1) NOT NULL DEFAULT 1,
    `CreatedAt` DATETIME(6) NOT NULL,
    `UpdatedAt` DATETIME(6) NOT NULL,
    INDEX `IX_products_OrgId` (`OrgId`),
    INDEX `IX_products_Code` (`Code`),
    INDEX `IX_products_Name` (`Name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**SQL Server** (`database/mssql/V0024_Add_Product_Table.sql`):
```sql
-- Add Product table for product management
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'products')
BEGIN
    CREATE TABLE [products] (
        [Id] BIGINT IDENTITY(1,1) PRIMARY KEY,
        [OrgId] BIGINT NOT NULL,
        [Name] NVARCHAR(200) NOT NULL,
        [Code] NVARCHAR(50) NOT NULL,
        [Description] NVARCHAR(MAX),
        [Price] DECIMAL(18,2) NOT NULL DEFAULT 0,
        [Stock] INT NOT NULL DEFAULT 0,
        [IsActive] BIT NOT NULL DEFAULT 1,
        [CreatedAt] DATETIME2 NOT NULL,
        [UpdatedAt] DATETIME2 NOT NULL,
        INDEX [IX_products_OrgId] ([OrgId]),
        INDEX [IX_products_Code] ([Code]),
        INDEX [IX_products_Name] ([Name])
    );
END
```

**PostgreSQL** (`database/postgresql/V0024_Add_Product_Table.sql`):
```sql
-- Add Product table for product management
CREATE TABLE IF NOT EXISTS "products" (
    "Id" BIGSERIAL PRIMARY KEY,
    "OrgId" BIGINT NOT NULL,
    "Name" VARCHAR(200) NOT NULL,
    "Code" VARCHAR(50) NOT NULL,
    "Description" TEXT,
    "Price" DECIMAL(18,2) NOT NULL DEFAULT 0,
    "Stock" INTEGER NOT NULL DEFAULT 0,
    "IsActive" BOOLEAN NOT NULL DEFAULT true,
    "CreatedAt" TIMESTAMP NOT NULL,
    "UpdatedAt" TIMESTAMP NOT NULL
);

CREATE INDEX IF NOT EXISTS "IX_products_OrgId" ON "products" ("OrgId");
CREATE INDEX IF NOT EXISTS "IX_products_Code" ON "products" ("Code");
CREATE INDEX IF NOT EXISTS "IX_products_Name" ON "products" ("Name");
```

### 8. Verification

After creating migrations:
1. Verify all three files exist with the same version number
2. Check syntax is correct for each database
3. Ensure OrgId field and index are included
4. Confirm naming conventions are followed
5. Test migrations on local database if possible

### 9. Rollback Migrations

If needed, create rollback migrations with the same version:
- `V0024_Add_Product_Table_Rollback.sql`

Include DROP TABLE or ALTER TABLE statements to reverse the changes.
