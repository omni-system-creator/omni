using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities
{
    [Table("sys_user")]
    public class User
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }

        [Required]
        [MaxLength(50)]
        public string Username { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        public string Password { get; set; } = string.Empty; // 存储哈希后的密码

        [MaxLength(50)]
        public string? Nickname { get; set; }

        [MaxLength(100)]
        public string? Email { get; set; }

        [MaxLength(20)]
        public string? Phone { get; set; }

        public string? Avatar { get; set; }

        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.Now;

        public DateTime? LastLoginAt { get; set; }
    }
}
