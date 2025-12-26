using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Forms
{
    [Table("frm_definition")]
    public class FormDefinition
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }

        public long CategoryId { get; set; }

        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(50)]
        public string? Code { get; set; }

        [MaxLength(500)]
        public string? Description { get; set; }

        [Column(TypeName = "text")]
        public string? FormItems { get; set; } // JSON string

        public bool IsPublished { get; set; } = false;

        public DateTime CreatedAt { get; set; } = DateTime.Now;

        public DateTime UpdatedAt { get; set; } = DateTime.Now;

        public long? CreatedBy { get; set; }

        public long? UpdatedBy { get; set; }

        [ForeignKey("CategoryId")]
        public virtual FormCategory? Category { get; set; }
    }
}
