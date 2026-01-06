using System.ComponentModel.DataAnnotations;
using omsapi.Models.Enums;

namespace omsapi.Models.Dtos
{
    public class CreateDeptDto
    {
        public long? ParentId { get; set; }

        [Required]
        [MaxLength(50)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(50)]
        public string? Code { get; set; }

        public DeptType Type { get; set; } = DeptType.Department;

        [MaxLength(50)]
        public string? Leader { get; set; }

        [MaxLength(20)]
        public string? Phone { get; set; }

        [MaxLength(100)]
        public string? Email { get; set; }

        public int SortOrder { get; set; } = 0;
        public bool IsActive { get; set; } = true;

        public double? X { get; set; }
        public double? Y { get; set; }
    }

    public class UpdateDeptDto
    {
        public long? ParentId { get; set; }

        [MaxLength(50)]
        public string? Name { get; set; }

        [MaxLength(50)]
        public string? Code { get; set; }

        public DeptType? Type { get; set; }

        [MaxLength(50)]
        public string? Leader { get; set; }

        [MaxLength(20)]
        public string? Phone { get; set; }

        [MaxLength(100)]
        public string? Email { get; set; }

        public int? SortOrder { get; set; }
        public bool? IsActive { get; set; }

        public double? X { get; set; }
        public double? Y { get; set; }

        /// <summary>
        /// Set to true to clear X/Y coordinates (auto layout)
        /// </summary>
        public bool? ResetPosition { get; set; }
    }

    public class DeptDto
    {
        public long Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Code { get; set; }
        public string? FullCode { get; set; }
        public DeptType Type { get; set; }
        public long? ParentId { get; set; }
        public int SortOrder { get; set; }
        public bool IsActive { get; set; }
        public double? X { get; set; }
        public double? Y { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    public class DeptTreeDto
    {
        public long Id { get; set; }
        public long? ParentId { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Code { get; set; }
        public string? FullCode { get; set; }
        public DeptType Type { get; set; }
        public string? Leader { get; set; }
        public string? Phone { get; set; }
        public string? Email { get; set; }
        public int SortOrder { get; set; }
        public bool IsActive { get; set; }
        public double? X { get; set; }
        public double? Y { get; set; }
        public DateTime CreatedAt { get; set; }
        public List<DeptTreeDto>? Children { get; set; }
    }

    public class UpdateDeptStructureDto
    {
        public long Id { get; set; }
        public long? ParentId { get; set; }
        public int SortOrder { get; set; }
    }
}
