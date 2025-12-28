using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Contract
{
    [Table("contract_main")]
    public class ContractMain
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }

        [Required]
        [MaxLength(50)]
        [Column("contract_no")]
        public string ContractNo { get; set; } = string.Empty;

        [Required]
        [MaxLength(200)]
        [Column("contract_name")]
        public string ContractName { get; set; } = string.Empty;

        [Required]
        [MaxLength(20)]
        [Column("type")]
        public string Type { get; set; } = string.Empty; // sales, purchase, cooperation, other

        [MaxLength(100)]
        [Column("partner_name")]
        public string PartnerName { get; set; } = string.Empty; // Customer or Supplier Name

        [Column("sign_date")]
        public DateTime? SignDate { get; set; }

        [Column("start_date")]
        public DateTime? StartDate { get; set; }

        [Column("end_date")]
        public DateTime? EndDate { get; set; }

        [MaxLength(50)]
        [Column("manager")]
        public string? Manager { get; set; }

        [Column("total_amount", TypeName = "decimal(18, 2)")]
        public decimal TotalAmount { get; set; }

        [Column("paid_amount", TypeName = "decimal(18, 2)")]
        public decimal PaidAmount { get; set; } // Received for sales, Paid for purchase

        [Column("invoiced_amount", TypeName = "decimal(18, 2)")]
        public decimal InvoicedAmount { get; set; } // Total amount invoiced

        [Column("progress")]
        public int Progress { get; set; } = 0; // Execution progress 0-100

        [MaxLength(10)]
        [Column("currency")]
        public string Currency { get; set; } = "CNY";

        [MaxLength(20)]
        [Column("payment_method")]
        public string? PaymentMethod { get; set; }

        [MaxLength(50)]
        [Column("tax_id")]
        public string? TaxId { get; set; }

        [MaxLength(20)]
        [Column("status")]
        public string Status { get; set; } = "executing"; // executing, completed, abnormal

        [Column("description")]
        public string? Description { get; set; }

        [Column("latest_transaction_date")]
        public DateTime? LatestTransactionDate { get; set; } // Collection or Payment date

        [Column("files")]
        public string? Files { get; set; } // JSON string for file attachments

        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.Now;

        [Column("updated_at")]
        public DateTime? UpdatedAt { get; set; }

        public virtual ICollection<ContractPaymentPlan> PaymentPlans { get; set; } = new List<ContractPaymentPlan>();
        public virtual ICollection<ContractPaymentRecord> PaymentRecords { get; set; } = new List<ContractPaymentRecord>();
        public virtual ICollection<ContractInvoice> Invoices { get; set; } = new List<ContractInvoice>();
        public virtual ICollection<ContractContact> Contacts { get; set; } = new List<ContractContact>();
        public virtual ICollection<ContractAttachment> Attachments { get; set; } = new List<ContractAttachment>();
    }
}
