using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using omsapi.Models.Common;
using omsapi.Models.Dtos.Contract;
using omsapi.Services.Interfaces;

namespace omsapi.Controllers
{
    /// <summary>
    /// 合同管理控制器
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    // [Authorize] // Enable auth if needed
    public class ContractController : ControllerBase
    {
        private readonly IContractService _contractService;

        public ContractController(IContractService contractService)
        {
            _contractService = contractService;
        }

        // --- Contracts ---

        /// <summary>
        /// 获取合同列表
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<ApiResponse<IEnumerable<ContractDto>>>> GetContracts(
            [FromQuery] string? type,
            [FromQuery] string? keyword,
            [FromQuery] string? expiryStatus)
        {
            var result = await _contractService.GetContractsAsync(type, keyword, expiryStatus);
            return Ok(ApiResponse<IEnumerable<ContractDto>>.Success(result));
        }

        /// <summary>
        /// 获取客户列表（用于下拉选择）
        /// </summary>
        [HttpGet("customers")]
        public async Task<ActionResult<ApiResponse<IEnumerable<ContractCustomerSelectDto>>>> GetCustomers([FromQuery] string? keyword)
        {
            var result = await _contractService.GetCustomersAsync(keyword);
            return Ok(ApiResponse<IEnumerable<ContractCustomerSelectDto>>.Success(result));
        }

        /// <summary>
        /// 获取合同详情
        /// </summary>
        [HttpGet("{id}")]
        public async Task<ActionResult<ApiResponse<ContractDetailDto>>> GetContract(long id)
        {
            var result = await _contractService.GetContractByIdAsync(id);
            if (result == null) return NotFound(ApiResponse<object>.Error("Contract not found"));
            return Ok(ApiResponse<ContractDetailDto>.Success(result));
        }

        /// <summary>
        /// 获取关联合同列表
        /// </summary>
        [HttpGet("{id}/related-contracts")]
        public async Task<ActionResult<ApiResponse<IEnumerable<RelatedContractDto>>>> GetRelatedContracts(long id)
        {
            var result = await _contractService.GetRelatedContractsAsync(id);
            return Ok(ApiResponse<IEnumerable<RelatedContractDto>>.Success(result));
        }

        /// <summary>
        /// 设置关联合同（后端自动互相关联）
        /// </summary>
        [HttpPost("{id}/related-contracts")]
        public async Task<ActionResult<ApiResponse<IEnumerable<RelatedContractDto>>>> SetRelatedContracts(long id, [FromBody] SetRelatedContractsDto dto)
        {
            var result = await _contractService.SetRelatedContractsAsync(id, dto);
            return Ok(ApiResponse<IEnumerable<RelatedContractDto>>.Success(result));
        }

        /// <summary>
        /// 创建合同
        /// </summary>
        [HttpPost]
        public async Task<ActionResult<ApiResponse<ContractDto>>> CreateContract([FromBody] CreateContractDto dto)
        {
            var result = await _contractService.CreateContractAsync(dto);
            return Ok(ApiResponse<ContractDto>.Success(result));
        }

        /// <summary>
        /// 更新合同
        /// </summary>
        [HttpPut("{id}")]
        public async Task<ActionResult<ApiResponse<ContractDto>>> UpdateContract(long id, [FromBody] UpdateContractDto dto)
        {
            var result = await _contractService.UpdateContractAsync(id, dto);
            if (result == null) return NotFound(ApiResponse<object>.Error("Contract not found"));
            return Ok(ApiResponse<ContractDto>.Success(result));
        }

        /// <summary>
        /// 删除合同
        /// </summary>
        [HttpDelete("{id}")]
        public async Task<ActionResult<ApiResponse<object>>> DeleteContract(long id)
        {
            var result = await _contractService.DeleteContractAsync(id);
            if (!result) return NotFound(ApiResponse<object>.Error("Contract not found"));
            return Ok(ApiResponse<object>.Success(null));
        }

        /// <summary>
        /// 创建收付款计划
        /// </summary>
        [HttpPost("{contractId}/payment-plans")]
        public async Task<ActionResult<ApiResponse<ContractPaymentPlanDto>>> CreatePaymentPlan(long contractId, [FromBody] CreateContractPaymentPlanDto dto)
        {
            dto.ContractId = contractId;
            var result = await _contractService.CreatePaymentPlanAsync(dto);
            return Ok(ApiResponse<ContractPaymentPlanDto>.Success(result));
        }

        /// <summary>
        /// 更新收付款计划
        /// </summary>
        [HttpPut("payment-plans/{id}")]
        public async Task<ActionResult<ApiResponse<ContractPaymentPlanDto>>> UpdatePaymentPlan(long id, [FromBody] UpdateContractPaymentPlanDto dto)
        {
            var result = await _contractService.UpdatePaymentPlanAsync(id, dto);
            if (result == null) return NotFound(ApiResponse<object>.Error("Payment plan not found"));
            return Ok(ApiResponse<ContractPaymentPlanDto>.Success(result));
        }

