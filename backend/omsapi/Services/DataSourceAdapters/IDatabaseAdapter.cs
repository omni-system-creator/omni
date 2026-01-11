using omsapi.Models.Dtos.Data;
using omsapi.Models.Entities.Data;

namespace omsapi.Services.DataSourceAdapters
{
    public interface IDatabaseAdapter
    {
        Task<bool> TestConnectionAsync(DataSourceConnection connection);
        Task<IEnumerable<DatabaseSchemaDto>> GetDatabasesAsync(DataSourceConnection connection);
        Task<bool> CreateDatabaseAsync(DataSourceConnection connection, CreateDatabaseDto dto);
        Task<IEnumerable<TableSchemaDto>> GetTablesAsync(DataSourceConnection connection, string databaseName);
        Task<bool> CreateTableAsync(DataSourceConnection connection, string databaseName, CreateTableDto dto);
        Task<IEnumerable<ColumnSchemaDto>> GetColumnsAsync(DataSourceConnection connection, string databaseName, string tableName);
        Task<bool> AddColumnAsync(DataSourceConnection connection, string databaseName, string tableName, AddColumnDto dto);
        Task<TableDataResultDto> GetTableDataAsync(DataSourceConnection connection, string databaseName, string tableName, TableDataQueryDto query);
        Task<bool> InsertRowAsync(DataSourceConnection connection, string databaseName, string tableName, InsertRowDto dto);
        Task<bool> UpdateRowAsync(DataSourceConnection connection, string databaseName, string tableName, UpdateRowDto dto);
        Task<bool> DeleteRowAsync(DataSourceConnection connection, string databaseName, string tableName, DeleteRowDto dto);
        
        // Column management
        Task<bool> DeleteColumnAsync(DataSourceConnection connection, string databaseName, string tableName, string columnName);
        Task<bool> ModifyColumnAsync(DataSourceConnection connection, string databaseName, string tableName, string columnName, ModifyColumnDto dto);
    }
}
