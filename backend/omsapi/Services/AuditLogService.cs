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

        public AuditLogService(OmsContext context)
        {
            _context = context;
        }

        public async Task LogAsync(SystemAuditLog log)
        {
            _context.AuditLogs.Add(log);
            await _context.SaveChangesAsync();
        }
    }
}
