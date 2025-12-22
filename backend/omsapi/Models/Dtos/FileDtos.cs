using System.ComponentModel.DataAnnotations;

namespace omsapi.Models.Dtos
{
    public class FileDto
    {
        public long Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Extension { get; set; }
        public long Size { get; set; }
        public bool IsFolder { get; set; }
        public string? ContentType { get; set; }
        public long? ParentId { get; set; }
        public long OwnerId { get; set; }
        public string? OwnerName { get; set; }
        public long? DeptId { get; set; }
        public string? DeptName { get; set; }
        public bool IsPublic { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public bool HasChildren { get; set; }
    }

    public class CreateFolderDto
    {
        [Required]
        [MaxLength(255)]
        public string Name { get; set; } = string.Empty;

        public long? ParentId { get; set; }
        public long? DeptId { get; set; }
        public bool IsPublic { get; set; }
    }

    public class RenameFileDto
    {
        [Required]
        [MaxLength(255)]
        public string Name { get; set; } = string.Empty;
    }
    
    public class UpdateFileDto
    {
        [MaxLength(255)]
        public string? Name { get; set; }
        public long? ParentId { get; set; }
        public bool? IsPublic { get; set; }
    }

    public class FileQueryDto
    {
        public long? ParentId { get; set; }
        public long? OwnerId { get; set; } // If null, return current user's files
        public long? DeptId { get; set; } // If set, return dept files
        public string? Name { get; set; } // Search by name
        public bool? IsFolder { get; set; }
        public bool? IsPublic { get; set; }
    }

    public class ShareFileDto
    {
        [Required]
        public long FileId { get; set; }
        
        public List<long>? TargetUserIds { get; set; }
        
        public string Permission { get; set; } = "read";

        public bool IsPublicLink { get; set; }
        public DateTime? ExpirationTime { get; set; }
    }

    public class FileShareDto
    {
        public long Id { get; set; }
        public long FileId { get; set; }
        public string FileName { get; set; } = string.Empty;
        public bool IsFolder { get; set; }
        public long SharedByUserId { get; set; }
        public string SharedByUserName { get; set; } = string.Empty;
        public long? SharedToUserId { get; set; }
        public string? SharedToUserName { get; set; }
        public string Permission { get; set; } = "read";
        public DateTime CreatedAt { get; set; }
        public string? Token { get; set; }
        public DateTime? ExpirationTime { get; set; }
    }
}
