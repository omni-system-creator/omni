using System;
using System.Net.Http;
using System.Net.Http.Json;
using System.Threading.Tasks;
using OmsDesktop.Configuration;
using OmsDesktop.Models;

namespace OmsDesktop.Services;

public class ApiService
{
    private static ApiService? _instance;
    public static ApiService Instance => _instance ??= new ApiService();

    private readonly HttpClient _httpClient;
    private string _token = string.Empty;
    private User? _currentUser;

    public User? CurrentUser => _currentUser;

    private ApiService()
    {
        _httpClient = new HttpClient();
        UpdateBaseUrl(SettingsManager.Settings.ApiBaseUrl);
    }

    public void UpdateBaseUrl(string baseUrl)
    {
        if (string.IsNullOrWhiteSpace(baseUrl)) return;
        
        if (!baseUrl.EndsWith("/"))
        {
            baseUrl += "/";
        }
        
        _httpClient.BaseAddress = new Uri(baseUrl);
    }

    public async Task<(bool Success, string Message)> LoginAsync(string username, string password)
    {
        try
        {
            var request = new LoginRequest { Username = username, Password = password };
            // Assuming /api/login or /api/auth/login. I'll use /api/login as a starting point.
            // If the user didn't specify, I'll guess standard paths.
            // Based on "os.jinlan.info", it might be a custom system.
            // I'll try /api/system/login based on common enterprise patterns or just /api/login.
            // Let's assume /api/v1/login or just /api/login.
            // I'll use /api/login for now.
            
            var response = await _httpClient.PostAsJsonAsync("api/auth/login", request);
            
            if (response.IsSuccessStatusCode)
            {
                var result = await response.Content.ReadFromJsonAsync<ApiResponse<LoginResponse>>();
                if (result != null && result.Code == 200 && result.Data != null)
                {
                    _token = result.Data.Token;
                    _currentUser = result.Data.User;
                    _httpClient.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", _token);
                    return (true, "登录成功");
                }
                return (false, result?.Message ?? "登录失败");
            }
            
            return (false, $"请求失败: {response.StatusCode}");
        }
        catch (Exception ex)
        {
            return (false, $"连接错误: {ex.Message}");
        }
    }

    public async Task<User?> GetUserInfoAsync()
    {
        try
        {
            var response = await _httpClient.GetFromJsonAsync<ApiResponse<User>>("api/user/me");
            if (response != null && response.Code == 200 && response.Data != null)
            {
                _currentUser = response.Data;
                return _currentUser;
            }
        }
        catch
        {
            // Log error
        }
        return null;
    }

    public async Task<(bool Success, string Message)> SwitchOrganizationAsync(long orgId)
    {
        try
        {
            var response = await _httpClient.PostAsync($"api/user/switch-org/{orgId}", null);
            if (response.IsSuccessStatusCode)
            {
                var result = await response.Content.ReadFromJsonAsync<ApiResponse<object>>();
                if (result != null && result.Code == 200)
                {
                    // Refresh user info to get updated context if needed, 
                    // or just update local CurrentUser if the API doesn't return the full user object.
                    // Ideally, we fetch the user info again.
                    await GetUserInfoAsync();
                    return (true, "切换成功");
                }
                return (false, result?.Message ?? "切换失败");
            }
            return (false, $"请求失败: {response.StatusCode}");
        }
        catch (Exception ex)
        {
            return (false, $"连接错误: {ex.Message}");
        }
    }

    public void Logout()
    {
        _token = string.Empty;
        _currentUser = null;
        _httpClient.DefaultRequestHeaders.Authorization = null;
    }
}
