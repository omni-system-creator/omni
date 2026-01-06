namespace omsapi.Models.Dtos.Sales
{
    public class SalesTargetDto
    {
        public string Id { get; set; } = string.Empty;
        public string Period { get; set; } = string.Empty;
        public string TargetType { get; set; } = string.Empty;
        public string TargetId { get; set; } = string.Empty;
        public string TargetName { get; set; } = string.Empty;
        public decimal TargetAmount { get; set; }
        public decimal CompletedAmount { get; set; }
        public decimal ProgressRate => TargetAmount > 0 ? Math.Round((CompletedAmount / TargetAmount) * 100, 1) : 0;
        public string Status { get; set; } = string.Empty;
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public List<SalesTargetDto> Children { get; set; } = new();
    }

    public class SalesTargetOverviewDto
    {
        public decimal TotalTarget { get; set; }
        public decimal CompletedAmount { get; set; }
        public decimal ProgressRate { get; set; }
        public int RemainingDays { get; set; }
        public string Deadline { get; set; } = string.Empty;
    }

    public class SalesTargetResultDto
    {
        public SalesTargetOverviewDto Overview { get; set; } = new();
        public List<SalesTargetDto> Items { get; set; } = new();
        public int Total { get; set; }
    }

    public class SalesTargetSearchParams
    {
        public string? Period { get; set; }
        public string? Group { get; set; }
        public string? Product { get; set; }
        public string? Region { get; set; }
        public string? Industry { get; set; }
        public int Page { get; set; } = 1;
        public int PageSize { get; set; } = 10;
    }
}
