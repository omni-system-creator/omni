using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace OmsApi.Models.Entities.Kb
{
    [Table("kb_node_source")]
    public class KbNodeSource
    {
        [Key]
        public Guid Id { get; set; }

        [Required]
        public Guid NodeId { get; set; }

        [Required]
        public Guid FileId { get; set; }

        public int Page { get; set; }

        [MaxLength(255)]
        public string? Description { get; set; }

        [ForeignKey(nameof(NodeId))]
        public KbNode? Node { get; set; }

        [ForeignKey(nameof(FileId))]
        public KbFile? File { get; set; }
    }
}
