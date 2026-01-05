namespace OmsApi.Models.Dtos.Kb
{
    public class KbInfoDto
    {
        public Guid Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string Category { get; set; } = "general";
        public string Type { get; set; } = "general";
        public DateTime CreatedAt { get; set; }
        public int FileCount { get; set; }
    }

    public class CreateKbDto
    {
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string Category { get; set; } = "general";
        public string Type { get; set; } = "general";
    }

    public class KbFileDto
    {
        public Guid Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Size { get; set; } = string.Empty; // Formatted size
        public string Status { get; set; } = "uploading";
        public string UploadTime { get; set; } = string.Empty;
        public string? Path { get; set; }
        public bool IsFolder { get; set; }
        public Guid? ParentId { get; set; }
    }

    public class CreateKbFolderDto
    {
        public Guid KbId { get; set; }
        public string Name { get; set; } = string.Empty;
        public Guid? ParentId { get; set; }
    }

    public class KbNodeDto
    {
        public string Key { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public string? Summary { get; set; }
        public string? Content { get; set; }
        public List<KbNodeSourceDto> Sources { get; set; } = new();
        public List<KbNodeDto> Children { get; set; } = new();
    }

    public class KbNodeSourceDto
    {
        public Guid FileId { get; set; }
        public string FileName { get; set; } = string.Empty;
        public int Page { get; set; }
    }

    public class ChatMessageDto
    {
        public string Role { get; set; } = "user"; // user, ai
        public string Content { get; set; } = string.Empty;
        public List<KbNodeSourceDto>? Sources { get; set; }
    }

    public class SendMessageDto
    {
        public Guid KbId { get; set; }
        public string Message { get; set; } = string.Empty;
        public string? Model { get; set; }
    }

    public class SiliconModelDto
    {
        public string Id { get; set; } = string.Empty;
        public string Object { get; set; } = "model";
        public long Created { get; set; }
        public string OwnedBy { get; set; } = string.Empty;
    }

    public class RenameKbFileDto
    {
        public string Name { get; set; } = string.Empty;
    }

    public class MoveKbFileDto
    {
        public Guid? TargetFolderId { get; set; }
    }
}
