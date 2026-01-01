using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace omsapi.Models.Entities.Contract
{
    [Table("contract_payment_plan")]
    public class ContractPaymentPlan
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
        [Column("phase")]
        public string Phase { get; set; } = string.Empty; // e.g. "Phase 1"

        [Column("due_date")]
        public DateTime? DueDate { get; set; }

        [Column("amount", TypeName = "decimal(18, 2)")]
        public decimal Amount { get; set; }

        [MaxLength(200)]
        [Column("condition")]
        public string? Condition { get; set; }

        [MaxLength(20)]
        [Column("status")]
        public string Status { get; set; } = "pending"; // pending, paid
    }
}
