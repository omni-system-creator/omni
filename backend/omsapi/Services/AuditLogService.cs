using omsapi.Data;
using omsapi.Models.Entities;
using omsapi.Services.Interfaces;

using omsapi.Infrastructure.Attributes;

namespace omsapi.Services
{
    [AutoInject(ServiceLifetime.Scoped)]
    public class AuditLogService : IAuditLogService
    {
        private readonly OmsContext _context;
        private readonly ILogger<AuditLogService> _logger;

        public AuditLogService(OmsContext context, ILogger<AuditLogService> logger)
        {
            _context = context;
            _logger = logger;
        }

        public async Task LogAsync(AuditLog log)
        {
            try
            {
                _context.AuditLogs.Add(log);
                await _context.SaveChangesAsync();
            }
            catch (Exception ex)
            {
                // 审计日志记录失败不应影响主业务，记录到系统日志即可
                _logger.LogError(ex, "Failed to write audit log");
            }
        }
    }
}
