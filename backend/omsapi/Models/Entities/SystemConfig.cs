using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities
{
    [Table("sys_config")]
    public class SystemConfig
    {
        [Key]
        public long Id { get; set; }

        [Required]
        [MaxLength(50)]
        public string Category { get; set; } = string.Empty; // e.g. "Basic", "Security", "Email"

        [Required]
        [MaxLength(100)]
        public string Key { get; set; } = string.Empty; // Unique Key

        [MaxLength(500)]
        public string? Value { get; set; } // Config Value

        [MaxLength(200)]
        public string? Description { get; set; }

        public bool IsSystem { get; set; } = false; // If true, cannot be deleted

        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }
    }
}
