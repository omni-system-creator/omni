namespace omsapi.Models.Dtos.Sales
{
    public class SalesOpportunityDto
    {
        public string Id { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public string Customer { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public string Stage { get; set; } = string.Empty;
        public string Owner { get; set; } = string.Empty;
        public DateTime? Date { get; set; } // Maps to EstimatedCloseDate
        public DateTime CreatedAt { get; set; }
    }

    public class CreateOpportunityDto
    {
        public string Title { get; set; } = string.Empty;
        public string Customer { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public string Stage { get; set; } = string.Empty;
        public string Owner { get; set; } = string.Empty;
        public DateTime? Date { get; set; }
    }

    public class UpdateOpportunityDto : CreateOpportunityDto { }
}
