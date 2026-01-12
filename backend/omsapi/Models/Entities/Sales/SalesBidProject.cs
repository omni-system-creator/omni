using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Sales
{
    [Table("sales_bid_project")]
    public class SalesBidProject
    {
        [Key]
        [Column("id")]
        public string Id { get; set; } = Guid.NewGuid().ToString("N");

        [Column("code")]
        [Required]
        [MaxLength(50)]
        public string Code { get; set; } = string.Empty;

        [Column("name")]
        [Required]
        [MaxLength(200)]
        public string Name { get; set; } = string.Empty;

        [Column("customer")]
        [MaxLength(200)]
        public string? Customer { get; set; }

        [Column("region")]
        [MaxLength(100)]
        public string? Region { get; set; }

        [Column("type")]
        [MaxLength(50)]
        public string? Type { get; set; }

        [Column("budget")]
        [MaxLength(50)]
        public string? Budget { get; set; }

        [Column("bid_time")]
        public DateTime? BidTime { get; set; }

        [Column("leader")]
        [MaxLength(100)]
        public string? Leader { get; set; }

        [Column("status")]
        [MaxLength(50)]
        public string Status { get; set; } = "进行中";

        [Column("description")]
        public string? Description { get; set; }

        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [Column("updated_at")]
        public DateTime? UpdatedAt { get; set; }
    }
}
