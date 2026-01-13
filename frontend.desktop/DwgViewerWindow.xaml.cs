using System;
using System.IO;
using System.Threading.Tasks;
using System.Windows;
using netDxf;
using OmsDesktop.Services;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;
using MessageBox = System.Windows.MessageBox;

namespace OmsDesktop;

public partial class DwgViewerWindow : Window
{
    private string _docId;
    private string _fileName;

    public string FileName => _fileName;

    public DwgViewerWindow(string docId, string fileName)
    {
        InitializeComponent();
        _docId = docId;
        _fileName = fileName;
        DataContext = this;
        
        Loaded += DwgViewerWindow_Loaded;
    }

    private async void DwgViewerWindow_Loaded(object sender, RoutedEventArgs e)
    {
        await LoadDxfAsync();
    }

    private async Task LoadDxfAsync()
    {
        loadingOverlay.Visibility = Visibility.Visible;
        statusText.Text = "正在下载图纸...";
        
        try
        {
            var stream = await ApiService.Instance.DownloadDwgPreviewAsync(_docId);
            if (stream == null)
            {
                statusText.Text = "下载失败";
                MessageBox.Show("无法下载图纸预览文件。", "错误", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }

            statusText.Text = "正在解析DXF...";
            
            // Debug: Save to temp file to inspect content if needed
            var tempFile = System.IO.Path.GetTempFileName();
            using (var fileStream = File.Create(tempFile))
            {
                await stream.CopyToAsync(fileStream);
            }
            
            // Check file content briefly
            var firstLines = File.ReadLines(tempFile).Take(10).ToList();
            if (firstLines.Any(l => l.Contains("<!DOCTYPE html>") || l.Contains("<html"))) 
            {
                statusText.Text = "服务器错误";
                var content = File.ReadAllText(tempFile);
                MessageBox.Show($"服务器返回了HTML而非DXF。可能是错误页面。\n预览:\n{content.Substring(0, Math.Min(500, content.Length))}", "下载错误", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }

            await Task.Run(() =>
            {
                try 
                {
                    // Load from file instead of stream to be safer and inspectable
                    var doc = DxfDocument.Load(tempFile);
                    Dispatcher.Invoke(() =>
                    {
                        dxfCanvas.Document = doc;
                        statusText.Text = "就绪";
                    });
                }
                catch (Exception ex)
                {
                    Dispatcher.Invoke(() =>
                    {
                        statusText.Text = "解析失败";
                        // Read version if possible
                        string version = "Unknown";
                        try 
                        {
                            var lines = File.ReadAllLines(tempFile);
                            for(int i=0; i<lines.Length; i++) 
                            {
                                if(lines[i].Trim() == "$ACADVER" && i+2 < lines.Length)
                                {
                                    version = lines[i+2].Trim();
                                    break;
                                }
                            }
                        } catch {}

                        MessageBox.Show($"解析DXF文件失败: {ex.Message}\n检测到的版本: {version}\n临时文件已保存至: {tempFile}", "错误", MessageBoxButton.OK, MessageBoxImage.Error);
                    });
                }
                finally 
                {
                    // Clean up temp file later or keep for debug
                    // File.Delete(tempFile);
                }
            });
        }
        catch (Exception ex)
        {
             statusText.Text = "错误";
             MessageBox.Show($"发生错误: {ex.Message}", "错误", MessageBoxButton.OK, MessageBoxImage.Error);
        }
        finally
        {
            loadingOverlay.Visibility = Visibility.Collapsed;
        }
    }

    private void FitView_Click(object sender, RoutedEventArgs e)
    {
        // Re-set document to trigger FitToView
        var doc = dxfCanvas.Document;
        dxfCanvas.Document = null;
        dxfCanvas.Document = doc;
    }
}
