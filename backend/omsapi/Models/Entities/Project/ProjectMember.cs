using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Project
{
    [Table("project_members")]
    public class ProjectMember
    {
        [Key]
        [Column("id")]
        public long Id { get; set; }

        [Column("project_code")]
        [Required]
        [MaxLength(50)]
        public string ProjectCode { get; set; } = string.Empty;

        [Column("username")]
        [Required]
        [MaxLength(50)]
        public string Username { get; set; } = string.Empty;

        [Column("role")]
        [Required]
        [MaxLength(20)]
        public string Role { get; set; } = "Member"; // Manager, Member, Viewer

        [Column("joined_at")]
        public DateTime JoinedAt { get; set; } = DateTime.Now;
    }
}
