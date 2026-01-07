namespace omsapi.Models.Dtos
{
    public class UserOrgDto
    {
        public long Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Type { get; set; } = string.Empty; // "Group", "Company", "Demo"
        public bool IsCurrent { get; set; }
    }
}
