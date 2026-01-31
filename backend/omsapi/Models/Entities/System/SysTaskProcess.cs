using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.System
{
    [Table("sys_task_process")]
    public class SysTaskProcess
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }

        [Column("task_id")]
        public long TaskId { get; set; }

        [Column("operator_id")]
        public long OperatorId { get; set; }

        [Column("action")]
        [MaxLength(50)]
        public string Action { get; set; } = "process"; // process, complete, reopen

        [Column("comment")]
        public string? Comment { get; set; }

        [Column("create_time")]
        public DateTime CreateTime { get; set; } = DateTime.Now;

        // Store file IDs as comma-separated string for simplicity
        [Column("attachment_ids")]
        [MaxLength(500)]
        public string? AttachmentIds { get; set; }

        [ForeignKey("TaskId")]
        public virtual SysTask? Task { get; set; }

        [ForeignKey("OperatorId")]
        public virtual SystemUser? Operator { get; set; }
    }
}
