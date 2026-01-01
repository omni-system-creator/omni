using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Project
{
    [Table("project_task_dependencies")]
    public class ProjectTaskDependency
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        [Column("id")]
        public int Id { get; set; }
        
        [Column("taskId")]
        public string TaskId { get; set; } = null!;
        
        [Column("dependencyId")]
        public string DependencyId { get; set; } = null!;
        
        [Column("project_code")]
        public string ProjectCode { get; set; } = null!;
        
        [Column("type")]
        public string? Type { get; set; }
        
        [Column("sourcePort")]
        public string? SourcePort { get; set; }
        
        [Column("targetPort")]
        public string? TargetPort { get; set; }
        
        [Column("controlPoints")]
        public string? ControlPoints { get; set; } // JSON string
        
        [Column("controlPointCount")]
        public int? ControlPointCount { get; set; }
    }
}