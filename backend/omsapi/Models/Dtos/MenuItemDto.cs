namespace omsapi.Models.Dtos
{
    public class MenuItemDto
    {
        public string Key { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public string? Icon { get; set; }
        public string? Path { get; set; }
        public string? Component { get; set; }
        public string? Query { get; set; }
        public List<MenuItemDto>? Children { get; set; }
    }
}
