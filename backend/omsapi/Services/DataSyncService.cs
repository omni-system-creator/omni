using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;
using omsapi.Data;
using omsapi.Infrastructure.Attributes;
using System.Reflection;

namespace omsapi.Services
{
    [AutoInject(ServiceLifetime.Scoped)]
    public class DataSyncService
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<DataSyncService> _logger;

        public DataSyncService(IConfiguration configuration, ILogger<DataSyncService> logger)
        {
            _configuration = configuration;
            _logger = logger;
        }

        public async Task<string> SyncFromMysqlToMssqlAsync()
        {
            try
            {
                // 1. 配置源数据库 (MySQL)
                var mysqlConnStr = _configuration.GetConnectionString("DefaultConnection_mysql");
                if (string.IsNullOrEmpty(mysqlConnStr)) return "Error: MySQL connection string (DefaultConnection_mysql) not found.";

                var mysqlOptionsBuilder = new DbContextOptionsBuilder<OmsContext>();
                mysqlOptionsBuilder.UseMySql(mysqlConnStr, new MySqlServerVersion(new Version(8, 0, 21)));
                using var sourceDb = new OmsContext(mysqlOptionsBuilder.Options);

                // 2. 配置目标数据库 (MSSQL)
                var mssqlConnStr = _configuration.GetConnectionString("DefaultConnection_mssql");
                if (string.IsNullOrEmpty(mssqlConnStr)) return "Error: MSSQL connection string (DefaultConnection_mssql) not found.";

                var mssqlOptionsBuilder = new DbContextOptionsBuilder<OmsContextSqlServer>();
                mssqlOptionsBuilder.UseSqlServer(mssqlConnStr);
                using var targetDb = new OmsContextSqlServer(mssqlOptionsBuilder.Options);

                // 3. 连接并禁用约束
                await targetDb.Database.OpenConnectionAsync();
                _logger.LogInformation("Disabling constraints on MSSQL...");
                await targetDb.Database.ExecuteSqlRawAsync("EXEC sp_msforeachtable \"ALTER TABLE ? NOCHECK CONSTRAINT all\"");

                // 4. 获取所有实体类型并排序（简单起见，我们先禁用约束，所以顺序不重要，但为了逻辑清晰，我们按字母顺序）
                var entityTypes = targetDb.Model.GetEntityTypes().ToList();
                var results = new List<string>();

                foreach (var entityType in entityTypes)
                {
                    var clrType = entityType.ClrType;
                    var tableName = entityType.GetTableName();
                    var schema = entityType.GetSchema() ?? "dbo";
                    var fullTableName = $"[{schema}].[{tableName}]";

                    _logger.LogInformation($"Syncing table: {fullTableName}");

                    // 4.1 读取源数据
                    // 使用反射调用 Set<T>()
                    var setMethod = typeof(DbContext).GetMethod(nameof(DbContext.Set), Type.EmptyTypes)?.MakeGenericMethod(clrType);
                    if (setMethod == null) continue;

                    var queryable = (IQueryable<object>)setMethod.Invoke(sourceDb, null)!;
                    var data = await queryable.AsNoTracking().ToListAsync();

                    if (data.Count == 0)
                    {
                        results.Add($"{tableName}: 0 rows (Skipped)");
                        continue;
                    }

                    // Fix DateTime Kind for PostgreSQL
                    foreach (var item in data)
                    {
                        FixDateTimeKind(item);
                    }

                    // 4.2 清理目标表数据
                    try 
                    {
#pragma warning disable EF1002 // SQL Injection: Table name from EF Model is trusted
                        await targetDb.Database.ExecuteSqlRawAsync($"DELETE FROM {fullTableName}");
#pragma warning restore EF1002
                    }
                    catch (Exception ex)
                    {
                        _logger.LogWarning($"Failed to clear table {tableName}: {ex.Message}. Attempting to proceed with inserts.");
                    }

                    // 4.3 插入数据
                    // 检查是否有自增列 (Identity)
                    // 注意：Guid 类型即使是 OnAdd 也不是 Identity，不需要 SET IDENTITY_INSERT
                    var hasIdentity = entityType.GetProperties().Any(p => 
                        p.ValueGenerated == Microsoft.EntityFrameworkCore.Metadata.ValueGenerated.OnAdd &&
                        (p.ClrType == typeof(int) || p.ClrType == typeof(long))
                    );

                    if (hasIdentity)
                    {
#pragma warning disable EF1002 // SQL Injection: Table name from EF Model is trusted
                        await targetDb.Database.ExecuteSqlRawAsync($"SET IDENTITY_INSERT {fullTableName} ON");
#pragma warning restore EF1002
                    }

                    await targetDb.AddRangeAsync(data);
                    await targetDb.SaveChangesAsync();

                    if (hasIdentity)
                    {
#pragma warning disable EF1002 // SQL Injection: Table name from EF Model is trusted
                        await targetDb.Database.ExecuteSqlRawAsync($"SET IDENTITY_INSERT {fullTableName} OFF");
#pragma warning restore EF1002
                    }

                    // Detach entities to avoid tracking issues if we were to reuse them (though we are creating new instances ideally)
                    // But since we are using two different context instances, we don't need to detach from sourceDb.
                    // However, targetDb will track them. We should clear tracker to free memory.
                    targetDb.ChangeTracker.Clear();

                    results.Add($"{tableName}: {data.Count} rows synced");
                }

                // 5. 重新启用约束
                _logger.LogInformation("Re-enabling constraints on MSSQL...");
                await targetDb.Database.ExecuteSqlRawAsync("EXEC sp_msforeachtable \"ALTER TABLE ? WITH CHECK CHECK CONSTRAINT all\"");

                return string.Join("\n", results);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Sync failed");
                return $"Sync failed: {ex.Message}\n{ex.StackTrace}";
            }
        }

