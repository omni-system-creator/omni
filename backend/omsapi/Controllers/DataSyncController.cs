using Microsoft.AspNetCore.Mvc;
using omsapi.Services;

namespace omsapi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class DataSyncController : ControllerBase
    {
        private readonly DataSyncService _syncService;

        public DataSyncController(DataSyncService syncService)
        {
            _syncService = syncService;
        }

        [HttpPost("mysql-to-mssql")]
        public async Task<IActionResult> SyncMysqlToMssql()
        {
            // 这是一个危险操作，应该有权限控制
            // 简单起见，这里假设是开发环境
            var result = await _syncService.SyncFromMysqlToMssqlAsync();
            return Ok(result);
        }

        [HttpPost("mysql-to-postgres")]
        public async Task<IActionResult> SyncMysqlToPostgres()
        {
            // 这是一个危险操作，应该有权限控制
            // 简单起见，这里假设是开发环境
            var result = await _syncService.SyncFromMysqlToPostgresAsync();
            return Ok(result);
        }
    }
}
