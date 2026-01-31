using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.System
{
    [Table("sys_task_member")]
    public class SysTaskMember
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }

        [Column("task_id")]
        public long TaskId { get; set; }

        [Column("user_id")]
        public long UserId { get; set; }

        [Column("join_time")]
        public DateTime JoinTime { get; set; } = DateTime.Now;

        [ForeignKey("TaskId")]
        public virtual SysTask Task { get; set; } = null!;

        [ForeignKey("UserId")]
        public virtual SystemUser User { get; set; } = null!;
    }
}
