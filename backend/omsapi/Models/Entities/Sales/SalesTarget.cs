using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Sales
{
    [Table("sales_target")]
    public class SalesTarget
    {
        [Key]
        [Column("id")]
        public string Id { get; set; } = Guid.NewGuid().ToString("N");

        [Column("period")]
        [MaxLength(50)]
        public string Period { get; set; } = string.Empty; // year, quarter, month

        [Column("target_type")]
        [MaxLength(50)]
        public string TargetType { get; set; } = string.Empty; // group, product, region, industry, total

        [Column("target_id")]
        [MaxLength(100)]
        public string TargetId { get; set; } = string.Empty; // Relation ID or Code

        [Column("target_name")]
        [MaxLength(200)]
        public string TargetName { get; set; } = string.Empty; // Display Name

        [Column("target_amount", TypeName = "decimal(18,2)")]
        public decimal TargetAmount { get; set; }

        [Column("completed_amount", TypeName = "decimal(18,2)")]
        public decimal CompletedAmount { get; set; }

        [Column("status")]
        [MaxLength(50)]
        public string Status { get; set; } = "in_progress"; // draft, in_progress, completed, archived

        [Column("start_date")]
        public DateTime StartDate { get; set; }

        [Column("end_date")]
        public DateTime EndDate { get; set; }

        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.Now;

        [Column("updated_at")]
        public DateTime? UpdatedAt { get; set; }
    }
}
