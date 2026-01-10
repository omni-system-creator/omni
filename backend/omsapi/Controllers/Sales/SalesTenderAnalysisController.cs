using Microsoft.AspNetCore.Mvc;
using omsapi.Models.Dtos.Sales;
using omsapi.Services.Interfaces;
using System.Text.Json;

namespace omsapi.Controllers.Sales
{
    [ApiController]
    [Route("api/sales/tender-analysis")]
    public class SalesTenderAnalysisController : ControllerBase
    {
        private readonly ISalesTenderAnalysisService _service;

        public SalesTenderAnalysisController(ISalesTenderAnalysisService service)
        {
            _service = service;
        }

        [HttpGet("{bidProjectId}")]
        public async Task<ActionResult<SalesTenderAnalysisDto>> GetByBidProjectId(string bidProjectId)
        {
            var result = await _service.GetByBidProjectIdAsync(bidProjectId);
            if (result == null)
            {
                return NotFound();
            }
            return Ok(result);
        }

        [HttpPost]
        public async Task<ActionResult<SalesTenderAnalysisDto>> CreateOrUpdate(CreateSalesTenderAnalysisDto dto)
        {
            var result = await _service.CreateOrUpdateAsync(dto);
            return Ok(result);
        }

        private long GetCurrentUserId()
        {
            var userIdClaim = User.FindFirst("id");
            if (userIdClaim == null || !long.TryParse(userIdClaim.Value, out long userId))
            {
                return 1; // Default or throw
            }
            return userId;
        }

        [HttpPost("{bidProjectId}/upload")]
        public async Task<ActionResult<SalesTenderAnalysisDto>> UploadTenderDoc(string bidProjectId, IFormFile file)
        {
            try
            {
                var userId = GetCurrentUserId();
                var result = await _service.UploadTenderDocAsync(bidProjectId, file, userId);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpGet("{bidProjectId}/download")]
        public async Task<IActionResult> DownloadTenderDoc(string bidProjectId)
        {
            try
            {
                var userId = GetCurrentUserId();
                var (success, message, contentType, stream, fileName) = await _service.DownloadTenderDocAsync(bidProjectId, userId);

                if (!success || stream == null) return NotFound(message);

                return File(stream, contentType ?? "application/octet-stream", fileName);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpGet("{bidProjectId}/status")]
        public async Task<ActionResult<SalesTenderAnalysisStatusDto>> GetStatus(string bidProjectId)
        {
            var userId = GetCurrentUserId();
            var result = await _service.GetStatusAsync(bidProjectId, userId);
            return Ok(result);
        }

        [HttpPost("{bidProjectId}/reanalyze")]
        public async Task<ActionResult<SalesTenderAnalysisStatusDto>> Reanalyze(string bidProjectId)
        {
            var userId = GetCurrentUserId();
            var result = await _service.StartReanalyzeAsync(bidProjectId, userId);
            return Ok(result);
        }

        [HttpPost("{bidProjectId}/cancel")]
        public async Task<IActionResult> CancelAnalysis(string bidProjectId)
        {
            var userId = GetCurrentUserId();
            await _service.CancelAnalysisAsync(bidProjectId, userId);
            return Ok();
        }

        [HttpGet("{bidProjectId}/logs")]
        public async Task<ActionResult<List<SalesTenderAnalysisLogDto>>> GetLogs(string bidProjectId, [FromQuery] long? runId, [FromQuery] long? afterId, [FromQuery] int take = 200)
        {
            var userId = GetCurrentUserId();
            var result = await _service.GetLogsAsync(bidProjectId, runId, afterId, take, userId);
            return Ok(result);
        }

        [HttpGet("{bidProjectId}/logs/stream")]
        public async Task StreamLogs(string bidProjectId, [FromQuery] long? runId)
        {
            var userId = GetCurrentUserId();
            var status = await _service.GetStatusAsync(bidProjectId, userId);
            var resolvedRunId = runId ?? status.RunId;
            if (resolvedRunId == null)
            {
                Response.StatusCode = 404;
                return;
            }

            Response.Headers.Append("Content-Type", "text/event-stream");
            Response.Headers.Append("Cache-Control", "no-cache");
            Response.Headers.Append("X-Accel-Buffering", "no");

            long? lastId = null;
            try 
            {
                while (!HttpContext.RequestAborted.IsCancellationRequested)
                {
                    var logs = await _service.GetLogsAsync(bidProjectId, resolvedRunId, lastId, 200, userId);
                    foreach (var log in logs)
                    {
                        lastId = log.Id;
                        var json = JsonSerializer.Serialize(log, new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase });
                        await Response.WriteAsync($"data: {json}\n\n");
                    }

                    await Response.Body.FlushAsync();

                    var currentStatus = await _service.GetStatusAsync(bidProjectId, userId);
                    if (currentStatus.RunId == resolvedRunId && !currentStatus.IsAnalyzing)
                    {
                        await Response.WriteAsync("event: done\ndata: {}\n\n");
                        await Response.Body.FlushAsync();
                        return;
                    }

                    await Task.Delay(1000, HttpContext.RequestAborted);
                }
            }
            catch (TaskCanceledException)
            {
                // Client disconnected, ignore
            }
        }
    }
}
