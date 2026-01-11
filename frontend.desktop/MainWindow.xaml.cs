using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using Microsoft.Win32;
using System.IO;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Windows.Interop;

namespace OmsDesktop;

/// <summary>
/// Interaction logic for MainWindow.xaml
/// </summary>
public partial class MainWindow : Window
{
    private readonly ThemeService _themeService;

    public MainWindow()
    {
        InitializeComponent();
        _themeService = ThemeService.Instance;
        // Initialize with saved theme
        _themeService.SetTheme(_themeService.CurrentTheme);
        Loaded += MainWindow_Loaded;
        Closing += MainWindow_Closing;
        SourceInitialized += MainWindow_SourceInitialized;
    }

    private void MainWindow_SourceInitialized(object? sender, EventArgs e)
    {
        ((HwndSource)PresentationSource.FromVisual(this)).AddHook(WindowProc);
    }

    private void MainWindow_Closing(object? sender, System.ComponentModel.CancelEventArgs e)
    {
        SaveWindowSettings();
    }

    private IntPtr WindowProc(IntPtr hwnd, int msg, IntPtr wParam, IntPtr lParam, ref bool handled)
    {
        if (msg == 0x0024) // WM_GETMINMAXINFO
        {
            WmGetMinMaxInfo(hwnd, lParam);
            handled = true;
        }
        return (IntPtr)0;
    }

