using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace OmsApi.Models.Entities.Kb
{
    [Table("kb_qa_history")]
    public class KbQaHistory
    {
        [Key]
        public Guid Id { get; set; }

        [Required]
        public Guid KbId { get; set; }

        public Guid? UserId { get; set; }

        [Column(TypeName = "text")]
        public string Question { get; set; } = string.Empty;

        [Column(TypeName = "longtext")]
        public string? Answer { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [Column(TypeName = "text")]
        public string? SourcesJson { get; set; } // Simplified storage for sources

        [ForeignKey(nameof(KbId))]
        public KbInfo? Kb { get; set; }
    }
}
