using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Sales
{
    [Table("sales_bid_analysis_log")]
    public class SalesTenderAnalysisLog
    {
        [Key]
        [Column("id")]
        public long Id { get; set; }

        [Column("run_id")]
        public long RunId { get; set; }

        [Column("bid_project_id")]
        public string BidProjectId { get; set; } = string.Empty;

        [Column("message")]
        public string Message { get; set; } = string.Empty;

        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
}

