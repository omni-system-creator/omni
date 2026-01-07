namespace omsapi.Models.Dtos
{
    public class RegisterRequest
    {
        public string OrgName { get; set; } = string.Empty;
        public string? OrgShortName { get; set; }
        public string? OrgAbbr { get; set; }
        public string? LicenseCode { get; set; }
        public string? LicenseFileUrl { get; set; }
        public string? AuthLetterFileUrl { get; set; }
        public string ContactName { get; set; } = string.Empty;
        public string ContactPhone { get; set; } = string.Empty;
        public string? ContactEmail { get; set; }
        public string Username { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
    }
}
