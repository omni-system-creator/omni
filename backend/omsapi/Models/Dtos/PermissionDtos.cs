using System.ComponentModel.DataAnnotations;

namespace omsapi.Models.Dtos
{
    public class CreatePermissionDto
    {
        [Required]
        [MaxLength(50)]
        public string Name { get; set; } = string.Empty;

        [Required]
        [MaxLength(50)]
        public string Code { get; set; } = string.Empty;

        [Required]
        public string Type { get; set; } = "MENU"; // MENU, BUTTON

        public string? Icon { get; set; }
        public string? Path { get; set; }
        public string? Component { get; set; }
        public string? Query { get; set; }
        public long? ParentId { get; set; }
        public int SortOrder { get; set; } = 0;
        public bool IsVisible { get; set; } = true;
    }

    public class UpdatePermissionDto
    {
        [MaxLength(50)]
        public string? Name { get; set; }

        [MaxLength(50)]
        public string? Code { get; set; }

        public string? Type { get; set; }
        public string? Icon { get; set; }
        public string? Path { get; set; }
        public string? Component { get; set; }
        public string? Query { get; set; }
        public long? ParentId { get; set; }
        public int? SortOrder { get; set; }
        public bool? IsVisible { get; set; }
    }

    public class UpdatePermissionStructureDto
    {
        public long Id { get; set; }
        public long? ParentId { get; set; }
        public int SortOrder { get; set; }
    }
}