        /// <summary>
        /// 删除收付款计划
        /// </summary>
        [HttpDelete("payment-plans/{id}")]
        public async Task<ActionResult<ApiResponse<object>>> DeletePaymentPlan(long id)
        {
            var result = await _contractService.DeletePaymentPlanAsync(id);
            if (!result) return NotFound(ApiResponse<object>.Error("Payment plan not found"));
            return Ok(ApiResponse<object>.Success(null));
        }

        /// <summary>
        /// 创建收付款记录
        /// </summary>
        [HttpPost("{contractId}/payment-records")]
        public async Task<ActionResult<ApiResponse<ContractPaymentRecordDto>>> CreatePaymentRecord(long contractId, [FromBody] CreateContractPaymentRecordDto dto)
        {
            dto.ContractId = contractId;
            var result = await _contractService.CreatePaymentRecordAsync(dto);
            return Ok(ApiResponse<ContractPaymentRecordDto>.Success(result));
        }

        /// <summary>
        /// 更新收付款记录
        /// </summary>
        [HttpPut("payment-records/{id}")]
        public async Task<ActionResult<ApiResponse<ContractPaymentRecordDto>>> UpdatePaymentRecord(long id, [FromBody] UpdateContractPaymentRecordDto dto)
        {
            var result = await _contractService.UpdatePaymentRecordAsync(id, dto);
            if (result == null) return NotFound(ApiResponse<object>.Error("Payment record not found"));
            return Ok(ApiResponse<ContractPaymentRecordDto>.Success(result));
        }

        /// <summary>
        /// 删除收付款记录
        /// </summary>
        [HttpDelete("payment-records/{id}")]
        public async Task<ActionResult<ApiResponse<object>>> DeletePaymentRecord(long id)
        {
            var result = await _contractService.DeletePaymentRecordAsync(id);
            if (!result) return NotFound(ApiResponse<object>.Error("Payment record not found"));
            return Ok(ApiResponse<object>.Success(null));
        }

        /// <summary>
        /// 上传收付款记录凭证附件
        /// </summary>
        [HttpPost("payment-records/{id}/voucher")]
        public async Task<ActionResult<ApiResponse<ContractPaymentRecordDto>>> UploadPaymentRecordVoucher(long id, IFormFile file)
        {
            var result = await _contractService.UploadPaymentRecordVoucherAsync(id, file);
            if (result == null) return NotFound(ApiResponse<object>.Error("Payment record not found or file invalid"));
            return Ok(ApiResponse<ContractPaymentRecordDto>.Success(result));
        }

        /// <summary>
        /// 创建发票记录
        /// </summary>
        [HttpPost("{contractId}/invoices")]
        public async Task<ActionResult<ApiResponse<ContractInvoiceDto>>> CreateInvoice(long contractId, [FromBody] CreateContractInvoiceDto dto)
        {
            dto.ContractId = contractId;
            var result = await _contractService.CreateInvoiceAsync(dto);
            return Ok(ApiResponse<ContractInvoiceDto>.Success(result));
        }

        /// <summary>
        /// 更新发票记录
        /// </summary>
        [HttpPut("invoices/{id}")]
        public async Task<ActionResult<ApiResponse<ContractInvoiceDto>>> UpdateInvoice(long id, [FromBody] UpdateContractInvoiceDto dto)
        {
            var result = await _contractService.UpdateInvoiceAsync(id, dto);
            if (result == null) return NotFound(ApiResponse<object>.Error("Invoice not found"));
            return Ok(ApiResponse<ContractInvoiceDto>.Success(result));
        }

        /// <summary>
        /// 删除发票记录
        /// </summary>
        [HttpDelete("invoices/{id}")]
        public async Task<ActionResult<ApiResponse<object>>> DeleteInvoice(long id)
        {
            var result = await _contractService.DeleteInvoiceAsync(id);
            if (!result) return NotFound(ApiResponse<object>.Error("Invoice not found"));
            return Ok(ApiResponse<object>.Success(null));
        }

        /// <summary>
        /// 上传发票附件
        /// </summary>
        [HttpPost("invoices/{id}/attachment")]
        public async Task<ActionResult<ApiResponse<ContractInvoiceDto>>> UploadInvoiceAttachment(long id, IFormFile file)
        {
            var result = await _contractService.UploadInvoiceAttachmentAsync(id, file);
            if (result == null) return NotFound(ApiResponse<object>.Error("Invoice not found or file invalid"));
            return Ok(ApiResponse<ContractInvoiceDto>.Success(result));
        }

