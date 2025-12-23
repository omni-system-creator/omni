using Microsoft.EntityFrameworkCore;
using MySqlConnector;
using omsapi.Data;
using omsapi.Infrastructure.Attributes;
using omsapi.Models.Dtos.Data;
using omsapi.Models.Entities.Data;
using omsapi.Services.Interfaces;
using System.Data;
using System.Text;

namespace omsapi.Services
{
    [AutoInject(ServiceLifetime.Scoped)]
    public class DataSourceService : IDataSourceService
    {
        private readonly OmsContext _context;

        public DataSourceService(OmsContext context)
        {
            _context = context;
        }

        // Helper to build connection string
        private string BuildConnectionString(DataSourceConnection connection, string? database = null)
        {
            var builder = new MySqlConnectionStringBuilder
            {
                Server = connection.Host,
                Port = uint.Parse(connection.Port),
                UserID = connection.User,
                Password = connection.Password,
                Database = database ?? connection.Database,
                CharacterSet = "utf8mb4",
                ConvertZeroDateTime = true
            };
            return builder.ConnectionString;
        }

        private string BuildConnectionString(CreateDataSourceConnectionDto dto)
        {
            var builder = new MySqlConnectionStringBuilder
            {
                Server = dto.Host,
                Port = uint.Parse(dto.Port),
                UserID = dto.User,
                Password = dto.Password,
                Database = dto.Database,
                CharacterSet = "utf8mb4",
                ConvertZeroDateTime = true
            };
            return builder.ConnectionString;
        }

        public async Task<IEnumerable<DataSourceConnectionDto>> GetAllAsync()
        {
            var connections = await _context.DataSourceConnections
                .OrderBy(c => c.Name)
                .ToListAsync();

            return connections.Select(c => new DataSourceConnectionDto
            {
                Id = c.Id,
                Name = c.Name,
                Type = c.Type,
                Host = c.Host,
                Port = c.Port,
                User = c.User,
                Database = c.Database,
                CreatedAt = c.CreatedAt
            });
        }

        public async Task<DataSourceConnectionDto?> GetByIdAsync(long id)
        {
            var connection = await _context.DataSourceConnections.FindAsync(id);
            if (connection == null) return null;

            return new DataSourceConnectionDto
            {
                Id = connection.Id,
                Name = connection.Name,
                Type = connection.Type,
                Host = connection.Host,
                Port = connection.Port,
                User = connection.User,
                Database = connection.Database,
                CreatedAt = connection.CreatedAt
            };
        }

        public async Task<DataSourceConnectionDto> CreateAsync(CreateDataSourceConnectionDto createDto)
        {
            var connection = new DataSourceConnection
            {
                Name = createDto.Name,
                Type = createDto.Type,
                Host = createDto.Host,
                Port = createDto.Port,
                User = createDto.User,
                Password = createDto.Password,
                Database = createDto.Database
            };

            _context.DataSourceConnections.Add(connection);
            await _context.SaveChangesAsync();

            return new DataSourceConnectionDto
            {
                Id = connection.Id,
                Name = connection.Name,
                Type = connection.Type,
                Host = connection.Host,
                Port = connection.Port,
                User = connection.User,
                Database = connection.Database,
                CreatedAt = connection.CreatedAt
            };
        }

        public async Task<DataSourceConnectionDto?> UpdateAsync(long id, UpdateDataSourceConnectionDto updateDto)
        {
            var connection = await _context.DataSourceConnections.FindAsync(id);
            if (connection == null) return null;

            if (updateDto.Name != null) connection.Name = updateDto.Name;
            if (updateDto.Type != null) connection.Type = updateDto.Type;
            if (updateDto.Host != null) connection.Host = updateDto.Host;
            if (updateDto.Port != null) connection.Port = updateDto.Port;
            if (updateDto.User != null) connection.User = updateDto.User;
            if (!string.IsNullOrEmpty(updateDto.Password)) connection.Password = updateDto.Password;
            if (updateDto.Database != null) connection.Database = updateDto.Database;

            connection.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();

            return new DataSourceConnectionDto
            {
                Id = connection.Id,
                Name = connection.Name,
                Type = connection.Type,
                Host = connection.Host,
                Port = connection.Port,
                User = connection.User,
                Database = connection.Database,
                CreatedAt = connection.CreatedAt
            };
        }

