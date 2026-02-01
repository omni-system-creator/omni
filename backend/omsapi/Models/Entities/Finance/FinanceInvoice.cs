using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Finance
{
    /// <summary>
    /// 发票管理表
    /// </summary>
    [Table("finance_invoice")]
    public class FinanceInvoice
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }

        /// <summary>
        /// 发票号码
        /// </summary>
        [Required]
        [MaxLength(50)]
        [Column("invoice_no")]
        public string InvoiceNo { get; set; } = string.Empty;

        /// <summary>
        /// 发票代码
        /// </summary>
        [MaxLength(50)]
        [Column("invoice_code")]
        public string? InvoiceCode { get; set; }

        /// <summary>
        /// 购方名称
        /// </summary>
        [Required]
        [MaxLength(200)]
        [Column("purchaser_name")]
        public string PurchaserName { get; set; } = string.Empty;

        /// <summary>
        /// 购方纳税人识别号
        /// </summary>
        [MaxLength(50)]
        [Column("purchaser_tax_id")]
        public string? PurchaserTaxId { get; set; }

        /// <summary>
        /// 销方名称
        /// </summary>
        [Required]
        [MaxLength(200)]
        [Column("seller_name")]
        public string SellerName { get; set; } = string.Empty;

        /// <summary>
        /// 销方纳税人识别号
        /// </summary>
        [MaxLength(50)]
        [Column("seller_tax_id")]
        public string? SellerTaxId { get; set; }

        /// <summary>
        /// 发票方向 (input: 进项/收票, output: 销项/开票)
        /// </summary>
        [Required]
        [MaxLength(20)]
        [Column("direction")]
        public string Direction { get; set; } = "input";

        /// <summary>
        /// 发票类型 (vat_special, vat_normal, electronic)
        /// </summary>
        [Required]
        [MaxLength(50)]
        [Column("type")]
        public string Type { get; set; } = string.Empty;

        /// <summary>
        /// 金额(不含税)
        /// </summary>
        [Column("amount", TypeName = "decimal(18,2)")]
        public decimal Amount { get; set; }

        /// <summary>
        /// 税额
        /// </summary>
        [Column("tax_amount", TypeName = "decimal(18,2)")]
        public decimal TaxAmount { get; set; }

        /// <summary>
        /// 价税合计
        /// </summary>
        [Column("total_amount", TypeName = "decimal(18,2)")]
        public decimal TotalAmount { get; set; }

        /// <summary>
        /// 开票日期
        /// </summary>
        [Column("invoice_date")]
        public DateTime InvoiceDate { get; set; }

        /// <summary>
        /// 状态 (draft, issued, void)
        /// </summary>
        [Required]
        [MaxLength(20)]
        [Column("status")]
        public string Status { get; set; } = "draft";

        /// <summary>
        /// 备注
        /// </summary>
        [MaxLength(500)]
        [Column("remark")]
        public string? Remark { get; set; }

        /// <summary>
        /// 组织ID
        /// </summary>
        [Column("org_id")]
        public long? OrgId { get; set; }

        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.Now;

        [Column("updated_at")]
        public DateTime? UpdatedAt { get; set; }
        
        [MaxLength(50)]
        [Column("created_by")]
        public string? CreatedBy { get; set; }

        /// <summary>
        /// 关联合同ID
        /// </summary>
        [Column("contract_id")]
        public long? ContractId { get; set; }

        /// <summary>
        /// 关联应收应付ID
        /// </summary>
        [Column("apar_id")]
        public long? ApArId { get; set; }
    }
}
