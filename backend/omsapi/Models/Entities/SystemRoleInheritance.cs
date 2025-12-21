using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities
{
    [Table("sys_role_inheritance")]
    public class SystemRoleInheritance
    {
        public long ParentRoleId { get; set; }

        public long ChildRoleId { get; set; }

        [ForeignKey("ParentRoleId")]
        public virtual SystemRole ParentRole { get; set; } = null!;

        [ForeignKey("ChildRoleId")]
        public virtual SystemRole ChildRole { get; set; } = null!;
    }
}
