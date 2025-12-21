using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using omsapi.Models.Enums;

namespace omsapi.Models.Entities
{
    [Table("sys_dept")]
    public class SystemDept
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }

        public long? ParentId { get; set; }

        [Required]
        [MaxLength(50)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(50)]
        public string? Code { get; set; } 

        public DeptType Type { get; set; } = DeptType.Department;

        [MaxLength(50)]
        public string? Leader { get; set; }

        [MaxLength(20)]
        public string? Phone { get; set; }

        [MaxLength(100)]
        public string? Email { get; set; }

        public int SortOrder { get; set; } = 0;

        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }

        [ForeignKey("ParentId")]
        public virtual SystemDept? Parent { get; set; }
        
        public virtual ICollection<SystemDept> Children { get; set; } = new List<SystemDept>();
        public virtual ICollection<SystemUser> Users { get; set; } = new List<SystemUser>();
    }
}
