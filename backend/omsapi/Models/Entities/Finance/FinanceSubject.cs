using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Finance
{
    /// <summary>
    /// 财务科目表
    /// </summary>
    [Table("finance_subject")]
    public class FinanceSubject
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }

        [Required]
        [MaxLength(50)]
        [Column("code")]
        public string Code { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        [Column("name")]
        public string Name { get; set; } = string.Empty;

        [Column("parent_id")]
        public long? ParentId { get; set; }

        [ForeignKey("ParentId")]
        public virtual FinanceSubject? Parent { get; set; }

        public virtual ICollection<FinanceSubject> Children { get; set; } = new List<FinanceSubject>();

        /// <summary>
        /// 科目方向：income (收入/应收), expense (支出/应付)
        /// </summary>
        [Required]
        [MaxLength(20)]
        [Column("direction")]
        public string Direction { get; set; } = "income"; 

        [MaxLength(200)]
        [Column("description")]
        public string? Description { get; set; }

        [Column("is_system")]
        public bool IsSystem { get; set; } = false;

        [Column("is_active")]
        public bool IsActive { get; set; } = true;

        [Column("org_id")]
        public long? OrgId { get; set; }

        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.Now;

        [Column("updated_at")]
        public DateTime? UpdatedAt { get; set; }
    }
}
