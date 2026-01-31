using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using omsapi.Data;
using omsapi.DTOs;
using omsapi.Infrastructure.Attributes;
using omsapi.Models.Dtos;
using omsapi.Models.Entities;
using omsapi.Models.Entities.System;
using omsapi.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

namespace omsapi.Services
{
    [AutoInject(ServiceLifetime.Scoped)]
    public class TaskService : ITaskService
    {
        private readonly OmsContext _context;
        private readonly IWebHostEnvironment _env;

        public TaskService(OmsContext context, IWebHostEnvironment env)
        {
            _context = context;
            _env = env;
        }
        
        private static TaskDto MapToDto(SysTask entity)
        {
            return new TaskDto
            {
                Id = entity.Id,
                Title = entity.Title,
                Type = entity.Type,
                Priority = entity.Priority,
                Description = entity.Description,
                CreatorId = entity.CreatorId,
                CreatorName = entity.Creator?.Nickname ?? entity.Creator?.Username ?? "",
                CreatorAvatar = entity.Creator?.Avatar,
                AssigneeId = entity.AssigneeId,
                AssigneeName = entity.Assignee?.Nickname ?? entity.Assignee?.Username ?? "",
                AssigneeAvatar = entity.Assignee?.Avatar,
                CreateTime = entity.CreateTime,
                StartTime = entity.StartTime,
                Deadline = entity.Deadline,
                FinishTime = entity.FinishTime,
                Status = entity.Status,
                OrgId = entity.OrgId,
                Attachments = entity.Attachments?.Select(a => new TaskAttachmentDto
                {
                    Id = a.Id,
                    Name = a.FileName,
                    Extension = a.Extension,
                    Size = a.FileSize,
                    IsFolder = false,
                    ContentType = a.ContentType,
                    FilePath = a.FilePath,
                    ParentId = null,
                    OwnerId = a.UploaderId,
                    IsPublic = false,
                    CreatedAt = a.CreateTime,
                    UpdatedAt = a.CreateTime
                }).ToList() ?? new List<TaskAttachmentDto>(),
                Members = entity.Members?.Select(m => new TaskMemberDto
                {
                    UserId = m.UserId,
                    Username = m.User?.Username ?? "",
                    Name = m.User?.Nickname ?? m.User?.Username ?? "",
                    Avatar = m.User?.Avatar,
                    JoinTime = m.JoinTime
                }).ToList() ?? new List<TaskMemberDto>()
            };
        }

        public async Task<List<TaskDto>> GetMyPendingTasksAsync(long userId, long orgId)
        {
            return await _context.SysTasks
                .Include(t => t.Creator)
                .Include(t => t.Assignee)
                .Include(t => t.Attachments)
                .Include(t => t.Members).ThenInclude(m => m.User)
                .Where(t => (t.AssigneeId == userId || t.CreatorId == userId || t.Members.Any(m => m.UserId == userId)) && t.Status != "completed" && t.OrgId == orgId)
                .OrderByDescending(t => t.Priority == "high")
                .ThenBy(t => t.Deadline)
                .Select(t => MapToDto(t))
                .ToListAsync();
        }

        public async Task<List<TaskDto>> GetMyCompletedTasksAsync(long userId, long orgId)
        {
            return await _context.SysTasks
                .Include(t => t.Creator)
                .Include(t => t.Assignee)
                .Include(t => t.Attachments)
                .Include(t => t.Members).ThenInclude(m => m.User)
                .Where(t => (t.AssigneeId == userId || t.Members.Any(m => m.UserId == userId)) && t.Status == "completed" && t.OrgId == orgId)
                .OrderByDescending(t => t.FinishTime)
                .Select(t => MapToDto(t))
                .ToListAsync();
        }

        public async Task<List<TaskDto>> GetSubordinateTasksAsync(long userId, long orgId)
        {
            // 1. 获取直接下属ID (不包含间接下属)
            var subordinateIds = await _context.Users
                .Where(u => u.SuperiorId == userId)
                .Select(u => u.Id)
                .ToListAsync();

            if (!subordinateIds.Any())
            {
                // 如果没有下属，返回空列表
                return new List<TaskDto>();
            }

            // 2. 查询任务：Creator OR Assignee OR Members 包含任意直接下属ID
            return await _context.SysTasks
                .Include(t => t.Creator)
                .Include(t => t.Assignee)
                .Include(t => t.Attachments)
                .Include(t => t.Members).ThenInclude(m => m.User)
                .Where(t => t.OrgId == orgId && 
                           (subordinateIds.Contains(t.CreatorId) || 
                            subordinateIds.Contains(t.AssigneeId) || 
                            t.Members.Any(m => subordinateIds.Contains(m.UserId))))
                .OrderByDescending(t => t.CreateTime)
                .Select(t => MapToDto(t))
                .ToListAsync();
        }

