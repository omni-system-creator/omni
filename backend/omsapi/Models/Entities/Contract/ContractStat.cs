using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Contract
{
    // 合同统计数据（按月、季、年）
    [Table("contract_stat")]
    public class ContractStat
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }

        [Required]
        [MaxLength(20)]
        [Column("period_type")]
        public string PeriodType { get; set; } = "Month"; // Month, Quarter, Year

        [Required]
        [MaxLength(20)]
        [Column("period_key")]
        public string PeriodKey { get; set; } = string.Empty; // 2023-10, 2023-Q3, 2023

        [Required]
        [Column("stat_date")]
        public DateTime StatDate { get; set; } // 统计周期的起始日期，用于排序

        [Column("total_contracts")]
        public int TotalContracts { get; set; }

        [Column("total_contracts_growth", TypeName = "decimal(5, 2)")]
        public decimal TotalContractsGrowth { get; set; } // 同比增长率 %

        [Column("amount_completion_rate", TypeName = "decimal(5, 2)")]
        public decimal AmountCompletionRate { get; set; } // 金额完成率 %

        [Column("received_rate", TypeName = "decimal(5, 2)")]
        public decimal ReceivedRate { get; set; } // 回款率 %

        [Column("total_amount", TypeName = "decimal(18, 2)")]
        public decimal TotalAmount { get; set; }

        [Column("received_amount", TypeName = "decimal(18, 2)")]
        public decimal ReceivedAmount { get; set; } // 回款金额

        [Column("invoiced_amount", TypeName = "decimal(18, 2)")]
        public decimal InvoicedAmount { get; set; } // 已开票金额

        [Column("pending_invoice_amount", TypeName = "decimal(18, 2)")]
        public decimal PendingInvoiceAmount { get; set; } // 待开票金额

        [Column("sales_count")]
        public int SalesCount { get; set; }

        [Column("purchase_count")]
        public int PurchaseCount { get; set; }

        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
}
