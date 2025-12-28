using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Pages
{
    [Table("page_definitions")]
    public class PageDefinition
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }

        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        public long? CategoryId { get; set; }

        [Column(TypeName = "longtext")]
        public string? Code { get; set; } // TSX Code

        [Column(TypeName = "longtext")]
        public string? Config { get; set; } // Visual Config (JSON)

        [Column(TypeName = "longtext")]
        public string? ApiBindings { get; set; } // JSON ApiBindings

        [MaxLength(500)]
        public string? Description { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.Now;

        public DateTime UpdatedAt { get; set; } = DateTime.Now;

        [ForeignKey("CategoryId")]
        public virtual PageCategory? Category { get; set; }
    }
}