    private void WmGetMinMaxInfo(IntPtr hwnd, IntPtr lParam)
    {
        MINMAXINFO mmi = (MINMAXINFO)Marshal.PtrToStructure(lParam, typeof(MINMAXINFO))!;
        int MONITOR_DEFAULTTONEAREST = 0x00000002;
        IntPtr monitor = MonitorFromWindow(hwnd, MONITOR_DEFAULTTONEAREST);
        if (monitor != IntPtr.Zero)
        {
            MONITORINFO monitorInfo = new MONITORINFO();
            GetMonitorInfo(monitor, monitorInfo);
            RECT rcWorkArea = monitorInfo.rcWork;
            RECT rcMonitor = monitorInfo.rcMonitor;
            mmi.ptMaxPosition.x = Math.Abs(rcWorkArea.left - rcMonitor.left);
            mmi.ptMaxPosition.y = Math.Abs(rcWorkArea.top - rcMonitor.top);
            mmi.ptMaxSize.x = Math.Abs(rcWorkArea.right - rcWorkArea.left);
            mmi.ptMaxSize.y = Math.Abs(rcWorkArea.bottom - rcWorkArea.top);
        }
        Marshal.StructureToPtr(mmi, lParam, true);
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct POINT
    {
        public int x;
        public int y;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct MINMAXINFO
    {
        public POINT ptReserved;
        public POINT ptMaxSize;
        public POINT ptMaxPosition;
        public POINT ptMinTrackSize;
        public POINT ptMaxTrackSize;
    }

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
    public class MONITORINFO
    {
        public int cbSize = Marshal.SizeOf(typeof(MONITORINFO));
        public RECT rcMonitor = new RECT();
        public RECT rcWork = new RECT();
        public int dwFlags = 0;
    }

    [StructLayout(LayoutKind.Sequential, Pack = 0)]
    public struct RECT
    {
        public int left;
        public int top;
        public int right;
        public int bottom;
    }

    [DllImport("user32")]
    internal static extern bool GetMonitorInfo(IntPtr hMonitor, MONITORINFO lpmi);

    [DllImport("user32")]
    internal static extern IntPtr MonitorFromWindow(IntPtr handle, int flags);

    private void Menu_Click(object sender, RoutedEventArgs e)
    {
        var button = sender as System.Windows.Controls.Button;
        if (button != null && button.ContextMenu != null)
        {
            button.ContextMenu.IsOpen = true;
        }
    }

    private void ThemeDark_Click(object sender, RoutedEventArgs e)
    {
        _themeService.SetTheme(ThemeType.Dark);
    }

    private void ThemeLight_Click(object sender, RoutedEventArgs e)
    {
        _themeService.SetTheme(ThemeType.Light);
    }

    private void ThemeSystem_Click(object sender, RoutedEventArgs e)
    {
        _themeService.SetTheme(ThemeType.System);
    }

    private void MainWindow_Loaded(object sender, RoutedEventArgs e)
    {
        RefreshHardwareInfo();
        LoadUserAvatar();
        RestoreWindowSettings();
        LoadOrganizations();
    }

    private void LoadOrganizations()
    {
        var user = OmsDesktop.Services.ApiService.Instance.CurrentUser;
        
        // 只有当组织数量大于1时才显示切换器
        if (user != null && user.Orgs != null && user.Orgs.Count > 1)
        {
            OrgSwitcher.ItemsSource = user.Orgs;
            
            // Set selected item based on CurrentOrgId
            if (user.CurrentOrgId.HasValue)
            {
                OrgSwitcher.SelectedValue = user.CurrentOrgId.Value;
            }
            else
            {
                OrgSwitcher.SelectedIndex = 0;
            }
            
            OrgSwitcher.Visibility = Visibility.Visible;
        }
        else
        {
            OrgSwitcher.Visibility = Visibility.Collapsed;
        }
    }

    private async void OrgSwitcher_SelectionChanged(object sender, SelectionChangedEventArgs e)
    {
        if (OrgSwitcher.SelectedItem is OmsDesktop.Models.Organization selectedOrg)
        {
             var user = OmsDesktop.Services.ApiService.Instance.CurrentUser;
             // Avoid triggering on initial load if the selection matches current
             if (user != null && user.CurrentOrgId == selectedOrg.Id)
             {
                 return;
             }

             var result = await OmsDesktop.Services.ApiService.Instance.SwitchOrganizationAsync(selectedOrg.Id);
             if (result.Success)
             {
                 // Refresh data or show success
                 // Reloading user info is already done in ApiService
                 // We might want to refresh other parts of the UI that depend on Org
                 LoadUserAvatar(); // Just in case avatar depends on org (unlikely but possible)
                 System.Windows.MessageBox.Show($"已切换到组织: {selectedOrg.Name}", "提示", MessageBoxButton.OK, MessageBoxImage.Information);
             }
             else
             {
                 // Revert selection if failed (simple way is to reload orgs to reset selection)
                 LoadOrganizations(); 
                 System.Windows.MessageBox.Show(result.Message, "切换失败", MessageBoxButton.OK, MessageBoxImage.Error);
             }
        }
    }

    private void RestoreWindowSettings()
    {
        var user = OmsDesktop.Services.ApiService.Instance.CurrentUser;
        if (user == null || string.IsNullOrWhiteSpace(user.Username)) return;

        var settings = OmsDesktop.Configuration.SettingsManager.Settings;
        if (settings.UserSettings.TryGetValue(user.Username, out var userSettings))
        {
            // Restore position and size if valid
            if (userSettings.WindowWidth > 0 && userSettings.WindowHeight > 0)
            {
                this.Top = userSettings.WindowTop;
                this.Left = userSettings.WindowLeft;
                this.Width = userSettings.WindowWidth;
                this.Height = userSettings.WindowHeight;
            }

            // Restore state
            if (userSettings.WindowState == (int)WindowState.Maximized)
            {
                this.WindowState = WindowState.Maximized;
            }
            else
            {
                this.WindowState = WindowState.Normal;
            }

            // Ensure window is on screen (basic check)
            if (this.Left < SystemParameters.VirtualScreenLeft || 
                this.Top < SystemParameters.VirtualScreenTop ||
                this.Left > SystemParameters.VirtualScreenWidth ||
                this.Top > SystemParameters.VirtualScreenHeight)
            {
                this.WindowStartupLocation = WindowStartupLocation.CenterScreen;
            }
        }
    }

    protected override void OnClosing(System.ComponentModel.CancelEventArgs e)
    {
        base.OnClosing(e);
        SaveWindowSettings();
    }

    private void SaveWindowSettings()
    {
        var user = OmsDesktop.Services.ApiService.Instance.CurrentUser;
        if (user == null || string.IsNullOrWhiteSpace(user.Username)) return;

        var settings = OmsDesktop.Configuration.SettingsManager.Settings;
        if (!settings.UserSettings.ContainsKey(user.Username))
        {
            settings.UserSettings[user.Username] = new OmsDesktop.Configuration.UserSettings();
        }

        var userSettings = settings.UserSettings[user.Username];

        if (this.WindowState == WindowState.Maximized)
        {
            userSettings.WindowState = (int)WindowState.Maximized;
            userSettings.WindowTop = this.RestoreBounds.Top;
            userSettings.WindowLeft = this.RestoreBounds.Left;
            userSettings.WindowWidth = this.RestoreBounds.Width;
            userSettings.WindowHeight = this.RestoreBounds.Height;
        }
        else
        {
            userSettings.WindowState = (int)this.WindowState; // Should be Normal or Minimized
            // If minimized, we might want to keep the last Normal bounds. 
            // But WindowState check handles maximized.
            // If Minimized, ActualHeight/Width might be irrelevant, but RestoreBounds usually works.
            
            if (this.WindowState == WindowState.Minimized)
            {
                 userSettings.WindowState = (int)WindowState.Normal; // Restore as normal next time
                 userSettings.WindowTop = this.RestoreBounds.Top;
                 userSettings.WindowLeft = this.RestoreBounds.Left;
                 userSettings.WindowWidth = this.RestoreBounds.Width;
                 userSettings.WindowHeight = this.RestoreBounds.Height;
            }
            else
            {
                userSettings.WindowTop = this.Top;
                userSettings.WindowLeft = this.Left;
                userSettings.WindowWidth = this.Width;
                userSettings.WindowHeight = this.Height;
            }
        }

        OmsDesktop.Configuration.SettingsManager.Save();
    }

    private void LoadUserAvatar()
    {
        var user = OmsDesktop.Services.ApiService.Instance.CurrentUser;
        if (user != null && !string.IsNullOrWhiteSpace(user.Avatar))
        {
            try
            {
                var bitmap = new BitmapImage();
                bitmap.BeginInit();
                
                // Handle Base64
                if (user.Avatar.StartsWith("data:image"))
                {
                    var base64Data = user.Avatar.Split(',')[1];
                    bitmap.StreamSource = new MemoryStream(Convert.FromBase64String(base64Data));
                }
                // Handle Absolute URL
                else if (Uri.IsWellFormedUriString(user.Avatar, UriKind.Absolute))
                {
                    bitmap.UriSource = new Uri(user.Avatar);
                }
                // Handle Relative URL starting with /
                else if (user.Avatar.StartsWith("/"))
                {
                    var apiBaseUrl = OmsDesktop.Configuration.SettingsManager.Settings.ApiBaseUrl;
                    if (string.IsNullOrWhiteSpace(apiBaseUrl))
                    {
                        apiBaseUrl = "https://os.jinlan.info";
                    }
                    
                    if (apiBaseUrl.EndsWith("/"))
                    {
                        apiBaseUrl = apiBaseUrl.TrimEnd('/');
                    }
                    
                    bitmap.UriSource = new Uri(apiBaseUrl + user.Avatar);
                }
                else
                {
                     // Fallback for relative path or invalid url - try to treat as absolute if it starts with http
                     if (user.Avatar.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                     {
                          bitmap.UriSource = new Uri(user.Avatar);
                     }
                }
                
                bitmap.CacheOption = BitmapCacheOption.OnLoad;
                bitmap.EndInit();
                UserAvatar.ImageSource = bitmap;
            }
            catch (Exception ex)
            {
                // Fallback to default if loading fails
                Debug.WriteLine($"Failed to load avatar: {ex.Message}");
            }
        }
    }

    private void Window_MouseDown(object sender, MouseButtonEventArgs e)
    {
        if (e.ChangedButton == MouseButton.Left)
        {
            if (e.ClickCount == 2)
            {
                if (this.WindowState == WindowState.Maximized)
                {
                    this.WindowState = WindowState.Normal;
                }
                else
                {
                    this.WindowState = WindowState.Maximized;
                }
            }
            else
            {
                this.DragMove();
            }
        }
    }

    private void Minimize_Click(object sender, RoutedEventArgs e)
    {
        this.WindowState = WindowState.Minimized;
    }

    private void Maximize_Click(object sender, RoutedEventArgs e)
    {
        if (this.WindowState == WindowState.Maximized)
            this.WindowState = WindowState.Normal;
        else
            this.WindowState = WindowState.Maximized;
    }

    private void Close_Click(object sender, RoutedEventArgs e)
    {
        this.Hide();
        MyNotifyIcon.ShowBalloonTip("OMS Desktop", "程序已最小化到托盘，双击图标可重新打开", Hardcodet.Wpf.TaskbarNotification.BalloonIcon.Info);
    }

    private void ShowWindow_Click(object sender, RoutedEventArgs e)
    {
        this.Show();
        this.WindowState = WindowState.Normal;
        this.Activate();
    }

    private void Exit_Click(object sender, RoutedEventArgs e)
    {
        MyNotifyIcon.Dispose();
        System.Windows.Application.Current.Shutdown();
    }

    private void Logout_Click(object sender, RoutedEventArgs e)
    {
        // 1. Dispose notify icon to remove it from tray
        MyNotifyIcon.Dispose();

        // 2. Change shutdown mode to avoid closing app when this window closes
        System.Windows.Application.Current.ShutdownMode = ShutdownMode.OnExplicitShutdown;

        // 3. Show Login Window
        var loginWindow = new LoginWindow();
        loginWindow.Show();

        // 4. Close Main Window
        this.Close();
    }

    private void CloseButton_MouseEnter(object sender, System.Windows.Input.MouseEventArgs e)
    {
        BtnClose.Background = new SolidColorBrush(System.Windows.Media.Color.FromRgb(0xFA, 0x51, 0x51));
        IconClose.Foreground = System.Windows.Media.Brushes.White;
    }

    private void CloseButton_MouseLeave(object sender, System.Windows.Input.MouseEventArgs e)
    {
        BtnClose.Background = System.Windows.Media.Brushes.Transparent;
        IconClose.Foreground = new SolidColorBrush(System.Windows.Media.Color.FromRgb(0x66, 0x66, 0x66));
    }

    private void RefreshHardwareInfo_Click(object sender, RoutedEventArgs e)
    {
        RefreshHardwareInfo();
    }

    private void RefreshHardwareInfo()
    {
        var sb = new StringBuilder();
        sb.AppendLine($"操作系统: {Environment.OSVersion}");
        sb.AppendLine($"处理器架构: {RuntimeInformation.ProcessArchitecture}");
        sb.AppendLine($".NET 版本: {Environment.Version}");
        sb.AppendLine($"逻辑处理器: {Environment.ProcessorCount}");
        sb.AppendLine($"系统页面大小: {Environment.SystemPageSize} bytes");
        
        // 获取当前进程内存占用
        var currentProcess = Process.GetCurrentProcess();
        sb.AppendLine($"当前进程内存占用: {currentProcess.WorkingSet64 / 1024 / 1024} MB");

        SystemInfoText.Text = sb.ToString();
    }

    private async void OpenFile_Click(object sender, RoutedEventArgs e)
    {
        var openFileDialog = new Microsoft.Win32.OpenFileDialog();
        if (openFileDialog.ShowDialog() == true)
        {
            try
            {
                var fileInfo = new FileInfo(openFileDialog.FileName);
                FileContentText.Text = $"正在读取文件: {fileInfo.Name} ({fileInfo.Length / 1024} KB)...";

                // 模拟读取大文件的前1KB，避免卡顿
                using (var stream = new FileStream(openFileDialog.FileName, FileMode.Open, FileAccess.Read, FileShare.Read, 4096, true))
                using (var reader = new StreamReader(stream))
                {
                    char[] buffer = new char[1024];
                    int bytesRead = await reader.ReadAsync(buffer, 0, buffer.Length);
                    string content = new string(buffer, 0, bytesRead);
                    
                    FileContentText.Text = $"文件路径: {openFileDialog.FileName}\n" +
                                         $"文件大小: {fileInfo.Length} bytes\n\n" +
                                         $"前1KB内容预览:\n{content}...";
                }
            }
            catch (Exception ex)
            {
                System.Windows.MessageBox.Show($"读取文件失败: {ex.Message}");
            }
        }
    }
}