        public async Task<TaskDto> CreateTaskAsync(CreateTaskDto dto, List<IFormFile> attachments, long userId, long orgId)
        {
            var entity = new SysTask
            {
                Title = dto.Title,
                Type = dto.Type,
                Priority = dto.Priority,
                Description = dto.Description,
                CreatorId = userId,
                AssigneeId = dto.AssigneeId ?? userId, // Default to self
                CreateTime = DateTime.Now,
                StartTime = dto.StartTime,
                Deadline = dto.Deadline,
                Status = "pending",
                OrgId = orgId
            };

            _context.SysTasks.Add(entity);
            await _context.SaveChangesAsync();

            // Handle members
            // 处理成员
            if (dto.MemberIds != null && dto.MemberIds.Any())
            {
                foreach (var memberId in dto.MemberIds.Distinct())
                {
                     _context.SysTaskMembers.Add(new SysTaskMember
                     {
                         TaskId = entity.Id,
                         UserId = memberId,
                         JoinTime = DateTime.Now
                     });
                }
                await _context.SaveChangesAsync();
            }

            // Handle attachments
            // 处理附件
            if (attachments != null && attachments.Any())
            {
                var webRootPath = _env.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
                var relativePath = Path.Combine("uploads", "tasks", entity.Id.ToString());
                var uploadPath = Path.Combine(webRootPath, relativePath);

                if (!Directory.Exists(uploadPath)) Directory.CreateDirectory(uploadPath);

                foreach (var file in attachments)
                {
                    if (file.Length > 0)
                    {
                        var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
                        var uniqueName = $"{Guid.NewGuid()}{extension}";
                        var filePath = Path.Combine(uploadPath, uniqueName);

                        using (var stream = new FileStream(filePath, FileMode.Create))
                        {
                            await file.CopyToAsync(stream);
                        }

                        var attachment = new SysTaskAttachment
                        {
                            TaskId = entity.Id,
                            FileName = file.FileName,
                            Extension = extension,
                            FileSize = file.Length,
                            ContentType = file.ContentType,
                            FilePath = Path.Combine(relativePath, uniqueName).Replace("\\", "/"),
                            UploaderId = userId,
                            CreateTime = DateTime.Now
                        };
                        _context.SysTaskAttachments.Add(attachment);
                    }
                }
                await _context.SaveChangesAsync();
            }

            // Reload to get names
            return await GetTaskByIdAsync(entity.Id) ?? MapToDto(entity);
        }

        public async Task<TaskDto?> UpdateTaskAsync(long id, UpdateTaskDto dto, long userId)
        {
            var entity = await _context.SysTasks.FindAsync(id);
            if (entity == null) return null;

            // Check permission? Creator or Assignee can update?
            // Usually Assignee updates status, Creator updates details.
            // For simplicity, allow both if related.
            if (entity.CreatorId != userId && entity.AssigneeId != userId)
            {
                // return null or throw?
                // silently return null for now implies "not found/access denied"
                return null;
            }

            if (dto.Title != null) entity.Title = dto.Title;
            if (dto.Type != null) entity.Type = dto.Type;
            if (dto.Priority != null) entity.Priority = dto.Priority;
            if (dto.Description != null) entity.Description = dto.Description;
            if (dto.StartTime != null) entity.StartTime = dto.StartTime;
            if (dto.Deadline != null) entity.Deadline = dto.Deadline;
            
            if (dto.AssigneeId.HasValue) entity.AssigneeId = dto.AssigneeId.Value;

            if (dto.MemberIds != null)
            {
                var existingMembers = await _context.SysTaskMembers.Where(m => m.TaskId == id).ToListAsync();
                _context.SysTaskMembers.RemoveRange(existingMembers);

                foreach (var memberId in dto.MemberIds.Distinct())
                {
                     _context.SysTaskMembers.Add(new SysTaskMember
                     {
                         TaskId = id,
                         UserId = memberId,
                         JoinTime = DateTime.Now
                     });
                }
            }

            if (dto.Status != null)
            {
                entity.Status = dto.Status;
                if (dto.Status == "completed" && entity.FinishTime == null)
                {
                    entity.FinishTime = DateTime.Now;
                }
                else if (dto.Status != "completed")
                {
                    entity.FinishTime = null;
                }
            }

            await _context.SaveChangesAsync();
            return await GetTaskByIdAsync(id);
        }

