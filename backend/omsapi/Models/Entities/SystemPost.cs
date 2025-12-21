using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities
{
    [Table("sys_post")]
    public class SystemPost
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }

        [Required]
        [MaxLength(50)]
        public string Code { get; set; } = string.Empty; // 岗位编码

        [Required]
        [MaxLength(50)]
        public string Name { get; set; } = string.Empty; // 岗位名称

        public int SortOrder { get; set; } = 0;

        public bool IsActive { get; set; } = true;

        [MaxLength(200)]
        public string? Remark { get; set; }

        public long? DeptId { get; set; }
        [ForeignKey("DeptId")]
        public SystemDept? Dept { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }
    }
}