        public async Task<string> SyncFromMysqlToPostgresAsync()
        {
            try
            {
                // 1. 配置源数据库 (MySQL)
                var mysqlConnStr = _configuration.GetConnectionString("DefaultConnection_mysql");
                if (string.IsNullOrEmpty(mysqlConnStr)) return "Error: MySQL connection string (DefaultConnection_mysql) not found.";

                var mysqlOptionsBuilder = new DbContextOptionsBuilder<OmsContext>();
                mysqlOptionsBuilder.UseMySql(mysqlConnStr, new MySqlServerVersion(new Version(8, 0, 21)));
                using var sourceDb = new OmsContext(mysqlOptionsBuilder.Options);

                // 2. 配置目标数据库 (PostgreSQL)
                var pgConnStr = _configuration.GetConnectionString("DefaultConnection_postgres");
                if (string.IsNullOrEmpty(pgConnStr)) return "Error: PostgreSQL connection string (DefaultConnection_postgres) not found.";

                var pgOptionsBuilder = new DbContextOptionsBuilder<OmsContextPostgreSql>();
                pgOptionsBuilder.UseNpgsql(pgConnStr);
                using var targetDb = new OmsContextPostgreSql(pgOptionsBuilder.Options);

                // 3. 连接
                await targetDb.Database.OpenConnectionAsync();
                
                // 4. 获取所有实体类型并排序 (拓扑排序，确保父表先插入)
                var entityTypes = GetSortedEntityTypes(targetDb);
                var results = new List<string>();

                foreach (var entityType in entityTypes)
                {
                    var clrType = entityType.ClrType;
                    var tableName = entityType.GetTableName();
                    var schema = entityType.GetSchema() ?? "public";
                    var fullTableName = $"\"{schema}\".\"{tableName}\"";

                    _logger.LogInformation($"Syncing table: {fullTableName}");

                    // 4.1 读取源数据
                    var setMethod = typeof(DbContext).GetMethod(nameof(DbContext.Set), Type.EmptyTypes)?.MakeGenericMethod(clrType);
                    if (setMethod == null) continue;

                    var queryable = (IQueryable<object>)setMethod.Invoke(sourceDb, null)!;
                    var data = await queryable.AsNoTracking().ToListAsync();

                    if (data.Count == 0)
                    {
                        // 即使没有数据，也要清空目标表，以防目标表有残留数据
                        // 但如果是 CASCADE 模式，可能已经被父表清空了，再清空一次也无妨
                        // 不过为了安全，我们还是执行清空
                    }

                    // Fix DateTime Kind for PostgreSQL
                    foreach (var item in data)
                    {
                        FixDateTimeKind(item);
                    }

                    // 4.2 清理目标表数据
                    try 
                    {
#pragma warning disable EF1002 // SQL Injection: Table name from EF Model is trusted
                        await targetDb.Database.ExecuteSqlRawAsync($"TRUNCATE TABLE {fullTableName} CASCADE");
#pragma warning restore EF1002
                    }
                    catch (Exception ex)
                    {
                        _logger.LogWarning($"Failed to truncate table {tableName}: {ex.Message}. Attempting to delete.");
                        try 
                        {
#pragma warning disable EF1002 // SQL Injection: Table name from EF Model is trusted
                            await targetDb.Database.ExecuteSqlRawAsync($"DELETE FROM {fullTableName}");
#pragma warning restore EF1002
                        }
                        catch (Exception deleteEx)
                        {
                             _logger.LogError($"Failed to delete from table {tableName}: {deleteEx.Message}");
                             // 如果清空失败，插入可能会违反主键约束，但我们继续尝试
                        }
                    }

                    if (data.Count == 0)
                    {
                        results.Add($"{tableName}: 0 rows (Skipped/Cleared)");
                        continue;
                    }

                    // 4.3 插入数据
                    await targetDb.AddRangeAsync(data);
                    await targetDb.SaveChangesAsync();

                    // 4.4 重置序列 (可选，但推荐)
                    var identityProp = entityType.GetProperties().FirstOrDefault(p => 
                        p.ValueGenerated == ValueGenerated.OnAdd &&
                        (p.ClrType == typeof(int) || p.ClrType == typeof(long))
                    );

                    if (identityProp != null)
                    {
                        try
                        {
                            var columnName = identityProp.GetColumnName();
                            // PostgreSQL 序列通常命名为 table_column_seq
                            // 使用 setval 重置序列到当前最大值
#pragma warning disable EF1002 // SQL Injection: Table name from EF Model is trusted
                             await targetDb.Database.ExecuteSqlRawAsync($"SELECT setval(pg_get_serial_sequence('{fullTableName}', '{columnName}'), (SELECT MAX(\"{columnName}\") FROM {fullTableName}))");
#pragma warning restore EF1002
                        }
                        catch (Exception ex)
                        {
                            _logger.LogWarning($"Failed to reset sequence for table {tableName}: {ex.Message}");
                        }
                    }

                    targetDb.ChangeTracker.Clear();
                    results.Add($"{tableName}: {data.Count} rows synced");
                }

                return string.Join("\n", results);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Sync failed");
                return $"Sync failed: {ex.Message}\n{ex.StackTrace}";
            }
        }

