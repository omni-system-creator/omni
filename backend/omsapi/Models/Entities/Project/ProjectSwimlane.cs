using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Project
{
    [Table("project_swimlanes")]
    public class ProjectSwimlane
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