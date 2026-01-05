namespace omsapi.Services.Interfaces
{
    public interface IAiService
    {
        Task<float[]> GetEmbeddingAsync(string text, string model = "BAAI/bge-m3");
        Task<List<float[]>> GetEmbeddingsAsync(List<string> texts, string model = "BAAI/bge-m3");
        Task<string> GetImageDescriptionAsync(byte[] imageBytes, string mimeType, string model = "deepseek-ai/DeepSeek-V2.5"); // Note: DeepSeek might not support vision, might need to switch to Qwen or similar in implementation default
    }
}
