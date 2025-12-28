using System.ComponentModel.DataAnnotations;

namespace omsapi.Models.Dtos.Contract
{
    // --- Contract Main DTOs ---

    public class ContractDto
    {
        public long Id { get; set; }
        public string ContractNo { get; set; } = string.Empty;
        public string ContractName { get; set; } = string.Empty;
        public string Type { get; set; } = string.Empty;
        public string PartnerName { get; set; } = string.Empty;
        public DateTime? SignDate { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public string? Manager { get; set; }
        public decimal TotalAmount { get; set; }
        public decimal PaidAmount { get; set; }
        public decimal InvoicedAmount { get; set; }
        public int Progress { get; set; }
        public string Currency { get; set; } = "CNY";
        public string? PaymentMethod { get; set; }
        public string? TaxId { get; set; }
        public string Status { get; set; } = "executing";
        public string? Description { get; set; }
        public DateTime? LatestTransactionDate { get; set; }
        public string? Files { get; set; } // JSON string
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }

    public class ContractDetailDto : ContractDto
    {
        public List<ContractPaymentPlanDto> PaymentPlans { get; set; } = new();
        public List<ContractPaymentRecordDto> PaymentRecords { get; set; } = new();
        public List<ContractInvoiceDto> Invoices { get; set; } = new();
        public List<ContractContactDto> Contacts { get; set; } = new();
        public List<ContractAttachmentDto> Attachments { get; set; } = new();
    }

    public class ContractPaymentPlanDto
    {
        public long Id { get; set; }
        public string Phase { get; set; } = string.Empty;
        public DateTime? DueDate { get; set; }
        public decimal Amount { get; set; }
        public string? Condition { get; set; }
        public string Status { get; set; } = "pending";
    }

    public class ContractPaymentRecordDto
    {
        public long Id { get; set; }
        public DateTime PaymentDate { get; set; }
        public decimal Amount { get; set; }
        public string? Method { get; set; }
        public string? Operator { get; set; }
        public string? Remark { get; set; }
    }

    public class ContractInvoiceDto
    {
        public long Id { get; set; }
        public string InvoiceNo { get; set; } = string.Empty;
        public DateTime InvoiceDate { get; set; }
        public decimal Amount { get; set; }
        public string? Type { get; set; }
        public string Status { get; set; } = "issued";
    }

    public class ContractContactDto
    {
        public long Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Role { get; set; }
        public string? Phone { get; set; }
        public string? Email { get; set; }
    }

    public class ContractAttachmentDto
    {
        public long Id { get; set; }
        public string FileName { get; set; } = string.Empty;
        public string? FilePath { get; set; }
        public string? Size { get; set; }
        public DateTime UploadDate { get; set; }
    }

    public class CreateContractDto
    {
        [Required]
        [MaxLength(200)]
        public string ContractName { get; set; } = string.Empty;

        [Required]
        [MaxLength(20)]
        public string Type { get; set; } = string.Empty;

        [MaxLength(100)]
        public string PartnerName { get; set; } = string.Empty;

        public DateTime? SignDate { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }

        [MaxLength(50)]
        public string? Manager { get; set; }

        public decimal TotalAmount { get; set; }
        public string Currency { get; set; } = "CNY";
        public string? PaymentMethod { get; set; }
        public string? TaxId { get; set; }
        public string? Description { get; set; }
        public string? Files { get; set; }
    }

    public class UpdateContractDto : CreateContractDto
    {
        public string? Status { get; set; }
        public decimal? PaidAmount { get; set; }
        public decimal? InvoicedAmount { get; set; }
        public int? Progress { get; set; }
    }

    // --- Contract Template DTOs ---

    public class ContractTemplateDto
    {
        public long Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Type { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string? FilePath { get; set; }
        public string? FileName { get; set; }
        public string Status { get; set; } = "active";
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }

    public class CreateContractTemplateDto
    {
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        [Required]
        [MaxLength(20)]
        public string Type { get; set; } = string.Empty;

        public string? Description { get; set; }
        public string? FilePath { get; set; }
        public string? FileName { get; set; }
        public string Status { get; set; } = "active";
    }

    public class UpdateContractTemplateDto : CreateContractTemplateDto
    {
    }

    // --- Contract Stats DTOs ---

    public class ContractStatDto
    {
        public long Id { get; set; }
        public string PeriodType { get; set; } = "Month";
        public string PeriodKey { get; set; } = string.Empty;
        public DateTime StatDate { get; set; }
        public int TotalContracts { get; set; }
        public decimal TotalContractsGrowth { get; set; }
        public decimal AmountCompletionRate { get; set; }
        public decimal ReceivedRate { get; set; }
        public decimal TotalAmount { get; set; }
        public decimal ReceivedAmount { get; set; }
        public decimal InvoicedAmount { get; set; }
        public decimal PendingInvoiceAmount { get; set; }
        public int SalesCount { get; set; }
        public int PurchaseCount { get; set; }
    }

    // --- Knowledge DTOs ---
    
    public class ContractKnowledgeCategoryDto
    {
        public long Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public long? ParentId { get; set; }
        public int SortOrder { get; set; }
        public List<ContractKnowledgeCategoryDto> Children { get; set; } = new();
    }

    public class CreateContractKnowledgeCategoryDto
    {
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        public long? ParentId { get; set; }
        public int SortOrder { get; set; }
    }

    public class UpdateContractKnowledgeCategoryDto
    {
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        public long? ParentId { get; set; }

        public int SortOrder { get; set; }
    }

    public class ContractKnowledgeFileDto
    {
        public long Id { get; set; }
        public long CategoryId { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Type { get; set; } = string.Empty;
        public string? ContentType { get; set; }
        public string? FilePath { get; set; }
        public long Size { get; set; }
        public string? Uploader { get; set; }
        public DateTime UploadTime { get; set; }
    }

    public class CreateContractKnowledgeFileDto
    {
        [Required]
        public long CategoryId { get; set; }

        [Required]
        [MaxLength(200)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(20)]
        public string Type { get; set; } = string.Empty;

        public string? FilePath { get; set; }
        public string? Size { get; set; }
        public string? Uploader { get; set; }
    }

    public class UpdateContractKnowledgeFileDto
    {
        [Required]
        [MaxLength(200)]
        public string Name { get; set; } = string.Empty;
    }
}
