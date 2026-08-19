using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using System.Threading;
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
        private const string DefaultVisionModel = "Qwen/Qwen3-VL-32B-Instruct";
        private const string DefaultOcrModel = "Qwen/Qwen3-VL-32B-Instruct";
        private static List<string>? _cachedModels;
        private static readonly SemaphoreSlim _modelLock = new(1, 1);

        public AiService(HttpClient httpClient, IConfiguration configuration)
        {
            _httpClient = httpClient;
            _configuration = configuration;
        }

        /// <summary>
        /// 统一读取视觉模型配置；当调用方未传入模型时，回退到配置文件中的默认视觉模型。
        /// </summary>
        private string GetVisionModel(string? model = null)
        {
            if (!string.IsNullOrWhiteSpace(model) && !model.Equals("deepseek-ai/DeepSeek-V2.5", StringComparison.OrdinalIgnoreCase))
            {
                return model;
            }

            return _configuration["SiliconFlow:VisionModel"] ?? DefaultVisionModel;
        }

        /// <summary>
        /// 统一读取 OCR 模型配置，营业执照等证照识别场景单独使用专项模型。
        /// </summary>
        private string GetOcrModel()
        {
            return _configuration["SiliconFlow:OcrModel"] ?? DefaultOcrModel;
        }

        private async Task<string> ValidateModelAsync(string model)
        {
            if (string.IsNullOrEmpty(model)) return "deepseek-ai/DeepSeek-V2.5";

            if (_cachedModels == null)
            {
                await _modelLock.WaitAsync();
                try
                {
                    if (_cachedModels == null)
                    {
                        _cachedModels = await GetAvailableModelsAsync();
                    }
                }
                finally
                {
                    _modelLock.Release();
                }
            }

            if (_cachedModels != null && _cachedModels.Count > 0 && !_cachedModels.Contains(model))
            {
                // Try to find a fallback
                // 1. Exact match ignored case? (Ids are usually case sensitive but let's check)
                var exact = _cachedModels.FirstOrDefault(m => m.Equals(model, StringComparison.OrdinalIgnoreCase));
                if (exact != null) return exact;

                // 2. Fallback for DeepSeek-V3 -> V2.5
                if (model.Contains("DeepSeek-V3"))
                {
                    var v25 = _cachedModels.FirstOrDefault(m => m.Contains("DeepSeek-V2.5"));
                    if (v25 != null) 
                    {
                        Console.WriteLine($"[AiService] Model {model} not found. Switching to {v25}");
                        return v25;
                    }
                }

                // 3. Any DeepSeek model
                if (model.Contains("DeepSeek", StringComparison.OrdinalIgnoreCase))
                {
                    var ds = _cachedModels.FirstOrDefault(m => m.Contains("DeepSeek", StringComparison.OrdinalIgnoreCase));
                    if (ds != null)
                    {
                        Console.WriteLine($"[AiService] Model {model} not found. Switching to {ds}");
                        return ds;
                    }
                }
                
                // 4. Any Qwen model (good alternative)
                var qwen = _cachedModels.FirstOrDefault(m => m.Contains("Qwen", StringComparison.OrdinalIgnoreCase));
                if (qwen != null)
                {
                    Console.WriteLine($"[AiService] Model {model} not found. Switching to {qwen}");
                    return qwen;
                }

                // 5. First available
                var first = _cachedModels.First();
                Console.WriteLine($"[AiService] Model {model} not found. Switching to {first}");
                return first;
            }

            return model;
        }

        public async Task<float[]> GetEmbeddingAsync(string text, string model = "BAAI/bge-m3")
        {
            // Embeddings usually use specific models, validation might be tricky if we mix chat/embedding models in list.
            // SiliconFlow /models returns all. 
            // We can try to validate but embedding models are specific. 
            // Let's skip auto-fallback for embeddings for now unless requested, or just do basic check.
            // "BAAI/bge-m3" is in the list I saw.

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

        public async Task<string> GetChatCompletionAsync(string prompt, string model = "deepseek-ai/DeepSeek-V2.5")
        {
            model = await ValidateModelAsync(model);
            var apiKey = _configuration["SiliconFlow:ApiKey"];
            var baseUrl = _configuration["SiliconFlow:BaseUrl"] ?? "https://api.siliconflow.cn/v1";

            if (string.IsNullOrEmpty(apiKey))
            {
                return "AI API Key missing. Cannot generate analysis.";
            }

            var requestBody = new
            {
                model = model,
                messages = new[]
                {
                    new { role = "user", content = prompt }
                },
                temperature = 0.7,
                max_tokens = 8192
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
                    throw new Exception($"Chat API Error: {response.StatusCode} - {error}");
                }

                var responseString = await response.Content.ReadAsStringAsync();
                using var doc = JsonDocument.Parse(responseString);
                
                if (doc.RootElement.TryGetProperty("choices", out var choices) && choices.GetArrayLength() > 0)
                {
                    return choices[0].GetProperty("message").GetProperty("content").GetString() ?? "";
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[AiService] Error in chat completion: {ex.Message}");
                throw;
            }

            return "Analysis failed due to API error.";
        }

        public async Task<string> GetImageAnalysisAsync(byte[] imageBytes, string prompt = "Extract all text from this image.", string model = "")
        {
            var apiKey = _configuration["SiliconFlow:ApiKey"];
            var baseUrl = _configuration["SiliconFlow:BaseUrl"] ?? "https://api.siliconflow.cn/v1";

            if (string.IsNullOrEmpty(apiKey)) return "";

            // 视觉识别默认走配置文件中的视觉模型，避免业务代码里散落硬编码。
            model = GetVisionModel(model);

            var base64Image = Convert.ToBase64String(imageBytes);
            var imageUri = $"data:image/jpeg;base64,{base64Image}";

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
                            new { type = "text", text = prompt },
                            new { type = "image_url", image_url = new { url = imageUri } }
                        }
                    }
                },
                max_tokens = 2048
            };

            var json = JsonSerializer.Serialize(requestBody);
            var request = new HttpRequestMessage(HttpMethod.Post, $"{baseUrl}/chat/completions");
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", apiKey);
            request.Content = new StringContent(json, Encoding.UTF8, "application/json");

            try
            {
                var response = await _httpClient.SendAsync(request);
                // Don't throw immediately, check status
                if (!response.IsSuccessStatusCode)
                {
                    var error = await response.Content.ReadAsStringAsync();
                    Console.WriteLine($"[AiService] Vision API Error: {response.StatusCode} - {error}");
                    return "";
                }

                var responseString = await response.Content.ReadAsStringAsync();
                using var doc = JsonDocument.Parse(responseString);
                
                if (doc.RootElement.TryGetProperty("choices", out var choices) && choices.GetArrayLength() > 0)
                {
                    return choices[0].GetProperty("message").GetProperty("content").GetString() ?? "";
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[AiService] Error in image analysis: {ex.Message}");
            }

            return "";
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

            // 视觉描述通过图片输入走对话接口。
            var base64Image = Convert.ToBase64String(imageBytes);
            var dataUrl = $"data:{mimeType};base64,{base64Image}";

            if (string.IsNullOrWhiteSpace(model) || model == "deepseek-ai/DeepSeek-V2.5")
            {
                // 当调用方沿用文本模型默认值时，自动切换到配置中的视觉模型。
                model = GetVisionModel(model);
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

        public async Task<string> GetChatCompletionAsync(string message, string systemPrompt, string model = "deepseek-ai/DeepSeek-V2.5", double temperature = 0.7)
        {
            model = await ValidateModelAsync(model);
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
                max_tokens = 8192,
                temperature = temperature
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
                    throw new Exception($"Chat API Error: {response.StatusCode} - {error}");
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
                throw;
            }

            return "";
        }

        public async IAsyncEnumerable<string> GetChatCompletionStreamAsync(string message, string systemPrompt, string model = "deepseek-ai/DeepSeek-V2.5")
        {
            model = await ValidateModelAsync(model);
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
                max_tokens = 8192,
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

            // 营业执照 OCR 单独走配置中的 OCR 模型，便于和通用视觉模型分开调优。
            string model = GetOcrModel();

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
                throw;
            }

            return (null, null, null, null);
        }
        public async Task<List<string>> GetAvailableModelsAsync()
        {
            var apiKey = _configuration["SiliconFlow:ApiKey"];
            var baseUrl = _configuration["SiliconFlow:BaseUrl"] ?? "https://api.siliconflow.cn/v1";
            var results = new List<string>();

            if (string.IsNullOrEmpty(apiKey))
            {
                return results;
            }

            var request = new HttpRequestMessage(HttpMethod.Get, $"{baseUrl}/models");
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", apiKey);

            try
            {
                var response = await _httpClient.SendAsync(request);
                response.EnsureSuccessStatusCode();

                var responseString = await response.Content.ReadAsStringAsync();
                using var doc = JsonDocument.Parse(responseString);

                if (doc.RootElement.TryGetProperty("data", out var data) && data.ValueKind == JsonValueKind.Array)
                {
                    foreach (var item in data.EnumerateArray())
                    {
                        if (item.TryGetProperty("id", out var idElement))
                        {
                            results.Add(idElement.GetString() ?? string.Empty);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[AiService] Error listing models: {ex.Message}");
                // We don't throw here, just return empty list or what we found
            }

            return results;
        }
    }
}
