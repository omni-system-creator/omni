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
        public int SortOrder { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }

        // 额外信息：用于前端同时展示/编辑全局值和组织值
        public long GlobalId { get; set; }
        public string? GlobalValue { get; set; }
        public string? GlobalDescription { get; set; }
        public long? OrgConfigId { get; set; }
        public string? OrgValue { get; set; }
    }

    public class UpdateSystemConfigDto
    {
        [MaxLength(500)]
        public string? Value { get; set; }

        [MaxLength(200)]
        public string? Description { get; set; }

        public int? SortOrder { get; set; }

        /// <summary>
        /// Only for SuperAdmin: If true, updates the Global Config instead of creating/updating an override.
        /// </summary>
        public bool UpdateGlobal { get; set; } = false;
    }
}
