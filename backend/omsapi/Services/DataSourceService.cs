using Microsoft.EntityFrameworkCore;
using omsapi.Data;
using omsapi.Infrastructure.Attributes;
using omsapi.Models.Dtos.Data;
using omsapi.Models.Entities.Data;
using omsapi.Services.DataSourceAdapters;
using omsapi.Services.Interfaces;

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

        private IDatabaseAdapter GetAdapter(string type)
        {
            return type.ToLower() switch
            {
                "mysql" => new MySqlAdapter(),
                "sqlserver" => new SqlServerAdapter(),
                _ => throw new NotImplementedException($"Database type '{type}' is not supported.")
            };
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
            var tempConnection = new DataSourceConnection
            {
                Type = connectionDto.Type,
                Host = connectionDto.Host,
                Port = connectionDto.Port,
                User = connectionDto.User,
                Password = connectionDto.Password,
                Database = connectionDto.Database
            };

            var adapter = GetAdapter(connectionDto.Type);
            return await adapter.TestConnectionAsync(tempConnection);
        }

        public async Task<IEnumerable<DatabaseSchemaDto>> GetDatabasesAsync(long connectionId)
        {
            var connectionEntity = await _context.DataSourceConnections.FindAsync(connectionId);
            if (connectionEntity == null) throw new KeyNotFoundException("Connection not found");

            var adapter = GetAdapter(connectionEntity.Type);
            return await adapter.GetDatabasesAsync(connectionEntity);
        }
        
        public async Task<bool> CreateDatabaseAsync(long connectionId, CreateDatabaseDto dto)
        {
            var connectionEntity = await _context.DataSourceConnections.FindAsync(connectionId);
            if (connectionEntity == null) throw new KeyNotFoundException("Connection not found");

            var adapter = GetAdapter(connectionEntity.Type);
            return await adapter.CreateDatabaseAsync(connectionEntity, dto);
        }

        public async Task<IEnumerable<TableSchemaDto>> GetTablesAsync(long connectionId, string databaseName)
        {
            var connectionEntity = await _context.DataSourceConnections.FindAsync(connectionId);
            if (connectionEntity == null) throw new KeyNotFoundException("Connection not found");

            var adapter = GetAdapter(connectionEntity.Type);
            return await adapter.GetTablesAsync(connectionEntity, databaseName);
        }
        
        public async Task<bool> CreateTableAsync(long connectionId, string databaseName, CreateTableDto dto)
        {
            var connectionEntity = await _context.DataSourceConnections.FindAsync(connectionId);
            if (connectionEntity == null) throw new KeyNotFoundException("Connection not found");

            var adapter = GetAdapter(connectionEntity.Type);
            return await adapter.CreateTableAsync(connectionEntity, databaseName, dto);
        }

        public async Task<IEnumerable<ColumnSchemaDto>> GetColumnsAsync(long connectionId, string databaseName, string tableName)
        {
            var connectionEntity = await _context.DataSourceConnections.FindAsync(connectionId);
            if (connectionEntity == null) throw new KeyNotFoundException("Connection not found");

            var adapter = GetAdapter(connectionEntity.Type);
            return await adapter.GetColumnsAsync(connectionEntity, databaseName, tableName);
        }
        
        public async Task<bool> AddColumnAsync(long connectionId, string databaseName, string tableName, AddColumnDto dto)
        {
            var connectionEntity = await _context.DataSourceConnections.FindAsync(connectionId);
            if (connectionEntity == null) throw new KeyNotFoundException("Connection not found");

            var adapter = GetAdapter(connectionEntity.Type);
            return await adapter.AddColumnAsync(connectionEntity, databaseName, tableName, dto);
        }

        public async Task<TableDataResultDto> GetTableDataAsync(long connectionId, string databaseName, string tableName, TableDataQueryDto query)
        {
            var connectionEntity = await _context.DataSourceConnections.FindAsync(connectionId);
            if (connectionEntity == null) throw new KeyNotFoundException("Connection not found");

            var adapter = GetAdapter(connectionEntity.Type);
            
            // Note: Adapter GetTableDataAsync now returns raw rows. 
            // The original logic fetched column metadata to ensure columns are defined in result.
            // Let's rely on Adapter to handle this or the frontend to be robust.
            // The Adapter implementation I wrote returns a TableDataResultDto which is consistent.
            
            var result = await adapter.GetTableDataAsync(connectionEntity, databaseName, tableName, query);
            
            // If the adapter doesn't populate Columns (MySqlAdapter implementation didn't explicitly), 
            // we might want to fetch them.
            // My MySqlAdapter implementation was simplified and missed filling result.Columns.
            // Let's fix that in the Service by calling GetColumnsAsync if needed, or update Adapters.
            // Since I cannot easily update Adapters now without multiple writes, let's just populate Columns here.
            
            if (result.Columns == null || !result.Columns.Any())
            {
                var columns = await adapter.GetColumnsAsync(connectionEntity, databaseName, tableName);
                result.Columns = columns.ToList();
            }
            
            return result;
        }

        public async Task<bool> InsertRowAsync(long connectionId, string databaseName, string tableName, InsertRowDto dto)
        {
            var connectionEntity = await _context.DataSourceConnections.FindAsync(connectionId);
            if (connectionEntity == null) throw new KeyNotFoundException("Connection not found");

            var adapter = GetAdapter(connectionEntity.Type);
            return await adapter.InsertRowAsync(connectionEntity, databaseName, tableName, dto);
        }

        public async Task<bool> UpdateRowAsync(long connectionId, string databaseName, string tableName, UpdateRowDto dto)
        {
            var connectionEntity = await _context.DataSourceConnections.FindAsync(connectionId);
            if (connectionEntity == null) throw new KeyNotFoundException("Connection not found");

            var adapter = GetAdapter(connectionEntity.Type);
            return await adapter.UpdateRowAsync(connectionEntity, databaseName, tableName, dto);
        }
        
        public async Task<bool> DeleteRowAsync(long connectionId, string databaseName, string tableName, DeleteRowDto dto)
        {
             var connectionEntity = await _context.DataSourceConnections.FindAsync(connectionId);
            if (connectionEntity == null) throw new KeyNotFoundException("Connection not found");

            var adapter = GetAdapter(connectionEntity.Type);
            return await adapter.DeleteRowAsync(connectionEntity, databaseName, tableName, dto);
        }

        public async Task<bool> DeleteColumnAsync(long connectionId, string databaseName, string tableName, string columnName)
        {
            var connectionEntity = await _context.DataSourceConnections.FindAsync(connectionId);
            if (connectionEntity == null) throw new KeyNotFoundException("Connection not found");

            var adapter = GetAdapter(connectionEntity.Type);
            return await adapter.DeleteColumnAsync(connectionEntity, databaseName, tableName, columnName);
        }

        public async Task<bool> ModifyColumnAsync(long connectionId, string databaseName, string tableName, string columnName, ModifyColumnDto dto)
        {
            var connectionEntity = await _context.DataSourceConnections.FindAsync(connectionId);
            if (connectionEntity == null) throw new KeyNotFoundException("Connection not found");

            var adapter = GetAdapter(connectionEntity.Type);
            return await adapter.ModifyColumnAsync(connectionEntity, databaseName, tableName, columnName, dto);
        }
    }
}
