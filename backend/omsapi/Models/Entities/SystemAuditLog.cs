using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities
{
    [Table("sys_audit_log")]
    public class SystemAuditLog
    {
        [Key]
        public long Id { get; set; }

        public long? UserId { get; set; }

        [MaxLength(50)]
        public string? UserName { get; set; }

        [MaxLength(200)] // 增加长度
        public string Action { get; set; } = string.Empty; // e.g., Login, Create, Update, Delete

        [MaxLength(200)]
        public string? Route { get; set; } // API path

        [MaxLength(10)]
        public string? Method { get; set; } // GET, POST, etc.

        [MaxLength(50)]
        public string? IpAddress { get; set; }

        [MaxLength(500)]
        public string? UserAgent { get; set; }

        public string? Parameters { get; set; } // JSON of request parameters

        public bool IsSuccess { get; set; }

        public string? ErrorMessage { get; set; }

        public long ExecutionDuration { get; set; } // ms

        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
}