        private List<IEntityType> GetSortedEntityTypes(DbContext context)
        {
            var entityTypes = context.Model.GetEntityTypes().ToList();
            var sorted = new List<IEntityType>();
            var visited = new HashSet<IEntityType>();
            var visiting = new HashSet<IEntityType>();

            void Visit(IEntityType item)
            {
                if (visited.Contains(item)) return;
                if (visiting.Contains(item)) return; // Cycle detected

                visiting.Add(item);

                foreach (var fk in item.GetForeignKeys())
                {
                    var principal = fk.PrincipalEntityType;
                    if (principal != item) // Ignore self-referencing
                    {
                        Visit(principal);
                    }
                }

                visiting.Remove(item);
                visited.Add(item);
                sorted.Add(item);
            }

            foreach (var entityType in entityTypes)
            {
                Visit(entityType);
            }

            return sorted;
        }

        private void FixDateTimeKind(object entity)
        {
            if (entity == null) return;
            var properties = entity.GetType().GetProperties()
                .Where(p => p.PropertyType == typeof(DateTime) || p.PropertyType == typeof(DateTime?));

            foreach (var prop in properties)
            {
                var val = prop.GetValue(entity);
                if (val is DateTime dt)
                {
                    if (dt.Kind == DateTimeKind.Unspecified)
                    {
                        prop.SetValue(entity, DateTime.SpecifyKind(dt, DateTimeKind.Utc));
                    }
                    else if (dt.Kind == DateTimeKind.Local)
                    {
                        prop.SetValue(entity, dt.ToUniversalTime());
                    }
                }
            }
        }
    }
}
