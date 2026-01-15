using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace omsapi.Models.Entities.Contract
{
    [Table("contract_invoice")]
    public class ContractInvoice
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
        [MaxLength(50)]
        [Column("invoice_no")]
        public string InvoiceNo { get; set; } = string.Empty;

        [Column("invoice_date")]
        public DateTime InvoiceDate { get; set; }

        [Column("amount", TypeName = "decimal(18, 2)")]
        public decimal Amount { get; set; }

        [MaxLength(20)]
        [Column("direction")]
        public string Direction { get; set; } = "output";

        [MaxLength(50)]
        [Column("type")]
        public string? Type { get; set; }

        [MaxLength(20)]
        [Column("status")]
        public string Status { get; set; } = "issued";

        [MaxLength(255)]
        [Column("attachment_file_path")]
        public string? AttachmentFilePath { get; set; }

        [MaxLength(255)]
        [Column("attachment_file_name")]
        public string? AttachmentFileName { get; set; }
    }
}
