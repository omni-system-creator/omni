using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Configuration;
using omsapi.Infrastructure.Attributes;
using omsapi.Services.Interfaces;

namespace omsapi.Services
{
    [AutoInject]
    public class AiService : IAiService
    {
        private readonly HttpClient _httpClient;
        private readonly IConfiguration _configuration;

        public AiService(HttpClient httpClient, IConfiguration configuration)
        {
            _httpClient = httpClient;
            _configuration = configuration;
        }

        public async Task<float[]> GetEmbeddingAsync(string text, string model = "BAAI/bge-m3")
        {
            var apiKey = _configuration["SiliconFlow:ApiKey"];
            var baseUrl = _configuration["SiliconFlow:BaseUrl"] ?? "https://api.siliconflow.cn/v1";

            if (string.IsNullOrEmpty(apiKey))
            {
                // Return random vector for testing if no key? 
                // Or just zeros.
                // Let's return zeros if no key to allow testing without cost/key in some envs
                return new float[1024]; 
            }

            // Clean text (remove newlines usually helps)
            text = text.Replace("\r", " ").Replace("\n", " ");

            var requestBody = new
            {
                model = model,
                input = text,
                encoding_format = "float"
            };

            var json = JsonSerializer.Serialize(requestBody);
            var request = new HttpRequestMessage(HttpMethod.Post, $"{baseUrl}/embeddings");
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", apiKey);
            request.Content = new StringContent(json, Encoding.UTF8, "application/json");

            try 
            {
                var response = await _httpClient.SendAsync(request);
                response.EnsureSuccessStatusCode();

                var responseString = await response.Content.ReadAsStringAsync();
                using var doc = JsonDocument.Parse(responseString);
                
                // Response format: { "data": [ { "embedding": [0.1, ...] } ] }
                if (doc.RootElement.TryGetProperty("data", out var data) && data.GetArrayLength() > 0)
                {
                    var embeddingElement = data[0].GetProperty("embedding");
                    var vector = new List<float>();
                    foreach (var item in embeddingElement.EnumerateArray())
                    {
                        vector.Add((float)item.GetDouble());
                    }
                    return vector.ToArray();
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[AiService] Error generating embedding: {ex.Message}");
                throw;
            }

            return new float[0];
        }

        public async Task<List<float[]>> GetEmbeddingsAsync(List<string> texts, string model = "BAAI/bge-m3")
        {
            var apiKey = _configuration["SiliconFlow:ApiKey"];
            var baseUrl = _configuration["SiliconFlow:BaseUrl"] ?? "https://api.siliconflow.cn/v1";
            var results = new List<float[]>();

            if (string.IsNullOrEmpty(apiKey) || texts == null || !texts.Any())
            {
                return results;
            }

            // Clean texts
            var cleanTexts = texts.Select(t => t.Replace("\r", " ").Replace("\n", " ")).ToList();

            // SiliconFlow / OpenAI API supports array input
            var requestBody = new
            {
                model = model,
                input = cleanTexts,
                encoding_format = "float"
            };

            var json = JsonSerializer.Serialize(requestBody);
            var request = new HttpRequestMessage(HttpMethod.Post, $"{baseUrl}/embeddings");
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", apiKey);
            request.Content = new StringContent(json, Encoding.UTF8, "application/json");

            try 
            {
                var response = await _httpClient.SendAsync(request);
                response.EnsureSuccessStatusCode();

                var responseString = await response.Content.ReadAsStringAsync();
                using var doc = JsonDocument.Parse(responseString);
                
                if (doc.RootElement.TryGetProperty("data", out var data) && data.GetArrayLength() > 0)
                {
                    // The API returns embeddings in the same order as input
                    foreach (var item in data.EnumerateArray())
                    {
                        var embeddingElement = item.GetProperty("embedding");
                        var vector = new List<float>();
                        foreach (var val in embeddingElement.EnumerateArray())
                        {
                            vector.Add((float)val.GetDouble());
                        }
                        results.Add(vector.ToArray());
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[AiService] Error generating batch embeddings: {ex.Message}");
                // Fallback to serial processing if batch fails (optional, but good for robustness)
                // For now, just throw or return partial
                throw;
            }

            return results;
        }
        public async Task<string> GetImageDescriptionAsync(byte[] imageBytes, string mimeType, string model = "deepseek-ai/DeepSeek-V2.5")
        {
            var apiKey = _configuration["SiliconFlow:ApiKey"];
            var baseUrl = _configuration["SiliconFlow:BaseUrl"] ?? "https://api.siliconflow.cn/v1";

            if (string.IsNullOrEmpty(apiKey))
            {
                return "[System: Image description requires API Key]";
            }

            // SiliconFlow / OpenAI Vision API
            // Usually uses chat/completions with image_url content type
            var base64Image = Convert.ToBase64String(imageBytes);
            var dataUrl = $"data:{mimeType};base64,{base64Image}";

            // Auto-switch to a vision-capable model if the requested one is likely text-only
            // Common vision models: gpt-4-vision-preview, qwen-vl-max, etc.
            // On SiliconFlow, Qwen-VL or Yi-VL might be available.
            // Let's try to use a safe default if the user didn't specify a known vision model, 
            // but usually we respect the parameter. 
            // However, DeepSeek-V2.5 is text-only (as of knowledge cutoff). 
            // Let's hardcode a known vision model if the default is passed, or trust the user.
            // For now, let's use "Qwen/Qwen2-VL-72B-Instruct" as a powerful vision model available on SiliconFlow (assuming it is).
            // Or "OpenGVLab/InternVL2-26B" etc.
            // Let's default to "Qwen/Qwen2-VL-72B-Instruct" if the passed model is the default text one.
            if (model == "deepseek-ai/DeepSeek-V2.5")
            {
                model = "Qwen/Qwen2-VL-72B-Instruct";
            }

            var requestBody = new
            {
                model = model,
                messages = new[]
                {
                    new
                    {
                        role = "user",
                        content = new object[]
                        {
                            new { type = "text", text = "请详细描述这张图片的内容，包括主要物体、文字（如果有）、场景和氛围。请用中文回答。" },
                            new { type = "image_url", image_url = new { url = dataUrl } }
                        }
                    }
                },
                max_tokens = 500
            };

            var json = JsonSerializer.Serialize(requestBody);
            var request = new HttpRequestMessage(HttpMethod.Post, $"{baseUrl}/chat/completions");
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", apiKey);
            request.Content = new StringContent(json, Encoding.UTF8, "application/json");

            try
            {
                var response = await _httpClient.SendAsync(request);
                // If 404 or 400, it might be model not found or not supporting vision.
                if (!response.IsSuccessStatusCode)
                {
                    var error = await response.Content.ReadAsStringAsync();
                    Console.WriteLine($"[AiService] Vision API Error: {response.StatusCode} - {error}");
                    return $"[System: Image analysis failed ({response.StatusCode})]";
                }

                var responseString = await response.Content.ReadAsStringAsync();
                using var doc = JsonDocument.Parse(responseString);
                
                if (doc.RootElement.TryGetProperty("choices", out var choices) && choices.GetArrayLength() > 0)
                {
                    var content = choices[0].GetProperty("message").GetProperty("content").GetString();
                    return content ?? "";
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[AiService] Error analyzing image: {ex.Message}");
                return $"[System: Image analysis error: {ex.Message}]";
            }

            return "";
        }

        public async Task<string> GetChatCompletionAsync(string message, string systemPrompt, string model = "deepseek-ai/DeepSeek-V3")
        {
            var apiKey = _configuration["SiliconFlow:ApiKey"];
            var baseUrl = _configuration["SiliconFlow:BaseUrl"] ?? "https://api.siliconflow.cn/v1";

            if (string.IsNullOrEmpty(apiKey))
            {
                return "[System: Chat completion requires API Key]";
            }

            var requestBody = new
            {
                model = model,
                messages = new[]
                {
                    new { role = "system", content = systemPrompt },
                    new { role = "user", content = message }
                },
                max_tokens = 1000,
                temperature = 0.7
            };

            var json = JsonSerializer.Serialize(requestBody);
            var request = new HttpRequestMessage(HttpMethod.Post, $"{baseUrl}/chat/completions");
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", apiKey);
            request.Content = new StringContent(json, Encoding.UTF8, "application/json");

            try
            {
                var response = await _httpClient.SendAsync(request);
                if (!response.IsSuccessStatusCode)
                {
                    var error = await response.Content.ReadAsStringAsync();
                    Console.WriteLine($"[AiService] Chat API Error: {response.StatusCode} - {error}");
                    return $"[System: Chat completion failed ({response.StatusCode})]";
                }

                var responseString = await response.Content.ReadAsStringAsync();
                using var doc = JsonDocument.Parse(responseString);

                if (doc.RootElement.TryGetProperty("choices", out var choices) && choices.GetArrayLength() > 0)
                {
                    var content = choices[0].GetProperty("message").GetProperty("content").GetString();
                    return content ?? "";
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[AiService] Error in chat completion: {ex.Message}");
                return $"[System: Chat completion error: {ex.Message}]";
            }

            return "";
        }

        public async IAsyncEnumerable<string> GetChatCompletionStreamAsync(string message, string systemPrompt, string model = "deepseek-ai/DeepSeek-V3")
        {
            var apiKey = _configuration["SiliconFlow:ApiKey"];
            var baseUrl = _configuration["SiliconFlow:BaseUrl"] ?? "https://api.siliconflow.cn/v1";

            if (string.IsNullOrEmpty(apiKey))
            {
                yield return "[System: Chat completion requires API Key]";
                yield break;
            }

            var requestBody = new
            {
                model = model,
                messages = new[]
                {
                    new { role = "system", content = systemPrompt },
                    new { role = "user", content = message }
                },
                max_tokens = 1000,
                temperature = 0.7,
                stream = true
            };

            var json = JsonSerializer.Serialize(requestBody);
            var request = new HttpRequestMessage(HttpMethod.Post, $"{baseUrl}/chat/completions");
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", apiKey);
            request.Content = new StringContent(json, Encoding.UTF8, "application/json");

            HttpResponseMessage? response = null;
            string? errorMsg = null;
            try
            {
                response = await _httpClient.SendAsync(request, HttpCompletionOption.ResponseHeadersRead);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[AiService] Error in chat completion stream init: {ex.Message}");
                errorMsg = $"[System: Chat completion error: {ex.Message}]";
            }

            if (errorMsg != null)
            {
                yield return errorMsg;
                yield break;
            }

            if (!response!.IsSuccessStatusCode)
            {
                var error = await response.Content.ReadAsStringAsync();
                Console.WriteLine($"[AiService] Chat API Error: {response.StatusCode} - {error}");
                yield return $"[System: Chat completion failed ({response.StatusCode})]";
                yield break;
            }

            using var stream = await response.Content.ReadAsStreamAsync();
            using var reader = new StreamReader(stream);

            string? line;
            while ((line = await reader.ReadLineAsync()) != null)
            {
                if (string.IsNullOrWhiteSpace(line)) continue;
                if (!line.StartsWith("data: ")) continue;

                var data = line.Substring(6); // Remove "data: "
                if (data == "[DONE]") break;

                string? content = null;
                try
                {
                    using var doc = JsonDocument.Parse(data);
                    if (doc.RootElement.TryGetProperty("choices", out var choices) && choices.GetArrayLength() > 0)
                    {
                        var choice = choices[0];
                        if (choice.TryGetProperty("delta", out var delta) && delta.TryGetProperty("content", out var contentProp))
                        {
                            content = contentProp.GetString();
                        }
                    }
                }
                catch (Exception)
                {
                    // Ignore parse errors for partial chunks
                }

                if (!string.IsNullOrEmpty(content))
                {
                    yield return content;
                }
            }
        }
        public async Task<(string? OrgName, string? LicenseCode, string? OrgShortName, string? OrgAbbr)> OcrLicenseAsync(byte[] imageBytes, string mimeType)
        {
            var apiKey = _configuration["SiliconFlow:ApiKey"];
            var baseUrl = _configuration["SiliconFlow:BaseUrl"] ?? "https://api.siliconflow.cn/v1";

            if (string.IsNullOrEmpty(apiKey))
            {
                return (null, null, null, null);
            }

            var base64Image = Convert.ToBase64String(imageBytes);
            var dataUrl = $"data:{mimeType};base64,{base64Image}";

            // Use a vision model
            string model = "Qwen/Qwen2-VL-72B-Instruct"; // Default to a good vision model

            var requestBody = new
            {
                model = model,
                messages = new[]
                {
                    new
                    {
                        role = "user",
                        content = new object[]
                        {
                            new { type = "text", text = "请分析这张营业执照/证书图片，提取并返回以下信息为一个JSON对象：1) orgName 组织全称；2) licenseCode 证照编码（统一社会信用代码/注册号）；3) orgShortName 简称（如公司简称，去除“有限公司”等后缀并保留核心名称）；4) orgAbbr 字母缩写（根据中文名称拼音首字母生成，若无法生成则置为null）。只返回纯JSON字符串，不要Markdown。" },
                            new { type = "image_url", image_url = new { url = dataUrl } }
                        }
                    }
                },
                max_tokens = 500,
                temperature = 0.1 // Low temperature for deterministic output
            };

            var json = JsonSerializer.Serialize(requestBody);
            var request = new HttpRequestMessage(HttpMethod.Post, $"{baseUrl}/chat/completions");
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", apiKey);
            request.Content = new StringContent(json, Encoding.UTF8, "application/json");

            try
            {
                var response = await _httpClient.SendAsync(request);
                if (!response.IsSuccessStatusCode)
                {
                    var error = await response.Content.ReadAsStringAsync();
                    Console.WriteLine($"[AiService] OCR Error: {response.StatusCode} - {error}");
                    return (null, null, null, null);
                }

                var responseString = await response.Content.ReadAsStringAsync();
                using var doc = JsonDocument.Parse(responseString);
                
                if (doc.RootElement.TryGetProperty("choices", out var choices) && choices.GetArrayLength() > 0)
                {
                    var content = choices[0].GetProperty("message").GetProperty("content").GetString();
                    if (!string.IsNullOrEmpty(content))
                    {
                        // Try to parse JSON from content
                        // Remove markdown code blocks if present
                        content = content.Replace("```json", "").Replace("```", "").Trim();
                        try 
                        {
                            using var jsonDoc = JsonDocument.Parse(content);
                            string? orgName = null;
                            string? licenseCode = null;
                            string? orgShortName = null;
                            string? orgAbbr = null;

                            if (jsonDoc.RootElement.TryGetProperty("orgName", out var orgNameProp))
                                orgName = orgNameProp.GetString();
                            if (jsonDoc.RootElement.TryGetProperty("licenseCode", out var licenseCodeProp))
                                licenseCode = licenseCodeProp.GetString();
                            if (jsonDoc.RootElement.TryGetProperty("orgShortName", out var orgShortNameProp))
                                orgShortName = orgShortNameProp.GetString();
                            if (jsonDoc.RootElement.TryGetProperty("orgAbbr", out var orgAbbrProp))
                                orgAbbr = orgAbbrProp.GetString();

                            return (orgName, licenseCode, orgShortName, orgAbbr);
                        }
                        catch (JsonException)
                        {
                            Console.WriteLine($"[AiService] Failed to parse OCR JSON: {content}");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[AiService] Error in OCR: {ex.Message}");
            }

            return (null, null, null, null);
        }
    }
}
