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
        public long? PartnerId { get; set; }
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
        public string LifecycleStatus { get; set; } = "draft";
        public string PricingType { get; set; } = "fixed";
        public string? Description { get; set; }
        public DateTime? LatestTransactionDate { get; set; }
        public string? Files { get; set; } // JSON string
        public string? OrgName { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }

    public class ContractQueryDto
    {
        public string? Keyword { get; set; }
        public string? Type { get; set; }
        public string? ExpiryStatus { get; set; }
        
        public string? ContractNo { get; set; }
        public string? PartnerName { get; set; }
        public string? Manager { get; set; }
        public string? PricingType { get; set; }
        public string? LifecycleStatus { get; set; }
        public string? PerformanceStatus { get; set; }
        public string? PaymentMethod { get; set; }

        public decimal? TotalAmountMin { get; set; }
        public decimal? TotalAmountMax { get; set; }

        public DateTime? SignDateStart { get; set; }
        public DateTime? SignDateEnd { get; set; }
        
        public DateTime? StartDateStart { get; set; }
        public DateTime? StartDateEnd { get; set; }

        public DateTime? EndDateStart { get; set; }
        public DateTime? EndDateEnd { get; set; }
    }

    public class ContractDetailDto : ContractDto
    {
        public List<ContractPaymentPlanDto> PaymentPlans { get; set; } = new();
        public List<ContractPaymentRecordDto> PaymentRecords { get; set; } = new();
        public List<ContractInvoiceDto> Invoices { get; set; } = new();
        public List<ContractContactDto> Contacts { get; set; } = new();
        public List<ContractAttachmentDto> Attachments { get; set; } = new();
        public List<RelatedContractDto> RelatedContracts { get; set; } = new();
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
        public string? Type { get; set; }
        public string? Method { get; set; }
        public string? Operator { get; set; }
        public string? Remark { get; set; }
        public string? VoucherFilePath { get; set; }
        public string? VoucherFileName { get; set; }
    }

    public class CreateContractPaymentPlanDto
    {
        [Required]
        public long ContractId { get; set; }

        [Required]
        [MaxLength(50)]
        public string Phase { get; set; } = string.Empty;

        public DateTime? DueDate { get; set; }

        [Required]
        public decimal Amount { get; set; }

        [MaxLength(200)]
        public string? Condition { get; set; }

        [MaxLength(20)]
        public string Status { get; set; } = "pending";
    }

    public class UpdateContractPaymentPlanDto : CreateContractPaymentPlanDto
    {
    }

    public class CreateContractPaymentRecordDto
    {
        [Required]
        public long ContractId { get; set; }

        [Required]
        public DateTime PaymentDate { get; set; }

        [Required]
        public decimal Amount { get; set; }

        [MaxLength(20)]
        public string? Type { get; set; }

        [MaxLength(50)]
        public string? Method { get; set; }

        [MaxLength(50)]
        public string? Operator { get; set; }

        public string? Remark { get; set; }
    }

    public class UpdateContractPaymentRecordDto : CreateContractPaymentRecordDto
    {
    }

    public class ContractInvoiceDto
    {
        public long Id { get; set; }
        public string InvoiceNo { get; set; } = string.Empty;
        public DateTime InvoiceDate { get; set; }
        public decimal Amount { get; set; }
        public string Direction { get; set; } = "output";
        public string? Type { get; set; }
        public string Status { get; set; } = "issued";
        public string? AttachmentFilePath { get; set; }
        public string? AttachmentFileName { get; set; }
        public string? Content { get; set; }
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

    public class RelatedContractDto
    {
        public long Id { get; set; }
        public string ContractNo { get; set; } = string.Empty;
        public string ContractName { get; set; } = string.Empty;
        public string Type { get; set; } = string.Empty;
        public string? Manager { get; set; }
        public decimal TotalAmount { get; set; }
        public string Currency { get; set; } = "CNY";
        public string Status { get; set; } = "executing";
        public DateTime? SignDate { get; set; }
    }

    public class CreateContractInvoiceDto
    {
        [Required]
        public long ContractId { get; set; }

        [Required]
        [MaxLength(50)]
        public string InvoiceNo { get; set; } = string.Empty;

        [Required]
        public DateTime InvoiceDate { get; set; }

        [Required]
        public decimal Amount { get; set; }

        [MaxLength(20)]
        public string Direction { get; set; } = "output";

        [MaxLength(50)]
        public string? Type { get; set; }

        [MaxLength(20)]
        public string Status { get; set; } = "issued";

        public string? Content { get; set; }
    }

    public class UpdateContractInvoiceDto : CreateContractInvoiceDto
    {
    }

    public class ContractCustomerSelectDto
    {
        public string Id { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public string Industry { get; set; } = string.Empty;
        public string Contact { get; set; } = string.Empty;
        public string Phone { get; set; } = string.Empty;
        public string Level { get; set; } = string.Empty;
    }

    public class ExportContractsDto
    {
        public string? Type { get; set; }
        public string? Keyword { get; set; }
        public string? ExpiryStatus { get; set; }

        public string? ContractNo { get; set; }
        public string? PartnerName { get; set; }
        public string? Manager { get; set; }
        public string? PricingType { get; set; }
        public string? LifecycleStatus { get; set; }
        public string? PerformanceStatus { get; set; }
        public string? PaymentMethod { get; set; }

        public decimal? TotalAmountMin { get; set; }
        public decimal? TotalAmountMax { get; set; }

        public DateTime? SignDateStart { get; set; }
        public DateTime? SignDateEnd { get; set; }
        
        public DateTime? StartDateStart { get; set; }
        public DateTime? StartDateEnd { get; set; }

        public DateTime? EndDateStart { get; set; }
        public DateTime? EndDateEnd { get; set; }

        public List<ExportColumnDto> Columns { get; set; } = new();
    }

    public class ExportColumnDto
    {
        public string Title { get; set; } = string.Empty;
        public string DataIndex { get; set; } = string.Empty;
    }

    public class CreateContractDto
    {
        [MaxLength(50)]
        public string? ContractNo { get; set; }

        [Required]
        [MaxLength(200)]
        public string ContractName { get; set; } = string.Empty;

        [Required]
        [MaxLength(20)]
        public string Type { get; set; } = string.Empty;

        [MaxLength(100)]
        public string PartnerName { get; set; } = string.Empty;

        public long? PartnerId { get; set; }

        public DateTime? SignDate { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }

        [MaxLength(50)]
        public string? Manager { get; set; }

        public decimal TotalAmount { get; set; }
        public string Currency { get; set; } = "CNY";
        public string? PaymentMethod { get; set; }
        public string? TaxId { get; set; }
        public string LifecycleStatus { get; set; } = "draft";
        public string PricingType { get; set; } = "fixed";
        public string? Description { get; set; }
    }

    public class UpdateContractDto : CreateContractDto
    {
        public string? Status { get; set; }
        public decimal? PaidAmount { get; set; }
        public decimal? InvoicedAmount { get; set; }
        public int? Progress { get; set; }
    }

    public class SetRelatedContractsDto
    {
        [Required]
        public List<long> RelatedContractIds { get; set; } = new();
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

    public class ContractTemplateFileUploadResultDto
    {
        public string FilePath { get; set; } = string.Empty;
        public string FileName { get; set; } = string.Empty;
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
