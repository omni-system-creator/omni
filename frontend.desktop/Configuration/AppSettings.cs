namespace OmsDesktop.Configuration;

public class AppSettings
{
    public ThemeType Theme { get; set; } = ThemeType.Light;
    public string ApiBaseUrl { get; set; } = "https://os.jinlan.info";
    public bool RememberMe { get; set; } = false;
    public string SavedUsername { get; set; } = string.Empty;
    public string SavedPassword { get; set; } = string.Empty;
    public Dictionary<string, UserSettings> UserSettings { get; set; } = new();
}

public class UserSettings
{
    public double WindowTop { get; set; }
    public double WindowLeft { get; set; }
    public double WindowWidth { get; set; }
    public double WindowHeight { get; set; }
    public int WindowState { get; set; } // 0: Normal, 1: Minimized, 2: Maximized
}
