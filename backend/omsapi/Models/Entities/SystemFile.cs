using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities
{
    [Table("sys_file")]
    public class SystemFile
    {
        [Key]
        public long Id { get; set; }

        [Required]
        [MaxLength(255)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(20)]
        public string? Extension { get; set; }

        public long Size { get; set; }

        public bool IsFolder { get; set; }

        [MaxLength(500)]
        public string? FilePath { get; set; }
        
        [MaxLength(255)]
        public string? ContentType { get; set; }

        public long? ParentId { get; set; }
        
        [ForeignKey("ParentId")]
        public SystemFile? Parent { get; set; }
        
        public List<SystemFile> Children { get; set; } = new();

        public long OwnerId { get; set; }
        
        [ForeignKey("OwnerId")]
        public SystemUser? Owner { get; set; }

        // If null, it's a personal file. If set, it belongs to a department/group.
        public long? DeptId { get; set; }
        
        [ForeignKey("DeptId")]
        public SystemDept? Dept { get; set; }

        public bool IsPublic { get; set; } = false;

        // 0: Personal, 1: Dept/Group, 2: Company/Org (Derived from Dept Type usually, but can be explicit if needed)
        // For now, we infer from DeptId. If DeptId is not null, check Dept type.

        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime UpdatedAt { get; set; } = DateTime.Now;
    }
}