        public async Task<bool> DeleteAsync(long id)
        {
            var connection = await _context.DataSourceConnections.FindAsync(id);
            if (connection == null) return false;

            _context.DataSourceConnections.Remove(connection);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> TestConnectionAsync(CreateDataSourceConnectionDto connectionDto)
        {
            if (connectionDto.Type.ToLower() != "mysql")
                throw new NotImplementedException("Only MySQL is supported currently.");

            try
            {
                var connectionString = BuildConnectionString(connectionDto);
                using var connection = new MySqlConnection(connectionString);
                await connection.OpenAsync();
                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }

        public async Task<IEnumerable<DatabaseSchemaDto>> GetDatabasesAsync(long connectionId)
        {
            var connectionEntity = await _context.DataSourceConnections.FindAsync(connectionId);
            if (connectionEntity == null) throw new KeyNotFoundException("Connection not found");

            if (connectionEntity.Type.ToLower() != "mysql")
                throw new NotImplementedException("Only MySQL is supported currently.");

            var connectionString = BuildConnectionString(connectionEntity, ""); // Connect without specific DB to list all
            using var connection = new MySqlConnection(connectionString);
            await connection.OpenAsync();

            var databases = new List<DatabaseSchemaDto>();
            
            // Query detailed database information from information_schema.SCHEMATA and TABLES
            var sql = @"
                SELECT 
                    s.SCHEMA_NAME,
                    s.DEFAULT_CHARACTER_SET_NAME,
                    s.DEFAULT_COLLATION_NAME,
                    COUNT(t.TABLE_NAME) as TableCount,
                    SUM(t.DATA_LENGTH + t.INDEX_LENGTH) as DataLength
                FROM information_schema.SCHEMATA s
                LEFT JOIN information_schema.TABLES t ON s.SCHEMA_NAME = t.TABLE_SCHEMA
                WHERE s.SCHEMA_NAME NOT IN ('information_schema', 'performance_schema', 'mysql', 'sys')
                GROUP BY s.SCHEMA_NAME, s.DEFAULT_CHARACTER_SET_NAME, s.DEFAULT_COLLATION_NAME";

            using var command = new MySqlCommand(sql, connection);
            using var reader = await command.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                databases.Add(new DatabaseSchemaDto 
                { 
                    Name = reader.GetString(0),
                    CharSet = reader.IsDBNull(1) ? null : reader.GetString(1),
                    Collation = reader.IsDBNull(2) ? null : reader.GetString(2),
                    TableCount = reader.IsDBNull(3) ? 0 : reader.GetInt64(3),
                    DataLength = reader.IsDBNull(4) ? 0 : reader.GetDecimal(4) > long.MaxValue ? long.MaxValue : (long)reader.GetDecimal(4)
                });
            }

            return databases;
        }

        public async Task<IEnumerable<TableSchemaDto>> GetTablesAsync(long connectionId, string databaseName)
        {
            var connectionEntity = await _context.DataSourceConnections.FindAsync(connectionId);
            if (connectionEntity == null) throw new KeyNotFoundException("Connection not found");

            var connectionString = BuildConnectionString(connectionEntity, databaseName);
            using var connection = new MySqlConnection(connectionString);
            await connection.OpenAsync();

            var tables = new List<TableSchemaDto>();
            var sql = @"
                SELECT 
                    TABLE_NAME, 
                    TABLE_COMMENT, 
                    ENGINE, 
                    TABLE_ROWS, 
                    DATA_LENGTH, 
                    CREATE_TIME 
                FROM information_schema.TABLES 
                WHERE TABLE_SCHEMA = @database";

            using var command = new MySqlCommand(sql, connection);
            command.Parameters.AddWithValue("@database", databaseName);
            
            using (var reader = await command.ExecuteReaderAsync())
            {
                while (await reader.ReadAsync())
                {
                    tables.Add(new TableSchemaDto
                    {
                        Name = reader.GetString(0),
                        Comment = reader.IsDBNull(1) ? null : reader.GetString(1),
                        Engine = reader.IsDBNull(2) ? null : reader.GetString(2),
                        Rows = reader.IsDBNull(3) ? null : reader.GetInt64(3),
                        DataLength = reader.IsDBNull(4) ? null : reader.GetInt64(4),
                        CreateTime = reader.IsDBNull(5) ? null : reader.GetDateTime(5)
                    });
                }
            }

            // Get exact row count for each table
            foreach (var table in tables)
            {
                try
                {
                    var countSql = $"SELECT COUNT(*) FROM `{table.Name.Replace("`", "``")}`";
                    using var countCmd = new MySqlCommand(countSql, connection);
                    var count = await countCmd.ExecuteScalarAsync();
                    if (count != null)
                    {
                        table.Rows = Convert.ToInt64(count);
                    }
                }
                catch
                {
                    // Fallback to approximate count from information_schema if query fails
                }
            }

            return tables;
        }

        public async Task<IEnumerable<ColumnSchemaDto>> GetColumnsAsync(long connectionId, string databaseName, string tableName)
        {
            var connectionEntity = await _context.DataSourceConnections.FindAsync(connectionId);
            if (connectionEntity == null) throw new KeyNotFoundException("Connection not found");

            var connectionString = BuildConnectionString(connectionEntity, databaseName);
            using var connection = new MySqlConnection(connectionString);
            await connection.OpenAsync();

            var columns = new List<ColumnSchemaDto>();
            var sql = @"
                SELECT 
                    COLUMN_NAME, 
                    DATA_TYPE, 
                    COLUMN_TYPE, 
                    IS_NULLABLE, 
                    COLUMN_KEY, 
                    COLUMN_DEFAULT, 
                    COLUMN_COMMENT, 
                    ORDINAL_POSITION
                FROM information_schema.COLUMNS 
                WHERE TABLE_SCHEMA = @database AND TABLE_NAME = @table
                ORDER BY ORDINAL_POSITION";

            using var command = new MySqlCommand(sql, connection);
            command.Parameters.AddWithValue("@database", databaseName);
            command.Parameters.AddWithValue("@table", tableName);

            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                columns.Add(new ColumnSchemaDto
                {
                    Name = reader.GetString(0),
                    DataType = reader.GetString(1),
                    ColumnType = reader.GetString(2),
                    IsNullable = reader.GetString(3) == "YES",
                    IsPrimaryKey = reader.GetString(4) == "PRI",
                    DefaultValue = reader.IsDBNull(5) ? null : reader.GetString(5),
                    Comment = reader.IsDBNull(6) ? null : reader.GetString(6),
                    OrdinalPosition = reader.GetInt32(7)
                });
            }

            return columns;
        }

