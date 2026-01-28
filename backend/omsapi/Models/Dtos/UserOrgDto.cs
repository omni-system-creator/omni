namespace omsapi.Models.Dtos
{
    public class UserOrgDto
    {
        public long Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Type { get; set; } = string.Empty; // "Group", "Company", "Demo"
        public string OrgAbbr { get; set; } = string.Empty;
        public bool IsCurrent { get; set; }
    }
}
