using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Sales
{
    [Table("sales_bid_analysis")]
    public class SalesTenderAnalysis
    {
        [Key]
        [Column("id")]
        public long Id { get; set; }

        [Column("bid_project_id")]
        public string BidProjectId { get; set; } = string.Empty;

        [Column("tender_type")]
        public string TenderType { get; set; } = string.Empty; // service, goods, engineering

        [Column("file_name")]
        public string? FileName { get; set; }

        [Column("file_url")]
        public string? FileUrl { get; set; }

        // Core Metrics
        [Column("deadline")]
        public DateTime? Deadline { get; set; }

        [Column("bid_bond")]
        public string? BidBond { get; set; }

        [Column("budget")]
        public string? Budget { get; set; }

        // New Fields
        [Column("bid_start_time")]
        public DateTime? BidStartTime { get; set; }

        [Column("bid_end_time")]
        public DateTime? BidEndTime { get; set; }

        [Column("tender_start_time")]
        public DateTime? TenderStartTime { get; set; }

        [Column("open_bid_time")]
        public DateTime? OpenBidTime { get; set; }

        [Column("publish_time")]
        public DateTime? PublishTime { get; set; }

        [Column("contact_name")]
        public string? ContactName { get; set; }

        [Column("contact_phone")]
        public string? ContactPhone { get; set; }

        [Column("agency_name")]
        public string? AgencyName { get; set; }

        [Column("qualification")]
        public string? Qualification { get; set; }

        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.Now;

        [Column("updated_at")]
        public DateTime UpdatedAt { get; set; } = DateTime.Now;

        // Navigation properties
        public virtual ICollection<SalesTenderChapter> Chapters { get; set; } = new List<SalesTenderChapter>();
    }
}
