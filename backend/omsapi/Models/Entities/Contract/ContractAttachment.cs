using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace omsapi.Models.Entities.Contract
{
    [Table("contract_attachment")]
    public class ContractAttachment
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }

        [Column("contract_id")]
        public long ContractId { get; set; }

        [JsonIgnore]
        [ForeignKey("ContractId")]
        public virtual ContractMain Contract { get; set; } = null!;

        [Required]
        [MaxLength(200)]
        [Column("file_name")]
        public string FileName { get; set; } = string.Empty;

        [MaxLength(500)]
        [Column("file_path")]
        public string? FilePath { get; set; }

        [MaxLength(20)]
        [Column("size")]
        public string? Size { get; set; }

        [Column("upload_date")]
        public DateTime UploadDate { get; set; } = DateTime.Now;
    }
}
