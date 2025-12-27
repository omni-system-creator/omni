using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Interfaces
{
    [Table("api_category")]
    public class InterfaceCategory
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }

        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(100)]
        public string UrlPrefix { get; set; } = "/";

        public long? ParentId { get; set; }

        public int SortOrder { get; set; } = 0;

        public DateTime CreatedAt { get; set; } = DateTime.Now;

        public long? CreatedBy { get; set; }

        [ForeignKey("ParentId")]
        public virtual InterfaceCategory? Parent { get; set; }

        public virtual ICollection<InterfaceCategory> Children { get; set; } = new List<InterfaceCategory>();

        public virtual ICollection<InterfaceDefinition> Interfaces { get; set; } = new List<InterfaceDefinition>();
    }
}
