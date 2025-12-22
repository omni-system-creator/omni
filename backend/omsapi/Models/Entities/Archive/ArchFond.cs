using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Archive
{
    [Table("arch_fond")]
    public class ArchFond
    {
        [Key]
        public long Id { get; set; }

        [Required]
        [MaxLength(50)]
        public string Code { get; set; } = string.Empty; // 全宗号 (e.g. Z001)

        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty; // 全宗名称

        [MaxLength(500)]
        public string? Description { get; set; }

        public int SortOrder { get; set; } = 0;

        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
}