namespace omsapi.Models.Dtos
{
    public class PostDto
    {
        public long Id { get; set; }
        public string Code { get; set; } = string.Empty;
        public string FullCode { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public int SortOrder { get; set; }
        public bool IsActive { get; set; }
        public string? Remark { get; set; }
        public long? DeptId { get; set; }
        public string? DeptName { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    public class CreatePostDto
    {
        public string Code { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public int SortOrder { get; set; }
        public bool IsActive { get; set; } = true;
        public string? Remark { get; set; }
        public long? DeptId { get; set; }
    }

    public class UpdatePostDto
    {
        public string? Code { get; set; }
        public string? Name { get; set; }
        public int? SortOrder { get; set; }
        public bool? IsActive { get; set; }
        public string? Remark { get; set; }
        public long? DeptId { get; set; }
    }
}
