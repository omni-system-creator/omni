using System.Windows;
using System.Windows.Input;
using OmsDesktop.Configuration;
using OmsDesktop.Services;

namespace OmsDesktop
{
    public partial class LoginWindow : Window
    {
        public LoginWindow()
        {
            InitializeComponent();
            LoadSettings();
        }

        private void LoadSettings()
        {
            try
            {
                // Load Remember Me
                if (SettingsManager.Settings.RememberMe)
                {
                    ChkRememberMe.IsChecked = true;
                    TxtUsername.Text = SettingsManager.Settings.SavedUsername;
                    TxtPassword.Password = SettingsManager.Settings.SavedPassword;
                }

                var url = SettingsManager.Settings.ApiBaseUrl;
                if (Uri.TryCreate(url, UriKind.Absolute, out var uri))
                {
                    TxtServerAddress.Text = uri.Host;
                    TxtServerPort.Text = uri.Port.ToString();
                    ChkHttps.IsChecked = uri.Scheme == Uri.UriSchemeHttps;
                    
                    // Hide port if it's default
                    if ((uri.Scheme == Uri.UriSchemeHttp && uri.Port == 80) ||
                        (uri.Scheme == Uri.UriSchemeHttps && uri.Port == 443))
                    {
                        TxtServerPort.Text = "";
                    }
                }
            }
            catch
            {
                // Ignore parse errors
            }
        }

        private void Window_MouseDown(object sender, MouseButtonEventArgs e)
        {
            if (e.ChangedButton == MouseButton.Left)
                this.DragMove();
        }

        private void Minimize_Click(object sender, RoutedEventArgs e)
        {
            this.WindowState = WindowState.Minimized;
        }

        private void Close_Click(object sender, RoutedEventArgs e)
        {
            System.Windows.Application.Current.Shutdown();
        }

        private async void Login_Click(object sender, RoutedEventArgs e)
        {
            string username = TxtUsername.Text;
            string password = TxtPassword.Password;

            if (string.IsNullOrWhiteSpace(username) || string.IsNullOrWhiteSpace(password))
            {
                System.Windows.MessageBox.Show("请输入用户名和密码", "提示", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            var button = sender as System.Windows.Controls.Button;
            if (button != null) button.IsEnabled = false;

            try
            {
                var (success, message) = await ApiService.Instance.LoginAsync(username, password);
                
                if (success)
                {
                    // Save Remember Me settings
                    SettingsManager.Settings.RememberMe = ChkRememberMe.IsChecked == true;
                    if (SettingsManager.Settings.RememberMe)
                    {
                        SettingsManager.Settings.SavedUsername = username;
                        SettingsManager.Settings.SavedPassword = password;
                    }
                    else
                    {
                        SettingsManager.Settings.SavedUsername = string.Empty;
                        SettingsManager.Settings.SavedPassword = string.Empty;
                    }
                    SettingsManager.Save();

                    // Open main window
                    MainWindow mainWindow = new MainWindow();
                    System.Windows.Application.Current.MainWindow = mainWindow; // Set as main window
                    mainWindow.Show();
                    
                    // Restore shutdown mode to close app when main window closes
                    System.Windows.Application.Current.ShutdownMode = ShutdownMode.OnMainWindowClose;
                    
                    this.Close();
                }
                else
                {
                    System.Windows.MessageBox.Show(message, "登录失败", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
            finally
            {
                if (button != null) button.IsEnabled = true;
            }
        }

        private void ShowSettings_Click(object sender, RoutedEventArgs e)
        {
            LoginView.Visibility = Visibility.Collapsed;
            SettingsView.Visibility = Visibility.Visible;
            LoadSettings();
        }

        private void BackToLogin_Click(object sender, RoutedEventArgs e)
        {
            SettingsView.Visibility = Visibility.Collapsed;
            LoginView.Visibility = Visibility.Visible;
        }

        private void SaveSettings_Click(object sender, RoutedEventArgs e)
        {
            string host = TxtServerAddress.Text.Trim();
            string portStr = TxtServerPort.Text.Trim();
            bool useHttps = ChkHttps.IsChecked ?? false;

            if (string.IsNullOrWhiteSpace(host))
            {
                System.Windows.MessageBox.Show("请输入服务器地址", "提示", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            var builder = new UriBuilder
            {
                Scheme = useHttps ? Uri.UriSchemeHttps : Uri.UriSchemeHttp,
                Host = host
            };

            if (!string.IsNullOrWhiteSpace(portStr) && int.TryParse(portStr, out int port))
            {
                builder.Port = port;
            }

            string newUrl = builder.ToString();
            SettingsManager.Settings.ApiBaseUrl = newUrl;
            SettingsManager.Save();
            
            ApiService.Instance.UpdateBaseUrl(newUrl);

            SettingsView.Visibility = Visibility.Collapsed;
            LoginView.Visibility = Visibility.Visible;
        }
    }
}