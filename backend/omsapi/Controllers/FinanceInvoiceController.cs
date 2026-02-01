using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using omsapi.Models.Dtos;
using omsapi.Models.Common;
using omsapi.Services.Interfaces;

namespace omsapi.Controllers
{
    [ApiController]
    [Route("api/finance/invoice")]
    [Authorize]
    public class FinanceInvoiceController : ControllerBase
    {
        private readonly IFinanceInvoiceService _service;

        public FinanceInvoiceController(IFinanceInvoiceService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<ApiResponse<List<FinanceInvoiceDto>>> GetInvoices([FromQuery] string? direction, [FromQuery] string? type, [FromQuery] string? status, [FromQuery] string? keyword)
        {
            var data = await _service.GetInvoicesAsync(direction, type, status, keyword);
            return ApiResponse<List<FinanceInvoiceDto>>.Success(data);
        }

        [HttpGet("{id}")]
        public async Task<ApiResponse<FinanceInvoiceDto>> GetInvoice(long id)
        {
            var data = await _service.GetInvoiceByIdAsync(id);
            if (data == null) return ApiResponse<FinanceInvoiceDto>.Error("发票不存在");
            return ApiResponse<FinanceInvoiceDto>.Success(data);
        }

        [HttpPost]
        public async Task<ApiResponse<object>> CreateInvoice([FromForm] CreateFinanceInvoiceDto dto, [FromForm] List<IFormFile> attachments)
        {
            var (success, message, id) = await _service.CreateInvoiceAsync(dto, attachments);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(new { Id = id }, message);
        }

        [HttpPut("{id}")]
        public async Task<ApiResponse<object>> UpdateInvoice(long id, [FromForm] UpdateFinanceInvoiceDto dto, [FromForm] List<IFormFile>? attachments)
        {
            var (success, message) = await _service.UpdateInvoiceAsync(id, dto, attachments);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null, message);
        }

        [HttpDelete("{id}")]
        public async Task<ApiResponse<object>> DeleteInvoice(long id)
        {
            var (success, message) = await _service.DeleteInvoiceAsync(id);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null, message);
        }

        [HttpPost("recognize")]
        public async Task<ApiResponse<FinanceInvoiceDto>> RecognizeInvoice(IFormFile file)
        {
            var (success, message, data) = await _service.RecognizeInvoiceAsync(file);
            if (!success) return ApiResponse<FinanceInvoiceDto>.Error(message);
            return ApiResponse<FinanceInvoiceDto>.Success(data, message);
        }
    }
}
