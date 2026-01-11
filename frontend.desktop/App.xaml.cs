using System.Configuration;
using System.Data;
using System.Windows;

namespace OmsDesktop;

/// <summary>
/// Interaction logic for App.xaml
/// </summary>
public partial class App : System.Windows.Application
{
    public App()
    {
        this.DispatcherUnhandledException += App_DispatcherUnhandledException;
    }

    protected override void OnStartup(StartupEventArgs e)
    {
        base.OnStartup(e);
        
        // Apply saved theme
        ThemeService.Instance.SetTheme(ThemeService.Instance.CurrentTheme);

        // Ensure ShutdownMode is OnExplicitShutdown so we can swap windows
        this.ShutdownMode = ShutdownMode.OnExplicitShutdown;

        var loginWindow = new LoginWindow();
        loginWindow.Show();
    }

    private void App_DispatcherUnhandledException(object sender, System.Windows.Threading.DispatcherUnhandledExceptionEventArgs e)
    {
        System.Windows.MessageBox.Show($"发生未捕获的异常: {e.Exception.Message}\n\n{e.Exception.StackTrace}", "错误", MessageBoxButton.OK, MessageBoxImage.Error);
        e.Handled = true;
    }
}

