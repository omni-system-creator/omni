namespace omsapi.Models.Dtos.System
{
    // --- Category ---
    public class DictCategoryDto
    {
        public long Id { get; set; }
        public long? ParentId { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Code { get; set; } = string.Empty;
        public int Sort { get; set; }
        public string? Remark { get; set; }
        public DateTime CreatedAt { get; set; }
        public List<DictCategoryDto> Children { get; set; } = new List<DictCategoryDto>();
    }

    public class CreateDictCategoryDto
    {
        public long? ParentId { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Code { get; set; } = string.Empty;
        public int Sort { get; set; }
        public string? Remark { get; set; }
    }

    public class UpdateDictCategoryDto
    {
        public string Name { get; set; } = string.Empty;
        public string Code { get; set; } = string.Empty;
        public int Sort { get; set; }
        public string? Remark { get; set; }
    }

    // --- Type ---
    public class DictTypeDto
    {
        public long Id { get; set; }
        public long? CategoryId { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Code { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;
        public string? Remark { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    public class CreateDictTypeDto
    {
        public long? CategoryId { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Code { get; set; } = string.Empty;
        public string Status { get; set; } = "normal";
        public string? Remark { get; set; }
    }

    public class UpdateDictTypeDto
    {
        public long? CategoryId { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Code { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;
        public string? Remark { get; set; }
    }

    // --- Data ---
    public class DictDataDto
    {
        public long Id { get; set; }
        public long DictTypeId { get; set; }
        public string Label { get; set; } = string.Empty;
        public string Value { get; set; } = string.Empty;
        public int Sort { get; set; }
        public string Status { get; set; } = string.Empty;
        public bool IsDefault { get; set; }
        public string? CssClass { get; set; }
        public string? ListClass { get; set; }
        public string? Remark { get; set; }
    }

    public class CreateDictDataDto
    {
        public long DictTypeId { get; set; }
        public string Label { get; set; } = string.Empty;
        public string Value { get; set; } = string.Empty;
        public int Sort { get; set; }
        public string Status { get; set; } = "normal";
        public bool IsDefault { get; set; }
        public string? CssClass { get; set; }
        public string? ListClass { get; set; }
        public string? Remark { get; set; }
    }

    public class UpdateDictDataDto
    {
        public string Label { get; set; } = string.Empty;
        public string Value { get; set; } = string.Empty;
        public int Sort { get; set; }
        public string Status { get; set; } = string.Empty;
        public bool IsDefault { get; set; }
        public string? CssClass { get; set; }
        public string? ListClass { get; set; }
        public string? Remark { get; set; }
    }
}