        public async Task<bool> DeleteTaskAsync(long id, long userId)
        {
            var entity = await _context.SysTasks.FindAsync(id);
            if (entity == null) return false;

            if (entity.CreatorId != userId) return false; // Only creator can delete?

            _context.SysTasks.Remove(entity);
            await _context.SaveChangesAsync();
            return true;
        }

        private async Task<TaskDto?> GetTaskByIdAsync(long id)
        {
             var entity = await _context.SysTasks
                .Include(t => t.Creator)
                .Include(t => t.Assignee)
                .Include(t => t.Members).ThenInclude(m => m.User)
                .Include(t => t.Attachments)
                .FirstOrDefaultAsync(t => t.Id == id);
            return entity == null ? null : MapToDto(entity);
        }

        public async Task<List<TaskProcessDto>> GetTaskProcessesAsync(long taskId)
        {
            var processes = await _context.SysTaskProcesses
                .Include(p => p.Operator)
                .Where(p => p.TaskId == taskId)
                .OrderBy(p => p.CreateTime)
                .Select(p => new TaskProcessDto
                {
                    Id = p.Id,
                    TaskId = p.TaskId,
                    OperatorId = p.OperatorId,
                    OperatorName = p.Operator != null ? (p.Operator.Nickname ?? p.Operator.Username) : "",
                    Action = p.Action,
                    Comment = p.Comment,
                    CreateTime = p.CreateTime,
                    AttachmentIds = p.AttachmentIds
                })
                .ToListAsync();

            if (processes.Any())
            {
                var attachments = await _context.SysTaskAttachments
                    .Where(a => a.TaskId == taskId)
                    .ToListAsync();

                foreach (var p in processes)
                {
                    if (!string.IsNullOrEmpty(p.AttachmentIds))
                    {
                        var ids = p.AttachmentIds.Split(',', StringSplitOptions.RemoveEmptyEntries)
                            .Select(id => long.TryParse(id, out var l) ? l : 0)
                            .Where(id => id > 0)
                            .ToList();
                        
                        p.Attachments = attachments
                            .Where(a => ids.Contains(a.Id))
                            .Select(a => new FileDto
                            {
                                Id = a.Id,
                                Name = a.FileName,
                                Extension = a.Extension,
                                Size = a.FileSize,
                                ContentType = a.ContentType,
                                OwnerId = a.UploaderId,
                                CreatedAt = a.CreateTime,
                                UpdatedAt = a.CreateTime
                            })
                            .ToList();
                    }
                }
            }

            return processes;
        }

