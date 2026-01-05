using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Pgvector;

namespace OmsApi.Models.Entities.Kb
{
    [Table("kb_node")]
    public class KbNode
    {
        [Key]
        public Guid Id { get; set; }

        [Required]
        public Guid KbId { get; set; }

        public Guid? ParentId { get; set; }

        [Required]
        [MaxLength(255)]
        public string Title { get; set; } = string.Empty;

        [Column(TypeName = "text")]
        public string? Summary { get; set; }

        [Column(TypeName = "text")]
        public string? Content { get; set; }

        [Column(TypeName = "vector(1024)")]
        public Vector? Vector { get; set; }

        [MaxLength(100)]
        public string? Key { get; set; }

        public int SortOrder { get; set; }

        [ForeignKey(nameof(KbId))]
        public KbInfo? Kb { get; set; }

        [ForeignKey(nameof(ParentId))]
        public KbNode? Parent { get; set; }

        public ICollection<KbNode> Children { get; set; } = new List<KbNode>();
        public ICollection<KbNodeSource> Sources { get; set; } = new List<KbNodeSource>();
    }
}
