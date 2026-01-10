using omsapi.Models.Entities.Sales;

namespace omsapi.Models.Dtos.Sales
{
    public class SalesTenderAnalysisDto
    {
        public long Id { get; set; }
        public string BidProjectId { get; set; } = string.Empty;
        public string TenderType { get; set; } = string.Empty;
        public string? FileName { get; set; }
        public string? FileUrl { get; set; }
        public DateTime? Deadline { get; set; }
        public string? BidBond { get; set; }
        public string? Budget { get; set; }
        public DateTime? BidStartTime { get; set; }
        public DateTime? BidEndTime { get; set; }
        public DateTime? TenderStartTime { get; set; }
        public DateTime? OpenBidTime { get; set; }
        public DateTime? PublishTime { get; set; }
        public string? ContactName { get; set; }
        public string? ContactPhone { get; set; }
        public string? AgencyName { get; set; }
        public string? Qualification { get; set; }
        public DateTime CreatedAt { get; set; }
        public List<SalesTenderChapterDto> Chapters { get; set; } = new List<SalesTenderChapterDto>();
    }

    public class SalesTenderChapterDto
    {
        public long Id { get; set; }
        public string Key { get; set; } = string.Empty; // For frontend tree key
        public string Title { get; set; } = string.Empty;
        public string? Type { get; set; } // Mapped from ChapterType
        public string? Content { get; set; }
        public string? Analysis { get; set; } // Mapped from AnalysisResult
        public string? RiskLevel { get; set; }
        public bool IsVeto { get; set; }
        public decimal? ScoreWeight { get; set; }
        public List<SalesTenderExtractionDto> Extraction { get; set; } = new List<SalesTenderExtractionDto>();
        public List<SalesTenderChapterDto> Children { get; set; } = new List<SalesTenderChapterDto>();
    }

    public class SalesTenderExtractionDto
    {
        public string Label { get; set; } = string.Empty;
        public string Value { get; set; } = string.Empty;
        public bool FullWidth { get; set; }
    }

    public class CreateSalesTenderAnalysisDto
    {
        public string BidProjectId { get; set; } = string.Empty;
        public string TenderType { get; set; } = string.Empty;
        public string? FileName { get; set; }
        public string? FileUrl { get; set; }
        public DateTime? Deadline { get; set; }
        public string? BidBond { get; set; }
        public string? Budget { get; set; }
        public DateTime? BidStartTime { get; set; }
        public DateTime? BidEndTime { get; set; }
        public DateTime? TenderStartTime { get; set; }
        public DateTime? OpenBidTime { get; set; }
        public DateTime? PublishTime { get; set; }
        public string? ContactName { get; set; }
        public string? ContactPhone { get; set; }
        public string? AgencyName { get; set; }
        public string? Qualification { get; set; }
        public List<CreateSalesTenderChapterDto> Chapters { get; set; } = new List<CreateSalesTenderChapterDto>();
    }

    public class CreateSalesTenderChapterDto
    {
        public string Title { get; set; } = string.Empty;
        public string? Type { get; set; }
        public string? Content { get; set; }
        public string? Analysis { get; set; }
        public string? RiskLevel { get; set; }
        public bool IsVeto { get; set; }
        public decimal? ScoreWeight { get; set; }
        public List<SalesTenderExtractionDto> Extraction { get; set; } = new List<SalesTenderExtractionDto>();
        public List<CreateSalesTenderChapterDto> Children { get; set; } = new List<CreateSalesTenderChapterDto>();
    }

    public class SalesTenderAnalysisStatusDto
    {
        public bool IsAnalyzing { get; set; }
        public string Status { get; set; } = string.Empty;
        public long? RunId { get; set; }
        public DateTime? StartedAt { get; set; }
        public DateTime? FinishedAt { get; set; }
    }

    public class SalesTenderAnalysisLogDto
    {
        public long Id { get; set; }
        public long RunId { get; set; }
        public string Message { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
    }

    public class AiTenderChapterDto
    {
        public string Title { get; set; } = string.Empty;
        public string? Type { get; set; }
        public string? Analysis { get; set; }
        public string? RiskLevel { get; set; }
        public bool IsVeto { get; set; }
        public string? Content { get; set; }
        public List<SalesTenderExtractionDto> Extraction { get; set; } = new List<SalesTenderExtractionDto>();
        public List<AiTenderChapterDto> Children { get; set; } = new List<AiTenderChapterDto>();
    }

    public class AiTenderAnalysisResultDto
    {
        public string? Deadline { get; set; }
        public string? BidBond { get; set; }
        public string? Budget { get; set; }
        public string? Qualification { get; set; }
        public string? BidStartTime { get; set; }
        public string? BidEndTime { get; set; }
        public string? TenderStartTime { get; set; }
        public string? OpenBidTime { get; set; }
        public string? PublishTime { get; set; }
        public string? ContactName { get; set; }
        public string? ContactPhone { get; set; }
        public string? AgencyName { get; set; }
        public string? ProjectCode { get; set; }
        public string? ProjectName { get; set; }
        public string? CustomerName { get; set; }
        public string? Region { get; set; }
        public string? ProjectType { get; set; }
        public string? ProjectLeader { get; set; }
        public string? ProjectBackground { get; set; }
        public List<AiTenderChapterDto> Chapters { get; set; } = new List<AiTenderChapterDto>();
    }
}
