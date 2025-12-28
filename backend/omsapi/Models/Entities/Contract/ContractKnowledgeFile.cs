using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Contract
{
    // 合同知识库文件
    [Table("contract_knowledge_file")]
    public class ContractKnowledgeFile
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }

        [Required]
        [Column("category_id")]
        public long CategoryId { get; set; }

        [Required]
        [MaxLength(255)]
        [Column("name")]
        public string Name { get; set; } = string.Empty;

        [MaxLength(20)]
        [Column("type")]
        public string Type { get; set; } = string.Empty; // pdf, doc, xls, etc.

        [MaxLength(100)]
        [Column("content_type")]
        public string? ContentType { get; set; }

        [MaxLength(255)]
        [Column("file_path")]
        public string? FilePath { get; set; }

        [Column("size")]
        public long Size { get; set; }

        [MaxLength(50)]
        [Column("uploader")]
        public string? Uploader { get; set; }

        [Column("upload_time")]
        public DateTime UploadTime { get; set; } = DateTime.Now;
    }
}
