using MySqlConnector;
using omsapi.Models.Dtos.Data;
using omsapi.Models.Entities.Data;
using System.Data;
using System.Text;
using System.Text.Json;

namespace omsapi.Services.DataSourceAdapters
{
    public class MySqlAdapter : IDatabaseAdapter
    {
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
                ConvertZeroDateTime = true,
                AllowUserVariables = true
            };
            return builder.ConnectionString;
        }

        public async Task<bool> TestConnectionAsync(DataSourceConnection connection)
        {
            try
            {
                using var mySqlConnection = new MySqlConnection(BuildConnectionString(connection));
                await mySqlConnection.OpenAsync();
                return true;
            }
            catch
            {
                return false;
            }
        }

        public async Task<IEnumerable<DatabaseSchemaDto>> GetDatabasesAsync(DataSourceConnection connection)
        {
            using var mySqlConnection = new MySqlConnection(BuildConnectionString(connection));
            await mySqlConnection.OpenAsync();

            var databases = new List<DatabaseSchemaDto>();
            var sql = @"
                SELECT 
                    SCHEMA_NAME, 
                    DEFAULT_COLLATION_NAME,
                    (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = SCHEMA_NAME) as TableCount
                FROM information_schema.SCHEMATA 
                WHERE SCHEMA_NAME NOT IN ('information_schema', 'mysql', 'performance_schema', 'sys') 
                ORDER BY SCHEMA_NAME";

            using var command = new MySqlCommand(sql, mySqlConnection);
            using var reader = await command.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                databases.Add(new DatabaseSchemaDto
                {
                    Name = reader.GetString(0),
                    Collation = reader.GetString(1),
                    TableCount = reader.GetInt64(2)
                });
            }

            return databases;
        }

        public async Task<bool> CreateDatabaseAsync(DataSourceConnection connection, CreateDatabaseDto dto)
        {
            using var mySqlConnection = new MySqlConnection(BuildConnectionString(connection));
            await mySqlConnection.OpenAsync();

            var sqlBuilder = new StringBuilder($"CREATE DATABASE `{dto.Name}`");
            if (!string.IsNullOrEmpty(dto.CharSet))
            {
                sqlBuilder.Append($" CHARACTER SET {dto.CharSet}");
            }
            if (!string.IsNullOrEmpty(dto.Collation))
            {
                sqlBuilder.Append($" COLLATE {dto.Collation}");
            }

            using var command = new MySqlCommand(sqlBuilder.ToString(), mySqlConnection);
            await command.ExecuteNonQueryAsync();
            return true;
        }

        public async Task<IEnumerable<TableSchemaDto>> GetTablesAsync(DataSourceConnection connection, string databaseName)
        {
            using var mySqlConnection = new MySqlConnection(BuildConnectionString(connection, databaseName));
            await mySqlConnection.OpenAsync();

            var tables = new List<TableSchemaDto>();
            var sql = "SELECT TABLE_NAME, TABLE_COMMENT, TABLE_ROWS, CREATE_TIME FROM information_schema.TABLES WHERE TABLE_SCHEMA = @database ORDER BY TABLE_NAME";

            using var command = new MySqlCommand(sql, mySqlConnection);
            command.Parameters.AddWithValue("@database", databaseName);
            using var reader = await command.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                tables.Add(new TableSchemaDto
                {
                    Name = reader.GetString(0),
                    Comment = reader.IsDBNull(1) ? null : reader.GetString(1),
                    Rows = reader.IsDBNull(2) ? 0 : reader.GetInt64(2),
                    CreateTime = reader.GetDateTime(3)
                });
            }
            return tables;
        }

        public async Task<bool> CreateTableAsync(DataSourceConnection connection, string databaseName, CreateTableDto dto)
        {
            using var mySqlConnection = new MySqlConnection(BuildConnectionString(connection, databaseName));
            await mySqlConnection.OpenAsync();

            var sqlBuilder = new StringBuilder($"CREATE TABLE `{dto.Name}` (");
            var columnDefinitions = new List<string>();
            var primaryKeys = new List<string>();

            foreach (var col in dto.Columns)
            {
                var colDef = new StringBuilder($"`{col.Name}` {col.DataType}");

                if (col.DataType.ToLower().Contains("char") || col.DataType.ToLower().Contains("binary"))
                {
                    colDef.Append($"({(col.Length > 0 ? col.Length.ToString() : "255")})");
                }
                else if (col.DataType.ToLower() == "decimal" || col.DataType.ToLower() == "double" || col.DataType.ToLower() == "float")
                {
                    // For simplicity using default or passed length if applicable
                }

                if (!col.IsNullable) colDef.Append(" NOT NULL");
                else colDef.Append(" NULL");

                if (col.IsAutoIncrement) colDef.Append(" AUTO_INCREMENT");

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

                columnDefinitions.Add(colDef.ToString());

                if (col.IsPrimaryKey) primaryKeys.Add($"`{col.Name}`");
            }

            if (!columnDefinitions.Any()) throw new ArgumentException("At least one column is required");

            sqlBuilder.Append(string.Join(", ", columnDefinitions));

            if (primaryKeys.Any())
            {
                sqlBuilder.Append($", PRIMARY KEY ({string.Join(", ", primaryKeys)})");
            }

            sqlBuilder.Append(")");

            if (!string.IsNullOrEmpty(dto.Engine)) sqlBuilder.Append($" ENGINE={dto.Engine}");
            if (!string.IsNullOrEmpty(dto.CharSet)) sqlBuilder.Append($" DEFAULT CHARSET={dto.CharSet}");
            if (!string.IsNullOrEmpty(dto.Collation)) sqlBuilder.Append($" COLLATE={dto.Collation}");
            if (!string.IsNullOrEmpty(dto.Comment)) sqlBuilder.Append($" COMMENT='{dto.Comment.Replace("'", "''")}'");

            using var command = new MySqlCommand(sqlBuilder.ToString(), mySqlConnection);
            await command.ExecuteNonQueryAsync();
            return true;
        }

        public async Task<IEnumerable<ColumnSchemaDto>> GetColumnsAsync(DataSourceConnection connection, string databaseName, string tableName)
        {
            using var mySqlConnection = new MySqlConnection(BuildConnectionString(connection, databaseName));
            await mySqlConnection.OpenAsync();

            var columns = new List<ColumnSchemaDto>();
            var sql = "SELECT COLUMN_NAME, DATA_TYPE, COLUMN_TYPE, IS_NULLABLE, COLUMN_KEY, COLUMN_DEFAULT, COLUMN_COMMENT, ORDINAL_POSITION FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = @database AND TABLE_NAME = @table ORDER BY ORDINAL_POSITION";

            using var command = new MySqlCommand(sql, mySqlConnection);
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

        public async Task<bool> AddColumnAsync(DataSourceConnection connection, string databaseName, string tableName, AddColumnDto dto)
        {
            using var mySqlConnection = new MySqlConnection(BuildConnectionString(connection, databaseName));
            await mySqlConnection.OpenAsync();

            var colDef = new StringBuilder($"ALTER TABLE `{tableName}` ADD COLUMN `{dto.Name}` {dto.DataType}");
            if (dto.DataType.ToLower().Contains("char") || dto.DataType.ToLower().Contains("binary"))
            {
                colDef.Append($"({(dto.Length > 0 ? dto.Length.ToString() : "255")})");
            }

            if (!dto.IsNullable) colDef.Append(" NOT NULL");
            else colDef.Append(" NULL");
            
            if (!string.IsNullOrEmpty(dto.DefaultValue)) colDef.Append($" DEFAULT '{dto.DefaultValue}'");
            if (!string.IsNullOrEmpty(dto.Comment)) colDef.Append($" COMMENT '{dto.Comment}'");

            using var command = new MySqlCommand(colDef.ToString(), mySqlConnection);
            await command.ExecuteNonQueryAsync();
            return true;
        }

        public async Task<TableDataResultDto> GetTableDataAsync(DataSourceConnection connection, string databaseName, string tableName, TableDataQueryDto query)
        {
            using var mySqlConnection = new MySqlConnection(BuildConnectionString(connection, databaseName));
            await mySqlConnection.OpenAsync();

            var countSql = $"SELECT COUNT(*) FROM `{tableName}`";
            using var countCmd = new MySqlCommand(countSql, mySqlConnection);
            var total = Convert.ToInt64(await countCmd.ExecuteScalarAsync());

            var whereClause = new StringBuilder(" WHERE 1=1");
            var parameters = new List<MySqlParameter>();
            int paramIndex = 0;

            foreach (var filter in query.Filters)
            {
                var paramName = $"@p{paramIndex++}";
                var safeField = $"`{filter.Field}`";
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
                parameters.Add(new MySqlParameter(paramName, filter.Value));
            }

            var orderClause = "";
            if (!string.IsNullOrEmpty(query.SortField))
            {
                orderClause = $" ORDER BY `{query.SortField}` {(query.SortOrder?.ToLower() == "desc" ? "DESC" : "ASC")}";
            }

            var limitClause = $" LIMIT {(query.Page - 1) * query.PageSize}, {query.PageSize}";

            var dataSql = $"SELECT * FROM `{tableName}`{whereClause}{orderClause}{limitClause}";
            using var dataCmd = new MySqlCommand(dataSql, mySqlConnection);
            dataCmd.Parameters.AddRange(parameters.ToArray());

            using var reader = await dataCmd.ExecuteReaderAsync();
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
            using var mySqlConnection = new MySqlConnection(BuildConnectionString(connection, databaseName));
            await mySqlConnection.OpenAsync();

            var columns = new List<string>();
            var values = new List<string>();
            var parameters = new List<MySqlParameter>();
            int paramIndex = 0;

            foreach (var kvp in dto.Data)
            {
                columns.Add($"`{kvp.Key}`");
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
                parameters.Add(new MySqlParameter(paramName, value ?? DBNull.Value));
            }

            var sql = $"INSERT INTO `{tableName}` ({string.Join(", ", columns)}) VALUES ({string.Join(", ", values)})";
            using var command = new MySqlCommand(sql, mySqlConnection);
            command.Parameters.AddRange(parameters.ToArray());
            await command.ExecuteNonQueryAsync();
            return true;
        }

        public async Task<bool> UpdateRowAsync(DataSourceConnection connection, string databaseName, string tableName, UpdateRowDto dto)
        {
            using var mySqlConnection = new MySqlConnection(BuildConnectionString(connection, databaseName));
            await mySqlConnection.OpenAsync();

            var setClauses = new List<string>();
            var whereClauses = new List<string>();
            var parameters = new List<MySqlParameter>();
            int paramIndex = 0;

            foreach (var kvp in dto.Data)
            {
                var paramName = $"@p{paramIndex++}";
                setClauses.Add($"`{kvp.Key}` = {paramName}");
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
                parameters.Add(new MySqlParameter(paramName, value ?? DBNull.Value));
            }

            foreach (var kvp in dto.Keys)
            {
                var paramName = $"@k{paramIndex++}";
                whereClauses.Add($"`{kvp.Key}` = {paramName}");
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
                parameters.Add(new MySqlParameter(paramName, value ?? DBNull.Value));
            }

            var sql = $"UPDATE `{tableName}` SET {string.Join(", ", setClauses)} WHERE {string.Join(" AND ", whereClauses)}";
            using var command = new MySqlCommand(sql, mySqlConnection);
            command.Parameters.AddRange(parameters.ToArray());
            await command.ExecuteNonQueryAsync();
            return true;
        }

        public async Task<bool> DeleteRowAsync(DataSourceConnection connection, string databaseName, string tableName, DeleteRowDto dto)
        {
            using var mySqlConnection = new MySqlConnection(BuildConnectionString(connection, databaseName));
            await mySqlConnection.OpenAsync();

            var whereClauses = new List<string>();
            var parameters = new List<MySqlParameter>();
            int paramIndex = 0;

            foreach (var kvp in dto.Keys)
            {
                var paramName = $"@k{paramIndex++}";
                whereClauses.Add($"`{kvp.Key}` = {paramName}");
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
                parameters.Add(new MySqlParameter(paramName, value ?? DBNull.Value));
            }

            var sql = $"DELETE FROM `{tableName}` WHERE {string.Join(" AND ", whereClauses)}";
            using var command = new MySqlCommand(sql, mySqlConnection);
            command.Parameters.AddRange(parameters.ToArray());
            await command.ExecuteNonQueryAsync();
            return true;
        }

        public async Task<bool> DeleteColumnAsync(DataSourceConnection connection, string databaseName, string tableName, string columnName)
        {
            using var mySqlConnection = new MySqlConnection(BuildConnectionString(connection, databaseName));
            await mySqlConnection.OpenAsync();

            var sql = $"ALTER TABLE `{tableName}` DROP COLUMN `{columnName}`";
            using var command = new MySqlCommand(sql, mySqlConnection);
            await command.ExecuteNonQueryAsync();
            return true;
        }

        public async Task<bool> ModifyColumnAsync(DataSourceConnection connection, string databaseName, string tableName, string columnName, ModifyColumnDto dto)
        {
            using var mySqlConnection = new MySqlConnection(BuildConnectionString(connection, databaseName));
            await mySqlConnection.OpenAsync();

            var colDef = new StringBuilder($"ALTER TABLE `{tableName}` CHANGE COLUMN `{columnName}` `{dto.NewName ?? dto.Name}` {dto.DataType}");

            if (dto.DataType.ToLower().Contains("char") || dto.DataType.ToLower().Contains("binary"))
            {
                colDef.Append($"({(dto.Length > 0 ? dto.Length.ToString() : "255")})");
            }

            if (!dto.IsNullable) colDef.Append(" NOT NULL");
            else colDef.Append(" NULL");

            if (!string.IsNullOrEmpty(dto.DefaultValue)) colDef.Append($" DEFAULT '{dto.DefaultValue}'");
            if (!string.IsNullOrEmpty(dto.Comment)) colDef.Append($" COMMENT '{dto.Comment}'");

            if (dto.IsFirst)
            {
                colDef.Append(" FIRST");
            }
            else if (!string.IsNullOrEmpty(dto.AfterColumn))
            {
                colDef.Append($" AFTER `{dto.AfterColumn}`");
            }

            using var command = new MySqlCommand(colDef.ToString(), mySqlConnection);
            await command.ExecuteNonQueryAsync();
            return true;
        }
    }
}
