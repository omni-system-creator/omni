using omsapi.Models.Dtos.Contract;
using Microsoft.AspNetCore.Http;

namespace omsapi.Services.Interfaces
{
    public interface IContractService
    {
        // Contracts
        Task<IEnumerable<ContractDto>> GetContractsAsync(string? type = null, string? keyword = null, string? expiryStatus = null);
        Task<IEnumerable<ContractCustomerSelectDto>> GetCustomersAsync(string? keyword = null);
        Task<ContractDetailDto?> GetContractByIdAsync(long id);
        Task<ContractDto> CreateContractAsync(CreateContractDto dto);
        Task<ContractDto?> UpdateContractAsync(long id, UpdateContractDto dto);
        Task<bool> DeleteContractAsync(long id);

        // Payments
        Task<ContractPaymentPlanDto> CreatePaymentPlanAsync(CreateContractPaymentPlanDto dto);
        Task<ContractPaymentPlanDto?> UpdatePaymentPlanAsync(long id, UpdateContractPaymentPlanDto dto);
        Task<bool> DeletePaymentPlanAsync(long id);
        Task<ContractPaymentRecordDto> CreatePaymentRecordAsync(CreateContractPaymentRecordDto dto);
        Task<ContractPaymentRecordDto?> UpdatePaymentRecordAsync(long id, UpdateContractPaymentRecordDto dto);
        Task<bool> DeletePaymentRecordAsync(long id);

        // Templates
        Task<IEnumerable<ContractTemplateDto>> GetTemplatesAsync(string? type = null);
        Task<ContractTemplateDto> CreateTemplateAsync(CreateContractTemplateDto dto);
        Task<ContractTemplateDto?> UpdateTemplateAsync(long id, UpdateContractTemplateDto dto);
        Task<bool> DeleteTemplateAsync(long id);
        Task<ContractTemplateDto?> UploadTemplateFileAsync(long id, IFormFile file);
        Task<ContractTemplateDto?> DeleteTemplateFileAsync(long id);

        // Stats
        Task<ContractStatDto?> GetCurrentStatsAsync(string periodType);
        Task<IEnumerable<ContractStatDto>> GetTrendStatsAsync(string periodType, int count = 12);
        
        // Knowledge
        Task<IEnumerable<ContractKnowledgeCategoryDto>> GetKnowledgeTreeAsync();
        Task<ContractKnowledgeCategoryDto> CreateKnowledgeCategoryAsync(CreateContractKnowledgeCategoryDto dto);
        Task<ContractKnowledgeCategoryDto?> UpdateKnowledgeCategoryAsync(long id, UpdateContractKnowledgeCategoryDto dto);
        Task<bool> DeleteKnowledgeCategoryAsync(long id);
        Task<IEnumerable<ContractKnowledgeFileDto>> GetKnowledgeFilesAsync(long categoryId, string? keyword = null);
        Task<ContractKnowledgeFileDto> UploadKnowledgeFileAsync(IFormFile file, long categoryId, string uploader);
        Task<ContractKnowledgeFileDto?> GetKnowledgeFileByIdAsync(long id);
        Task<ContractKnowledgeFileDto?> UpdateKnowledgeFileAsync(long id, UpdateContractKnowledgeFileDto dto);
        Task<bool> DeleteKnowledgeFileAsync(long id);

        // Payment Record Vouchers
        Task<ContractPaymentRecordDto?> UploadPaymentRecordVoucherAsync(long id, IFormFile file);

        // Invoices
        Task<ContractInvoiceDto> CreateInvoiceAsync(CreateContractInvoiceDto dto);
        Task<ContractInvoiceDto?> UpdateInvoiceAsync(long id, UpdateContractInvoiceDto dto);
        Task<bool> DeleteInvoiceAsync(long id);
        Task<ContractInvoiceDto?> UploadInvoiceAttachmentAsync(long id, IFormFile file);

        // Related Contracts
        Task<IEnumerable<RelatedContractDto>> GetRelatedContractsAsync(long contractId);
        Task<IEnumerable<RelatedContractDto>> SetRelatedContractsAsync(long contractId, SetRelatedContractsDto dto);

        // Attachments
        Task<ContractAttachmentDto?> UploadContractAttachmentAsync(long contractId, IFormFile file);
        Task<bool> DeleteContractAttachmentAsync(long id);

        // Invoice Recognition
        Task<ContractInvoiceDto?> RecognizeInvoiceAsync(IFormFile file);
    }
}
