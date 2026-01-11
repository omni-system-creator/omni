using Microsoft.Data.SqlClient;
using omsapi.Models.Dtos.Data;
using omsapi.Models.Entities.Data;
using System.Data;
using System.Text;
using System.Text.Json;

namespace omsapi.Services.DataSourceAdapters
{
    public class SqlServerAdapter : IDatabaseAdapter
    {
        private string BuildConnectionString(DataSourceConnection connection, string? database = null)
        {
            var builder = new SqlConnectionStringBuilder
            {
                DataSource = $"{connection.Host},{connection.Port}",
                UserID = connection.User,
                Password = connection.Password,
                InitialCatalog = database ?? connection.Database,
                TrustServerCertificate = true // Simplify setup
            };
            return builder.ConnectionString;
        }

        public async Task<bool> TestConnectionAsync(DataSourceConnection connection)
        {
            try
            {
                using var sqlConnection = new SqlConnection(BuildConnectionString(connection));
                await sqlConnection.OpenAsync();
                return true;
            }
            catch
            {
                return false;
            }
        }

        public async Task<IEnumerable<DatabaseSchemaDto>> GetDatabasesAsync(DataSourceConnection connection)
        {
            using var sqlConnection = new SqlConnection(BuildConnectionString(connection));
            await sqlConnection.OpenAsync();

            var databases = new List<DatabaseSchemaDto>();
            // Exclude system databases
            var sql = @"
                SELECT name, collation_name
                FROM sys.databases 
                WHERE name NOT IN ('master', 'tempdb', 'model', 'msdb')
                ORDER BY name";

            using var command = new SqlCommand(sql, sqlConnection);
            using var reader = await command.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                databases.Add(new DatabaseSchemaDto
                {
                    Name = reader.GetString(0),
                    Collation = reader.IsDBNull(1) ? null : reader.GetString(1)
                });
            }

            return databases;
        }

        public async Task<bool> CreateDatabaseAsync(DataSourceConnection connection, CreateDatabaseDto dto)
        {
            // Connect to master to create database
            using var sqlConnection = new SqlConnection(BuildConnectionString(connection, "master"));
            await sqlConnection.OpenAsync();

            var sqlBuilder = new StringBuilder($"CREATE DATABASE [{dto.Name}]");
            
            if (!string.IsNullOrEmpty(dto.Collation))
            {
                sqlBuilder.Append($" COLLATE {dto.Collation}");
            }

            using var command = new SqlCommand(sqlBuilder.ToString(), sqlConnection);
            await command.ExecuteNonQueryAsync();
            return true;
        }

        public async Task<IEnumerable<TableSchemaDto>> GetTablesAsync(DataSourceConnection connection, string databaseName)
        {
            using var sqlConnection = new SqlConnection(BuildConnectionString(connection, databaseName));
            await sqlConnection.OpenAsync();

            var tables = new List<TableSchemaDto>();
            var sql = @"
                SELECT 
                    t.name,
                    ep.value as comment,
                    p.rows,
                    t.create_date
                FROM sys.tables t
                LEFT JOIN sys.extended_properties ep ON t.object_id = ep.major_id AND ep.minor_id = 0 AND ep.name = 'MS_Description'
                LEFT JOIN sys.partitions p ON t.object_id = p.object_id AND p.index_id IN (0,1)
                ORDER BY t.name";

            using var command = new SqlCommand(sql, sqlConnection);
            using var reader = await command.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                tables.Add(new TableSchemaDto
                {
                    Name = reader.GetString(0),
                    Comment = reader.IsDBNull(1) ? null : reader.GetString(1), // Assuming value is string
                    Rows = reader.IsDBNull(2) ? 0 : reader.GetInt64(2),
                    CreateTime = reader.GetDateTime(3)
                });
            }

