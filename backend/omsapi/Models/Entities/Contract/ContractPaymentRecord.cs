using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace omsapi.Models.Entities.Contract
{
    [Table("contract_payment_record")]
    public class ContractPaymentRecord
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }

        [Column("contract_id")]
        public long ContractId { get; set; }

        [JsonIgnore]
        [ForeignKey("ContractId")]
        public virtual ContractMain Contract { get; set; } = null!;

        [Column("payment_date")]
        public DateTime PaymentDate { get; set; }

        [Column("amount", TypeName = "decimal(18, 2)")]
        public decimal Amount { get; set; }

        [MaxLength(20)]
        [Column("type")]
        public string? Type { get; set; } // collection, payment

        [MaxLength(50)]
        [Column("method")]
        public string? Method { get; set; } // Bank Transfer, Check, etc.

        [MaxLength(50)]
        [Column("operator")]
        public string? Operator { get; set; }

        [Column("remark")]
        public string? Remark { get; set; }

        [MaxLength(255)]
        [Column("voucher_file_path")]
        public string? VoucherFilePath { get; set; }

        [MaxLength(255)]
        [Column("voucher_file_name")]
        public string? VoucherFileName { get; set; }
    }
}
