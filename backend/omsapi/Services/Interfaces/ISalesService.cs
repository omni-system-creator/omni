using omsapi.Models.Dtos.Sales;
using omsapi.Models.Common;

namespace omsapi.Services.Interfaces
{
    public interface ISalesService
    {
        // Customer
        Task<PagedResult<SalesCustomerDto>> GetCustomersAsync(CustomerSearchParams searchParams);
        Task<SalesCustomerDto?> GetCustomerAsync(string id);
        Task<SalesCustomerDto?> CreateCustomerAsync(CreateCustomerDto dto);
        Task<SalesCustomerDto?> UpdateCustomerAsync(string id, UpdateCustomerDto dto);
        Task<bool> DeleteCustomerAsync(string id);

        // Opportunity
        Task<List<SalesOpportunityDto>> GetOpportunitiesAsync(string? stage = null);
        Task<SalesOpportunityDto> CreateOpportunityAsync(CreateOpportunityDto dto);
        Task<SalesOpportunityDto?> UpdateOpportunityAsync(string id, UpdateOpportunityDto dto);
        Task<bool> DeleteOpportunityAsync(string id);

        // Materials
        Task<List<SalesScriptDto>> GetSalesScriptsAsync();
        Task<SalesScriptDto> CreateSalesScriptAsync(CreateSalesScriptDto dto);
        Task<SalesScriptDto?> UpdateSalesScriptAsync(string id, UpdateSalesScriptDto dto);
        Task<string> GenerateScriptFieldAsync(GenerateScriptFieldRequest request);
        IAsyncEnumerable<string> GenerateScriptFieldStreamAsync(GenerateScriptFieldRequest request);
        Task<List<ProductDocDto>> GetProductDocsAsync();
        Task<ProductDocDto> CreateProductDocAsync(CreateProductDocDto dto);
        Task<ProductDocDto> UploadProductDocAsync(IFormFile file, string? parentId);
        Task<bool> DeleteProductDocAsync(string id);
        Task<bool> RenameProductDocAsync(string id, string newName);
        Task<bool> MoveProductDocAsync(string id, string? newParentId);
        Task<List<ProcessRuleDto>> GetProcessRulesAsync();
        Task<SalesScriptChatResponseDto> SalesScriptChatAsync(SalesScriptChatDto dto);
        IAsyncEnumerable<SalesScriptChatResponseDto> SalesScriptChatStreamAsync(SalesScriptChatDto dto);

        // Stats
        Task<SalesDashboardStatsDto> GetDashboardStatsAsync();
        Task<List<TeamRankingDto>> GetTeamRankingAsync();

        // Targets
        Task<SalesTargetResultDto> GetSalesTargetsAsync(SalesTargetSearchParams searchParams);
    }
}
