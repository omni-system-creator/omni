using MaterialDesignThemes.Wpf;
using Microsoft.Win32;
using System.Runtime.InteropServices;
using System.Windows;
using System.Windows.Interop;
using System.Windows.Media;
using OmsDesktop.Configuration;

namespace OmsDesktop;

public enum ThemeType
{
    Light,
    Dark,
    System
}

public class ThemeService
{
    private readonly PaletteHelper _paletteHelper = new PaletteHelper();
    private ThemeType _currentTheme;
    private static ThemeService? _instance;

    public static ThemeService Instance => _instance ??= new ThemeService();

    private ThemeService()
    {
        SettingsManager.Load();
        _currentTheme = SettingsManager.Settings.Theme;
    }

    public ThemeType CurrentTheme => _currentTheme;

    public void SetTheme(ThemeType theme)
    {
        _currentTheme = theme;
        SettingsManager.Settings.Theme = theme;
        SettingsManager.Save();

        if (theme == ThemeType.System)
        {
            ApplySystemTheme();
            SystemEvents.UserPreferenceChanged += SystemEvents_UserPreferenceChanged;
        }
        else
        {
            SystemEvents.UserPreferenceChanged -= SystemEvents_UserPreferenceChanged;
            ApplyBaseTheme(theme == ThemeType.Dark);
        }
    }

    private void SystemEvents_UserPreferenceChanged(object sender, UserPreferenceChangedEventArgs e)
    {
        if (e.Category == UserPreferenceCategory.General)
        {
            ApplySystemTheme();
        }
    }

    private void ApplySystemTheme()
    {
        bool isDark = IsSystemDarkTheme();
        ApplyBaseTheme(isDark);
    }

    private bool IsSystemDarkTheme()
    {
        try
        {
            const string registryKey = @"Software\Microsoft\Windows\CurrentVersion\Themes\Personalize";
            const string registryValue = "AppsUseLightTheme";
            using var key = Registry.CurrentUser.OpenSubKey(registryKey);
            var value = key?.GetValue(registryValue);
            return value is int i && i == 0;
        }
        catch
        {
            return false;
        }
    }

