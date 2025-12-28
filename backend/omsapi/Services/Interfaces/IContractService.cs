using omsapi.Models.Dtos.Contract;
using Microsoft.AspNetCore.Http;

namespace omsapi.Services.Interfaces
{
    public interface IContractService
    {
        // Contracts
        Task<IEnumerable<ContractDto>> GetContractsAsync(string? type = null, string? keyword = null);
        Task<ContractDetailDto?> GetContractByIdAsync(long id);
        Task<ContractDto> CreateContractAsync(CreateContractDto dto);
        Task<ContractDto?> UpdateContractAsync(long id, UpdateContractDto dto);
        Task<bool> DeleteContractAsync(long id);

        // Templates
        Task<IEnumerable<ContractTemplateDto>> GetTemplatesAsync(string? type = null);
        Task<ContractTemplateDto> CreateTemplateAsync(CreateContractTemplateDto dto);
        Task<ContractTemplateDto?> UpdateTemplateAsync(long id, UpdateContractTemplateDto dto);
        Task<bool> DeleteTemplateAsync(long id);

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
    }
}
