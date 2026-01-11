using System;
using System.IO;
using System.Text.Json;

namespace OmsDesktop.Configuration;

public static class SettingsManager
{
    private static readonly string ConfigPath = Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
        "OmsDesktop",
        "settings.json");

    public static AppSettings Settings { get; private set; } = new AppSettings();

    public static void Load()
    {
        try
        {
            if (File.Exists(ConfigPath))
            {
                var json = File.ReadAllText(ConfigPath);
                var settings = JsonSerializer.Deserialize<AppSettings>(json);
                if (settings != null)
                {
                    Settings = settings;
                }
            }
        }
        catch
        {
            // Ignore errors, use defaults
        }
    }

    public static void Save()
    {
        try
        {
            var directory = Path.GetDirectoryName(ConfigPath);
            if (directory != null && !Directory.Exists(directory))
            {
                Directory.CreateDirectory(directory);
            }

            var json = JsonSerializer.Serialize(Settings, new JsonSerializerOptions { WriteIndented = true });
            File.WriteAllText(ConfigPath, json);
        }
        catch
        {
            // Handle save errors if necessary
        }
    }
}
