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
        Task<List<ProductDocDto>> GetProductDocsAsync();
        Task<List<ProcessRuleDto>> GetProcessRulesAsync();

        // Stats
        Task<SalesDashboardStatsDto> GetDashboardStatsAsync();
        Task<List<TeamRankingDto>> GetTeamRankingAsync();
    }
}
