using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Pages
{
    [Table("page_categories")]
    public class PageCategory
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }

        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        public long? ParentId { get; set; }

        public int SortOrder { get; set; } = 0;

        [ForeignKey("ParentId")]
        public virtual PageCategory? Parent { get; set; }

        public virtual ICollection<PageCategory> Children { get; set; } = new List<PageCategory>();
    }
}
