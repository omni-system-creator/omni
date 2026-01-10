namespace omsapi.Services.Interfaces
{
    public interface IAiService
    {
        Task<float[]> GetEmbeddingAsync(string text, string model = "BAAI/bge-m3");
        Task<List<float[]>> GetEmbeddingsAsync(List<string> texts, string model = "BAAI/bge-m3");
        Task<string> GetChatCompletionAsync(string prompt, string model = "deepseek-ai/DeepSeek-V3");
        Task<string> GetChatCompletionAsync(string message, string systemPrompt, string model = "deepseek-ai/DeepSeek-V3", double temperature = 0.7);
        Task<string> GetImageAnalysisAsync(byte[] imageBytes, string prompt = "Extract all text from this image.", string model = "Qwen/Qwen2-VL-72B-Instruct");
        Task<string> GetImageDescriptionAsync(byte[] imageBytes, string mimeType, string model = "deepseek-ai/DeepSeek-V2.5");
        IAsyncEnumerable<string> GetChatCompletionStreamAsync(string message, string systemPrompt, string model = "deepseek-ai/DeepSeek-V3");
        Task<(string? OrgName, string? LicenseCode, string? OrgShortName, string? OrgAbbr)> OcrLicenseAsync(byte[] imageBytes, string mimeType);
    }
}