        public async Task<TableDataResultDto> GetTableDataAsync(long connectionId, string databaseName, string tableName, TableDataQueryDto query)
        {
            var connectionEntity = await _context.DataSourceConnections.FindAsync(connectionId);
            if (connectionEntity == null) throw new KeyNotFoundException("Connection not found");

            var connectionString = BuildConnectionString(connectionEntity, databaseName);
            using var connection = new MySqlConnection(connectionString);
            await connection.OpenAsync();

            // Sanitize table name
            var safeTableName = $"`{tableName.Replace("`", "``")}`";

            // Build WHERE clause
            var whereClause = new StringBuilder();
            var parameters = new List<MySqlParameter>();
            
            if (query.Filters != null && query.Filters.Any())
            {
                whereClause.Append(" WHERE 1=1");
                int paramIndex = 0;
                foreach (var filter in query.Filters)
                {
                    // Basic SQL Injection prevention for column names: only allow alphanumeric and underscore
                    if (!System.Text.RegularExpressions.Regex.IsMatch(filter.Field, @"^[a-zA-Z0-9_]+$"))
                        continue;

                    var paramName = $"@p{paramIndex}";
                    var safeField = $"`{filter.Field}`";
                    
                    switch (filter.Operator.ToLower())
                    {
                        case "=":
                            whereClause.Append($" AND {safeField} = {paramName}");
                            parameters.Add(new MySqlParameter(paramName, filter.Value));
                            break;
                        case "!=":
                        case "<>":
                            whereClause.Append($" AND {safeField} != {paramName}");
                            parameters.Add(new MySqlParameter(paramName, filter.Value));
                            break;
                        case ">":
                            whereClause.Append($" AND {safeField} > {paramName}");
                            parameters.Add(new MySqlParameter(paramName, filter.Value));
                            break;
                        case "<":
                            whereClause.Append($" AND {safeField} < {paramName}");
                            parameters.Add(new MySqlParameter(paramName, filter.Value));
                            break;
                        case ">=":
                            whereClause.Append($" AND {safeField} >= {paramName}");
                            parameters.Add(new MySqlParameter(paramName, filter.Value));
                            break;
                        case "<=":
                            whereClause.Append($" AND {safeField} <= {paramName}");
                            parameters.Add(new MySqlParameter(paramName, filter.Value));
                            break;
                        case "like":
                        case "contains":
                            whereClause.Append($" AND {safeField} LIKE {paramName}");
                            parameters.Add(new MySqlParameter(paramName, $"%{filter.Value}%"));
                            break;
                        case "startswith":
                            whereClause.Append($" AND {safeField} LIKE {paramName}");
                            parameters.Add(new MySqlParameter(paramName, $"{filter.Value}%"));
                            break;
                        case "endswith":
                            whereClause.Append($" AND {safeField} LIKE {paramName}");
                            parameters.Add(new MySqlParameter(paramName, $"%{filter.Value}"));
                            break;
                    }
                    paramIndex++;
                }
            }

            // Get Total Count
            var countSql = $"SELECT COUNT(*) FROM {safeTableName}{whereClause}";
            using var countCommand = new MySqlCommand(countSql, connection);
            foreach (var p in parameters) countCommand.Parameters.Add(p.Clone());
            
            var totalObj = await countCommand.ExecuteScalarAsync();
            long total = totalObj != null ? Convert.ToInt64(totalObj) : 0;

            // Build Sort
            var orderClause = "";
            if (!string.IsNullOrEmpty(query.SortField) && System.Text.RegularExpressions.Regex.IsMatch(query.SortField, @"^[a-zA-Z0-9_]+$"))
            {
                var sortOrder = query.SortOrder?.ToLower() == "desc" ? "DESC" : "ASC";
                orderClause = $" ORDER BY `{query.SortField}` {sortOrder}";
            }

            // Build Limit
            var limitClause = $" LIMIT @limitOffset, @limitSize";
            
            // Execute Data Query
            var dataSql = $"SELECT * FROM {safeTableName}{whereClause}{orderClause}{limitClause}";
            using var dataCommand = new MySqlCommand(dataSql, connection);
            foreach (var p in parameters) dataCommand.Parameters.Add(p.Clone());
            dataCommand.Parameters.AddWithValue("@limitOffset", (query.Page - 1) * query.PageSize);
            dataCommand.Parameters.AddWithValue("@limitSize", query.PageSize);

            using var reader = await dataCommand.ExecuteReaderAsync();
            
            // Fetch metadata to include comments (uses separate connection)
            var columnMetadata = await GetColumnsAsync(connectionId, databaseName, tableName);
            var metadataDict = columnMetadata.ToDictionary(c => c.Name, StringComparer.OrdinalIgnoreCase);

            var result = new TableDataResultDto
            {
                Total = total,
                Page = query.Page,
                PageSize = query.PageSize
            };
            
            // Get column names and map to metadata
            for (int i = 0; i < reader.FieldCount; i++)
            {
                var colName = reader.GetName(i);
                if (metadataDict.TryGetValue(colName, out var meta))
                {
                    result.Columns.Add(meta);
                }
                else
                {
                    result.Columns.Add(new ColumnSchemaDto 
                    { 
                        Name = colName,
                        DataType = reader.GetDataTypeName(i)
                    });
                }
            }

            // Get rows
            while (await reader.ReadAsync())
            {
                var row = new Dictionary<string, object?>();
                for (int i = 0; i < reader.FieldCount; i++)
                {
                    var colName = reader.GetName(i);
                    var val = reader.GetValue(i);
                    row[colName] = val == DBNull.Value ? null : val;
                }
                result.Rows.Add(row);
            }

            return result;
        }

