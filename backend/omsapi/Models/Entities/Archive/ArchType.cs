using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Archive
{
    [Table("arch_type")]
    public class ArchType
    {
        [Key]
        public long Id { get; set; }

        public long? ParentId { get; set; } // For tree structure (e.g. Wenshu -> Administration)

        [Required]
        [MaxLength(50)]
        public string Code { get; set; } = string.Empty; // 分类号 (e.g. WS, KJ)

        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty; // 分类名称

        public int SortOrder { get; set; } = 0;

        [ForeignKey("ParentId")]
        public virtual ArchType? Parent { get; set; }
        
        public virtual ICollection<ArchType> Children { get; set; } = new List<ArchType>();
    }
}