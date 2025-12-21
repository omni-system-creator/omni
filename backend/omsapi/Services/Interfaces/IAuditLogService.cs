using omsapi.Models.Entities;

namespace omsapi.Services.Interfaces
{
    public interface IAuditLogService
    {
        Task LogAsync(AuditLog log);
    }
}
