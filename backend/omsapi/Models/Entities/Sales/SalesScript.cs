using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Sales
{
    [Table("sales_script")]
    public class SalesScript
    {
        [Key]
        [Column("id")]
        public string Id { get; set; } = Guid.NewGuid().ToString("N");

        [Column("title")]
        [Required]
        [MaxLength(200)]
        public string Title { get; set; } = string.Empty;

        [Column("content")]
        public string Content { get; set; } = string.Empty; // TEXT

        [Column("category")]
        [MaxLength(100)]
        public string Category { get; set; } = string.Empty;

        [Column("description")]
        [MaxLength(500)]
        public string Description { get; set; } = string.Empty;

        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
}
