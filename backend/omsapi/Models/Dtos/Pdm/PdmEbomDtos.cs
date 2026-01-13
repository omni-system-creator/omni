namespace omsapi.Models.Dtos.Pdm
{
    public class EbomItemDto
    {
        public string Key { get; set; } = string.Empty; // Id
        public string Title { get; set; } = string.Empty; // Name
        public string Spec { get; set; } = string.Empty;
        public decimal Qty { get; set; }
        public string Unit { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;
        public string ProductType { get; set; } = string.Empty;
        public string Version { get; set; } = string.Empty;
        public string Designer { get; set; } = string.Empty;
        public List<EbomDocumentDto> RelatedDocuments { get; set; } = new List<EbomDocumentDto>();
        public bool IsLeaf { get; set; }
        public List<EbomItemDto> Children { get; set; } = new List<EbomItemDto>();
    }

    public class EbomDetailDto
    {
        public string Key { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public string Version { get; set; } = string.Empty;
        public string Designer { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;
        public string ProductType { get; set; } = string.Empty;
        public string Spec { get; set; } = string.Empty;
        public string Unit { get; set; } = string.Empty;
        public List<EbomDocumentDto> RelatedDocuments { get; set; } = new List<EbomDocumentDto>();
    }

    public class CreateEbomItemDto
    {
        public string Key { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public string Spec { get; set; } = "Standard";
        public string Unit { get; set; } = "PCS";
        public string ProductType { get; set; } = string.Empty;
        public string Version { get; set; } = "V1.0";
        public string Designer { get; set; } = "工程师A";
        public List<EbomDocumentDto> RelatedDocuments { get; set; } = new List<EbomDocumentDto>();
        public string ParentId { get; set; } = string.Empty;
        public decimal Qty { get; set; } = 1;
        public bool IsLeaf { get; set; } = true;
    }

    public class AddChildItemDto
    {
        public string ParentId { get; set; } = string.Empty;
        public string ChildId { get; set; } = string.Empty;
        public decimal Qty { get; set; } = 1;
    }

    public class UpdateChildItemQtyDto
    {
        public decimal Qty { get; set; }
    }

    public class UpdateEbomItemDto
    {
        public string Title { get; set; } = string.Empty;
        public string Spec { get; set; } = string.Empty;
        public string Unit { get; set; } = string.Empty;
        public string ProductType { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;
        public string Version { get; set; } = string.Empty;
        public string Designer { get; set; } = string.Empty;
        public List<EbomDocumentDto> RelatedDocuments { get; set; } = new List<EbomDocumentDto>();
    }

    public class EbomDocumentDto
    {
        public long Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Path { get; set; } = string.Empty;
        public string FileType { get; set; } = string.Empty;
        public long Size { get; set; }
        public DateTime UploadedAt { get; set; }
    }
}
