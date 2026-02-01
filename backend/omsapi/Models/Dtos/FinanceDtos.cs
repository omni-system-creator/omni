using System.ComponentModel.DataAnnotations;

namespace omsapi.Models.Dtos
{
    public class FinanceSubjectDto
    {
        public long Id { get; set; }
        public string Code { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public long? ParentId { get; set; }
        public string Direction { get; set; } = string.Empty;
        public string? Description { get; set; }
        public bool IsSystem { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    public class CreateFinanceSubjectDto
    {
        [Required]
        [MaxLength(50)]
        public string Code { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;
        
        public long? ParentId { get; set; }

        [Required]
        [MaxLength(20)]
        public string Direction { get; set; } = "income"; // income, expense

        [MaxLength(200)]
        public string? Description { get; set; }
    }

    public class FinanceApArDto
    {
        public long Id { get; set; }
        public string BillNo { get; set; } = string.Empty;
        public string Type { get; set; } = string.Empty;
        public long? SubjectId { get; set; }
        public string? SubjectName { get; set; }
        public decimal Amount { get; set; }
        public DateTime? DueDate { get; set; }
        public string PartnerName { get; set; } = string.Empty;
        public string? PartnerId { get; set; }
        public int Status { get; set; }
        public string SourceType { get; set; } = string.Empty;
        public long? SourceId { get; set; }
        public string? Description { get; set; }
        public DateTime CreatedAt { get; set; }
        public string? CreatedBy { get; set; }
        
        // Calculated fields
        public int OverdueDays { get; set; }

        public List<FinanceAttachmentDto> Attachments { get; set; } = new();
    }

    public class FinanceAttachmentDto
    {
        public long Id { get; set; }
        public string TargetType { get; set; } = string.Empty;
        public long TargetId { get; set; }
        public string FileName { get; set; } = string.Empty;
        public string? FilePath { get; set; }
        public string? Size { get; set; }
        public string? ContentType { get; set; }
        public DateTime UploadDate { get; set; }
        public string? Uploader { get; set; }
    }

    public class CreateFinanceApArDto
    {
        [Required]
        [MaxLength(10)]
        public string Type { get; set; } = "AR";

        public long? SubjectId { get; set; }

        [Required]
        public decimal Amount { get; set; }

        [Required]
        public DateTime DueDate { get; set; }

        [Required]
        [MaxLength(200)]
        public string PartnerName { get; set; } = string.Empty;

        [MaxLength(50)]
        public string? PartnerId { get; set; }

        [MaxLength(500)]
        public string? Description { get; set; }
    }

    public class UpdateFinanceApArDto
    {
        public long? SubjectId { get; set; }
        public decimal? Amount { get; set; }
        public DateTime? DueDate { get; set; }
        public string? PartnerName { get; set; }
        public string? PartnerId { get; set; }
        public int? Status { get; set; }
        public string? Description { get; set; }
    }

    public class UpdateFinanceSubjectDto
    {
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        public long? ParentId { get; set; }

        [Required]
        [MaxLength(20)]
        public string Direction { get; set; } = "income";

        [MaxLength(200)]
        public string? Description { get; set; }
        
        public bool IsActive { get; set; }
    }

    public class FinanceStatsDto
    {
        public decimal TotalReceivables { get; set; }
        public decimal TotalPayables { get; set; }
        public decimal OverdueReceivables { get; set; }
        public decimal OverduePayables { get; set; }
    }
}