        public async Task<bool> InsertRowAsync(long connectionId, string databaseName, string tableName, InsertRowDto dto)
        {
            var connectionEntity = await _context.DataSourceConnections.FindAsync(connectionId);
            if (connectionEntity == null) throw new KeyNotFoundException("Connection not found");

            var connectionString = BuildConnectionString(connectionEntity, databaseName);
            using var connection = new MySqlConnection(connectionString);
            await connection.OpenAsync();

            var safeTableName = $"`{tableName.Replace("`", "``")}`";
            
            var columns = new List<string>();
            var values = new List<string>();
            var parameters = new List<MySqlParameter>();
            int paramIndex = 0;

            foreach (var kvp in dto.Data)
            {
                // Basic SQL Injection prevention for column names
                if (!System.Text.RegularExpressions.Regex.IsMatch(kvp.Key, @"^[a-zA-Z0-9_]+$"))
                    continue;

                columns.Add($"`{kvp.Key}`");
                var paramName = $"@p{paramIndex}";
                values.Add(paramName);
                
                object? value = kvp.Value;
                if (value is System.Text.Json.JsonElement je)
                {
                     switch(je.ValueKind)
                     {
                         case System.Text.Json.JsonValueKind.String: value = je.GetString(); break;
                         case System.Text.Json.JsonValueKind.Number: 
                            if (je.TryGetInt64(out long l)) value = l;
                            else if (je.TryGetDouble(out double d)) value = d;
                            break;
                         case System.Text.Json.JsonValueKind.True: value = true; break;
                         case System.Text.Json.JsonValueKind.False: value = false; break;
                         case System.Text.Json.JsonValueKind.Null: value = null; break;
                         default: value = je.ToString(); break;
                     }
                }

                parameters.Add(new MySqlParameter(paramName, value ?? DBNull.Value));
                paramIndex++;
            }

            if (!columns.Any()) throw new ArgumentException("No valid columns to insert");

            var sql = $"INSERT INTO {safeTableName} ({string.Join(", ", columns)}) VALUES ({string.Join(", ", values)})";
            
            using var command = new MySqlCommand(sql, connection);
            foreach (var p in parameters) command.Parameters.Add(p);

            await command.ExecuteNonQueryAsync();
            return true;
        }

