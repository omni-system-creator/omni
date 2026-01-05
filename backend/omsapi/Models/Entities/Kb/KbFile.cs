using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace OmsApi.Models.Entities.Kb
{
    [Table("kb_file")]
    public class KbFile
    {
        [Key]
        public Guid Id { get; set; }

        [Required]
        public Guid KbId { get; set; }

        [Required]
        [MaxLength(255)]
        public string Name { get; set; } = string.Empty;

        public long Size { get; set; }

        [MaxLength(20)]
        public string? Extension { get; set; }

        [MaxLength(500)]
        public string Path { get; set; } = string.Empty;

        [MaxLength(20)]
        public string Status { get; set; } = "uploading"; // uploading, processing, ready, error

        public DateTime UploadTime { get; set; } = DateTime.Now;

        public bool IsFolder { get; set; } = false;

        public Guid? ParentId { get; set; }

        [ForeignKey(nameof(ParentId))]
        public KbFile? Parent { get; set; }

        [ForeignKey(nameof(KbId))]
        public KbInfo? Kb { get; set; }
    }
}