        /// <summary>
        /// 上传合同附件
        /// </summary>
        [HttpPost("{contractId}/attachments")]
        public async Task<ActionResult<ApiResponse<ContractAttachmentDto>>> UploadContractAttachment(long contractId, IFormFile file)
        {
            var result = await _contractService.UploadContractAttachmentAsync(contractId, file);
            if (result == null) return NotFound(ApiResponse<object>.Error("Contract not found or file invalid"));
            return Ok(ApiResponse<ContractAttachmentDto>.Success(result));
        }

        /// <summary>
        /// 删除合同附件
        /// </summary>
        [HttpDelete("attachments/{id}")]
        public async Task<ActionResult<ApiResponse<object>>> DeleteContractAttachment(long id)
        {
            var result = await _contractService.DeleteContractAttachmentAsync(id);
            if (!result) return NotFound(ApiResponse<object>.Error("Attachment not found"));
            return Ok(ApiResponse<object>.Success(null));
        }

        // --- Templates ---

        /// <summary>
        /// 获取合同模板列表
        /// </summary>
        [HttpGet("templates")]
        public async Task<ActionResult<ApiResponse<IEnumerable<ContractTemplateDto>>>> GetTemplates([FromQuery] string? type)
        {
            var result = await _contractService.GetTemplatesAsync(type);
            return Ok(ApiResponse<IEnumerable<ContractTemplateDto>>.Success(result));
        }

        /// <summary>
        /// 创建合同模板
        /// </summary>
        [HttpPost("templates")]
        public async Task<ActionResult<ApiResponse<ContractTemplateDto>>> CreateTemplate([FromBody] CreateContractTemplateDto dto)
        {
            var result = await _contractService.CreateTemplateAsync(dto);
            return Ok(ApiResponse<ContractTemplateDto>.Success(result));
        }

        /// <summary>
        /// 更新合同模板
        /// </summary>
        [HttpPut("templates/{id}")]
        public async Task<ActionResult<ApiResponse<ContractTemplateDto>>> UpdateTemplate(long id, [FromBody] UpdateContractTemplateDto dto)
        {
            var result = await _contractService.UpdateTemplateAsync(id, dto);
            if (result == null) return NotFound(ApiResponse<object>.Error("Template not found"));
            return Ok(ApiResponse<ContractTemplateDto>.Success(result));
        }

        /// <summary>
        /// 上传合同模板文件
        /// </summary>
        [HttpPost("templates/{id}/file")]
        public async Task<ActionResult<ApiResponse<ContractTemplateDto>>> UploadTemplateFile(long id, IFormFile file)
        {
            var result = await _contractService.UploadTemplateFileAsync(id, file);
            if (result == null) return NotFound(ApiResponse<object>.Error("Template not found or file invalid"));
            return Ok(ApiResponse<ContractTemplateDto>.Success(result));
        }

        /// <summary>
        /// 删除合同模板文件
        /// </summary>
        [HttpDelete("templates/{id}/file")]
        public async Task<ActionResult<ApiResponse<ContractTemplateDto>>> DeleteTemplateFile(long id)
        {
            var result = await _contractService.DeleteTemplateFileAsync(id);
            if (result == null) return NotFound(ApiResponse<object>.Error("Template not found"));
            return Ok(ApiResponse<ContractTemplateDto>.Success(result));
        }

        /// <summary>
        /// 删除合同模板
        /// </summary>
        [HttpDelete("templates/{id}")]
        public async Task<ActionResult<ApiResponse<object>>> DeleteTemplate(long id)
        {
            var result = await _contractService.DeleteTemplateAsync(id);
            if (!result) return NotFound(ApiResponse<object>.Error("Template not found"));
            return Ok(ApiResponse<object>.Success(null));
        }

        // --- Stats ---

        /// <summary>
        /// 获取当前统计数据
        /// </summary>
        [HttpGet("stats/current")]
        public async Task<ActionResult<ApiResponse<ContractStatDto>>> GetCurrentStats([FromQuery] string periodType = "Month")
        {
            var result = await _contractService.GetCurrentStatsAsync(periodType);
            return Ok(ApiResponse<ContractStatDto>.Success(result));
        }

        /// <summary>
        /// 获取趋势统计数据
        /// </summary>
        [HttpGet("stats/trend")]
        public async Task<ActionResult<ApiResponse<IEnumerable<ContractStatDto>>>> GetTrendStats([FromQuery] string periodType = "Year", [FromQuery] int count = 5)
        {
            var result = await _contractService.GetTrendStatsAsync(periodType, count);
            return Ok(ApiResponse<IEnumerable<ContractStatDto>>.Success(result));
        }

        // --- Knowledge ---

