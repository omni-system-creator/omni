using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using omsapi.Models.Entities;

namespace omsapi.Models.Entities.System
{
    [Table("sys_task")]
    public class SysTask
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }

        [Required]
        [MaxLength(200)]
        [Column("title")]
        public string Title { get; set; } = string.Empty;

        [Required]
        [MaxLength(50)]
        [Column("type")]
        public string Type { get; set; } = "task"; // task, approval, notice

        [Required]
        [MaxLength(20)]
        [Column("priority")]
        public string Priority { get; set; } = "medium"; // high, medium, low

        [Column("description")]
        public string? Description { get; set; }

        [Column("creator_id")]
        public long CreatorId { get; set; }

        [Column("assignee_id")]
        public long AssigneeId { get; set; }

        [Column("create_time")]
        public DateTime CreateTime { get; set; } = DateTime.Now;

        [Column("start_time")]
        public DateTime? StartTime { get; set; }

        [Column("deadline")]
        public DateTime? Deadline { get; set; }

        [Column("finish_time")]
        public DateTime? FinishTime { get; set; }

        [Required]
        [MaxLength(50)]
        [Column("status")]
        public string Status { get; set; } = "pending"; // pending, completed

        [Column("org_id")]
        public long OrgId { get; set; }

        [ForeignKey("CreatorId")]
        public virtual SystemUser? Creator { get; set; }

        [ForeignKey("AssigneeId")]
        public virtual SystemUser? Assignee { get; set; }

        public virtual ICollection<SysTaskAttachment> Attachments { get; set; } = new List<SysTaskAttachment>();

        public virtual ICollection<SysTaskMember> Members { get; set; } = new List<SysTaskMember>();
    }
}
