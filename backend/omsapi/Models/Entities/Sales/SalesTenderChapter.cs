using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Sales
{
    [Table("sales_bid_chapter")]
    public class SalesTenderChapter
    {
        [Key]
        [Column("id")]
        public long Id { get; set; }

        [Column("analysis_id")]
        public long AnalysisId { get; set; }

        [Column("parent_id")]
        public long? ParentId { get; set; }

        [Column("title")]
        public string Title { get; set; } = string.Empty;

        [Column("chapter_type")]
        public string? ChapterType { get; set; }

        [Column("content")]
        public string? Content { get; set; }

        [Column("analysis_result")]
        public string? AnalysisResult { get; set; }

        [Column("risk_level")]
        public string? RiskLevel { get; set; } // low, medium, high

        [Column("is_veto")]
        public bool IsVeto { get; set; }

        [Column("score_weight")]
        public decimal? ScoreWeight { get; set; }

        [Column("sort_order")]
        public int SortOrder { get; set; }

        // JSON string for extraction data: [{ "label": "...", "value": "...", "fullWidth": true }]
        [Column("extractions_json")]
        public string? ExtractionsJson { get; set; }

        [ForeignKey("AnalysisId")]
        public virtual SalesTenderAnalysis? Analysis { get; set; }

        [ForeignKey("ParentId")]
        public virtual SalesTenderChapter? Parent { get; set; }
        
        public virtual ICollection<SalesTenderChapter> Children { get; set; } = new List<SalesTenderChapter>();
    }
}
