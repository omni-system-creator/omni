using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.System
{
    [Table("sys_task_attachment")]
    public class SysTaskAttachment
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }

        [Column("task_id")]
        public long TaskId { get; set; }

        [Column("file_name")]
        [MaxLength(255)]
        public string FileName { get; set; } = string.Empty;

        [Column("file_path")]
        [MaxLength(500)]
        public string FilePath { get; set; } = string.Empty;

        [Column("extension")]
        [MaxLength(20)]
        public string? Extension { get; set; }

        [Column("file_size")]
        public long FileSize { get; set; }

        [Column("content_type")]
        [MaxLength(100)]
        public string? ContentType { get; set; }

        [Column("uploader_id")]
        public long UploaderId { get; set; }

        [Column("create_time")]
        public DateTime CreateTime { get; set; } = DateTime.Now;

        [ForeignKey("TaskId")]
        public virtual SysTask? Task { get; set; }

        [ForeignKey("UploaderId")]
        public virtual SystemUser? Uploader { get; set; }
    }
}
