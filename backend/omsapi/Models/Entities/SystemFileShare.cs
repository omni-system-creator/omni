using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities
{
    [Table("sys_file_share")]
    public class SystemFileShare
    {
        [Key]
        public long Id { get; set; }

        public long FileId { get; set; }
        
        [ForeignKey("FileId")]
        public SystemFile File { get; set; } = null!;

        public long SharedByUserId { get; set; }
        
        [ForeignKey("SharedByUserId")]
        public SystemUser SharedByUser { get; set; } = null!;

        public long? SharedToUserId { get; set; }
        
        [ForeignKey("SharedToUserId")]
        public SystemUser? SharedToUser { get; set; }

        [MaxLength(20)]
        public string Permission { get; set; } = "read"; // read, write

        [MaxLength(64)]
        public string? Token { get; set; } // For public link sharing

        public DateTime? ExpirationTime { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
}
