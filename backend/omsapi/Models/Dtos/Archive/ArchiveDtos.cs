using System.ComponentModel.DataAnnotations;

namespace omsapi.Models.Dtos.Archive
{
    public class ArchFondDto
    {
        public long Id { get; set; }
        public string Code { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public int SortOrder { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    public class CreateFondDto
    {
        [Required]
        [MaxLength(50)]
        public string Code { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;
        
        public string? Description { get; set; }
        public int SortOrder { get; set; }
    }

    public class UpdateFondDto
    {
        [MaxLength(50)]
        public string? Code { get; set; }
        
        [MaxLength(100)]
        public string? Name { get; set; }
        
        public string? Description { get; set; }
        public int? SortOrder { get; set; }
    }

    public class ArchTypeDto
    {
        public long Id { get; set; }
        public long? ParentId { get; set; }
        public string Code { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public int SortOrder { get; set; }
        public List<ArchTypeDto>? Children { get; set; }
    }

    public class CreateArchTypeDto
    {
        public long? ParentId { get; set; }
        
        [Required]
        [MaxLength(50)]
        public string Code { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;
        
        public int SortOrder { get; set; }
    }

    public class UpdateArchTypeDto
    {
        public long? ParentId { get; set; }
        
        [MaxLength(50)]
        public string? Code { get; set; }
        
        [MaxLength(100)]
        public string? Name { get; set; }
        
        public int? SortOrder { get; set; }
    }

    public class ArchFileDto
    {
        public long Id { get; set; }
        public long FondId { get; set; }
        public string FondName { get; set; } = string.Empty;
        public long TypeId { get; set; }
        public string TypeName { get; set; } = string.Empty;
        public long? BoxId { get; set; }
        public string? BoxCode { get; set; }
        public string ArchCode { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public string? DocNumber { get; set; }
        public string? Author { get; set; }
        public DateTime? FileDate { get; set; }
        public string? Year { get; set; }
        public string? RetentionPeriod { get; set; }
        public string? SecurityLevel { get; set; }
        public int PageCount { get; set; }
        public int Status { get; set; }
        public string? Keywords { get; set; }
        public string? Remark { get; set; }
        public long? SourceFileId { get; set; }
        public DateTime CreatedAt { get; set; }
        public List<ArchAttachmentDto> Attachments { get; set; } = new();
    }

    public class CreateArchFileDto
    {
        public long FondId { get; set; }
        public long TypeId { get; set; }
        public long? BoxId { get; set; }
        
        [Required]
        [MaxLength(100)]
        public string ArchCode { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(500)]
        public string Title { get; set; } = string.Empty;
        
        public string? DocNumber { get; set; }
        public string? Author { get; set; }
        public DateTime? FileDate { get; set; }
        public string? Year { get; set; }
        public string? RetentionPeriod { get; set; }
        public string? SecurityLevel { get; set; }
        public int PageCount { get; set; }
        public string? Keywords { get; set; }
        public string? Remark { get; set; }
        public long? SourceFileId { get; set; }
    }

    public class UpdateArchFileDto
    {
        public long? FondId { get; set; }
        public long? TypeId { get; set; }
        public long? BoxId { get; set; }
        public string? ArchCode { get; set; }
        public string? Title { get; set; }
        public string? DocNumber { get; set; }
        public string? Author { get; set; }
        public DateTime? FileDate { get; set; }
        public string? Year { get; set; }
        public string? RetentionPeriod { get; set; }
        public string? SecurityLevel { get; set; }
        public int? PageCount { get; set; }
        public string? Keywords { get; set; }
        public string? Remark { get; set; }
    }

    public class ArchAttachmentDto
    {
        public long Id { get; set; }
        public string FileName { get; set; } = string.Empty;
        public string? Extension { get; set; }
        public long Size { get; set; }
        public string? FilePath { get; set; }
        public long? FileId { get; set; }
    }

    public class ArchQueryDto
    {
        public long? FondId { get; set; }
        public long? TypeId { get; set; }
        public long? BoxId { get; set; }
        public string? Title { get; set; }
        public string? ArchCode { get; set; }
        public string? Year { get; set; }
        public string? RetentionPeriod { get; set; }
        public string? SecurityLevel { get; set; }
        public string? Keyword { get; set; }
        public int Page { get; set; } = 1;
        public int PageSize { get; set; } = 20;
    }
}