using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Archive
{
    [Table("arch_attachment")]
    public class ArchAttachment
    {
        [Key]
        public long Id { get; set; }

        public long ArchFileId { get; set; }

        // We can link to SystemFile or store path directly. 
        // Linking to SystemFile allows reuse of storage logic.
        public long? FileId { get; set; }

        [MaxLength(255)]
        public string FileName { get; set; } = string.Empty;

        [MaxLength(20)]
        public string? Extension { get; set; }

        public long Size { get; set; }

        [MaxLength(500)]
        public string? FilePath { get; set; } // If independent storage

        public DateTime CreatedAt { get; set; } = DateTime.Now;

        [ForeignKey("ArchFileId")]
        public virtual ArchFile ArchFile { get; set; } = null!;
        
        [ForeignKey("FileId")]
        public virtual SystemFile? File { get; set; }
    }
}