using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.System
{
    [Table("sys_db_migration")]
    public class SysDbMigration
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }

        [Required]
        [MaxLength(255)]
        public string FileName { get; set; } = string.Empty;

        public DateTime ExecutedAt { get; set; } = DateTime.Now;

        [MaxLength(50)]
        public string Status { get; set; } = "success";

        public string? ErrorMessage { get; set; }
    }
}
