using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Project
{
    [Table("project_info")]
    public class ProjectInfo
    {
        [Key]
        [Column("code")]
        public string Code { get; set; } = null!;
        
        [Column("name")]
        public string? Name { get; set; }
        
        [Column("type")]
        public string? Type { get; set; }
        
        [Column("description")]
        public string? Description { get; set; }
        
        [Column("manager")]
        public string? Manager { get; set; }
        
        [Column("planned_start_date")]
        public DateTime? PlannedStartDate { get; set; }
        
        [Column("planned_end_date")]
        public DateTime? PlannedEndDate { get; set; }
    }
}