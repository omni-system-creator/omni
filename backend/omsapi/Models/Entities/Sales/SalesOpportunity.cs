using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Sales
{
    [Table("sales_opportunity")]
    public class SalesOpportunity
    {
        [Key]
        [Column("id")]
        public string Id { get; set; } = Guid.NewGuid().ToString("N");

        [Column("title")]
        [Required]
        [MaxLength(200)]
        public string Title { get; set; } = string.Empty;

        [Column("customer")]
        [MaxLength(200)]
        public string Customer { get; set; } = string.Empty;

        [Column("customer_id")]
        [MaxLength(50)]
        public string CustomerId { get; set; } = string.Empty;

        [Column("amount")]
        public decimal Amount { get; set; }

        [Column("stage")]
        [MaxLength(50)]
        public string Stage { get; set; } = string.Empty; // new, proposition, negotiation, won, lost

        [Column("win_rate")]
        public int WinRate { get; set; }

        [Column("owner")]
        [MaxLength(100)]
        public string Owner { get; set; } = string.Empty;

        [Column("description")]
        public string Description { get; set; } = string.Empty;

        [Column("estimated_close_date")]
        public DateTime? EstimatedCloseDate { get; set; }

        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.Now;

        [Column("updated_at")]
        public DateTime? UpdatedAt { get; set; }
    }
}
