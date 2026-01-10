using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Sales
{
    [Table("sales_bid_analysis_run")]
    public class SalesTenderAnalysisRun
    {
        [Key]
        [Column("id")]
        public long Id { get; set; }

        [Column("bid_project_id")]
        public string BidProjectId { get; set; } = string.Empty;

        [Column("status")]
        public string Status { get; set; } = "running";

        [Column("started_at")]
        public DateTime StartedAt { get; set; } = DateTime.Now;

        [Column("finished_at")]
        public DateTime? FinishedAt { get; set; }

        [Column("created_by")]
        public long CreatedBy { get; set; }
    }
}

