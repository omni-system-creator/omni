using System.ComponentModel.DataAnnotations;

namespace omsapi.Models.Dtos.Sales
{
    public class SalesBidProjectDto
    {
        public string Id { get; set; } = string.Empty;
        public string Code { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public string? Customer { get; set; }
        public string? Region { get; set; }
        public string? Type { get; set; }
        public string? Budget { get; set; }
        public DateTime? BidTime { get; set; }
        public string? Leader { get; set; }
        public string Status { get; set; } = string.Empty;
        public string? Description { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }

    public class CreateSalesBidProjectDto
    {
        [Required]
        public string Code { get; set; } = string.Empty;

        [Required]
        public string Name { get; set; } = string.Empty;

        public string? Customer { get; set; }
        public string? Region { get; set; }
        public string? Type { get; set; }
        public string? Budget { get; set; }
        public DateTime? BidTime { get; set; }
        public string? Leader { get; set; }
        public string Status { get; set; } = "进行中";
        public string? Description { get; set; }
    }

    public class UpdateSalesBidProjectDto
    {
        public string? Name { get; set; }
        public string? Customer { get; set; }
        public string? Region { get; set; }
        public string? Type { get; set; }
        public string? Budget { get; set; }
        public DateTime? BidTime { get; set; }
        public string? Leader { get; set; }
        public string? Status { get; set; }
        public string? Description { get; set; }
    }
}
