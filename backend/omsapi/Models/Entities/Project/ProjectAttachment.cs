using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Project
{
    [Table("project_attachments")]
    public class ProjectAttachment
    {
        [Key]
        [Column("id")]
        public string Id { get; set; } = null!;
        
        [Column("taskId")]
        public string TaskId { get; set; } = null!;
        
        [Column("project_code")]
        public string ProjectCode { get; set; } = null!;
        
        [Column("name")]
        public string? Name { get; set; }
        
        [Column("url")]
        public string? Url { get; set; }
        
        [Column("type")]
        public string? Type { get; set; }
        
        [Column("uploadDate")]
        public DateTime? UploadDate { get; set; }
    }
}