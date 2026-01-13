using Microsoft.AspNetCore.Mvc;
using omsapi.Models.Dtos.Pdm;
using omsapi.Services.Interfaces;
using omsapi.Models.Common;

namespace omsapi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PdmController : ControllerBase
    {
        private readonly IPdmService _pdmService;

        public PdmController(IPdmService pdmService)
        {
            _pdmService = pdmService;
        }

        [HttpPost("init")]
        public async Task<ApiResponse<bool>> InitData()
        {
            await _pdmService.InitEbomDataAsync();
            return ApiResponse<bool>.Success(true);
        }

        [HttpGet("ebom/tree")]
        public async Task<ApiResponse<List<EbomItemDto>>> GetEbomTrees()
        {
            var data = await _pdmService.GetEbomTreesAsync();
            return ApiResponse<List<EbomItemDto>>.Success(data);
        }

        [HttpGet("ebom/items/{id}")]
        public async Task<ApiResponse<EbomDetailDto>> GetEbomItem(string id)
        {
            var data = await _pdmService.GetEbomItemAsync(id);
            if (data == null)
            {
                return ApiResponse<EbomDetailDto>.Error("Item not found");
            }
            return ApiResponse<EbomDetailDto>.Success(data);
        }

        [HttpGet("ebom/items/{id}/children")]
        public async Task<ApiResponse<List<EbomItemDto>>> GetEbomChildren(string id)
        {
            var data = await _pdmService.GetEbomChildrenAsync(id);
            return ApiResponse<List<EbomItemDto>>.Success(data);
        }
        [HttpPost("ebom/create")]
        public async Task<ApiResponse<EbomItemDto>> CreateEbomItem([FromBody] CreateEbomItemDto dto)
        {
            try
            {
                var result = await _pdmService.CreateEbomItemAsync(dto);
                return ApiResponse<EbomItemDto>.Success(result);
            }
            catch (Exception ex)
            {
                return ApiResponse<EbomItemDto>.Error(ex.Message);
            }
        }

        [HttpPut("ebom/items/{id}")]
        public async Task<ApiResponse<EbomItemDto>> UpdateEbomItem(string id, [FromBody] UpdateEbomItemDto dto)
        {
            try
            {
                var result = await _pdmService.UpdateEbomItemAsync(id, dto);
                return ApiResponse<EbomItemDto>.Success(result);
            }
            catch (Exception ex)
            {
                return ApiResponse<EbomItemDto>.Error(ex.Message);
            }
        }

        [HttpDelete("ebom/items/{id}")]
        public async Task<ApiResponse<bool>> DeleteEbomItem(string id)
        {
            try
            {
                var result = await _pdmService.DeleteEbomItemAsync(id);
                return ApiResponse<bool>.Success(result);
            }
            catch (Exception ex)
            {
                return ApiResponse<bool>.Error(ex.Message);
            }
        }

        [HttpPost("ebom/documents/upload")]
        public async Task<ApiResponse<EbomDocumentDto>> UploadEbomDocument(IFormFile file)
        {
            try
            {
                var (success, message, data) = await _pdmService.UploadEbomDocumentAsync(file);
                if (!success) return ApiResponse<EbomDocumentDto>.Error(message);
                return ApiResponse<EbomDocumentDto>.Success(data, message);
            }
            catch (Exception ex)
            {
                return ApiResponse<EbomDocumentDto>.Error(ex.Message);
            }
        }

        [HttpGet("ebom/documents/{id}/download")]
        public async Task<IActionResult> DownloadEbomDocument(long id)
        {
            try
            {
                var (success, message, contentType, stream, fileName) = await _pdmService.DownloadEbomDocumentAsync(id);
                if (!success || stream == null) return NotFound(message);
                return File(stream, contentType, fileName);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }
    }
}
