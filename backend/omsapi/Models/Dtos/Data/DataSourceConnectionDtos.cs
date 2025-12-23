using System.ComponentModel.DataAnnotations;

namespace omsapi.Models.Dtos.Data
{
    public class DataSourceConnectionDto
    {
        public long Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Type { get; set; } = string.Empty;
        public string Host { get; set; } = string.Empty;
        public string Port { get; set; } = string.Empty;
        public string User { get; set; } = string.Empty;
        public string Database { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
    }

    public class CreateDataSourceConnectionDto
    {
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        [Required]
        [MaxLength(20)]
        public string Type { get; set; } = "mysql";

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
    }

    public class UpdateDataSourceConnectionDto
    {
        [MaxLength(100)]
        public string? Name { get; set; }

        [MaxLength(20)]
        public string? Type { get; set; }

        [MaxLength(200)]
        public string? Host { get; set; }

        [MaxLength(10)]
        public string? Port { get; set; }

        [MaxLength(100)]
        public string? User { get; set; }

        [MaxLength(200)]
        public string? Password { get; set; }

        [MaxLength(100)]
        public string? Database { get; set; }
    }
}
