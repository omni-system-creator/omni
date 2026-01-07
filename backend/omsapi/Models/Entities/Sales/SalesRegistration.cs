using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Sales
{
    [Table("sales_registrations")]
    public class SalesRegistration
    {
        [Key]
        public string Id { get; set; } = string.Empty;

        [Required]
        [MaxLength(200)]
        public string ProjectName { get; set; } = string.Empty;

        [Required]
        [MaxLength(200)]
        public string CustomerName { get; set; } = string.Empty;

        [MaxLength(100)]
        public string? Contact { get; set; }

        [MaxLength(50)]
        public string? Phone { get; set; }

        public decimal Amount { get; set; }

        [Required]
        public DateTime Date { get; set; }

        public string Status { get; set; } = "pending"; // pending, approved, rejected

        [MaxLength(100)]
        public string Owner { get; set; } = string.Empty;

        public string? Remarks { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.Now;

        public DateTime? UpdatedAt { get; set; } = DateTime.Now;
    }
}
