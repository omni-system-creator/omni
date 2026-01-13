using System.Configuration;
using System.Data;
using System.Windows;
using Microsoft.Win32;

namespace OmsDesktop;

/// <summary>
/// Interaction logic for App.xaml
/// </summary>
public partial class App : System.Windows.Application
{
    public static string? PendingDocId { get; private set; }
    public static string? PendingDocName { get; private set; }

    public App()
    {
        this.DispatcherUnhandledException += App_DispatcherUnhandledException;
    }

    protected override void OnStartup(StartupEventArgs e)
    {
        base.OnStartup(e);

        RegisterProtocol();
        ParseArgs(e.Args);
        
        // Apply saved theme
        ThemeService.Instance.SetTheme(ThemeService.Instance.CurrentTheme);

        // Ensure ShutdownMode is OnExplicitShutdown so we can swap windows
        this.ShutdownMode = ShutdownMode.OnExplicitShutdown;

        var loginWindow = new LoginWindow();
        loginWindow.Show();
    }

    private void RegisterProtocol()
    {
        try
        {
            using (var key = Registry.CurrentUser.CreateSubKey(@"Software\Classes\oms"))
            {
                key.SetValue("", "URL:OMS Protocol");
                key.SetValue("URL Protocol", "");
                
                using (var iconKey = key.CreateSubKey("DefaultIcon"))
                {
                    string exePath = System.Diagnostics.Process.GetCurrentProcess().MainModule?.FileName ?? "";
                    iconKey.SetValue("", $"{exePath},1");
                }
                
                using (var commandKey = key.CreateSubKey(@"shell\open\command"))
                {
                    string exePath = System.Diagnostics.Process.GetCurrentProcess().MainModule?.FileName ?? "";
                    commandKey.SetValue("", $"\"{exePath}\" \"%1\"");
                }
            }
        }
        catch (Exception ex)
        {
            // Ignore registry errors (might be permissions)
            System.Diagnostics.Debug.WriteLine($"Failed to register protocol: {ex.Message}");
        }
    }

    private void ParseArgs(string[] args)
    {
        if (args != null && args.Length > 0)
        {
            foreach (var arg in args)
            {
                if (arg.StartsWith("oms://", StringComparison.OrdinalIgnoreCase))
                {
                    try
                    {
                        var uri = new Uri(arg);
                        if (uri.Host == "preview")
                        {
                            var query = uri.Query.TrimStart('?').Split('&')
                                .Select(part => part.Split('='))
                                .Where(part => part.Length == 2)
                                .ToDictionary(part => part[0], part => Uri.UnescapeDataString(part[1]));
                            
                            if (query.TryGetValue("id", out var id)) PendingDocId = id;
                            if (query.TryGetValue("name", out var name)) PendingDocName = name;
                        }
                    }
                    catch
                    {
                        // Parse error
                    }
                }
            }
        }
    }

    private void App_DispatcherUnhandledException(object sender, System.Windows.Threading.DispatcherUnhandledExceptionEventArgs e)
    {
        System.Windows.MessageBox.Show($"发生未捕获的异常: {e.Exception.Message}\n\n{e.Exception.StackTrace}", "错误", MessageBoxButton.OK, MessageBoxImage.Error);
        e.Handled = true;
    }
}

