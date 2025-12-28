using System.ComponentModel.DataAnnotations;

namespace omsapi.Models.Dtos
{
    public class PageCategoryDto
    {
        public long Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public long? ParentId { get; set; }
        public int SortOrder { get; set; }
        public List<PageCategoryDto> Children { get; set; } = new List<PageCategoryDto>();
    }

    public class CreatePageCategoryDto
    {
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;
        public long? ParentId { get; set; }
        public int SortOrder { get; set; }
    }

    public class UpdatePageCategoryDto
    {
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;
        public long? ParentId { get; set; }
        public int SortOrder { get; set; }
    }

    public class PageDefinitionDto
    {
        public long Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public long? CategoryId { get; set; }
        public string? Code { get; set; }
        public string? Config { get; set; }
        public string? ApiBindings { get; set; }
        public string? Description { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }

    public class CreatePageDefinitionDto
    {
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;
        public long? CategoryId { get; set; }
        public string? Code { get; set; }
        public string? Config { get; set; }
        public string? ApiBindings { get; set; }
        [MaxLength(500)]
        public string? Description { get; set; }
    }

    public class UpdatePageDefinitionDto
    {
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;
        public long? CategoryId { get; set; }
        public string? Code { get; set; }
        public string? Config { get; set; }
        public string? ApiBindings { get; set; }
        [MaxLength(500)]
        public string? Description { get; set; }
    }
}