    private void ApplyBaseTheme(bool isDark)
    {
        ITheme theme = _paletteHelper.GetTheme();
        IBaseTheme baseTheme = isDark ? new MaterialDesignDarkTheme() : new MaterialDesignLightTheme();
        theme.SetBaseTheme(baseTheme);
        
        // Set Primary and Secondary colors to Brand Color (#07C160)
        System.Windows.Media.Color brandColor = (System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("#07C160");
        theme.SetPrimaryColor(brandColor);
        theme.SetSecondaryColor(brandColor);

        _paletteHelper.SetTheme(theme);
        
        // Update custom brushes
        UpdateCustomBrushes(isDark);
    }
    
    private void UpdateCustomBrushes(bool isDark)
    {
        var resources = System.Windows.Application.Current.Resources;
        
        if (isDark)
        {
            resources["SidebarBackground"] = new SolidColorBrush(System.Windows.Media.Color.FromRgb(0x2E, 0x2E, 0x2E)); // Always dark
            resources["ChatListBackground"] = new SolidColorBrush(System.Windows.Media.Color.FromRgb(0x1E, 0x1E, 0x1E));
            resources["ContentBackground"] = new SolidColorBrush(System.Windows.Media.Color.FromRgb(0x12, 0x12, 0x12));
            resources["BorderBrush"] = new SolidColorBrush(System.Windows.Media.Color.FromRgb(0x33, 0x33, 0x33));
            resources["TextPrimary"] = new SolidColorBrush(Colors.White);
            resources["TextSecondary"] = new SolidColorBrush(System.Windows.Media.Color.FromRgb(0xAA, 0xAA, 0xAA));
            resources["InputAreaBackground"] = new SolidColorBrush(System.Windows.Media.Color.FromRgb(0x1E, 0x1E, 0x1E));
            resources["SearchBarBackground"] = new SolidColorBrush(System.Windows.Media.Color.FromRgb(0x2A, 0x2A, 0x2A));
            resources["IconForeground"] = new SolidColorBrush(Colors.White);
            resources["AvatarPlaceholder"] = new SolidColorBrush(System.Windows.Media.Color.FromRgb(0x44, 0x44, 0x44));
            resources["ListItemSelected"] = new SolidColorBrush(System.Windows.Media.Color.FromRgb(0x33, 0x33, 0x33));
            resources["SendButtonBackground"] = new SolidColorBrush(System.Windows.Media.Color.FromRgb(0x33, 0x33, 0x33));
            resources["SendButtonForeground"] = new SolidColorBrush(System.Windows.Media.Color.FromRgb(0x07, 0xC1, 0x60));
            resources["BrandColor"] = new SolidColorBrush(System.Windows.Media.Color.FromRgb(0x07, 0xC1, 0x60));
            resources["SidebarIconForeground"] = new SolidColorBrush(System.Windows.Media.Color.FromRgb(0x99, 0x99, 0x99));
            resources["SidebarIconHover"] = new SolidColorBrush(Colors.White);
            resources["LoginWindowBackground"] = new SolidColorBrush(System.Windows.Media.Color.FromRgb(0x1E, 0x1E, 0x1E));
        }
        else
        {
            resources["SidebarBackground"] = new SolidColorBrush(System.Windows.Media.Color.FromRgb(0xE6, 0xE6, 0xE6)); // Light sidebar for Light Mode
            resources["ChatListBackground"] = new SolidColorBrush(System.Windows.Media.Color.FromRgb(0xF5, 0xF5, 0xF5));
            resources["ContentBackground"] = new SolidColorBrush(System.Windows.Media.Color.FromRgb(0xF5, 0xF5, 0xF5));
            resources["BorderBrush"] = new SolidColorBrush(System.Windows.Media.Color.FromRgb(0xD6, 0xD6, 0xD6));
            resources["TextPrimary"] = new SolidColorBrush(System.Windows.Media.Color.FromRgb(0x33, 0x33, 0x33));
            resources["TextSecondary"] = new SolidColorBrush(System.Windows.Media.Color.FromRgb(0x99, 0x99, 0x99));
            resources["InputAreaBackground"] = new SolidColorBrush(System.Windows.Media.Color.FromRgb(0xF5, 0xF5, 0xF5));
            resources["SearchBarBackground"] = new SolidColorBrush(System.Windows.Media.Color.FromRgb(0xE2, 0xE2, 0xE2));
            resources["IconForeground"] = new SolidColorBrush(System.Windows.Media.Color.FromRgb(0x66, 0x66, 0x66));
            resources["AvatarPlaceholder"] = new SolidColorBrush(System.Windows.Media.Color.FromRgb(0xDD, 0xDD, 0xDD));
            resources["ListItemSelected"] = new SolidColorBrush(System.Windows.Media.Color.FromRgb(0xC9, 0xC9, 0xC9));
            resources["SendButtonBackground"] = new SolidColorBrush(System.Windows.Media.Color.FromRgb(0xE9, 0xE9, 0xE9));
            resources["SendButtonForeground"] = new SolidColorBrush(System.Windows.Media.Color.FromRgb(0x07, 0xC1, 0x60));
            resources["BrandColor"] = new SolidColorBrush(System.Windows.Media.Color.FromRgb(0x07, 0xC1, 0x60));
            resources["SidebarIconForeground"] = new SolidColorBrush(System.Windows.Media.Color.FromRgb(0x66, 0x66, 0x66));
            resources["SidebarIconHover"] = new SolidColorBrush(System.Windows.Media.Color.FromRgb(0x33, 0x33, 0x33));
            resources["LoginWindowBackground"] = new SolidColorBrush(Colors.White);
        }
    }
}
