using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities
{
    [Table("sys_role_permission")]
    public class SystemRolePermission
    {
        public long RoleId { get; set; }

        public long PermissionId { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
}
