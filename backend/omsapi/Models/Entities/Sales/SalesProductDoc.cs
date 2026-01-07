using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Sales
{
    [Table("sales_product_doc")]
    public class SalesProductDoc
    {
        [Key]
        [Column("id")]
        public string Id { get; set; } = Guid.NewGuid().ToString("N");

        [Column("title")]
        [Required]
        [MaxLength(200)]
        public string Title { get; set; } = string.Empty;

        [Column("size")]
        [MaxLength(50)]
        public string Size { get; set; } = string.Empty;

        [Column("url")]
        [MaxLength(500)]
        public string Url { get; set; } = string.Empty;

        [Column("parent_id")]
        [MaxLength(50)]
        public string? ParentId { get; set; }

        [Column("type")]
        [MaxLength(20)]
        public string Type { get; set; } = "file"; // "folder" or "file"

        [Column("upload_date")]
        public DateTime UploadDate { get; set; } = DateTime.Now;
    }
}
