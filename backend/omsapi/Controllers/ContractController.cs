using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using omsapi.Models.Common;
using omsapi.Models.Dtos.Contract;
using omsapi.Services.Interfaces;

namespace omsapi.Controllers
{
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

        [HttpGet]
        public async Task<ActionResult<ApiResponse<IEnumerable<ContractDto>>>> GetContracts([FromQuery] string? type, [FromQuery] string? keyword)
        {
            var result = await _contractService.GetContractsAsync(type, keyword);
            return Ok(ApiResponse<IEnumerable<ContractDto>>.Success(result));
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<ApiResponse<ContractDetailDto>>> GetContract(long id)
        {
            var result = await _contractService.GetContractByIdAsync(id);
            if (result == null) return NotFound(ApiResponse<object>.Error("Contract not found"));
            return Ok(ApiResponse<ContractDetailDto>.Success(result));
        }

        [HttpPost]
        public async Task<ActionResult<ApiResponse<ContractDto>>> CreateContract([FromBody] CreateContractDto dto)
        {
            var result = await _contractService.CreateContractAsync(dto);
            return Ok(ApiResponse<ContractDto>.Success(result));
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<ApiResponse<ContractDto>>> UpdateContract(long id, [FromBody] UpdateContractDto dto)
        {
            var result = await _contractService.UpdateContractAsync(id, dto);
            if (result == null) return NotFound(ApiResponse<object>.Error("Contract not found"));
            return Ok(ApiResponse<ContractDto>.Success(result));
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<ApiResponse<object>>> DeleteContract(long id)
        {
            var result = await _contractService.DeleteContractAsync(id);
            if (!result) return NotFound(ApiResponse<object>.Error("Contract not found"));
            return Ok(ApiResponse<object>.Success(null));
        }

        // --- Templates ---

        [HttpGet("templates")]
        public async Task<ActionResult<ApiResponse<IEnumerable<ContractTemplateDto>>>> GetTemplates([FromQuery] string? type)
        {
            var result = await _contractService.GetTemplatesAsync(type);
            return Ok(ApiResponse<IEnumerable<ContractTemplateDto>>.Success(result));
        }

        [HttpPost("templates")]
        public async Task<ActionResult<ApiResponse<ContractTemplateDto>>> CreateTemplate([FromBody] CreateContractTemplateDto dto)
        {
            var result = await _contractService.CreateTemplateAsync(dto);
            return Ok(ApiResponse<ContractTemplateDto>.Success(result));
        }

        [HttpPut("templates/{id}")]
        public async Task<ActionResult<ApiResponse<ContractTemplateDto>>> UpdateTemplate(long id, [FromBody] UpdateContractTemplateDto dto)
        {
            var result = await _contractService.UpdateTemplateAsync(id, dto);
            if (result == null) return NotFound(ApiResponse<object>.Error("Template not found"));
            return Ok(ApiResponse<ContractTemplateDto>.Success(result));
        }

        [HttpDelete("templates/{id}")]
        public async Task<ActionResult<ApiResponse<object>>> DeleteTemplate(long id)
        {
            var result = await _contractService.DeleteTemplateAsync(id);
            if (!result) return NotFound(ApiResponse<object>.Error("Template not found"));
            return Ok(ApiResponse<object>.Success(null));
        }

        // --- Stats ---

        [HttpGet("stats/current")]
        public async Task<ActionResult<ApiResponse<ContractStatDto>>> GetCurrentStats([FromQuery] string periodType = "Month")
        {
            var result = await _contractService.GetCurrentStatsAsync(periodType);
            return Ok(ApiResponse<ContractStatDto>.Success(result));
        }

        [HttpGet("stats/trend")]
        public async Task<ActionResult<ApiResponse<IEnumerable<ContractStatDto>>>> GetTrendStats([FromQuery] string periodType = "Year", [FromQuery] int count = 5)
        {
            var result = await _contractService.GetTrendStatsAsync(periodType, count);
            return Ok(ApiResponse<IEnumerable<ContractStatDto>>.Success(result));
        }

        // --- Knowledge ---

        [HttpGet("knowledge/categories")]
        public async Task<ActionResult<ApiResponse<IEnumerable<ContractKnowledgeCategoryDto>>>> GetKnowledgeCategories()
        {
            var result = await _contractService.GetKnowledgeTreeAsync();
            return Ok(ApiResponse<IEnumerable<ContractKnowledgeCategoryDto>>.Success(result));
        }

        [HttpPost("knowledge/categories")]
        public async Task<ActionResult<ApiResponse<ContractKnowledgeCategoryDto>>> CreateKnowledgeCategory([FromBody] CreateContractKnowledgeCategoryDto dto)
        {
            var result = await _contractService.CreateKnowledgeCategoryAsync(dto);
            return Ok(ApiResponse<ContractKnowledgeCategoryDto>.Success(result));
        }

        [HttpPut("knowledge/categories/{id}")]
        public async Task<ActionResult<ApiResponse<ContractKnowledgeCategoryDto>>> UpdateKnowledgeCategory(long id, [FromBody] UpdateContractKnowledgeCategoryDto dto)
        {
            var result = await _contractService.UpdateKnowledgeCategoryAsync(id, dto);
            if (result == null) return NotFound(ApiResponse<object>.Error("Category not found"));
            return Ok(ApiResponse<ContractKnowledgeCategoryDto>.Success(result));
        }

        [HttpDelete("knowledge/categories/{id}")]
        public async Task<ActionResult<ApiResponse<bool>>> DeleteKnowledgeCategory(long id)
        {
            var result = await _contractService.DeleteKnowledgeCategoryAsync(id);
            if (!result) return NotFound(ApiResponse<object>.Error("Category not found"));
            return Ok(ApiResponse<bool>.Success(true));
        }

        [HttpGet("knowledge/files")]
        public async Task<ActionResult<ApiResponse<IEnumerable<ContractKnowledgeFileDto>>>> GetKnowledgeFiles([FromQuery] long categoryId, [FromQuery] string? keyword)
        {
            var result = await _contractService.GetKnowledgeFilesAsync(categoryId, keyword);
            return Ok(ApiResponse<IEnumerable<ContractKnowledgeFileDto>>.Success(result));
        }

        [HttpPost("knowledge/files")]
        public async Task<ActionResult<ApiResponse<ContractKnowledgeFileDto>>> UploadKnowledgeFile(IFormFile file, [FromForm] long categoryId)
        {
            var uploader = User.Identity?.Name ?? "Unknown";
            var result = await _contractService.UploadKnowledgeFileAsync(file, categoryId, uploader);
            return Ok(ApiResponse<ContractKnowledgeFileDto>.Success(result));
        }

        [HttpPut("knowledge/files/{id}")]
        public async Task<ActionResult<ApiResponse<ContractKnowledgeFileDto>>> UpdateKnowledgeFile(long id, [FromBody] UpdateContractKnowledgeFileDto dto)
        {
            var result = await _contractService.UpdateKnowledgeFileAsync(id, dto);
            if (result == null) return NotFound(ApiResponse<object>.Error("File not found"));
            return Ok(ApiResponse<ContractKnowledgeFileDto>.Success(result));
        }

        [HttpDelete("knowledge/files/{id}")]
        public async Task<ActionResult<ApiResponse<bool>>> DeleteKnowledgeFile(long id)
        {
            var result = await _contractService.DeleteKnowledgeFileAsync(id);
            if (!result) return NotFound(ApiResponse<object>.Error("File not found"));
            return Ok(ApiResponse<bool>.Success(true));
        }

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
