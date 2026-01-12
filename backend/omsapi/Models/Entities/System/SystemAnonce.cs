using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.System
{
    /// <summary>
    /// 系统公告表
    /// </summary>
    [Table("sys_anonce")]
    public class SystemAnonce
    {
        /// <summary>
        /// 主键ID
        /// </summary>
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }

        /// <summary>
        /// 公告标题
        /// </summary>
        [Required]
        [MaxLength(200)]
        public string Title { get; set; } = string.Empty;

        /// <summary>
        /// 公告内容
        /// </summary>
        [Required]
        public string Content { get; set; } = string.Empty;

        /// <summary>
        /// 公告类型 (关联字典 anonce_type)
        /// </summary>
        [Required]
        [MaxLength(50)]
        public string Type { get; set; } = string.Empty; // 关联字典 anonce_type 的 value

        /// <summary>
        /// 状态 (draft:草稿, published:已发布, revoked:已撤回)
        /// </summary>
        [MaxLength(20)]
        public string Status { get; set; } = "draft"; // draft, published, revoked

        /// <summary>
        /// 发布时间
        /// </summary>
        public DateTime? PublishTime { get; set; }

        /// <summary>
        /// 创建时间
        /// </summary>
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        /// <summary>
        /// 更新时间
        /// </summary>
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        /// <summary>
        /// 创建人ID
        /// </summary>
        public long? CreatedBy { get; set; }
        
        /// <summary>
        /// 更新人ID
        /// </summary>
        public long? UpdatedBy { get; set; }

        // Optional: Priority, TargetRoles, etc.
        /// <summary>
        /// 优先级 (high, normal, low)
        /// </summary>
        [MaxLength(20)]
        public string Priority { get; set; } = "normal"; // high, normal, low
    }
}
