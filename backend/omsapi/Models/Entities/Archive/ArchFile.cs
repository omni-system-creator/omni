using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Archive
{
    [Table("arch_file")]
    public class ArchFile
    {
        [Key]
        public long Id { get; set; }

        public long FondId { get; set; } // 全宗
        
        public long TypeId { get; set; } // 门类/分类

        public long? BoxId { get; set; } // 案卷/盒

        [Required]
        [MaxLength(100)]
        public string ArchCode { get; set; } = string.Empty; // 档号 (Unique identifier)

        [Required]
        [MaxLength(500)]
        public string Title { get; set; } = string.Empty; // 题名

        [MaxLength(50)]
        public string? DocNumber { get; set; } // 文号

        [MaxLength(100)]
        public string? Author { get; set; } // 责任者

        public DateTime? FileDate { get; set; } // 形成日期

        [MaxLength(10)]
        public string? Year { get; set; } // 年度

        [MaxLength(20)]
        public string? RetentionPeriod { get; set; } // 保管期限 (永久/30年/10年)

        [MaxLength(20)]
        public string? SecurityLevel { get; set; } // 密级 (公开/内部/秘密...)

        public int PageCount { get; set; } = 0; // 页数

        public int Status { get; set; } = 0; // 0: Draft, 1: Archived, 2: Destroyed

        [MaxLength(500)]
        public string? Keywords { get; set; } // 关键词

        [MaxLength(500)]
        public string? Remark { get; set; }

        // Link to source system file if applicable
        public long? SourceFileId { get; set; }
        
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime UpdatedAt { get; set; } = DateTime.Now;

        [ForeignKey("FondId")]
        public virtual ArchFond Fond { get; set; } = null!;

        [ForeignKey("TypeId")]
        public virtual ArchType Type { get; set; } = null!;

        [ForeignKey("BoxId")]
        public virtual ArchBox? Box { get; set; }

        public virtual ICollection<ArchAttachment> Attachments { get; set; } = new List<ArchAttachment>();
    }
}