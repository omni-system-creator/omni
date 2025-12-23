using Microsoft.AspNetCore.Mvc;
using omsapi.Models.Common;
using omsapi.Models.Dtos.Data;
using omsapi.Services.Interfaces;

namespace omsapi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class DataSourceController : ControllerBase
    {
        private readonly IDataSourceService _dataSourceService;

        public DataSourceController(IDataSourceService dataSourceService)
        {
            _dataSourceService = dataSourceService;
        }

        [HttpGet]
        public async Task<ActionResult<ApiResponse<IEnumerable<DataSourceConnectionDto>>>> GetAll()
        {
            var connections = await _dataSourceService.GetAllAsync();
            return Ok(ApiResponse<IEnumerable<DataSourceConnectionDto>>.Success(connections));
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<ApiResponse<DataSourceConnectionDto>>> GetById(long id)
        {
            var connection = await _dataSourceService.GetByIdAsync(id);
            if (connection == null)
            {
                return NotFound(ApiResponse<DataSourceConnectionDto>.Error("Data source not found"));
            }
            return Ok(ApiResponse<DataSourceConnectionDto>.Success(connection));
        }

        [HttpPost]
        public async Task<ActionResult<ApiResponse<DataSourceConnectionDto>>> Create(CreateDataSourceConnectionDto createDto)
        {
            var connection = await _dataSourceService.CreateAsync(createDto);
            return CreatedAtAction(nameof(GetById), new { id = connection.Id }, ApiResponse<DataSourceConnectionDto>.Success(connection));
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<ApiResponse<DataSourceConnectionDto>>> Update(long id, UpdateDataSourceConnectionDto updateDto)
        {
            var connection = await _dataSourceService.UpdateAsync(id, updateDto);
            if (connection == null)
            {
                return NotFound(ApiResponse<DataSourceConnectionDto>.Error("Data source not found"));
            }
            return Ok(ApiResponse<DataSourceConnectionDto>.Success(connection));
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<ApiResponse<bool>>> Delete(long id)
        {
            var result = await _dataSourceService.DeleteAsync(id);
            if (!result)
            {
                return NotFound(ApiResponse<bool>.Error("Data source not found"));
            }
            return Ok(ApiResponse<bool>.Success(true));
        }

        [HttpPost("test")]
        public async Task<ActionResult<ApiResponse<bool>>> TestConnection(CreateDataSourceConnectionDto connectionDto)
        {
            var result = await _dataSourceService.TestConnectionAsync(connectionDto);
            return Ok(ApiResponse<bool>.Success(result));
        }

        [HttpGet("{id}/databases")]
        public async Task<ActionResult<ApiResponse<IEnumerable<DatabaseSchemaDto>>>> GetDatabases(long id)
        {
            var databases = await _dataSourceService.GetDatabasesAsync(id);
            return Ok(ApiResponse<IEnumerable<DatabaseSchemaDto>>.Success(databases));
        }

        [HttpPost("{id}/databases")]
        public async Task<ActionResult<ApiResponse<bool>>> CreateDatabase(long id, [FromBody] CreateDatabaseDto dto)
        {
            try
            {
                var result = await _dataSourceService.CreateDatabaseAsync(id, dto);
                return Ok(ApiResponse<bool>.Success(result));
            }
            catch (Exception ex)
            {
                return BadRequest(ApiResponse<bool>.Error(ex.Message));
            }
        }

        [HttpPost("{id}/databases/{databaseName}/tables")]
        public async Task<ActionResult<ApiResponse<bool>>> CreateTable(long id, string databaseName, [FromBody] CreateTableDto dto)
        {
            try
            {
                var result = await _dataSourceService.CreateTableAsync(id, databaseName, dto);
                return Ok(ApiResponse<bool>.Success(result));
            }
            catch (Exception ex)
            {
                return BadRequest(ApiResponse<bool>.Error(ex.Message));
            }
        }

        [HttpGet("{id}/databases/{databaseName}/tables")]
        public async Task<ActionResult<ApiResponse<IEnumerable<TableSchemaDto>>>> GetTables(long id, string databaseName)
        {
            var tables = await _dataSourceService.GetTablesAsync(id, databaseName);
            return Ok(ApiResponse<IEnumerable<TableSchemaDto>>.Success(tables));
        }

        [HttpGet("{id}/databases/{databaseName}/tables/{tableName}/columns")]
        public async Task<ActionResult<ApiResponse<IEnumerable<ColumnSchemaDto>>>> GetColumns(long id, string databaseName, string tableName)
        {
            var columns = await _dataSourceService.GetColumnsAsync(id, databaseName, tableName);
            return Ok(ApiResponse<IEnumerable<ColumnSchemaDto>>.Success(columns));
        }

        [HttpPost("{id}/databases/{databaseName}/tables/{tableName}/data")]
        public async Task<IActionResult> GetTableData(long id, string databaseName, string tableName, [FromBody] TableDataQueryDto query)
        {
            var result = await _dataSourceService.GetTableDataAsync(id, databaseName, tableName, query);
            return Ok(ApiResponse<TableDataResultDto>.Success(result));
        }

        [HttpPost("{id}/databases/{databaseName}/tables/{tableName}/data/insert")]
        public async Task<IActionResult> InsertRow(long id, string databaseName, string tableName, [FromBody] InsertRowDto dto)
        {
            var result = await _dataSourceService.InsertRowAsync(id, databaseName, tableName, dto);
            return Ok(ApiResponse<bool>.Success(result));
        }

        [HttpPost("{id}/databases/{databaseName}/tables/{tableName}/data/update")]
        public async Task<IActionResult> UpdateRow(long id, string databaseName, string tableName, [FromBody] UpdateRowDto dto)
        {
            var result = await _dataSourceService.UpdateRowAsync(id, databaseName, tableName, dto);
            return Ok(ApiResponse<bool>.Success(result));
        }

        [HttpPost("{id}/databases/{databaseName}/tables/{tableName}/data/delete")]
        public async Task<IActionResult> DeleteRow(long id, string databaseName, string tableName, [FromBody] DeleteRowDto dto)
        {
            var result = await _dataSourceService.DeleteRowAsync(id, databaseName, tableName, dto);
            return Ok(ApiResponse<bool>.Success(result));
        }

        [HttpPost("{id}/databases/{databaseName}/tables/{tableName}/columns")]
        public async Task<IActionResult> AddColumn(long id, string databaseName, string tableName, [FromBody] AddColumnDto dto)
        {
            try
            {
                var result = await _dataSourceService.AddColumnAsync(id, databaseName, tableName, dto);
                return Ok(ApiResponse<bool>.Success(result));
            }
            catch (Exception ex)
            {
                return BadRequest(ApiResponse<bool>.Error(ex.Message));
            }
        }

        [HttpDelete("{id}/databases/{databaseName}/tables/{tableName}/columns/{columnName}")]
        public async Task<IActionResult> DeleteColumn(long id, string databaseName, string tableName, string columnName)
        {
            try
            {
                var result = await _dataSourceService.DeleteColumnAsync(id, databaseName, tableName, columnName);
                return Ok(ApiResponse<bool>.Success(result));
            }
            catch (Exception ex)
            {
                return BadRequest(ApiResponse<bool>.Error(ex.Message));
            }
        }

        [HttpPut("{id}/databases/{databaseName}/tables/{tableName}/columns/{columnName}")]
        public async Task<IActionResult> ModifyColumn(long id, string databaseName, string tableName, string columnName, [FromBody] ModifyColumnDto dto)
        {
            try
            {
                var result = await _dataSourceService.ModifyColumnAsync(id, databaseName, tableName, columnName, dto);
                return Ok(ApiResponse<bool>.Success(result));
            }
            catch (Exception ex)
            {
                return BadRequest(ApiResponse<bool>.Error(ex.Message));
            }
        }
    }
}
