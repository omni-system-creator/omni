using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace omsapi.Models.Entities.Finance
{
    [Table("finance_attachment")]
    public class FinanceAttachment
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }

        /// <summary>
        /// 关联目标类型：ApAr, Invoice, etc.
        /// </summary>
        [Required]
        [MaxLength(50)]
        [Column("target_type")]
        public string TargetType { get; set; } = string.Empty;

        /// <summary>
        /// 关联目标ID
        /// </summary>
        [Required]
        [Column("target_id")]
        public long TargetId { get; set; }

        [Required]
        [MaxLength(200)]
        [Column("file_name")]
        public string FileName { get; set; } = string.Empty;

        [MaxLength(500)]
        [Column("file_path")]
        public string? FilePath { get; set; }

        [MaxLength(20)]
        [Column("size")]
        public string? Size { get; set; }

        [MaxLength(100)]
        [Column("content_type")]
        public string? ContentType { get; set; }

        [Column("upload_date")]
        public DateTime UploadDate { get; set; } = DateTime.Now;

        [MaxLength(50)]
        [Column("uploader")]
        public string? Uploader { get; set; }
    }
}
