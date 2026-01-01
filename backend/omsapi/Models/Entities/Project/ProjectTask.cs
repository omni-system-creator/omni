using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Project
{
    [Table("project_tasks")]
    public class ProjectTask
    {
        [Column("id")]
        public string Id { get; set; } = null!;
        
        [Column("project_code")]
        public string ProjectCode { get; set; } = null!;
        
        [Column("name")]
        public string? Name { get; set; }
        
        [Column("phaseId")]
        public string? PhaseId { get; set; }
        
        [Column("swimlaneId")]
        public string? SwimlaneId { get; set; }
        
        [Column("status")]
        public string? Status { get; set; }
        
        [Column("progress")]
        public int Progress { get; set; }
        
        [Column("owner")]
        public string? Owner { get; set; }
        
        [Column("startDate")]
        public DateTime? StartDate { get; set; }
        
        [Column("endDate")]
        public DateTime? EndDate { get; set; }
        
        [Column("type")]
        public string? Type { get; set; }
        
        [Column("description")]
        public string? Description { get; set; }
        
        [Column("x")]
        public float X { get; set; }
        
        [Column("y")]
        public float Y { get; set; }
        
        [Column("width")]
        public float Width { get; set; }

        [Column("startColor")]
        public string? StartColor { get; set; }

        [Column("endColor")]
        public string? EndColor { get; set; }
    }
}