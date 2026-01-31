using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using omsapi.Data;
using omsapi.DTOs;
using omsapi.Models.Common;
using omsapi.Models.Dtos;
using omsapi.Services.Interfaces;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace omsapi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class TaskController : ControllerBase
    {
        private readonly ITaskService _taskService;
        private readonly OmsContext _context;
        private readonly IWebHostEnvironment _env;

        public TaskController(ITaskService taskService, OmsContext context, IWebHostEnvironment env)
        {
            _taskService = taskService;
            _context = context;
            _env = env;
        }

        private long GetCurrentUserId()
        {
            var userIdClaim = User.FindFirst("id");
            if (userIdClaim == null || !long.TryParse(userIdClaim.Value, out long userId))
            {
                throw new System.UnauthorizedAccessException("User ID not found in token");
            }
            return userId;
        }

        private async Task<long> GetCurrentOrgIdAsync(long userId)
        {
            // Ideally this should be in a claim or cached service
            var user = await _context.Users.FindAsync(userId);
            return user?.CurrentOrgId ?? 0;
        }

        [HttpGet("pending")]
        public async Task<ApiResponse<List<TaskDto>>> GetPendingTasks()
        {
            var userId = GetCurrentUserId();
            var orgId = await GetCurrentOrgIdAsync(userId);
            var tasks = await _taskService.GetMyPendingTasksAsync(userId, orgId);
            return ApiResponse<List<TaskDto>>.Success(tasks);
        }

        [HttpGet("completed")]
        public async Task<ApiResponse<List<TaskDto>>> GetCompletedTasks()
        {
            var userId = GetCurrentUserId();
            var orgId = await GetCurrentOrgIdAsync(userId);
            var tasks = await _taskService.GetMyCompletedTasksAsync(userId, orgId);
            return ApiResponse<List<TaskDto>>.Success(tasks);
        }

        [HttpGet("subordinate")]
        public async Task<ApiResponse<List<TaskDto>>> GetSubordinateTasks()
        {
            var userId = GetCurrentUserId();
            var orgId = await GetCurrentOrgIdAsync(userId);
            var tasks = await _taskService.GetSubordinateTasksAsync(userId, orgId);
            return ApiResponse<List<TaskDto>>.Success(tasks);
        }

        [HttpPost]
        public async Task<ApiResponse<TaskDto>> CreateTask([FromForm] CreateTaskDto dto, [FromForm] List<IFormFile> attachments)
        {
            var userId = GetCurrentUserId();
            var orgId = await GetCurrentOrgIdAsync(userId);
            var task = await _taskService.CreateTaskAsync(dto, attachments, userId, orgId);
            return ApiResponse<TaskDto>.Success(task);
        }

        [HttpPut("{id}")]
        public async Task<ApiResponse<TaskDto>> UpdateTask(long id, [FromBody] UpdateTaskDto dto)
        {
            var userId = GetCurrentUserId();
            var task = await _taskService.UpdateTaskAsync(id, dto, userId);
            if (task == null) return ApiResponse<TaskDto>.Error("Task not found or access denied", 404);
            return ApiResponse<TaskDto>.Success(task);
        }

        [HttpGet("{id}/process")]
        public async Task<ApiResponse<List<TaskProcessDto>>> GetTaskProcesses(long id)
        {
            var processes = await _taskService.GetTaskProcessesAsync(id);
            return ApiResponse<List<TaskProcessDto>>.Success(processes);
        }

        [HttpPost("{id}/process")]
        public async Task<ApiResponse<TaskProcessDto>> AddTaskProcess(long id, [FromForm] CreateTaskProcessDto dto, [FromForm] List<IFormFile> attachments)
        {
            var userId = GetCurrentUserId();
            var process = await _taskService.AddTaskProcessAsync(id, dto, attachments, userId);
            return ApiResponse<TaskProcessDto>.Success(process);
        }

        [HttpPost("{id}/attachment")]
        public async Task<ApiResponse<FileDto>> UploadTaskAttachment(long id, IFormFile file)
        {
            var userId = GetCurrentUserId();
            var result = await _taskService.UploadTaskAttachmentAsync(id, file, userId);
            return ApiResponse<FileDto>.Success(result);
        }

        [HttpGet("attachments/{id}")]
        public async Task<IActionResult> DownloadTaskAttachment(long id)
        {
            var file = await _taskService.GetTaskAttachmentAsync(id);
            if (file == null || string.IsNullOrEmpty(file.FilePath)) return NotFound();

            var webRootPath = _env.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
            var filePath = Path.Combine(webRootPath, file.FilePath.Replace("/", Path.DirectorySeparatorChar.ToString()));

            if (!System.IO.File.Exists(filePath)) return NotFound("File not found on server");

            var contentType = file.ContentType ?? "application/octet-stream";
            
            // Return file stream
            var fileStream = new FileStream(filePath, FileMode.Open, FileAccess.Read);
            return File(fileStream, contentType, file.Name);
        }

        [HttpDelete("{id}")]
        public async Task<ApiResponse<bool>> DeleteTask(long id)
        {
            var userId = GetCurrentUserId();
            var success = await _taskService.DeleteTaskAsync(id, userId);
            if (!success) return ApiResponse<bool>.Error("Task not found or access denied", 404);
            return ApiResponse<bool>.Success(true);
        }
    }
}
