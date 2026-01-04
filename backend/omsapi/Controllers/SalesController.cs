using Microsoft.AspNetCore.Mvc;
using omsapi.Models.Common;
using omsapi.Models.Dtos.Sales;
using omsapi.Services.Interfaces;

namespace omsapi.Controllers
{
    /// <summary>
    /// 销售管理控制器
    /// </summary>
    [ApiController]
    [Route("api/sales")]
    public class SalesController : ControllerBase
    {
        private readonly ISalesService _salesService;

        public SalesController(ISalesService salesService)
        {
            _salesService = salesService;
        }

        // --- Customers ---

        /// <summary>
        /// 获取客户列表
        /// </summary>
        [HttpGet("customers")]
        public async Task<ApiResponse<PagedResult<SalesCustomerDto>>> GetCustomers([FromQuery] CustomerSearchParams searchParams)
        {
            var result = await _salesService.GetCustomersAsync(searchParams);
            return ApiResponse<PagedResult<SalesCustomerDto>>.Success(result);
        }

        /// <summary>
        /// 获取客户详情
        /// </summary>
        [HttpGet("customers/{id}")]
        public async Task<ApiResponse<SalesCustomerDto>> GetCustomer(string id)
        {
            var result = await _salesService.GetCustomerAsync(id);
            return result != null 
                ? ApiResponse<SalesCustomerDto>.Success(result) 
                : ApiResponse<SalesCustomerDto>.Error("Customer not found");
        }

        /// <summary>
        /// 创建客户
        /// </summary>
        [HttpPost("customers")]
        public async Task<ApiResponse<SalesCustomerDto>> CreateCustomer([FromBody] CreateCustomerDto dto)
        {
            var result = await _salesService.CreateCustomerAsync(dto);
            return ApiResponse<SalesCustomerDto>.Success(result);
        }

        /// <summary>
        /// 更新客户
        /// </summary>
        [HttpPut("customers/{id}")]
        public async Task<ApiResponse<SalesCustomerDto>> UpdateCustomer(string id, [FromBody] UpdateCustomerDto dto)
        {
            var result = await _salesService.UpdateCustomerAsync(id, dto);
            return result != null
                ? ApiResponse<SalesCustomerDto>.Success(result)
                : ApiResponse<SalesCustomerDto>.Error("Customer not found");
        }

        /// <summary>
        /// 删除客户
        /// </summary>
        [HttpDelete("customers/{id}")]
        public async Task<ApiResponse<bool>> DeleteCustomer(string id)
        {
            var result = await _salesService.DeleteCustomerAsync(id);
            return ApiResponse<bool>.Success(result);
        }

        // --- Opportunities ---

        /// <summary>
        /// 获取商机列表
        /// </summary>
        [HttpGet("opportunities")]
        public async Task<ApiResponse<List<SalesOpportunityDto>>> GetOpportunities([FromQuery] string stage = null)
        {
            var result = await _salesService.GetOpportunitiesAsync(stage);
            return ApiResponse<List<SalesOpportunityDto>>.Success(result);
        }

        /// <summary>
        /// 创建商机
        /// </summary>
        [HttpPost("opportunities")]
        public async Task<ApiResponse<SalesOpportunityDto>> CreateOpportunity([FromBody] CreateOpportunityDto dto)
        {
            var result = await _salesService.CreateOpportunityAsync(dto);
            return ApiResponse<SalesOpportunityDto>.Success(result);
        }

        /// <summary>
        /// 更新商机
        /// </summary>
        [HttpPut("opportunities/{id}")]
        public async Task<ApiResponse<SalesOpportunityDto>> UpdateOpportunity(string id, [FromBody] UpdateOpportunityDto dto)
        {
            var result = await _salesService.UpdateOpportunityAsync(id, dto);
            return result != null
                ? ApiResponse<SalesOpportunityDto>.Success(result)
                : ApiResponse<SalesOpportunityDto>.Error("Opportunity not found");
        }

        /// <summary>
        /// 删除商机
        /// </summary>
        [HttpDelete("opportunities/{id}")]
        public async Task<ApiResponse<bool>> DeleteOpportunity(string id)
        {
            var result = await _salesService.DeleteOpportunityAsync(id);
            return ApiResponse<bool>.Success(result);
        }

        // --- Materials ---

        /// <summary>
        /// 获取话术列表
        /// </summary>
        [HttpGet("materials/scripts")]
        public async Task<ApiResponse<List<SalesScriptDto>>> GetSalesScripts()
        {
            var result = await _salesService.GetSalesScriptsAsync();
            return ApiResponse<List<SalesScriptDto>>.Success(result);
        }

        /// <summary>
        /// 获取产品资料列表
        /// </summary>
        [HttpGet("materials/docs")]
        public async Task<ApiResponse<List<ProductDocDto>>> GetProductDocs()
        {
            var result = await _salesService.GetProductDocsAsync();
            return ApiResponse<List<ProductDocDto>>.Success(result);
        }

        /// <summary>
        /// 获取流程规则列表
        /// </summary>
        [HttpGet("materials/rules")]
        public async Task<ApiResponse<List<ProcessRuleDto>>> GetProcessRules()
        {
            var result = await _salesService.GetProcessRulesAsync();
            return ApiResponse<List<ProcessRuleDto>>.Success(result);
        }

        // --- Stats ---

        /// <summary>
        /// 获取仪表盘统计数据
        /// </summary>
        [HttpGet("stats/dashboard")]
        public async Task<ApiResponse<SalesDashboardStatsDto>> GetDashboardStats()
        {
            var result = await _salesService.GetDashboardStatsAsync();
            return ApiResponse<SalesDashboardStatsDto>.Success(result);
        }

        /// <summary>
        /// 获取团队排名
        /// </summary>
        [HttpGet("stats/ranking")]
        public async Task<ApiResponse<List<TeamRankingDto>>> GetTeamRanking()
        {
            var result = await _salesService.GetTeamRankingAsync();
            return ApiResponse<List<TeamRankingDto>>.Success(result);
        }
    }
}
