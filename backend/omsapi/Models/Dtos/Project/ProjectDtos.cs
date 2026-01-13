namespace omsapi.Models.Dtos.Project
{
    public class ProjectFullDto
    {
        public ProjectInfoDto? ProjectInfo { get; set; }
        public List<PhaseDto> Phases { get; set; } = new();
        public List<SwimlaneDto> Swimlanes { get; set; } = new();
        public List<TaskDto> Tasks { get; set; } = new();
    }

    public class ProjectInfoDto
    {
        public string Code { get; set; } = null!;
        public string? Name { get; set; }
        public string? Type { get; set; }
        public string? Description { get; set; }
        public string? Manager { get; set; }
        public List<ProjectMemberDto>? Members { get; set; }
        public DateTime? PlannedStartDate { get; set; }
        public DateTime? PlannedEndDate { get; set; }
    }

    public class ProjectMemberDto
    {
        public string Username { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public string Organization { get; set; } = string.Empty;
        public string Role { get; set; } = "Member"; // Manager, Member, Viewer
    }

    public class PhaseDto
    {
        public string Id { get; set; } = null!;
        public string? Name { get; set; }
        public string? Color { get; set; }
    }

    public class SwimlaneDto
    {
        public string Id { get; set; } = null!;
        public string? Name { get; set; }
        public string? Color { get; set; }
    }

    public class TaskDto
    {
        public string Id { get; set; } = null!;
        public string? Name { get; set; }
        public string? PhaseId { get; set; }
        public string? SwimlaneId { get; set; }
        public string? Status { get; set; }
        public int Progress { get; set; }
        public string? Owner { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public string? Type { get; set; }
        public string? Description { get; set; }
        public float X { get; set; }
        public float Y { get; set; }
        public float Width { get; set; }

        public string? StartColor { get; set; }
        public string? EndColor { get; set; }
        
        public List<TaskDependencyDto> Dependencies { get; set; } = new();
        public List<AttachmentDto> Attachments { get; set; } = new();
    }

    public class TaskDependencyDto
    {
        public string TaskId { get; set; } = null!; // The ID of the dependency task
        public string? Type { get; set; }
        public string? SourcePort { get; set; }
        public string? TargetPort { get; set; }
        public string? ControlPoints { get; set; }
        public int? ControlPointCount { get; set; }
    }

    public class AttachmentDto
    {
        public string Id { get; set; } = null!;
        public string? Name { get; set; }
        public string? Url { get; set; }
        public string? Type { get; set; }
        public DateTime? UploadDate { get; set; }
    }
}