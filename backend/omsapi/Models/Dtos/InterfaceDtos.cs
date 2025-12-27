using System.ComponentModel.DataAnnotations;

namespace omsapi.Models.Dtos
{
    public class InterfaceCategoryDto
    {
        public long Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string UrlPrefix { get; set; } = string.Empty;
        public long? ParentId { get; set; }
        public int SortOrder { get; set; }
        public List<InterfaceCategoryDto> Children { get; set; } = new List<InterfaceCategoryDto>();
        public List<InterfaceDefinitionDto> Interfaces { get; set; } = new List<InterfaceDefinitionDto>();
    }

    public class CreateInterfaceCategoryDto
    {
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(100)]
        [RegularExpression("^/.*", ErrorMessage = "URL Prefix must start with /")]
        public string UrlPrefix { get; set; } = "/";

        public long? ParentId { get; set; }
        public int SortOrder { get; set; } = 0;
    }

    public class UpdateInterfaceCategoryDto
    {
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;
        
        [MaxLength(100)]
        [RegularExpression("^/.*", ErrorMessage = "URL Prefix must start with /")]
        public string UrlPrefix { get; set; } = "/";

        public long? ParentId { get; set; }

        public int SortOrder { get; set; }
    }

    public class InterfaceDefinitionDto
    {
        public long Id { get; set; }
        public long CategoryId { get; set; }
        public string CategoryName { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public string Path { get; set; } = string.Empty;
        public string FullPath { get; set; } = string.Empty;
        public string Method { get; set; } = string.Empty;
        public string? Description { get; set; }
        public List<long> ViewRoles { get; set; } = new List<long>();
        public List<long> CallRoles { get; set; } = new List<long>();
        public List<long> ManageRoles { get; set; } = new List<long>();
        public string? FlowConfig { get; set; }
        public bool IsPublished { get; set; }
        public bool RequiresAuth { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public long? CreatedBy { get; set; }
        public long? UpdatedBy { get; set; }
    }

    public class CreateInterfaceDto
    {
        [Required]
        public long CategoryId { get; set; }

        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        [Required]
        [MaxLength(200)]
        public string Path { get; set; } = string.Empty;

        [Required]
        [MaxLength(10)]
        public string Method { get; set; } = "GET";

        public string? Description { get; set; }
        
        public bool RequiresAuth { get; set; } = true;

        public List<long>? ViewRoles { get; set; }
        public List<long>? ManageRoles { get; set; }
    }

    public class UpdateInterfaceDto
    {
        public long? CategoryId { get; set; }

        [MaxLength(100)]
        public string? Name { get; set; }

        [MaxLength(200)]
        public string? Path { get; set; }

        [MaxLength(10)]
        public string? Method { get; set; }

        public string? Description { get; set; }
        
        public string? FlowConfig { get; set; }
        
        public bool? IsPublished { get; set; }
        
        public bool? RequiresAuth { get; set; }

        public List<long>? ViewRoles { get; set; }
        public List<long>? CallRoles { get; set; }
        public List<long>? ManageRoles { get; set; }
    }
}
