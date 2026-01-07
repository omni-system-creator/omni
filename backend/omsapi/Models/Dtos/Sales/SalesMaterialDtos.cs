namespace omsapi.Models.Dtos.Sales
{
    public class SalesScriptDto
    {
        public string Id { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public string Content { get; set; } = string.Empty;
        public string Category { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
    }

    public class CreateSalesScriptDto
    {
        public string Title { get; set; } = string.Empty;
        public string Content { get; set; } = string.Empty;
        public string Category { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
    }

    public class UpdateSalesScriptDto
    {
        public string Title { get; set; } = string.Empty;
        public string Content { get; set; } = string.Empty;
        public string Category { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
    }

    public class ProductDocDto
    {
        public string Id { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public string Size { get; set; } = string.Empty;
        public string Url { get; set; } = string.Empty;
        public string Type { get; set; } = "file";
        public string? ParentId { get; set; }
        public DateTime UploadDate { get; set; }
        public List<ProductDocDto> Children { get; set; } = new();
    }

    public class CreateProductDocDto
    {
        public string Title { get; set; } = string.Empty;
        public string? ParentId { get; set; }
        public string Type { get; set; } = "file";
        // For file upload, usually handled separately, but here simplified
        public string Size { get; set; } = "";
        public string Url { get; set; } = "";
    }

    public class ProcessRuleDto
    {
        public string Id { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public string Content { get; set; } = string.Empty;
    }

    public class SalesScriptChatDto
    {
        public string Message { get; set; } = string.Empty;
        public string ScriptId { get; set; } = string.Empty;
        public string UserRole { get; set; } = "salesman";
        public string Model { get; set; } = "";
    }

    public class SalesScriptChatResponseDto
    {
        public string Content { get; set; } = string.Empty;
        public string Role { get; set; } = "customer";
    }

    public class GenerateScriptFieldRequest
    {
        public string TargetField { get; set; } = string.Empty; // "title", "description", "content"
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string Content { get; set; } = string.Empty;
        public string Model { get; set; } = "";
    }
}
