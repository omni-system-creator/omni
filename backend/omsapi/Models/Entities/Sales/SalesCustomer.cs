using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Sales
{
    [Table("sales_customer")]
    public class SalesCustomer
    {
        [Key]
        [Column("id")]
        public string Id { get; set; } = Guid.NewGuid().ToString("N");

        [Column("name")]
        [Required]
        [MaxLength(200)]
        public string Name { get; set; } = string.Empty;

        [Column("industry")]
        [MaxLength(100)]
        public string Industry { get; set; } = string.Empty;

        [Column("contact")]
        [MaxLength(100)]
        public string Contact { get; set; } = string.Empty;

        [Column("phone")]
        [MaxLength(50)]
        public string Phone { get; set; } = string.Empty;

        [Column("email")]
        [MaxLength(100)]
        public string Email { get; set; } = string.Empty;

        [Column("level")]
        [MaxLength(50)]
        public string Level { get; set; } = string.Empty; // A, B, C

        [Column("status")]
        [MaxLength(50)]
        public string Status { get; set; } = string.Empty; // active, potential, lost

        [Column("address")]
        [MaxLength(200)]
        public string Address { get; set; } = string.Empty;

        [Column("source")]
        [MaxLength(50)]
        public string Source { get; set; } = string.Empty;

        [Column("description")]
        public string Description { get; set; } = string.Empty;

        [Column("owner")]
        [MaxLength(100)]
        public string Owner { get; set; } = string.Empty;

        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.Now;

        [Column("updated_at")]
        public DateTime? UpdatedAt { get; set; }
    }
}
