using omsapi.Models.Dtos.Data;
using omsapi.Models.Entities.Data;

namespace omsapi.Services.Interfaces
{
    public interface IDataSourceService
    {
        Task<IEnumerable<DataSourceConnectionDto>> GetAllAsync();
        Task<DataSourceConnectionDto?> GetByIdAsync(long id);
        Task<DataSourceConnectionDto> CreateAsync(CreateDataSourceConnectionDto createDto);
        Task<DataSourceConnectionDto?> UpdateAsync(long id, UpdateDataSourceConnectionDto updateDto);
        Task<bool> DeleteAsync(long id);
        Task<bool> TestConnectionAsync(CreateDataSourceConnectionDto connectionDto);

        // Metadata methods
        Task<IEnumerable<DatabaseSchemaDto>> GetDatabasesAsync(long connectionId);
        Task<IEnumerable<TableSchemaDto>> GetTablesAsync(long connectionId, string databaseName);
        Task<IEnumerable<ColumnSchemaDto>> GetColumnsAsync(long connectionId, string databaseName, string tableName);
        Task<TableDataResultDto> GetTableDataAsync(long connectionId, string databaseName, string tableName, TableDataQueryDto query);
        Task<bool> InsertRowAsync(long connectionId, string databaseName, string tableName, InsertRowDto dto);
        Task<bool> UpdateRowAsync(long connectionId, string databaseName, string tableName, UpdateRowDto dto);
        Task<bool> DeleteRowAsync(long connectionId, string databaseName, string tableName, DeleteRowDto dto);
        Task<bool> CreateDatabaseAsync(long connectionId, CreateDatabaseDto dto);
        Task<bool> CreateTableAsync(long connectionId, string databaseName, CreateTableDto dto);
        
        // Column operations
        Task<bool> AddColumnAsync(long connectionId, string databaseName, string tableName, AddColumnDto dto);
        Task<bool> DeleteColumnAsync(long connectionId, string databaseName, string tableName, string columnName);
        Task<bool> ModifyColumnAsync(long connectionId, string databaseName, string tableName, string columnName, ModifyColumnDto dto);
    }
}
