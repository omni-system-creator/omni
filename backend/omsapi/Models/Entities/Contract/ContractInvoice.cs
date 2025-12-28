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
        public virtual ContractMain Contract { get; set; }

        [Required]
        [MaxLength(50)]
        [Column("invoice_no")]
        public string InvoiceNo { get; set; } = string.Empty;

        [Column("invoice_date")]
        public DateTime InvoiceDate { get; set; }

        [Column("amount", TypeName = "decimal(18, 2)")]
        public decimal Amount { get; set; }

        [MaxLength(50)]
        [Column("type")]
        public string? Type { get; set; } // VAT Special Invoice, etc.

        [MaxLength(20)]
        [Column("status")]
        public string Status { get; set; } = "issued"; // issued, cancelled
    }
}
