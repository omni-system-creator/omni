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

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(Guid id, [FromBody] UpdateKbDto dto)
        {
            var success = await _kbService.UpdateKbAsync(id, dto);
            if (!success) return NotFound();
            return Ok();
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

        [HttpGet("{kbId}/folders")]
        public async Task<ActionResult<List<KbFileDto>>> GetFolders(Guid kbId, [FromQuery] Guid? parentId = null)
        {
            var result = await _kbService.GetFoldersAsync(kbId, parentId);
            return Ok(result);
        }

        [HttpPost("{kbId}/files")]
        public async Task<ActionResult<KbFileDto>> UploadFile(Guid kbId, IFormFile file, [FromQuery] Guid? parentId = null)
        {
            try
            {
                var result = await _kbService.UploadFileAsync(kbId, file, parentId);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPost("{kbId}/folders")]
        public async Task<ActionResult<KbFileDto>> CreateFolder(Guid kbId, [FromBody] CreateKbFolderDto dto)
        {
            dto.KbId = kbId;
            var result = await _kbService.CreateFolderAsync(dto);
            return Ok(result);
        }

        [HttpDelete("files/{fileId}")]
        public async Task<IActionResult> DeleteFile(Guid fileId)
        {
            var success = await _kbService.DeleteFileAsync(fileId);
            if (!success) return NotFound();
            return Ok();
        }

        [HttpPut("files/{fileId}/rename")]
        public async Task<IActionResult> RenameFile(Guid fileId, [FromBody] RenameKbFileDto dto)
        {
            var success = await _kbService.RenameFileAsync(fileId, dto.Name);
            if (!success) return NotFound();
            return Ok();
        }

        [HttpPut("files/{fileId}/move")]
        public async Task<IActionResult> MoveFile(Guid fileId, [FromBody] MoveKbFileDto dto)
        {
            var success = await _kbService.MoveFileAsync(fileId, dto.TargetFolderId);
            if (!success) return NotFound();
            return Ok();
        }

        [HttpGet("files/{fileId}/download")]
        public async Task<IActionResult> DownloadFile(Guid fileId)
        {
            var info = await _kbService.GetFileDownloadInfoAsync(fileId);
            if (info == null) return NotFound("File not found.");
            
            return PhysicalFile(info.Value.PhysicalPath, info.Value.ContentType, info.Value.Name);
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

        [HttpGet("models")]
        public async Task<ActionResult<List<SiliconModelDto>>> GetModels()
        {
            var result = await _kbService.GetAvailableModelsAsync();
            return Ok(result);
        }

        [HttpGet("{kbId}/chat")]
        public async Task<ActionResult<List<ChatMessageDto>>> GetChatHistory(Guid kbId)
        {
            var userId = Guid.Empty; // Replace with actual user ID
            var result = await _kbService.GetChatHistoryAsync(kbId, userId);
            return Ok(result);
        }

        [HttpDelete("{kbId}/chat")]
        public async Task<IActionResult> DeleteChatHistory(Guid kbId)
        {
            var userId = Guid.Empty; // Replace with actual user ID
            // If admin, maybe pass null as userId to delete all? 
            // The requirement says "Admin can delete". 
            // For now, let's assume it deletes the history for the current context (simulated user).
            // If we want to delete ALL history for the KB (admin feature), we might need a flag or different logic.
            // But based on "KbChat.vue", it's likely a per-session or per-user chat.
            // However, the current code uses Guid.Empty as placeholder.
            // I'll stick with that for consistency.
            
            var success = await _kbService.DeleteChatHistoryAsync(kbId, userId);
            if (!success) return NotFound();
            return Ok();
        }

        [HttpDelete("chat/message/{id}")]
        public async Task<IActionResult> DeleteKbQaHistory(Guid id)
        {
            var success = await _kbService.DeleteKbQaHistoryAsync(id);
            if (!success) return NotFound();
            return Ok();
        }

        [HttpPost("chat")]
        public async Task<ActionResult<ChatMessageDto>> SendMessage([FromBody] SendMessageDto dto)
        {
            var userId = Guid.Empty; // Replace with actual user ID
            var result = await _kbService.SendMessageAsync(dto, userId);
            return Ok(result);
        }

        [HttpPost("chat/stream")]
        public async Task SendMessageStream([FromBody] SendMessageDto dto)
        {
            var userId = Guid.Empty; // Replace with actual user ID
            
            Response.Headers.Append("Content-Type", "text/event-stream");
            Response.Headers.Append("Cache-Control", "no-cache");
            Response.Headers.Append("Connection", "keep-alive");

            await foreach (var chunk in _kbService.SendMessageStreamAsync(dto, userId))
            {
                // Send as SSE data
                // Need to be careful with newlines in data, but for simple text chunks usually okay
                // A better way is to JSON encode the chunk
                var data = System.Text.Json.JsonSerializer.Serialize(new { content = chunk });
                await Response.WriteAsync($"data: {data}\n\n");
                await Response.Body.FlushAsync();
            }
            
            await Response.WriteAsync("data: [DONE]\n\n");
            await Response.Body.FlushAsync();
        }
    }
}
