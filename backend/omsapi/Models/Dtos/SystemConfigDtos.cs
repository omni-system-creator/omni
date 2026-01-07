using System.ComponentModel.DataAnnotations;
using omsapi.Models.Enums;

namespace omsapi.Models.Dtos
{
    public class SystemConfigDto
    {
        public long Id { get; set; }
        public string Category { get; set; } = string.Empty;
        public string Key { get; set; } = string.Empty;
        public ConfigType Type { get; set; }
        public string? Value { get; set; }
        public string? Description { get; set; }
        public bool IsSystem { get; set; }
        public long? OrgId { get; set; }
        public bool IsOverridable { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }

    public class UpdateSystemConfigDto
    {
        [MaxLength(500)]
        public string? Value { get; set; }

        [MaxLength(200)]
        public string? Description { get; set; }
    }
}