        /// <summary>
        /// 获取知识库分类
        /// </summary>
        [HttpGet("knowledge/categories")]
        public async Task<ActionResult<ApiResponse<IEnumerable<ContractKnowledgeCategoryDto>>>> GetKnowledgeCategories()
        {
            var result = await _contractService.GetKnowledgeTreeAsync();
            return Ok(ApiResponse<IEnumerable<ContractKnowledgeCategoryDto>>.Success(result));
        }

        /// <summary>
        /// 创建知识库分类
        /// </summary>
        [HttpPost("knowledge/categories")]
        public async Task<ActionResult<ApiResponse<ContractKnowledgeCategoryDto>>> CreateKnowledgeCategory([FromBody] CreateContractKnowledgeCategoryDto dto)
        {
            var result = await _contractService.CreateKnowledgeCategoryAsync(dto);
            return Ok(ApiResponse<ContractKnowledgeCategoryDto>.Success(result));
        }

        /// <summary>
        /// 更新知识库分类
        /// </summary>
        [HttpPut("knowledge/categories/{id}")]
        public async Task<ActionResult<ApiResponse<ContractKnowledgeCategoryDto>>> UpdateKnowledgeCategory(long id, [FromBody] UpdateContractKnowledgeCategoryDto dto)
        {
            var result = await _contractService.UpdateKnowledgeCategoryAsync(id, dto);
            if (result == null) return NotFound(ApiResponse<object>.Error("Category not found"));
            return Ok(ApiResponse<ContractKnowledgeCategoryDto>.Success(result));
        }

        /// <summary>
        /// 删除知识库分类
        /// </summary>
        [HttpDelete("knowledge/categories/{id}")]
        public async Task<ActionResult<ApiResponse<bool>>> DeleteKnowledgeCategory(long id)
        {
            var result = await _contractService.DeleteKnowledgeCategoryAsync(id);
            if (!result) return NotFound(ApiResponse<object>.Error("Category not found"));
            return Ok(ApiResponse<bool>.Success(true));
        }

        /// <summary>
        /// 获取知识库文件列表
        /// </summary>
        [HttpGet("knowledge/files")]
        public async Task<ActionResult<ApiResponse<IEnumerable<ContractKnowledgeFileDto>>>> GetKnowledgeFiles([FromQuery] long categoryId, [FromQuery] string? keyword)
        {
            var result = await _contractService.GetKnowledgeFilesAsync(categoryId, keyword);
            return Ok(ApiResponse<IEnumerable<ContractKnowledgeFileDto>>.Success(result));
        }

        /// <summary>
        /// 上传知识库文件
        /// </summary>
        [HttpPost("knowledge/files")]
        public async Task<ActionResult<ApiResponse<ContractKnowledgeFileDto>>> UploadKnowledgeFile(IFormFile file, [FromForm] long categoryId)
        {
            var uploader = User.Identity?.Name ?? "Unknown";
            var result = await _contractService.UploadKnowledgeFileAsync(file, categoryId, uploader);
            return Ok(ApiResponse<ContractKnowledgeFileDto>.Success(result));
        }

        /// <summary>
        /// 更新知识库文件
        /// </summary>
        [HttpPut("knowledge/files/{id}")]
        public async Task<ActionResult<ApiResponse<ContractKnowledgeFileDto>>> UpdateKnowledgeFile(long id, [FromBody] UpdateContractKnowledgeFileDto dto)
        {
            var result = await _contractService.UpdateKnowledgeFileAsync(id, dto);
            if (result == null) return NotFound(ApiResponse<object>.Error("File not found"));
            return Ok(ApiResponse<ContractKnowledgeFileDto>.Success(result));
        }

        /// <summary>
        /// 删除知识库文件
        /// </summary>
        [HttpDelete("knowledge/files/{id}")]
        public async Task<ActionResult<ApiResponse<bool>>> DeleteKnowledgeFile(long id)
        {
            var result = await _contractService.DeleteKnowledgeFileAsync(id);
            if (!result) return NotFound(ApiResponse<object>.Error("File not found"));
            return Ok(ApiResponse<bool>.Success(true));
        }

        /// <summary>
        /// 下载知识库文件
        /// </summary>
        [HttpGet("knowledge/files/{id}/download")]
        public async Task<IActionResult> DownloadKnowledgeFile(long id)
        {
            var file = await _contractService.GetKnowledgeFileByIdAsync(id);
            if (file == null || string.IsNullOrEmpty(file.FilePath)) return NotFound();

            var webRootPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
            // Remove leading slash if present for Path.Combine
            var relativePath = file.FilePath.TrimStart('/', '\\');
            var filePath = Path.Combine(webRootPath, relativePath);

            if (!System.IO.File.Exists(filePath)) return NotFound("Physical file missing");

            var contentType = file.ContentType ?? "application/octet-stream"; // Default if null

            var fileBytes = await System.IO.File.ReadAllBytesAsync(filePath);
            return File(fileBytes, contentType, file.Name);
        }
    }
}
