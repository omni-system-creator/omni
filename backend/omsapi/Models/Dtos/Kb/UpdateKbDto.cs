using System.ComponentModel.DataAnnotations;

namespace OmsApi.Models.Dtos.Kb
{
    public class UpdateKbDto
    {
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(500)]
        public string? Description { get; set; }

        [MaxLength(50)]
        public string Category { get; set; } = "general";

        [MaxLength(50)]
        public string Type { get; set; } = "general";

        public int? SortOrder { get; set; }
    }
}