        public async Task<bool> UpdateRowAsync(long connectionId, string databaseName, string tableName, UpdateRowDto dto)
        {
            var connectionEntity = await _context.DataSourceConnections.FindAsync(connectionId);
            if (connectionEntity == null) throw new KeyNotFoundException("Connection not found");

            var connectionString = BuildConnectionString(connectionEntity, databaseName);
            using var connection = new MySqlConnection(connectionString);
            await connection.OpenAsync();

            var safeTableName = $"`{tableName.Replace("`", "``")}`";
            
            var setClauses = new List<string>();
            var whereClauses = new List<string>();
            var parameters = new List<MySqlParameter>();
            int paramIndex = 0;

            // SET Clause
            foreach (var kvp in dto.Data)
            {
                if (!System.Text.RegularExpressions.Regex.IsMatch(kvp.Key, @"^[a-zA-Z0-9_]+$")) continue;

                var paramName = $"@p{paramIndex}";
                setClauses.Add($"`{kvp.Key}` = {paramName}");
                
                object? value = kvp.Value;
                if (value is System.Text.Json.JsonElement je)
                {
                     switch(je.ValueKind)
                     {
                         case System.Text.Json.JsonValueKind.String: value = je.GetString(); break;
                         case System.Text.Json.JsonValueKind.Number: 
                            if (je.TryGetInt64(out long l)) value = l;
                            else if (je.TryGetDouble(out double d)) value = d;
                            break;
                         case System.Text.Json.JsonValueKind.True: value = true; break;
                         case System.Text.Json.JsonValueKind.False: value = false; break;
                         case System.Text.Json.JsonValueKind.Null: value = null; break;
                         default: value = je.ToString(); break;
                     }
                }
                
                parameters.Add(new MySqlParameter(paramName, value ?? DBNull.Value));
                paramIndex++;
            }

            // WHERE Clause
            foreach (var kvp in dto.Keys)
            {
                if (!System.Text.RegularExpressions.Regex.IsMatch(kvp.Key, @"^[a-zA-Z0-9_]+$")) continue;

                var paramName = $"@k{paramIndex}";
                whereClauses.Add($"`{kvp.Key}` = {paramName}");
                
                object? value = kvp.Value;
                if (value is System.Text.Json.JsonElement je)
                {
                     switch(je.ValueKind)
                     {
                         case System.Text.Json.JsonValueKind.String: value = je.GetString(); break;
                         case System.Text.Json.JsonValueKind.Number: 
                            if (je.TryGetInt64(out long l)) value = l;
                            else if (je.TryGetDouble(out double d)) value = d;
                            break;
                         case System.Text.Json.JsonValueKind.True: value = true; break;
                         case System.Text.Json.JsonValueKind.False: value = false; break;
                         case System.Text.Json.JsonValueKind.Null: value = null; break;
                         default: value = je.ToString(); break;
                     }
                }

                parameters.Add(new MySqlParameter(paramName, value ?? DBNull.Value));
                paramIndex++;
            }

            if (!setClauses.Any()) throw new ArgumentException("No data to update");
            if (!whereClauses.Any()) throw new ArgumentException("No keys provided for update");

            var sql = $"UPDATE {safeTableName} SET {string.Join(", ", setClauses)} WHERE {string.Join(" AND ", whereClauses)}";
            
            using var command = new MySqlCommand(sql, connection);
            foreach (var p in parameters) command.Parameters.Add(p);

            await command.ExecuteNonQueryAsync();
            return true;
        }

