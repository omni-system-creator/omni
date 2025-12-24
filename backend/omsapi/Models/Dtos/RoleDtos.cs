using System.ComponentModel.DataAnnotations;

namespace omsapi.Models.Dtos
{
    public class RoleDto
    {
        public long Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Code { get; set; } = string.Empty;
        public string? Description { get; set; }
        public bool IsSystem { get; set; }
        public DateTime CreatedAt { get; set; }
        public long? DeptId { get; set; }
        public List<long> ChildRoleIds { get; set; } = new();
    }

    public class CreateRoleDto
    {
        [Required]
        [MaxLength(50)]
        public string Name { get; set; } = string.Empty;

        [Required]
        [MaxLength(50)]
        public string Code { get; set; } = string.Empty;

        [MaxLength(200)]
        public string? Description { get; set; }

        public long? DeptId { get; set; }
        public List<long> ChildRoleIds { get; set; } = new();
    }

    public class UpdateRoleDto
    {
        [MaxLength(50)]
        public string? Name { get; set; }

        [MaxLength(200)]
        public string? Description { get; set; }

        public long? DeptId { get; set; }
        public List<long> ChildRoleIds { get; set; } = new();
    }

    public class AssignPermissionDto
    {
        public List<long> PermissionIds { get; set; } = new();
    }

    public class PermissionTreeDto
    {
        public long Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Code { get; set; } = string.Empty;
        public string Type { get; set; } = string.Empty; // MENU, BUTTON
        public string? Icon { get; set; }
        public string? Path { get; set; }
        public string? Component { get; set; }
        public string? Query { get; set; }
        public int SortOrder { get; set; }
        public bool IsVisible { get; set; }
        public long? ParentId { get; set; }
        public List<PermissionTreeDto>? Children { get; set; }
    }
}