            return tables;
        }

        public async Task<bool> CreateTableAsync(DataSourceConnection connection, string databaseName, CreateTableDto dto)
        {
            using var sqlConnection = new SqlConnection(BuildConnectionString(connection, databaseName));
            await sqlConnection.OpenAsync();

            var sqlBuilder = new StringBuilder($"CREATE TABLE [{dto.Name}] (");
            var columnDefinitions = new List<string>();
            var primaryKeys = new List<string>();

            foreach (var col in dto.Columns)
            {
                var colDef = new StringBuilder($"[{col.Name}] {col.DataType}");

                // Length handling
                if (col.DataType.ToLower().Contains("char") || col.DataType.ToLower().Contains("binary"))
                {
                    colDef.Append($"({(col.Length > 0 ? col.Length.ToString() : "MAX")})");
                }
                else if (col.DataType.ToLower() == "decimal" || col.DataType.ToLower() == "numeric")
                {
                     // Default precision/scale if needed, or parameterize
                     colDef.Append("(18,2)"); 
                }

                if (col.IsAutoIncrement && (col.DataType.Contains("int") || col.DataType.Contains("numeric")))
                {
                    colDef.Append(" IDENTITY(1,1)");
                }

                if (!col.IsNullable)
                {
                    colDef.Append(" NOT NULL");
                }
                else
                {
                    colDef.Append(" NULL");
                }

                if (!string.IsNullOrEmpty(col.DefaultValue))
                {
                    if (col.DataType.ToLower().Contains("char") || col.DataType.ToLower().Contains("text") || col.DataType.ToLower().Contains("date") || col.DataType.ToLower().Contains("time"))
                    {
                         colDef.Append($" DEFAULT '{col.DefaultValue.Replace("'", "''")}'");
                    }
                    else
                    {
                         colDef.Append($" DEFAULT {col.DefaultValue}");
                    }
                }
                
                // Note: SQL Server doesn't support inline column comments in CREATE TABLE easily without stored procedures
                
                columnDefinitions.Add(colDef.ToString());

                if (col.IsPrimaryKey)
                {
                    primaryKeys.Add($"[{col.Name}]");
                }
            }

            if (!columnDefinitions.Any())
            {
                 throw new ArgumentException("At least one column is required");
            }

            sqlBuilder.Append(string.Join(", ", columnDefinitions));

            if (primaryKeys.Any())
            {
                sqlBuilder.Append($", PRIMARY KEY ({string.Join(", ", primaryKeys)})");
            }

            sqlBuilder.Append(")");

            using var command = new SqlCommand(sqlBuilder.ToString(), sqlConnection);
            await command.ExecuteNonQueryAsync();

            // Add comments via sp_addextendedproperty
            if (!string.IsNullOrEmpty(dto.Comment))
            {
                var commentSql = "EXEC sp_addextendedproperty @name = N'MS_Description', @value = @value, @level0type = N'SCHEMA', @level0name = 'dbo', @level1type = N'TABLE', @level1name = @tableName";
                using var commentCmd = new SqlCommand(commentSql, sqlConnection);
                commentCmd.Parameters.AddWithValue("@value", dto.Comment);
                commentCmd.Parameters.AddWithValue("@tableName", dto.Name);
                await commentCmd.ExecuteNonQueryAsync();
            }

            foreach(var col in dto.Columns)
            {
                if (!string.IsNullOrEmpty(col.Comment))
                {
                    var colCommentSql = "EXEC sp_addextendedproperty @name = N'MS_Description', @value = @value, @level0type = N'SCHEMA', @level0name = 'dbo', @level1type = N'TABLE', @level1name = @tableName, @level2type = N'COLUMN', @level2name = @colName";
                    using var colCommentCmd = new SqlCommand(colCommentSql, sqlConnection);
                    colCommentCmd.Parameters.AddWithValue("@value", col.Comment);
                    colCommentCmd.Parameters.AddWithValue("@tableName", dto.Name);
                    colCommentCmd.Parameters.AddWithValue("@colName", col.Name);
                    await colCommentCmd.ExecuteNonQueryAsync();
                }
            }

            return true;
        }

        public async Task<IEnumerable<ColumnSchemaDto>> GetColumnsAsync(DataSourceConnection connection, string databaseName, string tableName)
        {
            using var sqlConnection = new SqlConnection(BuildConnectionString(connection, databaseName));
            await sqlConnection.OpenAsync();

            var columns = new List<ColumnSchemaDto>();
            var sql = @"
                SELECT 
                    c.name, 
                    t.name as type_name, 
                    c.max_length,
                    c.is_nullable, 
                    ISNULL(i.is_primary_key, 0) as is_primary,
                    object_definition(c.default_object_id) as default_value,
                    ep.value as comment,
                    c.column_id
                FROM sys.columns c
                JOIN sys.types t ON c.user_type_id = t.user_type_id
                LEFT JOIN sys.index_columns ic ON ic.object_id = c.object_id AND ic.column_id = c.column_id
                LEFT JOIN sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id AND i.is_primary_key = 1
                LEFT JOIN sys.extended_properties ep ON ep.major_id = c.object_id AND ep.minor_id = c.column_id AND ep.name = 'MS_Description'
                WHERE c.object_id = OBJECT_ID(@tableName)
                ORDER BY c.column_id";

            using var command = new SqlCommand(sql, sqlConnection);
            command.Parameters.AddWithValue("@tableName", tableName);
            using var reader = await command.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                columns.Add(new ColumnSchemaDto
                {
                    Name = reader.GetString(0),
                    DataType = reader.GetString(1),
                    // Simplify ColumnType mapping
                    ColumnType = $"{reader.GetString(1)}({reader.GetInt16(2)})",
                    IsNullable = reader.GetBoolean(3),
                    IsPrimaryKey = reader.GetInt32(4) == 1,
                    DefaultValue = reader.IsDBNull(5) ? null : reader.GetString(5),
                    Comment = reader.IsDBNull(6) ? null : reader.GetString(6).ToString(),
                    OrdinalPosition = reader.GetInt32(7)
                });
            }

            return columns;
        }

        public async Task<bool> AddColumnAsync(DataSourceConnection connection, string databaseName, string tableName, AddColumnDto dto)
        {
            using var sqlConnection = new SqlConnection(BuildConnectionString(connection, databaseName));
            await sqlConnection.OpenAsync();

            var colDef = new StringBuilder($"ALTER TABLE [{tableName}] ADD [{dto.Name}] {dto.DataType}");
            
             if (dto.DataType.ToLower().Contains("char") || dto.DataType.ToLower().Contains("binary"))
            {
                colDef.Append($"({(dto.Length > 0 ? dto.Length.ToString() : "MAX")})");
            }
             else if (dto.DataType.ToLower() == "decimal" || dto.DataType.ToLower() == "numeric")
            {
                 colDef.Append("(18,2)");
            }

            if (dto.IsAutoIncrement) colDef.Append(" IDENTITY(1,1)"); // Note: Usually can't add identity to existing column easily
            if (!dto.IsNullable) colDef.Append(" NOT NULL");
            if (!string.IsNullOrEmpty(dto.DefaultValue)) colDef.Append($" DEFAULT '{dto.DefaultValue}'");

            using var command = new SqlCommand(colDef.ToString(), sqlConnection);
            await command.ExecuteNonQueryAsync();
            
             if (!string.IsNullOrEmpty(dto.Comment))
            {
                var colCommentSql = "EXEC sp_addextendedproperty @name = N'MS_Description', @value = @value, @level0type = N'SCHEMA', @level0name = 'dbo', @level1type = N'TABLE', @level1name = @tableName, @level2type = N'COLUMN', @level2name = @colName";
                using var colCommentCmd = new SqlCommand(colCommentSql, sqlConnection);
                colCommentCmd.Parameters.AddWithValue("@value", dto.Comment);
                colCommentCmd.Parameters.AddWithValue("@tableName", tableName);
                colCommentCmd.Parameters.AddWithValue("@colName", dto.Name);
                await colCommentCmd.ExecuteNonQueryAsync();
            }

            return true;
        }

        public async Task<TableDataResultDto> GetTableDataAsync(DataSourceConnection connection, string databaseName, string tableName, TableDataQueryDto query)
        {
            using var sqlConnection = new SqlConnection(BuildConnectionString(connection, databaseName));
            await sqlConnection.OpenAsync();

            // Count
            var countSql = $"SELECT COUNT(*) FROM [{tableName}]";
            using var countCmd = new SqlCommand(countSql, sqlConnection);
            var total = Convert.ToInt64(await countCmd.ExecuteScalarAsync());

            // Data
            var whereClause = new StringBuilder(" WHERE 1=1");
            var parameters = new List<SqlParameter>();
            int paramIndex = 0;

            foreach (var filter in query.Filters)
            {
                var paramName = $"@p{paramIndex++}";
                var safeField = $"[{filter.Field}]";
                
                switch (filter.Operator)
                {
                    case "=": whereClause.Append($" AND {safeField} = {paramName}"); break;
                    case "!=": whereClause.Append($" AND {safeField} != {paramName}"); break;
                    case ">": whereClause.Append($" AND {safeField} > {paramName}"); break;
                    case "<": whereClause.Append($" AND {safeField} < {paramName}"); break;
                    case ">=": whereClause.Append($" AND {safeField} >= {paramName}"); break;
                    case "<=": whereClause.Append($" AND {safeField} <= {paramName}"); break;
                    case "like": whereClause.Append($" AND {safeField} LIKE {paramName}"); break;
                }
                parameters.Add(new SqlParameter(paramName, filter.Value));
            }

            var orderClause = "";
            if (!string.IsNullOrEmpty(query.SortField))
            {
                orderClause = $" ORDER BY [{query.SortField}] {(query.SortOrder?.ToLower() == "desc" ? "DESC" : "ASC")}";
            }
            else
            {
                // SQL Server offset fetch requires order by
                // Try to find PK
                orderClause = " ORDER BY (SELECT NULL)"; 
            }

            var pagingClause = $" OFFSET {(query.Page - 1) * query.PageSize} ROWS FETCH NEXT {query.PageSize} ROWS ONLY";
            
            var dataSql = $"SELECT * FROM [{tableName}]{whereClause}{orderClause}{pagingClause}";
            using var dataCmd = new SqlCommand(dataSql, sqlConnection);
            dataCmd.Parameters.AddRange(parameters.ToArray());

            using var reader = await dataCmd.ExecuteReaderAsync();
            
            // Metadata needed for type mapping? Simplified here
            
            var result = new TableDataResultDto
            {
                Total = total,
                Page = query.Page,
                PageSize = query.PageSize
            };

            while (await reader.ReadAsync())
            {
                var row = new Dictionary<string, object?>();
                for (int i = 0; i < reader.FieldCount; i++)
                {
                    var val = reader.GetValue(i);
                    row[reader.GetName(i)] = val == DBNull.Value ? null : val;
                }
                result.Rows.Add(row);
            }

            return result;
        }

        public async Task<bool> InsertRowAsync(DataSourceConnection connection, string databaseName, string tableName, InsertRowDto dto)
        {
            using var sqlConnection = new SqlConnection(BuildConnectionString(connection, databaseName));
            await sqlConnection.OpenAsync();

            var columns = new List<string>();
            var values = new List<string>();
            var parameters = new List<SqlParameter>();
            int paramIndex = 0;

            foreach (var kvp in dto.Data)
            {
                columns.Add($"[{kvp.Key}]");
                var paramName = $"@p{paramIndex++}";
                values.Add(paramName);
                
                object? value = kvp.Value;
                if (value is JsonElement je)
                {
                     switch(je.ValueKind)
                     {
                         case JsonValueKind.String: value = je.GetString(); break;
                         case JsonValueKind.Number: 
                            if (je.TryGetInt64(out long l)) value = l;
                            else if (je.TryGetDouble(out double d)) value = d;
                            break;
                         case JsonValueKind.True: value = true; break;
                         case JsonValueKind.False: value = false; break;
                         case JsonValueKind.Null: value = DBNull.Value; break;
                         default: value = je.ToString(); break;
                     }
                }
                parameters.Add(new SqlParameter(paramName, value ?? DBNull.Value));
            }

            var sql = $"INSERT INTO [{tableName}] ({string.Join(", ", columns)}) VALUES ({string.Join(", ", values)})";
            using var command = new SqlCommand(sql, sqlConnection);
            command.Parameters.AddRange(parameters.ToArray());
            
            await command.ExecuteNonQueryAsync();
            return true;
        }

        public async Task<bool> UpdateRowAsync(DataSourceConnection connection, string databaseName, string tableName, UpdateRowDto dto)
        {
            using var sqlConnection = new SqlConnection(BuildConnectionString(connection, databaseName));
            await sqlConnection.OpenAsync();

            var setClauses = new List<string>();
            var whereClauses = new List<string>();
            var parameters = new List<SqlParameter>();
            int paramIndex = 0;

            foreach (var kvp in dto.Data)
            {
                var paramName = $"@p{paramIndex++}";
                setClauses.Add($"[{kvp.Key}] = {paramName}");
                
                object? value = kvp.Value;
                if (value is JsonElement je)
                {
                     switch(je.ValueKind)
                     {
                         case JsonValueKind.String: value = je.GetString(); break;
                         case JsonValueKind.Number: 
                            if (je.TryGetInt64(out long l)) value = l;
                            else if (je.TryGetDouble(out double d)) value = d;
                            break;
                         case JsonValueKind.True: value = true; break;
                         case JsonValueKind.False: value = false; break;
                         case JsonValueKind.Null: value = DBNull.Value; break;
                         default: value = je.ToString(); break;
                     }
                }
                parameters.Add(new SqlParameter(paramName, value ?? DBNull.Value));
            }

            foreach (var kvp in dto.Keys)
            {
                var paramName = $"@k{paramIndex++}";
                whereClauses.Add($"[{kvp.Key}] = {paramName}");
                 object? value = kvp.Value;
                if (value is JsonElement je)
                {
                     switch(je.ValueKind)
                     {
                         case JsonValueKind.String: value = je.GetString(); break;
                         case JsonValueKind.Number: 
                            if (je.TryGetInt64(out long l)) value = l;
                            else if (je.TryGetDouble(out double d)) value = d;
                            break;
                         case JsonValueKind.True: value = true; break;
                         case JsonValueKind.False: value = false; break;
                         case JsonValueKind.Null: value = DBNull.Value; break;
                         default: value = je.ToString(); break;
                     }
                }
                parameters.Add(new SqlParameter(paramName, value ?? DBNull.Value));
            }

            var sql = $"UPDATE [{tableName}] SET {string.Join(", ", setClauses)} WHERE {string.Join(" AND ", whereClauses)}";
            using var command = new SqlCommand(sql, sqlConnection);
            command.Parameters.AddRange(parameters.ToArray());

            await command.ExecuteNonQueryAsync();
            return true;
        }

        public async Task<bool> DeleteRowAsync(DataSourceConnection connection, string databaseName, string tableName, DeleteRowDto dto)
        {
             using var sqlConnection = new SqlConnection(BuildConnectionString(connection, databaseName));
            await sqlConnection.OpenAsync();

            var whereClauses = new List<string>();
            var parameters = new List<SqlParameter>();
            int paramIndex = 0;

            foreach (var kvp in dto.Keys)
            {
                var paramName = $"@k{paramIndex++}";
                whereClauses.Add($"[{kvp.Key}] = {paramName}");
                object? value = kvp.Value;
                if (value is JsonElement je)
                {
                     switch(je.ValueKind)
                     {
                         case JsonValueKind.String: value = je.GetString(); break;
                         case JsonValueKind.Number: 
                            if (je.TryGetInt64(out long l)) value = l;
                            else if (je.TryGetDouble(out double d)) value = d;
                            break;
                         case JsonValueKind.True: value = true; break;
                         case JsonValueKind.False: value = false; break;
                         case JsonValueKind.Null: value = DBNull.Value; break;
                         default: value = je.ToString(); break;
                     }
                }
                parameters.Add(new SqlParameter(paramName, value ?? DBNull.Value));
            }

            var sql = $"DELETE FROM [{tableName}] WHERE {string.Join(" AND ", whereClauses)}";
            using var command = new SqlCommand(sql, sqlConnection);
            command.Parameters.AddRange(parameters.ToArray());

            await command.ExecuteNonQueryAsync();
            return true;
        }

        public async Task<bool> DeleteColumnAsync(DataSourceConnection connection, string databaseName, string tableName, string columnName)
        {
            using var sqlConnection = new SqlConnection(BuildConnectionString(connection, databaseName));
            await sqlConnection.OpenAsync();

            var sql = $"ALTER TABLE [{tableName}] DROP COLUMN [{columnName}]";
            using var command = new SqlCommand(sql, sqlConnection);
            await command.ExecuteNonQueryAsync();
            return true;
        }

        public async Task<bool> ModifyColumnAsync(DataSourceConnection connection, string databaseName, string tableName, string columnName, ModifyColumnDto dto)
        {
            using var sqlConnection = new SqlConnection(BuildConnectionString(connection, databaseName));
            await sqlConnection.OpenAsync();

            if (!string.IsNullOrEmpty(dto.NewName) && dto.NewName != columnName)
            {
                var renameSql = $"EXEC sp_rename '{tableName}.{columnName}', '{dto.NewName}', 'COLUMN'";
                using var renameCmd = new SqlCommand(renameSql, sqlConnection);
                await renameCmd.ExecuteNonQueryAsync();
                columnName = dto.NewName;
            }

            var colDef = new StringBuilder($"ALTER TABLE [{tableName}] ALTER COLUMN [{columnName}] {dto.DataType}");

            if (dto.DataType.ToLower().Contains("char") || dto.DataType.ToLower().Contains("binary"))
            {
                colDef.Append($"({(dto.Length > 0 ? dto.Length.ToString() : "MAX")})");
            }
            else if (dto.DataType.ToLower() == "decimal" || dto.DataType.ToLower() == "numeric")
            {
                colDef.Append("(18,2)");
            }

            if (!dto.IsNullable) colDef.Append(" NOT NULL");
            else colDef.Append(" NULL");

            using var command = new SqlCommand(colDef.ToString(), sqlConnection);
            await command.ExecuteNonQueryAsync();

            if (!string.IsNullOrEmpty(dto.Comment))
            {
                try
                {
                    var propSql = "EXEC sp_addextendedproperty @name = N'MS_Description', @value = @value, @level0type = N'SCHEMA', @level0name = 'dbo', @level1type = N'TABLE', @level1name = @tableName, @level2type = N'COLUMN', @level2name = @colName";
                    using var propCmd = new SqlCommand(propSql, sqlConnection);
                    propCmd.Parameters.AddWithValue("@value", dto.Comment);
                    propCmd.Parameters.AddWithValue("@tableName", tableName);
                    propCmd.Parameters.AddWithValue("@colName", columnName);
                    await propCmd.ExecuteNonQueryAsync();
                }
                catch
                {
                    try
                    {
                        var propSql = "EXEC sp_updateextendedproperty @name = N'MS_Description', @value = @value, @level0type = N'SCHEMA', @level0name = 'dbo', @level1type = N'TABLE', @level1name = @tableName, @level2type = N'COLUMN', @level2name = @colName";
                        using var propCmd = new SqlCommand(propSql, sqlConnection);
                        propCmd.Parameters.AddWithValue("@value", dto.Comment);
                        propCmd.Parameters.AddWithValue("@tableName", tableName);
                        propCmd.Parameters.AddWithValue("@colName", columnName);
                        await propCmd.ExecuteNonQueryAsync();
                    }
                    catch { }
                }
            }

            return true;
        }
    }
}
