using omsapi.Data;
using omsapi.Models.Entities;
using omsapi.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
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
            // Use a separate strategy for audit logs to avoid conflict with main transaction
            var strategy = _context.Database.CreateExecutionStrategy();
            await strategy.ExecuteAsync(async () => 
            {
                try 
                {
                   _context.AuditLogs.Add(log);
                   await _context.SaveChangesAsync();
                }
                catch
                {
                   // Ignore audit log errors to not hide the original error
                }
            });
        }
    }
}
