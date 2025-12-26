namespace omsapi.Models.Dtos.Forms
{
    public class FormCategoryDto
    {
        public long Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public long? ParentId { get; set; }
        public int SortOrder { get; set; }
        public List<FormCategoryDto> Children { get; set; } = new List<FormCategoryDto>();
    }

    public class CreateFormCategoryDto
    {
        public string Name { get; set; } = string.Empty;
        public long? ParentId { get; set; }
        public int SortOrder { get; set; }
    }

    public class UpdateFormCategoryDto
    {
        public string Name { get; set; } = string.Empty;
        public int SortOrder { get; set; }
    }

    public class FormDefinitionDto
    {
        public long Id { get; set; }
        public long CategoryId { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Code { get; set; }
        public string? Description { get; set; }
        public string? FormItems { get; set; }
        public bool IsPublished { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }

    public class CreateFormDefinitionDto
    {
        public long CategoryId { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Code { get; set; }
        public string? Description { get; set; }
        public string? FormItems { get; set; }
    }

    public class UpdateFormDefinitionDto
    {
        public long CategoryId { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Code { get; set; }
        public string? Description { get; set; }
        public string? FormItems { get; set; }
        public bool IsPublished { get; set; }
    }
}
