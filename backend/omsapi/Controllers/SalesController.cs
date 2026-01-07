using Microsoft.AspNetCore.Mvc;
using omsapi.Models.Common;
using omsapi.Models.Dtos.Sales;
using omsapi.Services.Interfaces;
using System.Text.Json;

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
        /// 创建话术
        /// </summary>
        [HttpPost("materials/scripts")]
        public async Task<ApiResponse<SalesScriptDto>> CreateSalesScript([FromBody] CreateSalesScriptDto dto)
        {
            var result = await _salesService.CreateSalesScriptAsync(dto);
            return ApiResponse<SalesScriptDto>.Success(result);
        }

        /// <summary>
        /// 更新话术
        /// </summary>
        [HttpPut("materials/scripts/{id}")]
        public async Task<ApiResponse<SalesScriptDto>> UpdateSalesScript(string id, [FromBody] UpdateSalesScriptDto dto)
        {
            var result = await _salesService.UpdateSalesScriptAsync(id, dto);
            return result != null
                ? ApiResponse<SalesScriptDto>.Success(result)
                : ApiResponse<SalesScriptDto>.Error("Sales script not found");
        }

        /// <summary>
        /// 生成话术字段内容
        /// </summary>
        [HttpPost("materials/scripts/generate")]
        public async Task<ApiResponse<string>> GenerateScriptField([FromBody] GenerateScriptFieldRequest request)
        {
            var result = await _salesService.GenerateScriptFieldAsync(request);
            return ApiResponse<string>.Success(result);
        }

        /// <summary>
        /// 生成话术字段内容(流式)
        /// </summary>
        [HttpPost("materials/scripts/generate/stream")]
        public async Task GenerateScriptFieldStream([FromBody] GenerateScriptFieldRequest request)
        {
            Response.Headers.Append("Content-Type", "text/event-stream");
            Response.Headers.Append("Cache-Control", "no-cache");
            Response.Headers.Append("Connection", "keep-alive");

            await foreach (var chunk in _salesService.GenerateScriptFieldStreamAsync(request))
            {
                var data = JsonSerializer.Serialize(new { content = chunk });
                await Response.WriteAsync($"data: {data}\n\n");
                await Response.Body.FlushAsync();
            }
            await Response.WriteAsync("data: [DONE]\n\n");
            await Response.Body.FlushAsync();
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
        /// 创建产品资料/文件夹
        /// </summary>
        [HttpPost("materials/docs")]
        public async Task<ApiResponse<ProductDocDto>> CreateProductDoc([FromBody] CreateProductDocDto dto)
        {
            var result = await _salesService.CreateProductDocAsync(dto);
            return ApiResponse<ProductDocDto>.Success(result);
        }

        [HttpPost("materials/docs/upload")]
        public async Task<ApiResponse<ProductDocDto>> UploadProductDoc(IFormFile file, [FromForm] string? parentId)
        {
            var result = await _salesService.UploadProductDocAsync(file, parentId);
            return ApiResponse<ProductDocDto>.Success(result);
        }

        [HttpDelete("materials/docs/{id}")]
        public async Task<ApiResponse<bool>> DeleteProductDoc(string id)
        {
            var result = await _salesService.DeleteProductDocAsync(id);
            return ApiResponse<bool>.Success(result);
        }

        [HttpPut("materials/docs/{id}/rename")]
        public async Task<ApiResponse<bool>> RenameProductDoc(string id, [FromQuery] string newName)
        {
            var result = await _salesService.RenameProductDocAsync(id, newName);
            return ApiResponse<bool>.Success(result);
        }

        [HttpPut("materials/docs/{id}/move")]
        public async Task<ApiResponse<bool>> MoveProductDoc(string id, [FromQuery] string? newParentId)
        {
            var result = await _salesService.MoveProductDocAsync(id, newParentId);
            return ApiResponse<bool>.Success(result);
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

        /// <summary>
        /// 销售话术AI对话
        /// </summary>
        [HttpPost("scripts/chat")]
        public async Task<ApiResponse<SalesScriptChatResponseDto>> SalesScriptChat([FromBody] SalesScriptChatDto dto)
        {
            var result = await _salesService.SalesScriptChatAsync(dto);
            return ApiResponse<SalesScriptChatResponseDto>.Success(result);
        }

        /// <summary>
        /// 销售话术AI对话（流式）
        /// </summary>
        [HttpPost("scripts/chat/stream")]
        public async Task SalesScriptChatStream([FromBody] SalesScriptChatDto dto)
        {
            Response.Headers.Append("Content-Type", "text/event-stream");
            Response.Headers.Append("Cache-Control", "no-cache");
            Response.Headers.Append("Connection", "keep-alive");

            await foreach (var item in _salesService.SalesScriptChatStreamAsync(dto))
            {
                var json = System.Text.Json.JsonSerializer.Serialize(item);
                var data = $"data: {json}\n\n";
                await Response.WriteAsync(data);
                await Response.Body.FlushAsync();
            }
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

        /// <summary>
        /// 获取销售目标
        /// </summary>
        [HttpGet("targets")]
        public async Task<ApiResponse<SalesTargetResultDto>> GetSalesTargets([FromQuery] SalesTargetSearchParams searchParams)
        {
            var result = await _salesService.GetSalesTargetsAsync(searchParams);
            return ApiResponse<SalesTargetResultDto>.Success(result);
        }

        // --- Registrations (报备) ---

        /// <summary>
        /// 获取报备列表
        /// </summary>
        [HttpGet("registrations")]
        public async Task<ApiResponse<PagedResult<SalesRegistrationDto>>> GetRegistrations([FromQuery] RegistrationSearchParams searchParams)
        {
            var result = await _salesService.GetRegistrationsAsync(searchParams);
            return ApiResponse<PagedResult<SalesRegistrationDto>>.Success(result);
        }

        /// <summary>
        /// 获取报备详情
        /// </summary>
        [HttpGet("registrations/{id}")]
        public async Task<ApiResponse<SalesRegistrationDto>> GetRegistration(string id)
        {
            var result = await _salesService.GetRegistrationAsync(id);
            return result != null
                ? ApiResponse<SalesRegistrationDto>.Success(result)
                : ApiResponse<SalesRegistrationDto>.Error("Registration not found");
        }

        /// <summary>
        /// 创建报备
        /// </summary>
        [HttpPost("registrations")]
        public async Task<ApiResponse<SalesRegistrationDto>> CreateRegistration([FromBody] CreateRegistrationDto dto)
        {
            var result = await _salesService.CreateRegistrationAsync(dto);
            return ApiResponse<SalesRegistrationDto>.Success(result);
        }

        /// <summary>
        /// 更新报备
        /// </summary>
        [HttpPut("registrations/{id}")]
        public async Task<ApiResponse<SalesRegistrationDto>> UpdateRegistration(string id, [FromBody] UpdateRegistrationDto dto)
        {
            var result = await _salesService.UpdateRegistrationAsync(id, dto);
            return result != null
                ? ApiResponse<SalesRegistrationDto>.Success(result)
                : ApiResponse<SalesRegistrationDto>.Error("Registration not found");
        }

        /// <summary>
        /// 删除报备
        /// </summary>
        [HttpDelete("registrations/{id}")]
        public async Task<ApiResponse<bool>> DeleteRegistration(string id)
        {
            var result = await _salesService.DeleteRegistrationAsync(id);
            return ApiResponse<bool>.Success(result);
        }

        /// <summary>
        /// 生成报备数据
        /// </summary>
        [HttpPost("registrations/generate")]
        public async Task<ApiResponse<CreateRegistrationDto>> GenerateRegistrationData()
        {
            var result = await _salesService.GenerateRegistrationDataAsync();
            return ApiResponse<CreateRegistrationDto>.Success(result);
        }
    }
}
