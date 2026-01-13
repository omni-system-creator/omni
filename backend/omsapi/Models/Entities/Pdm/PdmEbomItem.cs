using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Pdm
{
    [Table("pdm_ebom_items")]
    public class PdmEbomItem
    {
        [Key]
        [MaxLength(50)]
        [Column("id")]
        public string Id { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        [Column("name")]
        public string Name { get; set; } = string.Empty;

        [MaxLength(50)]
        [Column("version")]
        public string Version { get; set; } = "V1.0";

        [MaxLength(50)]
        [Column("status")]
        public string Status { get; set; } = "设计中";

        [MaxLength(50)]
        [Column("product_type")]
        public string ProductType { get; set; } = string.Empty;

        [MaxLength(50)]
        [Column("designer")]
        public string Designer { get; set; } = "工程师A";

        [MaxLength(100)]
        [Column("spec")]
        public string Spec { get; set; } = "Standard";

        [MaxLength(20)]
        [Column("unit")]
        public string Unit { get; set; } = "PCS";

        [Column("is_leaf")]
        public bool IsLeaf { get; set; } = false;

        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.Now;

        [Column("updated_at")]
        public DateTime UpdatedAt { get; set; } = DateTime.Now;
    }
}