        public async Task<TaskProcessDto> AddTaskProcessAsync(long taskId, CreateTaskProcessDto dto, List<IFormFile> attachments, long userId)
        {
            var task = await _context.SysTasks
                .Include(t => t.Members)
                .FirstOrDefaultAsync(t => t.Id == taskId);
            
            if (task == null) throw new Exception("任务未找到");

            // Permission check: Creator, Assignee, or Member can add process
            // 权限检查：创建者、负责人或成员可以添加进展
            var isCreator = task.CreatorId == userId;
            var isAssignee = task.AssigneeId == userId;
            var isMember = task.Members.Any(m => m.UserId == userId);

            if (!isCreator && !isAssignee && !isMember)
            {
                throw new UnauthorizedAccessException("您没有权限为此任务添加进展记录。");
            }

            // Update task status if requested
            // 如果请求更新任务状态
            if (!string.IsNullOrEmpty(dto.NewStatus) && dto.NewStatus != task.Status)
            {
                // Only Creator or Assignee can change status
                // 只有创建者或负责人可以更改状态
                if (!isCreator && !isAssignee)
                {
                    throw new UnauthorizedAccessException("只有创建者或负责人可以更改任务状态。");
                }

                task.Status = dto.NewStatus;
                if (dto.NewStatus == "completed" && task.FinishTime == null)
                {
                    task.FinishTime = DateTime.Now;
                }
                else if (dto.NewStatus != "completed")
                {
                    task.FinishTime = null;
                }
            }

            var process = new SysTaskProcess
            {
                TaskId = taskId,
                OperatorId = userId,
                Action = dto.Action,
                Comment = dto.Comment,
                CreateTime = DateTime.Now,
                AttachmentIds = dto.AttachmentIds
            };

            _context.SysTaskProcesses.Add(process);
            await _context.SaveChangesAsync();

            // Handle attachments
            if (attachments != null && attachments.Any())
            {
                var webRootPath = _env.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
                var relativePath = Path.Combine("uploads", "tasks", taskId.ToString());
                var uploadPath = Path.Combine(webRootPath, relativePath);

                if (!Directory.Exists(uploadPath)) Directory.CreateDirectory(uploadPath);

                var attachmentIds = new List<long>();
                if (!string.IsNullOrEmpty(process.AttachmentIds))
                {
                     attachmentIds = process.AttachmentIds.Split(',', StringSplitOptions.RemoveEmptyEntries)
                        .Select(id => long.TryParse(id, out var l) ? l : 0)
                        .Where(id => id > 0)
                        .ToList();
                }

                foreach (var file in attachments)
                {
                    if (file.Length > 0)
                    {
                        var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
                        var uniqueName = $"{Guid.NewGuid()}{extension}";
                        var filePath = Path.Combine(uploadPath, uniqueName);

                        using (var stream = new FileStream(filePath, FileMode.Create))
                        {
                            await file.CopyToAsync(stream);
                        }

                        var attachment = new SysTaskAttachment
                        {
                            TaskId = taskId,
                            FileName = file.FileName,
                            Extension = extension,
                            FileSize = file.Length,
                            ContentType = file.ContentType,
                            FilePath = Path.Combine(relativePath, uniqueName).Replace("\\", "/"),
                            UploaderId = userId,
                            CreateTime = DateTime.Now
                        };
                        _context.SysTaskAttachments.Add(attachment);
                        await _context.SaveChangesAsync();
                        attachmentIds.Add(attachment.Id);
                    }
                }
                
                process.AttachmentIds = string.Join(",", attachmentIds);
                await _context.SaveChangesAsync();
            }
            
            // Reload to get operator name
            // 重新加载以获取操作人名称
            return await _context.SysTaskProcesses
                .Include(p => p.Operator)
                .Where(p => p.Id == process.Id)
                .Select(p => new TaskProcessDto
                {
                    Id = p.Id,
                    TaskId = p.TaskId,
                    OperatorId = p.OperatorId,
                    OperatorName = p.Operator != null ? (p.Operator.Nickname ?? p.Operator.Username) : "",
                    Action = p.Action,
                    Comment = p.Comment,
                    CreateTime = p.CreateTime,
                    AttachmentIds = p.AttachmentIds
                })
                .FirstAsync();
        }

        public async Task<FileDto> UploadTaskAttachmentAsync(long taskId, IFormFile file, long userId)
        {
            if (file == null || file.Length == 0) throw new Exception("文件为空");

            var task = await _context.SysTasks.FindAsync(taskId);
            if (task == null) throw new Exception("任务未找到");

            var webRootPath = _env.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
            var relativePath = Path.Combine("uploads", "tasks", taskId.ToString());
            var uploadPath = Path.Combine(webRootPath, relativePath);

            if (!Directory.Exists(uploadPath)) Directory.CreateDirectory(uploadPath);

            var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
            var uniqueName = $"{Guid.NewGuid()}{extension}";
            var filePath = Path.Combine(uploadPath, uniqueName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            // Create SysTaskAttachment record
            // 创建 SysTaskAttachment 记录
            var attachment = new SysTaskAttachment
            {
                TaskId = taskId,
                FileName = file.FileName,
                Extension = extension,
                FileSize = file.Length,
                ContentType = file.ContentType,
                FilePath = Path.Combine(relativePath, uniqueName).Replace("\\", "/"),
                UploaderId = userId,
                CreateTime = DateTime.Now
            };

            _context.SysTaskAttachments.Add(attachment);
            await _context.SaveChangesAsync();

            return new FileDto
            {
                Id = attachment.Id,
                Name = attachment.FileName,
                Extension = attachment.Extension,
                Size = attachment.FileSize,
                IsFolder = false,
                ContentType = attachment.ContentType,
                ParentId = null,
                OwnerId = attachment.UploaderId,
                IsPublic = false,
                CreatedAt = attachment.CreateTime,
                UpdatedAt = attachment.CreateTime
            };
        }

        public async Task<TaskAttachmentDto?> GetTaskAttachmentAsync(long attachmentId)
        {
            var attachment = await _context.SysTaskAttachments.FindAsync(attachmentId);
            if (attachment == null) return null;

            return new TaskAttachmentDto
            {
                Id = attachment.Id,
                Name = attachment.FileName,
                Extension = attachment.Extension,
                Size = attachment.FileSize,
                IsFolder = false,
                ContentType = attachment.ContentType,
                FilePath = attachment.FilePath, // Internal use only for controller to serve file
                ParentId = null,
                OwnerId = attachment.UploaderId,
                IsPublic = false,
                CreatedAt = attachment.CreateTime,
                UpdatedAt = attachment.CreateTime
            };
        }
    }
}
