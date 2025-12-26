using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Forms
{
    [Table("frm_category")]
    public class FormCategory
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }

        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        public long? ParentId { get; set; }

        public int SortOrder { get; set; } = 0;

        public DateTime CreatedAt { get; set; } = DateTime.Now;

        public long? CreatedBy { get; set; }

        [ForeignKey("ParentId")]
        public virtual FormCategory? Parent { get; set; }

        public virtual ICollection<FormCategory> Children { get; set; } = new List<FormCategory>();

        public virtual ICollection<FormDefinition> Forms { get; set; } = new List<FormDefinition>();
    }
}
