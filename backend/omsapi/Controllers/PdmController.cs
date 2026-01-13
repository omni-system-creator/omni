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

        [HttpPost("ebom/items/children")]
        public async Task<ApiResponse<bool>> AddChildItem([FromBody] AddChildItemDto dto)
        {
            try
            {
                var result = await _pdmService.AddChildItemAsync(dto);
                return ApiResponse<bool>.Success(result);
            }
            catch (Exception ex)
            {
                return ApiResponse<bool>.Error(ex.Message);
            }
        }

        [HttpPut("ebom/items/{parentId}/children/{childId}/qty")]
        public async Task<ApiResponse<bool>> UpdateChildItemQty(string parentId, string childId, [FromBody] UpdateChildItemQtyDto dto)
        {
            try
            {
                var result = await _pdmService.UpdateChildItemQtyAsync(parentId, childId, dto.Qty);
                return ApiResponse<bool>.Success(result);
            }
            catch (Exception ex)
            {
                return ApiResponse<bool>.Error(ex.Message);
            }
        }

        [HttpDelete("ebom/items/{parentId}/children/{childId}")]
        public async Task<ApiResponse<bool>> RemoveChildItem(string parentId, string childId)
        {
            try
            {
                var result = await _pdmService.RemoveChildItemAsync(parentId, childId);
                return ApiResponse<bool>.Success(result);
            }
            catch (Exception ex)
            {
                return ApiResponse<bool>.Error(ex.Message);
            }
        }

        [HttpGet("ebom/search")]
        public async Task<ApiResponse<List<EbomItemDto>>> SearchEbomItems([FromQuery] string keyword = "", [FromQuery] string excludeId = "")
        {
            try
            {
                var result = await _pdmService.SearchEbomItemsAsync(keyword, excludeId);
                return ApiResponse<List<EbomItemDto>>.Success(result);
            }
            catch (Exception ex)
            {
                return ApiResponse<List<EbomItemDto>>.Error(ex.Message);
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

        [HttpPost("ebom/import")]
        public async Task<ApiResponse<bool>> ImportEbom(IFormFile file)
        {
            try
            {
                var (success, message) = await _pdmService.ImportEbomAsync(file);
                if (!success) return ApiResponse<bool>.Error(message);
                return ApiResponse<bool>.Success(true, message);
            }
            catch (Exception ex)
            {
                return ApiResponse<bool>.Error(ex.Message);
            }
        }

        [HttpGet("ebom/export")]
        public async Task<IActionResult> ExportEbom([FromQuery] string? rootId)
        {
            try
            {
                var (success, message, content, fileName) = await _pdmService.ExportEbomAsync(rootId);
                if (!success || content == null) return BadRequest(message);
                return File(content, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", fileName);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpGet("ebom/compare")]
        public async Task<ApiResponse<object>> CompareEbom([FromQuery] List<string> itemIds)
        {
            try
            {
                var (success, message, result) = await _pdmService.CompareEbomAsync(itemIds);
                if (!success) return ApiResponse<object>.Error(message);
                return ApiResponse<object>.Success(result, message);
            }
            catch (Exception ex)
            {
                return ApiResponse<object>.Error(ex.Message);
            }
        }
    }
}