        public async Task<bool> DeleteRowAsync(long connectionId, string databaseName, string tableName, DeleteRowDto dto)
        {
            var connectionEntity = await _context.DataSourceConnections.FindAsync(connectionId);
            if (connectionEntity == null) throw new KeyNotFoundException("Connection not found");

            var connectionString = BuildConnectionString(connectionEntity, databaseName);
            using var connection = new MySqlConnection(connectionString);
            await connection.OpenAsync();

            var safeTableName = $"`{tableName.Replace("`", "``")}`";
            
            var whereClauses = new List<string>();
            var parameters = new List<MySqlParameter>();
            int paramIndex = 0;

            foreach (var kvp in dto.Keys)
            {
                if (!System.Text.RegularExpressions.Regex.IsMatch(kvp.Key, @"^[a-zA-Z0-9_]+$")) continue;

                var paramName = $"@k{paramIndex}";
                whereClauses.Add($"`{kvp.Key}` = {paramName}");
                
                object? value = kvp.Value;
                if (value is System.Text.Json.JsonElement je)
                {
                     switch(je.ValueKind)
                     {
                         case System.Text.Json.JsonValueKind.String: value = je.GetString(); break;
                         case System.Text.Json.JsonValueKind.Number: 
                            if (je.TryGetInt64(out long l)) value = l;
                            else if (je.TryGetDouble(out double d)) value = d;
                            break;
                         case System.Text.Json.JsonValueKind.True: value = true; break;
                         case System.Text.Json.JsonValueKind.False: value = false; break;
                         case System.Text.Json.JsonValueKind.Null: value = null; break;
                         default: value = je.ToString(); break;
                     }
                }

                parameters.Add(new MySqlParameter(paramName, value ?? DBNull.Value));
                paramIndex++;
            }

            if (!whereClauses.Any()) throw new ArgumentException("No keys provided for delete");

            var sql = $"DELETE FROM {safeTableName} WHERE {string.Join(" AND ", whereClauses)}";
            
            using var command = new MySqlCommand(sql, connection);
            foreach (var p in parameters) command.Parameters.Add(p);

            await command.ExecuteNonQueryAsync();
            return true;
        }

        public async Task<bool> CreateDatabaseAsync(long connectionId, CreateDatabaseDto dto)
        {
            var connectionEntity = await _context.DataSourceConnections.FindAsync(connectionId);
            if (connectionEntity == null) throw new KeyNotFoundException("Connection not found");

            // Build connection string without specific database
            var connectionString = BuildConnectionString(connectionEntity, "");
            using var connection = new MySqlConnection(connectionString);
            await connection.OpenAsync();

            // Sanitize database name (basic check)
            if (!System.Text.RegularExpressions.Regex.IsMatch(dto.Name, @"^[a-zA-Z0-9_-]+$"))
                throw new ArgumentException("Invalid database name");

            // SQL: CREATE DATABASE `name` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci
            var sql = $"CREATE DATABASE `{dto.Name}`";
            if (!string.IsNullOrEmpty(dto.CharSet))
            {
                // Sanitize CharSet/Collation if needed, but usually these come from select
                sql += $" CHARACTER SET {dto.CharSet}";
            }
            if (!string.IsNullOrEmpty(dto.Collation))
            {
                sql += $" COLLATE {dto.Collation}";
            }

            using var command = new MySqlCommand(sql, connection);
            await command.ExecuteNonQueryAsync();
            
            return true;
        }

