using Microsoft.AspNetCore.Http;
using omsapi.DTOs;
using omsapi.Models.Dtos;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace omsapi.Services.Interfaces
{
    public interface ITaskService
    {
        Task<List<TaskDto>> GetMyPendingTasksAsync(long userId, long orgId);
        Task<List<TaskDto>> GetMyCompletedTasksAsync(long userId, long orgId);
        Task<List<TaskDto>> GetSubordinateTasksAsync(long userId, long orgId);
        Task<TaskDto> CreateTaskAsync(CreateTaskDto dto, List<IFormFile> attachments, long userId, long orgId);
        Task<TaskDto?> UpdateTaskAsync(long id, UpdateTaskDto dto, long userId);
        Task<bool> DeleteTaskAsync(long id, long userId);
        Task<List<TaskProcessDto>> GetTaskProcessesAsync(long taskId);
        Task<TaskProcessDto> AddTaskProcessAsync(long taskId, CreateTaskProcessDto dto, List<IFormFile> attachments, long userId);
        Task<FileDto> UploadTaskAttachmentAsync(long taskId, IFormFile file, long userId);
        Task<TaskAttachmentDto?> GetTaskAttachmentAsync(long attachmentId);
    }
}
