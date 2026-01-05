using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace OmsApi.Models.Entities.Kb
{
    [Table("kb_info")]
    public class KbInfo
    {
        [Key]
        public Guid Id { get; set; }

        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(500)]
        public string? Description { get; set; }

        [MaxLength(50)]
        public string Category { get; set; } = "general"; // general, tech, hr, project

        [MaxLength(50)]
        public string Type { get; set; } = "general"; // general, code, book

        public int SortOrder { get; set; } = 0;

        public DateTime CreatedAt { get; set; } = DateTime.Now;

        public DateTime? UpdatedAt { get; set; }

        public Guid? CreatedBy { get; set; }

        // Navigation properties
        public ICollection<KbFile> Files { get; set; } = new List<KbFile>();
        public ICollection<KbNode> Nodes { get; set; } = new List<KbNode>();
    }
}
