namespace omsapi.Models.Dtos.Project
{
    public class ProjectListItemDto
    {
        public string Code { get; set; } = null!;
        public string Name { get; set; } = string.Empty;
        public string Type { get; set; } = string.Empty;
        public string Manager { get; set; } = string.Empty;
        public string Status { get; set; } = "ongoing"; // Default for now
        public int Progress { get; set; } = 0;
        public DateTime? PlannedEndDate { get; set; }
    }
}
