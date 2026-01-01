using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Project
{
    [Table("project_phases")]
    public class ProjectPhase
    {
        [Column("id")]
        public string Id { get; set; } = null!;
        
        [Column("project_code")]
        public string ProjectCode { get; set; } = null!;
        
        [Column("name")]
        public string? Name { get; set; }
        
        [Column("color")]
        public string? Color { get; set; }
    }
}