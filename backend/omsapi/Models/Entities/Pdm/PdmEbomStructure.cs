using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Pdm
{
    [Table("pdm_ebom_structure")]
    public class PdmEbomStructure
    {
        [Key]
        [Column("id")]
        public long Id { get; set; }

        [Required]
        [MaxLength(50)]
        [Column("parent_id")]
        public string ParentId { get; set; } = string.Empty;

        [Required]
        [MaxLength(50)]
        [Column("child_id")]
        public string ChildId { get; set; } = string.Empty;

        [Column("quantity")]
        public decimal Quantity { get; set; } = 1;

        [MaxLength(20)]
        [Column("child_version")]
        public string? ChildVersion { get; set; }

        [Column("sort_order")]
        public int SortOrder { get; set; }

        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
}
