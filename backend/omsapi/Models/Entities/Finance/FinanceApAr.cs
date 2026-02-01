using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using omsapi.Models.Entities.Contract;
using omsapi.Models.Enums;

namespace omsapi.Models.Entities.Finance
{
    /// <summary>
    /// 应收应付账款表
    /// </summary>
    [Table("finance_apar")]
    public class FinanceApAr
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }

        [Required]
        [MaxLength(50)]
        [Column("bill_no")]
        public string BillNo { get; set; } = string.Empty;

        /// <summary>
        /// 类型：AP (应付), AR (应收) - See FinanceBillType
        /// </summary>
        [Required]
        [MaxLength(10)]
        [Column("type")]
        public string Type { get; set; } = FinanceBillType.AP;

        [Column("subject_id")]
        public long? SubjectId { get; set; }

        [ForeignKey("SubjectId")]
        public virtual FinanceSubject? Subject { get; set; }

        [Column("amount", TypeName = "decimal(18,2)")]
        public decimal Amount { get; set; }

        [Column("due_date")]
        public DateTime? DueDate { get; set; }

        [MaxLength(200)]
        [Column("partner_name")]
        public string? PartnerName { get; set; } // 往来单位名称

        [MaxLength(50)]
        [Column("partner_id")]
        public string? PartnerId { get; set; } // 往来单位ID (Customer/Supplier ID)

        /// <summary>
        /// 状态：0=Pending, 1=Approved, 2=Partial, 3=Completed, 4=Cancelled
        /// </summary>
        [Column("status")]
        public FinanceBillStatus Status { get; set; } = FinanceBillStatus.Pending;

        /// <summary>
        /// 来源类型：Contract, Manual, Other
        /// </summary>
        [MaxLength(20)]
        [Column("source_type")]
        public string SourceType { get; set; } = "Manual";

        /// <summary>
        /// 关联ID (如 ContractId)
        /// </summary>
        [Column("source_id")]
        public long? SourceId { get; set; }
        
        /// <summary>
        /// 关联子ID (如 ContractPaymentPlanId)
        /// </summary>
        [Column("source_sub_id")]
        public long? SourceSubId { get; set; }

        [MaxLength(500)]
        [Column("description")]
        public string? Description { get; set; }

        [Column("org_id")]
        public long? OrgId { get; set; }

        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.Now;

        [Column("updated_at")]
        public DateTime? UpdatedAt { get; set; }
        
        [MaxLength(50)]
        [Column("created_by")]
        public string? CreatedBy { get; set; }

        // Navigation for Contract if needed, but loose coupling is preferred usually.
        // Keeping it loose with SourceId.
    }
}
