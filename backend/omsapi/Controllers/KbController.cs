using Microsoft.AspNetCore.Mvc;
using omsapi.Models.Entities;
using omsapi.Services.Interfaces;
using OmsApi.Models.Dtos.Kb;

namespace omsapi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class KbController : ControllerBase
    {
        private readonly IKbService _kbService;

        public KbController(IKbService kbService)
        {
            _kbService = kbService;
        }

        // --- KB Management ---

        [HttpGet]
        public async Task<ActionResult<List<KbInfoDto>>> GetAll()
        {
            var result = await _kbService.GetAllKbsAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<KbInfoDto>> GetById(Guid id)
        {
            var result = await _kbService.GetKbByIdAsync(id);
            if (result == null) return NotFound();
            return Ok(result);
        }

        [HttpPost]
        public async Task<ActionResult<KbInfoDto>> Create([FromBody] CreateKbDto dto)
        {
            // Assuming we can get UserId from claims, using a placeholder for now
            // var userId = Guid.Parse(User.FindFirst("id")?.Value);
            var userId = Guid.Empty; // Replace with actual user ID
            
            var result = await _kbService.CreateKbAsync(dto, userId);
            return Ok(result);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(Guid id)
        {
            var success = await _kbService.DeleteKbAsync(id);
            if (!success) return NotFound();
            return Ok();
        }

        // --- File Management ---

        [HttpGet("{kbId}/files")]
        public async Task<ActionResult<List<KbFileDto>>> GetFiles(Guid kbId)
        {
            var result = await _kbService.GetKbFilesAsync(kbId);
            return Ok(result);
        }

        [HttpPost("{kbId}/files")]
        public async Task<ActionResult<KbFileDto>> UploadFile(Guid kbId, IFormFile file)
        {
            try
            {
                var result = await _kbService.UploadFileAsync(kbId, file);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpDelete("files/{fileId}")]
        public async Task<IActionResult> DeleteFile(Guid fileId)
        {
            var success = await _kbService.DeleteFileAsync(fileId);
            if (!success) return NotFound();
            return Ok();
        }

        // --- Catalog ---

        [HttpGet("{kbId}/nodes")]
        public async Task<ActionResult<List<KbNodeDto>>> GetNodes(Guid kbId)
        {
            var result = await _kbService.GetKbNodesAsync(kbId);
            return Ok(result);
        }

        [HttpGet("nodes/{key}")]
        public async Task<ActionResult<KbNodeDto>> GetNodeDetail(string key)
        {
            var result = await _kbService.GetNodeDetailAsync(key);
            if (result == null) return NotFound();
            return Ok(result);
        }

        // --- Chat ---

        [HttpGet("{kbId}/chat")]
        public async Task<ActionResult<List<ChatMessageDto>>> GetChatHistory(Guid kbId)
        {
            var userId = Guid.Empty; // Replace with actual user ID
            var result = await _kbService.GetChatHistoryAsync(kbId, userId);
            return Ok(result);
        }

        [HttpPost("chat")]
        public async Task<ActionResult<ChatMessageDto>> SendMessage([FromBody] SendMessageDto dto)
        {
            var userId = Guid.Empty; // Replace with actual user ID
            var result = await _kbService.SendMessageAsync(dto, userId);
            return Ok(result);
        }
    }
}
