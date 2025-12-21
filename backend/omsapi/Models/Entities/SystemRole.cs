using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities
{
    [Table("sys_role")]
    public class SystemRole
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }

        [Required]
        [MaxLength(50)]
        public string Name { get; set; } = string.Empty; // 角色名称 (e.g. "管理员")

        [Required]
        [MaxLength(50)]
        public string Code { get; set; } = string.Empty; // 角色编码 (e.g. "ADMIN")

        [MaxLength(200)]
        public string? Description { get; set; }

        public bool IsSystem { get; set; } = false; // 是否为系统内置角色 (不可删除)

        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }
    }
}
