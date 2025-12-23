using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Data
{
    [Table("data_source_connection")]
    public class DataSourceConnection
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }

        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        [Required]
        [MaxLength(20)]
        public string Type { get; set; } = "mysql"; // mysql, postgresql, oracle, sqlserver

        [MaxLength(200)]
        public string Host { get; set; } = "127.0.0.1";

        [MaxLength(10)]
        public string Port { get; set; } = "3306";

        [MaxLength(100)]
        public string User { get; set; } = string.Empty;

        [MaxLength(200)]
        public string Password { get; set; } = string.Empty;

        [MaxLength(100)]
        public string Database { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; } = DateTime.Now;

        public DateTime? UpdatedAt { get; set; }
    }
}
