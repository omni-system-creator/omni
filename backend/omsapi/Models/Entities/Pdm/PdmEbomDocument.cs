using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Pdm
{
    [Table("pdm_ebom_documents")]
    public class PdmEbomDocument
    {
        [Key]
        [Column("id")]
        public long Id { get; set; }

        [Required]
        [MaxLength(50)]
        [Column("ebom_item_id")]
        public string EbomItemId { get; set; } = string.Empty;

        [Required]
        [MaxLength(255)]
        [Column("name")]
        public string Name { get; set; } = string.Empty;

        [MaxLength(500)]
        [Column("path")]
        public string Path { get; set; } = string.Empty;

        [MaxLength(50)]
        [Column("file_type")]
        public string FileType { get; set; } = string.Empty;

        [Column("size")]
        public long Size { get; set; }

        [Column("uploaded_at")]
        public DateTime UploadedAt { get; set; } = DateTime.Now;

        [Column("uploaded_by")]
        public string UploadedBy { get; set; } = string.Empty;
    }
}