        public async Task<bool> CreateTableAsync(long connectionId, string databaseName, CreateTableDto dto)
        {
            var connectionEntity = await _context.DataSourceConnections.FindAsync(connectionId);
            if (connectionEntity == null) throw new KeyNotFoundException("Connection not found");

            // Build connection string with specific database
            var connectionString = BuildConnectionString(connectionEntity, databaseName);
            using var connection = new MySqlConnection(connectionString);
            await connection.OpenAsync();

            // Sanitize table name
            if (!System.Text.RegularExpressions.Regex.IsMatch(dto.Name, @"^[a-zA-Z0-9_]+$"))
                throw new ArgumentException("Invalid table name");

            var sqlBuilder = new StringBuilder();
            sqlBuilder.Append($"CREATE TABLE `{dto.Name}` (");

            var primaryKeys = new List<string>();
            var columnDefinitions = new List<string>();

            foreach (var col in dto.Columns)
            {
                if (!System.Text.RegularExpressions.Regex.IsMatch(col.Name, @"^[a-zA-Z0-9_]+$"))
                    throw new ArgumentException($"Invalid column name: {col.Name}");

                var colDef = new StringBuilder();
                colDef.Append($"`{col.Name}` {col.DataType}");

                if (col.Length.HasValue)
                {
                    if (col.Precision.HasValue && col.Scale.HasValue)
                    {
                        colDef.Append($"({col.Length},{col.Precision})"); // Actually decimal usually takes (Precision, Scale) or just (M, D)
                                                                          // But some types take (Length). Let's assume frontend sends correct usage.
                                                                          // For Decimal, it's (M, D).
                    }
                    else if (col.DataType.ToLower().Contains("char") || col.DataType.ToLower().Contains("binary") || col.DataType.ToLower().Contains("int"))
                    {
                        colDef.Append($"({col.Length})");
                    }
                }
                
                if (!col.IsNullable)
                {
                    colDef.Append(" NOT NULL");
                }
                else
                {
                     colDef.Append(" NULL");
                }

                if (col.IsAutoIncrement)
                {
                    colDef.Append(" AUTO_INCREMENT");
                }

                if (!string.IsNullOrEmpty(col.DefaultValue))
                {
                    // Basic SQL injection check for default value - better use parameters but CREATE TABLE doesn't support params for DDL well
                    // So we wrap in quotes if it's string-like
                    if (col.DataType.ToLower().Contains("char") || col.DataType.ToLower().Contains("text") || col.DataType.ToLower().Contains("date") || col.DataType.ToLower().Contains("time"))
                    {
                         colDef.Append($" DEFAULT '{col.DefaultValue.Replace("'", "''")}'");
                    }
                    else
                    {
                         colDef.Append($" DEFAULT {col.DefaultValue}");
                    }
                }

                if (!string.IsNullOrEmpty(col.Comment))
                {
                    colDef.Append($" COMMENT '{col.Comment.Replace("'", "''")}'");
                }

                columnDefinitions.Add(colDef.ToString());

                if (col.IsPrimaryKey)
                {
                    primaryKeys.Add($"`{col.Name}`");
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

            // Table Options
            if (!string.IsNullOrEmpty(dto.Engine))
            {
                sqlBuilder.Append($" ENGINE={dto.Engine}");
            }
            
            if (!string.IsNullOrEmpty(dto.CharSet))
            {
                 sqlBuilder.Append($" DEFAULT CHARSET={dto.CharSet}");
            }

             if (!string.IsNullOrEmpty(dto.Collation))
            {
                 sqlBuilder.Append($" COLLATE={dto.Collation}");
            }
            
            if (!string.IsNullOrEmpty(dto.Comment))
            {
                sqlBuilder.Append($" COMMENT='{dto.Comment.Replace("'", "''")}'");
            }

            using var command = new MySqlCommand(sqlBuilder.ToString(), connection);
            await command.ExecuteNonQueryAsync();

            return true;
        }
        public async Task<bool> AddColumnAsync(long connectionId, string databaseName, string tableName, AddColumnDto dto)
        {
             var connectionEntity = await _context.DataSourceConnections.FindAsync(connectionId);
             if (connectionEntity == null) throw new KeyNotFoundException("Connection not found");
             var connectionString = BuildConnectionString(connectionEntity, databaseName);
             using var connection = new MySqlConnection(connectionString);
             await connection.OpenAsync();
             
             if (!System.Text.RegularExpressions.Regex.IsMatch(tableName, @"^[a-zA-Z0-9_]+$")) throw new ArgumentException("Invalid table name");
             if (!System.Text.RegularExpressions.Regex.IsMatch(dto.Name, @"^[a-zA-Z0-9_]+$")) throw new ArgumentException("Invalid column name");

             var definition = BuildColumnDefinition(dto);
             var position = "";
             if (dto.IsFirst) position = " FIRST";
             else if (!string.IsNullOrEmpty(dto.AfterColumn)) 
             {
                 if (!System.Text.RegularExpressions.Regex.IsMatch(dto.AfterColumn, @"^[a-zA-Z0-9_]+$")) throw new ArgumentException("Invalid after column name");
                 position = $" AFTER `{dto.AfterColumn}`";
             }

             var sql = $"ALTER TABLE `{tableName}` ADD COLUMN {definition}{position}";
             using var command = new MySqlCommand(sql, connection);
             await command.ExecuteNonQueryAsync();
             return true;
        }

        public async Task<bool> DeleteColumnAsync(long connectionId, string databaseName, string tableName, string columnName)
        {
             var connectionEntity = await _context.DataSourceConnections.FindAsync(connectionId);
             if (connectionEntity == null) throw new KeyNotFoundException("Connection not found");
             var connectionString = BuildConnectionString(connectionEntity, databaseName);
             using var connection = new MySqlConnection(connectionString);
             await connection.OpenAsync();

             if (!System.Text.RegularExpressions.Regex.IsMatch(tableName, @"^[a-zA-Z0-9_]+$")) throw new ArgumentException("Invalid table name");
             if (!System.Text.RegularExpressions.Regex.IsMatch(columnName, @"^[a-zA-Z0-9_]+$")) throw new ArgumentException("Invalid column name");

             var sql = $"ALTER TABLE `{tableName}` DROP COLUMN `{columnName}`";
             using var command = new MySqlCommand(sql, connection);
             await command.ExecuteNonQueryAsync();
             return true;
        }

        public async Task<bool> ModifyColumnAsync(long connectionId, string databaseName, string tableName, string columnName, ModifyColumnDto dto)
        {
             var connectionEntity = await _context.DataSourceConnections.FindAsync(connectionId);
             if (connectionEntity == null) throw new KeyNotFoundException("Connection not found");
             var connectionString = BuildConnectionString(connectionEntity, databaseName);
             using var connection = new MySqlConnection(connectionString);
             await connection.OpenAsync();

             if (!System.Text.RegularExpressions.Regex.IsMatch(tableName, @"^[a-zA-Z0-9_]+$")) throw new ArgumentException("Invalid table name");
             if (!System.Text.RegularExpressions.Regex.IsMatch(columnName, @"^[a-zA-Z0-9_]+$")) throw new ArgumentException("Invalid column name");
             if (!System.Text.RegularExpressions.Regex.IsMatch(dto.Name, @"^[a-zA-Z0-9_]+$")) throw new ArgumentException("Invalid new column name");

             var definition = BuildColumnDefinition(dto);
             var position = "";
             if (dto.IsFirst) position = " FIRST";
             else if (!string.IsNullOrEmpty(dto.AfterColumn)) 
             {
                 if (!System.Text.RegularExpressions.Regex.IsMatch(dto.AfterColumn, @"^[a-zA-Z0-9_]+$")) throw new ArgumentException("Invalid after column name");
                 position = $" AFTER `{dto.AfterColumn}`";
             }
             
             var sql = $"ALTER TABLE `{tableName}` CHANGE COLUMN `{columnName}` {definition}{position}";
             using var command = new MySqlCommand(sql, connection);
             await command.ExecuteNonQueryAsync();
             return true;
        }

        private string BuildColumnDefinition(ColumnDefinitionDto col)
        {
             var colDef = new StringBuilder();
             colDef.Append($"`{col.Name}` {col.DataType}");

             if (col.Length.HasValue)
             {
                 if (col.DataType.ToLower().Contains("decimal") || col.DataType.ToLower().Contains("numeric"))
                 {
                     // Prefer Precision, Scale
                     if (col.Precision.HasValue && col.Scale.HasValue)
                        colDef.Append($"({col.Precision},{col.Scale})");
                     else if (col.Length.HasValue && col.Precision.HasValue) // Fallback logic seen in CreateTable
                        colDef.Append($"({col.Length},{col.Precision})");
                 }
                 else if (col.DataType.ToLower().Contains("char") || col.DataType.ToLower().Contains("binary") || col.DataType.ToLower().Contains("int") || col.DataType.ToLower().Contains("bit"))
                 {
                     colDef.Append($"({col.Length})");
                 }
             }
             else if ((col.DataType.ToLower().Contains("decimal") || col.DataType.ToLower().Contains("numeric")) && col.Precision.HasValue && col.Scale.HasValue)
             {
                  colDef.Append($"({col.Precision},{col.Scale})");
             }
             
             if (!col.IsNullable)
             {
                 colDef.Append(" NOT NULL");
             }
             else
             {
                  colDef.Append(" NULL");
             }

             if (col.IsAutoIncrement)
             {
                 colDef.Append(" AUTO_INCREMENT");
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

             if (!string.IsNullOrEmpty(col.Comment))
             {
                 colDef.Append($" COMMENT '{col.Comment.Replace("'", "''")}'");
             }
             
             return colDef.ToString();
        }
    }
}
