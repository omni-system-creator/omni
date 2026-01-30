namespace omsapi.Models.Dtos
{
    public class UserConfigDto
    {
        public string Key { get; set; } = string.Empty;
        public string? Value { get; set; }
        public string? Description { get; set; }
    }
}
