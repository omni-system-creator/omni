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

    public class ProductDocDto
    {
        public string Id { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public string Size { get; set; } = string.Empty;
        public string Url { get; set; } = string.Empty;
        public DateTime UploadDate { get; set; }
    }

    public class ProcessRuleDto
    {
        public string Id { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public string Content { get; set; } = string.Empty;
    }
}
