using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Interfaces
{
    [Table("api_definition")]
    public class InterfaceDefinition
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }

        public long CategoryId { get; set; }

        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        [Required]
        [MaxLength(200)]
        public string Path { get; set; } = string.Empty; // API URL path

        [Required]
        [MaxLength(10)]
        public string Method { get; set; } = "GET"; // GET, POST, etc.

        [MaxLength(500)]
        public string? Description { get; set; }

        // Role-based Access Control
        // Comma-separated Role IDs. Null or Empty means no restriction (or only admin).
        // Let's define:
        // ViewRoles: Who can see/call the API (Execution Permission)
        // ManageRoles: Who can edit/delete/publish the API (Management Permission)

        [MaxLength(200)]
        public string? ViewRoles { get; set; } // Who can see the API details

        [MaxLength(200)]
        public string? CallRoles { get; set; } // Who can call/execute the API

        [MaxLength(200)]
        public string? ManageRoles { get; set; } // Who can edit/delete/publish/offline/view stats

        public string? FlowConfig { get; set; } // JSON configuration of the API flow (nodes, edges)

        public bool IsPublished { get; set; } = false;

        public bool RequiresAuth { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.Now;

        public DateTime UpdatedAt { get; set; } = DateTime.Now;

        public long? CreatedBy { get; set; }

        public long? UpdatedBy { get; set; }

        [ForeignKey("CategoryId")]
        public virtual InterfaceCategory? Category { get; set; }
    }
}
