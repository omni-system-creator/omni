using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Contract
{
    [Table("contract_template")]
    public class ContractTemplate
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }

        [Required]
        [MaxLength(100)]
        [Column("name")]
        public string Name { get; set; } = string.Empty;

        [Required]
        [MaxLength(20)]
        [Column("type")]
        public string Type { get; set; } = string.Empty;

        [Column("description")]
        public string? Description { get; set; }

        [Column("file_path")]
        public string? FilePath { get; set; }

        [MaxLength(100)]
        [Column("file_name")]
        public string? FileName { get; set; }

        [MaxLength(20)]
        [Column("status")]
        public string Status { get; set; } = "active";

        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.Now;

        [Column("updated_at")]
        public DateTime? UpdatedAt { get; set; }
    }
}
