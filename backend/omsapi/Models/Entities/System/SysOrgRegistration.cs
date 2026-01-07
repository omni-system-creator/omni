using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.System
{
    [Table("sys_org_registration")]
    public class SysOrgRegistration
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }

        [Required]
        [MaxLength(100)]
        public string OrgName { get; set; } = string.Empty;

        [MaxLength(50)]
        public string? OrgShortName { get; set; }

        [MaxLength(20)]
        public string? OrgAbbr { get; set; }

        [MaxLength(100)]
        public string? LicenseCode { get; set; }

        public string? LicenseFileUrl { get; set; }

        public string? AuthLetterFileUrl { get; set; }

        [Required]
        [MaxLength(50)]
        public string ContactName { get; set; } = string.Empty;

        [Required]
        [MaxLength(20)]
        public string ContactPhone { get; set; } = string.Empty;

        [MaxLength(100)]
        public string? ContactEmail { get; set; }

        [Required]
        [MaxLength(50)]
        public string AdminUsername { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        public string AdminPassword { get; set; } = string.Empty; // Hashed

        [Required]
        [MaxLength(20)]
        public string Status { get; set; } = "pending"; // pending, approved, rejected

        public string? RejectReason { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }
    }
}
