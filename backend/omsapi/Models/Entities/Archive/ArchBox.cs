using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Archive
{
    [Table("arch_box")]
    public class ArchBox
    {
        [Key]
        public long Id { get; set; }

        public long FondId { get; set; }
        
        public long TypeId { get; set; } // Category

        [Required]
        [MaxLength(50)]
        public string BoxCode { get; set; } = string.Empty; // 盒号/案卷号

        [MaxLength(100)]
        public string? Title { get; set; } // 案卷题名

        [MaxLength(20)]
        public string? Year { get; set; } // 年度

        [MaxLength(20)]
        public string? RetentionPeriod { get; set; } // 保管期限

        [MaxLength(20)]
        public string? SecurityLevel { get; set; } // 密级

        [MaxLength(100)]
        public string? Location { get; set; } // 存放位置

        [MaxLength(50)]
        public string? RFID { get; set; }

        public int FileCount { get; set; } = 0; // 件数

        [MaxLength(200)]
        public string? Remark { get; set; }
        
        public int Status { get; set; } = 0; // 0: Open, 1: Closed/Archived

        public DateTime CreatedAt { get; set; } = DateTime.Now;

        [ForeignKey("FondId")]
        public virtual ArchFond Fond { get; set; } = null!;

        [ForeignKey("TypeId")]
        public virtual ArchType Type { get; set; } = null!;
    }
}