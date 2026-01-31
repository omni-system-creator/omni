using System;
using System.ComponentModel.DataAnnotations;
using omsapi.Models.Dtos;

namespace omsapi.DTOs
{
    public class TaskDto
    {
        public long Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Type { get; set; } = "task";
        public string Priority { get; set; } = "medium";
        public string? Description { get; set; }
        public long CreatorId { get; set; }
        public string CreatorName { get; set; } = string.Empty;
        public long AssigneeId { get; set; }
        public string AssigneeName { get; set; } = string.Empty;
        public string? AssigneeAvatar { get; set; }
        public string? CreatorAvatar { get; set; }
        public DateTime CreateTime { get; set; }
        public DateTime? StartTime { get; set; }
        public DateTime? Deadline { get; set; }
        public DateTime? FinishTime { get; set; }
        public string Status { get; set; } = "pending";
        public long OrgId { get; set; }
        public List<TaskAttachmentDto> Attachments { get; set; } = new();
        public List<TaskMemberDto> Members { get; set; } = new();
    }

    public class TaskMemberDto
    {
        public long UserId { get; set; }
        public string Username { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public string? Avatar { get; set; }
        public DateTime JoinTime { get; set; }
    }

    public class CreateTaskDto
    {
        [Required]
        [MaxLength(200)]
        public string Title { get; set; } = string.Empty;

        public string Type { get; set; } = "task";
        public string Priority { get; set; } = "medium";
        public string? Description { get; set; }
        
        public long? AssigneeId { get; set; } // If null, assign to self
        public List<long>? MemberIds { get; set; }
        
        public DateTime? StartTime { get; set; }
        public DateTime? Deadline { get; set; }
    }

    public class UpdateTaskDto
    {
        public string? Title { get; set; }
        public string? Type { get; set; }
        public string? Priority { get; set; }
        public string? Description { get; set; }
        public DateTime? StartTime { get; set; }
        public DateTime? Deadline { get; set; }
        public string? Status { get; set; }
        public long? AssigneeId { get; set; }
        public List<long>? MemberIds { get; set; }
    }

    public class TaskProcessDto
    {
        public long Id { get; set; }
        public long TaskId { get; set; }
        public long OperatorId { get; set; }
        public string OperatorName { get; set; } = string.Empty;
        public string Action { get; set; } = "process";
        public string? Comment { get; set; }
        public DateTime CreateTime { get; set; }
        public string? AttachmentIds { get; set; }
        public List<FileDto> Attachments { get; set; } = new();
    }

    public class CreateTaskProcessDto
    {
        [Required]
        public string Action { get; set; } = "process";
        public string? Comment { get; set; }
        public string? AttachmentIds { get; set; }
        public string? NewStatus { get; set; }
    }

    public class TaskAttachmentDto : FileDto
    {
        public string? FilePath { get; set; }
    }
}
