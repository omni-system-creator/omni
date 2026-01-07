using System.Text.RegularExpressions;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;
using omsapi.Data;
using omsapi.Infrastructure.Attributes;
using omsapi.Services.Interfaces;
using OmsApi.Models.Dtos.Kb;
using OmsApi.Models.Entities.Kb;
using System.Net.Http;
using System.Text.Json;
using System.Text;
using System.Net.Http.Headers;
using Microsoft.AspNetCore.StaticFiles;
using Pgvector;
using Pgvector.EntityFrameworkCore;
using NPOI.XWPF.UserModel; // For Docx
using NPOI.SS.UserModel; // For Excel
using NPOI.XSSF.UserModel; // For Xlsx
using NPOI.HSSF.UserModel; // For Xls
using UglyToad.PdfPig; // For PDF
using DocumentFormat.OpenXml.Packaging; // For Pptx

namespace omsapi.Services
{
    [AutoInject]
    public class KbService : IKbService
    {
        private readonly OmsContext _context;
        private readonly OmsPgContext _pgContext;
        private readonly IWebHostEnvironment _env;
        private readonly IServiceScopeFactory _scopeFactory;
        private readonly IConfiguration _configuration;
        private readonly HttpClient _httpClient;
        private readonly IAiService _aiService;

        public KbService(OmsContext context, OmsPgContext pgContext, IWebHostEnvironment env, IServiceScopeFactory scopeFactory, IConfiguration configuration, HttpClient httpClient, IAiService aiService)
        {
            _context = context;
            _pgContext = pgContext;
            _env = env;
            _scopeFactory = scopeFactory;
            _configuration = configuration;
            _httpClient = httpClient;
            _aiService = aiService;
        }

        // --- KB Management ---

        public async Task<List<KbInfoDto>> GetAllKbsAsync()
        {
            var kbs = await _context.KbInfos
                .Include(k => k.Files)
                .OrderBy(k => k.SortOrder)
                .ThenByDescending(k => k.CreatedAt)
                .ToListAsync();

            var kbIds = kbs.Select(k => k.Id).ToList();
            var wordCounts = await _pgContext.KbNodes
                .Where(n => kbIds.Contains(n.KbId))
                .GroupBy(n => n.KbId)
                .Select(g => new { KbId = g.Key, Count = g.Sum(n => 
                    (n.Title != null ? n.Title.Length : 0) + 
                    (n.Summary != null ? n.Summary.Length : 0) + 
                    (n.Content != null ? n.Content.Length : 0)) })
                .ToListAsync();
            var wcDict = wordCounts.ToDictionary(x => x.KbId, x => x.Count);

            return kbs.Select(k => new KbInfoDto
            {
                Id = k.Id,
                Name = k.Name,
                Description = k.Description,
                Category = k.Category,
                Type = k.Type,
                SortOrder = k.SortOrder,
                CreatedAt = k.CreatedAt,
                UpdatedAt = k.UpdatedAt,
                FileCount = k.Files.Count,
                WordCount = wcDict.TryGetValue(k.Id, out var wc) ? wc : 0
            }).ToList();
        }

        public async Task<KbInfoDto?> GetKbByIdAsync(Guid id)
        {
            var k = await _context.KbInfos
                .Include(k => k.Files)
                .FirstOrDefaultAsync(x => x.Id == id);

            if (k == null) return null;

            // Compute word count for this KB
            var wc = await _pgContext.KbNodes
                .Where(n => n.KbId == k.Id)
                .SumAsync(n => 
                    (n.Title != null ? n.Title.Length : 0) + 
                    (n.Summary != null ? n.Summary.Length : 0) + 
                    (n.Content != null ? n.Content.Length : 0));

            return new KbInfoDto
            {
                Id = k.Id,
                Name = k.Name,
                Description = k.Description,
                Category = k.Category,
                Type = k.Type,
                SortOrder = k.SortOrder,
                CreatedAt = k.CreatedAt,
                UpdatedAt = k.UpdatedAt,
                FileCount = k.Files.Count,
                WordCount = wc
            };
        }

        public async Task<KbInfoDto> CreateKbAsync(CreateKbDto dto, Guid userId)
        {
            var kb = new KbInfo
            {
                Id = Guid.NewGuid(),
                Name = dto.Name,
                Description = dto.Description,
                Category = dto.Category,
                Type = dto.Type,
                SortOrder = 0,
                CreatedAt = DateTime.Now,
                CreatedBy = userId
            };

            _context.KbInfos.Add(kb);
            await _context.SaveChangesAsync();

            return new KbInfoDto
            {
                Id = kb.Id,
                Name = kb.Name,
                Description = kb.Description,
                Category = kb.Category,
                Type = kb.Type,
                SortOrder = kb.SortOrder,
                CreatedAt = kb.CreatedAt,
                FileCount = 0
            };
        }

        public async Task<bool> UpdateKbAsync(Guid id, UpdateKbDto dto)
        {
            var kb = await _context.KbInfos.FindAsync(id);
            if (kb == null) return false;

            kb.Name = dto.Name;
            kb.Description = dto.Description;
            kb.Category = dto.Category;
            kb.Type = dto.Type;
            if (dto.SortOrder.HasValue)
            {
                kb.SortOrder = dto.SortOrder.Value;
            }
            kb.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> DeleteKbAsync(Guid id)
        {
            var kb = await _context.KbInfos.FindAsync(id);
            if (kb == null) return false;

            _context.KbInfos.Remove(kb);
            await _context.SaveChangesAsync();
            return true;
        }

        // --- File Management ---

        public async Task<List<KbFileDto>> GetKbFilesAsync(Guid kbId)
        {
            var files = await _context.KbFiles
                .Where(f => f.KbId == kbId)
                .OrderByDescending(f => f.IsFolder) // Folders first
                .ThenByDescending(f => f.UploadTime)
                .ToListAsync();

            return files.Select(f => new KbFileDto
            {
                Id = f.Id,
                Name = f.Name,
                Size = f.IsFolder ? "-" : FormatSize(f.Size),
                Status = f.Status,
                UploadTime = f.UploadTime.ToString("yyyy-MM-dd HH:mm"),
                Path = f.Path,
                IsFolder = f.IsFolder,
                ParentId = f.ParentId
            }).ToList();
        }

        public async Task<List<KbFileDto>> GetFoldersAsync(Guid kbId, Guid? parentId = null)
        {
            var folders = await _context.KbFiles
                .Where(f => f.KbId == kbId && f.IsFolder && f.ParentId == parentId)
                .OrderBy(f => f.Name)
                .ToListAsync();

            return folders.Select(f => new KbFileDto
            {
                Id = f.Id,
                Name = f.Name,
                Size = "-",
                Status = f.Status,
                UploadTime = f.UploadTime.ToString("yyyy-MM-dd HH:mm"),
                Path = f.Path,
                IsFolder = true,
                ParentId = f.ParentId
            }).ToList();
        }

        public async Task<KbFileDto> CreateFolderAsync(CreateKbFolderDto dto)
        {
            var kb = await _context.KbInfos.FindAsync(dto.KbId);
            if (kb == null) throw new Exception("Knowledge Base not found");

            var folder = new KbFile
            {
                Id = Guid.NewGuid(),
                KbId = dto.KbId,
                Name = dto.Name,
                Size = 0,
                Extension = null,
                Path = "", // Virtual folder
                Status = "ready",
                UploadTime = DateTime.Now,
                IsFolder = true,
                ParentId = dto.ParentId
            };

            _context.KbFiles.Add(folder);
            await _context.SaveChangesAsync();

            return new KbFileDto
            {
                Id = folder.Id,
                Name = folder.Name,
                Size = "-",
                Status = folder.Status,
                UploadTime = folder.UploadTime.ToString("yyyy-MM-dd HH:mm"),
                IsFolder = true,
                ParentId = folder.ParentId
            };
        }

        public async Task<KbFileDto> UploadFileAsync(Guid kbId, IFormFile file, Guid? parentId = null)
        {
            var kb = await _context.KbInfos.FindAsync(kbId);
            if (kb == null) throw new Exception("Knowledge Base not found");

            // Save file to disk
            var uploadsFolder = Path.Combine(_env.WebRootPath, "uploads", "kb", kbId.ToString());
            if (!Directory.Exists(uploadsFolder))
            {
                Directory.CreateDirectory(uploadsFolder);
            }

            var uniqueFileName = $"{Guid.NewGuid()}_{file.FileName}";
            var filePath = Path.Combine(uploadsFolder, uniqueFileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            // Save to DB
            var kbFile = new KbFile
            {
                Id = Guid.NewGuid(),
                KbId = kbId,
                Name = file.FileName,
                Size = file.Length,
                Extension = Path.GetExtension(file.FileName),
                Path = $"/uploads/kb/{kbId}/{uniqueFileName}",
                Status = "processing", // Simulate immediate processing start
                UploadTime = DateTime.Now,
                IsFolder = false,
                ParentId = parentId
            };

            _context.KbFiles.Add(kbFile);
            await _context.SaveChangesAsync();

            // Start background processing
            _ = ProcessFileAsync(kbFile.Id);

            return new KbFileDto
            {
                Id = kbFile.Id,
                Name = kbFile.Name,
                Size = FormatSize(kbFile.Size),
                Status = kbFile.Status,
                UploadTime = kbFile.UploadTime.ToString("yyyy-MM-dd HH:mm"),
                IsFolder = false,
                ParentId = parentId
            };
        }

        public async Task<bool> DeleteFileAsync(Guid fileId)
        {
            var file = await _context.KbFiles.FindAsync(fileId);
            if (file == null) return false;

            // 1. Find related nodes from KbNodeSources (MySQL)
            var nodeIds = await _context.KbNodeSources
                .Where(ns => ns.FileId == fileId)
                .Select(ns => ns.NodeId)
                .ToListAsync();

            // 2. Delete KbNodes from OmsPgContext (Postgres)
            if (nodeIds.Any())
            {
                // In case of many nodes, might need batching, but fine for now
                var nodesToDelete = await _pgContext.KbNodes
                    .Where(n => nodeIds.Contains(n.Id))
                    .ToListAsync();
                
                if (nodesToDelete.Any())
                {
                    _pgContext.KbNodes.RemoveRange(nodesToDelete);
                    await _pgContext.SaveChangesAsync();
                }
            }

            // 3. Delete KbNodeSources from OmsContext (MySQL)
            var sourcesToDelete = await _context.KbNodeSources
                .Where(ns => ns.FileId == fileId)
                .ToListAsync();
            
            if (sourcesToDelete.Any())
            {
                _context.KbNodeSources.RemoveRange(sourcesToDelete);
            }

            // Optional: Delete physical file
            try
            {
                var fullPath = Path.Combine(_env.WebRootPath, file.Path.TrimStart('/').Replace('/', Path.DirectorySeparatorChar));
                if (File.Exists(fullPath))
                {
                    File.Delete(fullPath);
                }
            }
            catch { /* Ignore file deletion errors */ }

            _context.KbFiles.Remove(file);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> RenameFileAsync(Guid fileId, string newName)
        {
            var file = await _context.KbFiles.FindAsync(fileId);
            if (file == null) return false;
            file.Name = newName;
            file.Extension = Path.GetExtension(newName);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> MoveFileAsync(Guid fileId, Guid? targetFolderId)
        {
            var file = await _context.KbFiles.FindAsync(fileId);
            if (file == null) return false;

            // Validate target folder if it's not root
            if (targetFolderId.HasValue)
            {
                var targetFolder = await _context.KbFiles.FindAsync(targetFolderId.Value);
                if (targetFolder == null || !targetFolder.IsFolder) return false;
                
                // Prevent moving a folder into itself or its children (cycle detection omitted for brevity but recommended)
                if (file.Id == targetFolderId.Value) return false;
            }

            file.ParentId = targetFolderId;
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<(string PhysicalPath, string Name, string ContentType)?> GetFileDownloadInfoAsync(Guid fileId)
        {
            var file = await _context.KbFiles.FindAsync(fileId);
            if (file == null) return null;

            // Compute physical path safely using IWebHostEnvironment
            var relativePath = file.Path.TrimStart('/', '\\')
                .Replace('/', Path.DirectorySeparatorChar)
                .Replace('\\', Path.DirectorySeparatorChar);
            
            var physicalPath = Path.Combine(_env.WebRootPath, relativePath);

            if (!System.IO.File.Exists(physicalPath))
            {
                return null;
            }

            var contentType = "application/octet-stream";
            if (!string.IsNullOrEmpty(file.Extension))
            {
                contentType = GetContentType(file.Extension);
            }
            return (physicalPath, file.Name, contentType);
        }

        // --- Knowledge Node Management ---

        public async Task<List<KbNodeDto>> GetKbNodesAsync(Guid kbId)
        {
            var nodes = await _pgContext.KbNodes
                .Where(n => n.KbId == kbId && n.ParentId == null)
                .Include(n => n.Children)
                .OrderBy(n => n.SortOrder)
                .ToListAsync();

            // Recursive mapping would be better, but for now 1-level deep or simple mapping
            return nodes.Select(n => MapNodeToDto(n)).ToList();
        }

        public async Task<KbNodeDto?> GetNodeDetailAsync(string key)
        {
            var node = await _pgContext.KbNodes
                .Include(n => n.Sources)
                .ThenInclude(s => s.File)
                .FirstOrDefaultAsync(n => n.Key == key || n.Id.ToString() == key);

            if (node == null) return null;

            return new KbNodeDto
            {
                Key = node.Key ?? node.Id.ToString(),
                Title = node.Title,
                Summary = node.Summary,
                Content = node.Content,
                Sources = node.Sources.Select(s => new KbNodeSourceDto
                {
                    FileId = s.FileId,
                    FileName = s.File?.Name ?? "Unknown",
                    Page = s.Page
                }).ToList()
            };
        }

        // --- Chat ---

        public async Task<List<ChatMessageDto>> GetChatHistoryAsync(Guid kbId, Guid? userId)
        {
            var history = await _context.KbQaHistories
                .Where(h => h.KbId == kbId && (userId == null || h.UserId == userId))
                .OrderBy(h => h.CreatedAt)
                .ToListAsync();

            var result = new List<ChatMessageDto>();
            foreach (var h in history)
            {
                result.Add(new ChatMessageDto { Id = h.Id, Role = "user", Content = h.Question, CreatedAt = h.CreatedAt });
                result.Add(new ChatMessageDto { Id = h.Id, Role = "ai", Content = h.Answer ?? "...", CreatedAt = h.CreatedAt });
            }

            return result;
        }

        public async Task<bool> DeleteChatHistoryAsync(Guid kbId, Guid? userId)
        {
            var history = await _context.KbQaHistories
                .Where(h => h.KbId == kbId && (userId == null || h.UserId == userId))
                .ToListAsync();

            if (!history.Any()) return false;

            _context.KbQaHistories.RemoveRange(history);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> DeleteKbQaHistoryAsync(Guid id)
        {
            var item = await _context.KbQaHistories.FindAsync(id);
            if (item == null) return false;

            _context.KbQaHistories.Remove(item);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<ChatMessageDto> SendMessageAsync(SendMessageDto dto, Guid? userId)
        {
            // 1. Prepare Question Object
            var qa = new KbQaHistory
            {
                Id = Guid.NewGuid(),
                KbId = dto.KbId,
                UserId = userId,
                Question = dto.Message,
                CreatedAt = DateTime.Now
            };

            // 2. Retrieve Context from KB
            var (contextText, sources) = await RetrieveRelevantContextAsync(dto.KbId, dto.Message);
            
            // 3. Call AI (SiliconFlow)
            string answerContent = "";
            var apiKey = _configuration["SiliconFlow:ApiKey"];
            var baseUrl = _configuration["SiliconFlow:BaseUrl"] ?? "https://api.siliconflow.cn/v1";

            if (!string.IsNullOrEmpty(apiKey))
            {
                try
                {
                    var modelName = !string.IsNullOrEmpty(dto.Model) ? dto.Model : "deepseek-ai/DeepSeek-V2.5";

                    var systemPrompt = "你是一个智能助手。请优先根据以下参考资料（Context）回答用户的问题。如果参考资料不足以回答，请使用你的通用知识补充，但需在回答中说明。";
                    var userContent = $"参考资料：\n{contextText}\n\n用户问题：{dto.Message}";

                    var requestBody = new
                    {
                        model = modelName,
                        messages = new[]
                        {
                            new { role = "system", content = systemPrompt },
                            new { role = "user", content = userContent }
                        },
                        stream = false
                    };

                    var json = JsonSerializer.Serialize(requestBody);
                    var content = new StringContent(json, Encoding.UTF8, "application/json");

                    // Create a new request message to ensure headers are set correctly for this request
                    var request = new HttpRequestMessage(HttpMethod.Post, $"{baseUrl}/chat/completions");
                    request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", apiKey);
                    request.Content = content;

                    var response = await _httpClient.SendAsync(request);
                    response.EnsureSuccessStatusCode();

                    var responseString = await response.Content.ReadAsStringAsync();
                    using var doc = JsonDocument.Parse(responseString);
                    answerContent = doc.RootElement
                        .GetProperty("choices")[0]
                        .GetProperty("message")
                        .GetProperty("content")
                        .GetString() ?? "";
                }
                catch (Exception ex)
                {
                    answerContent = $"[API Error] {ex.Message}";
                }
            }
            else
            {
                // Fallback to simulation
                await Task.Delay(1000); 
                var modelName = !string.IsNullOrEmpty(dto.Model) ? dto.Model : "Default Model";
                answerContent = $"[Simulated AI Response] (Model: {modelName}) Reply to '{dto.Message}'...\nContext found: {sources.Count} files.\n(Please configure SiliconFlow:ApiKey in appsettings.json to use real API)";
            }

            qa.Answer = answerContent;
            
            _context.KbQaHistories.Add(qa);
            await _context.SaveChangesAsync();

            return new ChatMessageDto
            {
                Id = qa.Id,
                Role = "ai",
                Content = qa.Answer,
                CreatedAt = qa.CreatedAt,
                Sources = sources
            };
        }

        public async IAsyncEnumerable<string> SendMessageStreamAsync(SendMessageDto dto, Guid? userId)
        {
            // 1. Prepare Question Object
            var qa = new KbQaHistory
            {
                Id = Guid.NewGuid(),
                KbId = dto.KbId,
                UserId = userId,
                Question = dto.Message,
                CreatedAt = DateTime.Now
            };

            // 2. Retrieve Context from KB
            var (contextText, sources) = await RetrieveRelevantContextAsync(dto.KbId, dto.Message);

            // 3. Call AI (SiliconFlow) with streaming
            var apiKey = _configuration["SiliconFlow:ApiKey"];
            var baseUrl = _configuration["SiliconFlow:BaseUrl"] ?? "https://api.siliconflow.cn/v1";
            var accumulatedAnswer = new StringBuilder();

            if (!string.IsNullOrEmpty(apiKey))
            {
                var modelName = !string.IsNullOrEmpty(dto.Model) ? dto.Model : "deepseek-ai/DeepSeek-V2.5";

                var systemPrompt = "你是一个智能助手。请优先根据以下参考资料（Context）回答用户的问题。如果参考资料不足以回答，请使用你的通用知识补充，但需在回答中说明。";
                var userContent = $"参考资料：\n{contextText}\n\n用户问题：{dto.Message}";

                var requestBody = new
                {
                    model = modelName,
                    messages = new[]
                    {
                        new { role = "system", content = systemPrompt },
                        new { role = "user", content = userContent }
                    },
                    stream = true // Enable streaming
                };

                var json = JsonSerializer.Serialize(requestBody);
                var request = new HttpRequestMessage(HttpMethod.Post, $"{baseUrl}/chat/completions");
                request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", apiKey);
                request.Content = new StringContent(json, Encoding.UTF8, "application/json");

                using var response = await _httpClient.SendAsync(request, HttpCompletionOption.ResponseHeadersRead);
                
                if (response.IsSuccessStatusCode)
                {
                    using var stream = await response.Content.ReadAsStreamAsync();
                    using var reader = new StreamReader(stream);

                    string? line;
                    while ((line = await reader.ReadLineAsync()) != null)
                    {
                        if (string.IsNullOrWhiteSpace(line)) continue;
                        if (line.StartsWith("data: "))
                        {
                            var data = line.Substring(6);
                            if (data == "[DONE]") break;

                            string content = "";
                            try 
                            {
                                using var doc = JsonDocument.Parse(data);
                                content = doc.RootElement
                                    .GetProperty("choices")[0]
                                    .GetProperty("delta")
                                    .TryGetProperty("content", out var contentElem) ? contentElem.GetString() ?? "" : "";
                            }
                            catch { /* ignore parsing errors for chunks */ }

                            if (!string.IsNullOrEmpty(content))
                            {
                                accumulatedAnswer.Append(content);
                                yield return content;
                            }
                        }
                    }
                }
                else
                {
                    var errorMsg = $"[API Error] {response.StatusCode}";
                    accumulatedAnswer.Append(errorMsg);
                    yield return errorMsg;
                }
                // Append Sources
                if (sources.Any())
                {
                    var sourcesText = "\n\n**参考资料**:\n" + string.Join("\n", sources.Select(s => $"- {s.FileName} (Page {s.Page})"));
                    accumulatedAnswer.Append(sourcesText);
                    yield return sourcesText;
                }
            }
            else
            {
                // Fallback to simulation stream
                var modelName = !string.IsNullOrEmpty(dto.Model) ? dto.Model : "Default Model";
                var mockResponse = $"[Simulated Stream] (Model: {modelName}) Reply to '{dto.Message}'...\nContext found: {sources.Count} files.\n(Please configure SiliconFlow:ApiKey)";
                
                foreach (var ch in mockResponse)
                {
                    accumulatedAnswer.Append(ch);
                    yield return ch.ToString();
                    await Task.Delay(50); // Simulate typing speed
                }
            }

            // 4. Save to History
            qa.Answer = accumulatedAnswer.ToString();
            
            _context.KbQaHistories.Add(qa);
            await _context.SaveChangesAsync();
        }

        private async Task<(string Context, List<KbNodeSourceDto> Sources)> RetrieveRelevantContextAsync(Guid kbId, string query)
        {
            if (string.IsNullOrWhiteSpace(query))
            {
                return ("", new List<KbNodeSourceDto>());
            }

            List<KbNode> relevantNodes = new List<KbNode>();
            
            // 1. Try Vector Search
            try 
            {
                var queryVector = await _aiService.GetEmbeddingAsync(query);
                if (queryVector != null && queryVector.Length > 0)
                {
                    var vector = new Vector(queryVector);
                    relevantNodes = await _pgContext.KbNodes
                        .Where(n => n.KbId == kbId && n.Vector != null)
                        .OrderBy(n => n.Vector.L2Distance(vector))
                        .Take(10)
                        .ToListAsync();
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[KbService] Vector search failed: {ex.Message}");
            }

            // 2. Fallback to Keyword Search if no vector results
            if (!relevantNodes.Any())
            {
                var keywords = query.Split(new[] { ' ', ',', '，', '。', '?' }, StringSplitOptions.RemoveEmptyEntries);
                if (keywords.Length > 0)
                {
                    // Fetch all nodes for the KB (assuming not too huge for this V1 implementation) 
                    // and filter in memory for complex keyword matching to avoid EF translation issues with array containment.
                    var allNodes = await _pgContext.KbNodes
                        .Where(n => n.KbId == kbId)
                        .ToListAsync();

                    relevantNodes = allNodes
                        .Where(n => keywords.Any(k => 
                            (n.Title != null && n.Title.Contains(k, StringComparison.OrdinalIgnoreCase)) ||
                            (n.Summary != null && n.Summary.Contains(k, StringComparison.OrdinalIgnoreCase)) ||
                            (n.Content != null && n.Content.Contains(k, StringComparison.OrdinalIgnoreCase))
                        ))
                        .Take(10) 
                        .ToList();
                }
            }

            if (!relevantNodes.Any())
            {
                return ("", new List<KbNodeSourceDto>());
            }

            // 3. Hydrate Sources from MySQL (Cross-Context Join)
            var nodeIds = relevantNodes.Select(n => n.Id).ToList();
            var nodeSources = await _context.KbNodeSources
                .Include(s => s.File)
                .Where(s => nodeIds.Contains(s.NodeId))
                .ToListAsync();

            foreach (var node in relevantNodes)
            {
                node.Sources = nodeSources.Where(s => s.NodeId == node.Id).ToList();
            }

            var contextBuilder = new StringBuilder();
            var sources = new List<KbNodeSourceDto>();
            var addedFileIds = new HashSet<Guid>();
            
            // Limit context size to avoid exceeding token limits (approx 3000 chars)
            const int MAX_CONTEXT_LENGTH = 3000;
            // For vector search, we might not have keywords to extract snippets with.
            // If vector search was used, keywords array is not defined in this scope.
            var searchKeywords = query.Split(new[] { ' ', ',', '，', '。', '?' }, StringSplitOptions.RemoveEmptyEntries);
            const int MAX_NODE_LENGTH = 500;
            int currentLength = 0;

            foreach (var node in relevantNodes)
            {
                if (currentLength >= MAX_CONTEXT_LENGTH) break;

                // Prioritize Summary, then Content
                string rawContent = !string.IsNullOrWhiteSpace(node.Summary) ? node.Summary : (node.Content ?? "");
                string cleanContent = StripHtml(rawContent);
                string snippet = ExtractRelevantSnippet(cleanContent, searchKeywords, MAX_NODE_LENGTH);
                
                if (string.IsNullOrWhiteSpace(snippet)) continue;

                var entry = $"--- Node: {node.Title} ---\n{snippet}\n\n";
                
                // If adding this entry exceeds max length, and we already have some context, stop here.
                if (currentLength + entry.Length > MAX_CONTEXT_LENGTH && currentLength > 0)
                {
                    break;
                }

                contextBuilder.Append(entry);
                currentLength += entry.Length;

                if (node.Sources != null)
                {
                    foreach (var src in node.Sources)
                    {
                        if (src.File != null && !addedFileIds.Contains(src.FileId))
                        {
                            sources.Add(new KbNodeSourceDto 
                            { 
                                FileName = src.File.Name, 
                                Page = src.Page 
                            });
                            addedFileIds.Add(src.FileId);
                        }
                    }
                }
            }

            return (contextBuilder.ToString(), sources);
        }

        private string StripHtml(string input)
        {
            if (string.IsNullOrEmpty(input)) return string.Empty;
            return Regex.Replace(input, "<.*?>", string.Empty);
        }

        private string ExtractRelevantSnippet(string content, string[] keywords, int maxLen)
        {
            if (string.IsNullOrEmpty(content)) return "";
            if (content.Length <= maxLen) return content;

            // Find first keyword occurrence
            int bestIndex = -1;
            foreach (var kw in keywords)
            {
                int idx = content.IndexOf(kw, StringComparison.OrdinalIgnoreCase);
                if (idx >= 0)
                {
                    bestIndex = idx;
                    break;
                }
            }

            if (bestIndex == -1)
            {
                // Return start if no keyword found in body (maybe matched title)
                return content.Substring(0, maxLen) + "...";
            }

            // Extract surrounding text
            int start = Math.Max(0, bestIndex - maxLen / 2);
            int length = Math.Min(maxLen, content.Length - start);
            
            string snippet = content.Substring(start, length);
            
            // Clean up partial words at edges (optional, keep simple for now)
            if (start > 0) snippet = "..." + snippet;
            if (start + length < content.Length) snippet = snippet + "...";

            return snippet;
        }

        public async Task<List<SiliconModelDto>> GetAvailableModelsAsync()
        {
            var apiKey = _configuration["SiliconFlow:ApiKey"];
            var baseUrl = _configuration["SiliconFlow:BaseUrl"] ?? "https://api.siliconflow.cn/v1";

            if (string.IsNullOrEmpty(apiKey))
            {
                // Return default models if no API key is configured
                return new List<SiliconModelDto>
                {
                    new SiliconModelDto { Id = "deepseek-ai/DeepSeek-V2.5", OwnedBy = "system" },
                    new SiliconModelDto { Id = "Qwen/Qwen2.5-72B-Instruct", OwnedBy = "system" }
                };
            }

            try
            {
                var request = new HttpRequestMessage(HttpMethod.Get, $"{baseUrl}/models");
                request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", apiKey);

                var response = await _httpClient.SendAsync(request);
                response.EnsureSuccessStatusCode();

                var responseString = await response.Content.ReadAsStringAsync();
                using var doc = JsonDocument.Parse(responseString);
                
                var models = new List<SiliconModelDto>();
                if (doc.RootElement.TryGetProperty("data", out var dataElement) && dataElement.ValueKind == JsonValueKind.Array)
                {
                    foreach (var element in dataElement.EnumerateArray())
                    {
                        models.Add(new SiliconModelDto
                        {
                            Id = element.GetProperty("id").GetString() ?? "",
                            Object = element.TryGetProperty("object", out var obj) ? obj.GetString() ?? "model" : "model",
                            Created = element.TryGetProperty("created", out var created) ? created.GetInt64() : 0,
                            OwnedBy = element.TryGetProperty("owned_by", out var ownedBy) ? ownedBy.GetString() ?? "" : ""
                        });
                    }
                }
                
                return models.OrderBy(m => m.Id).ToList();
            }
            catch (Exception ex)
            {
                // Log error
                Console.WriteLine($"Error fetching models: {ex.Message}");
                // Return defaults on error to avoid breaking UI
                 return new List<SiliconModelDto>
                {
                    new SiliconModelDto { Id = "deepseek-ai/DeepSeek-V2.5", OwnedBy = "system" },
                    new SiliconModelDto { Id = "Qwen/Qwen2.5-72B-Instruct", OwnedBy = "system" }
                };
            }
        }

        // --- Helpers ---

        private KbNodeDto MapNodeToDto(KbNode node)
        {
            return new KbNodeDto
            {
                Key = node.Key ?? node.Id.ToString(),
                Title = node.Title,
                Summary = node.Summary,
                Children = node.Children?.Select(c => MapNodeToDto(c)).ToList() ?? new List<KbNodeDto>()
            };
        }

        private string GetContentType(string extension)
        {
            var provider = new FileExtensionContentTypeProvider();
            if (provider.TryGetContentType("file" + extension, out var contentType))
            {
                return contentType;
            }
            return "application/octet-stream";
        }

        private string FormatSize(long bytes)
        {
            string[] sizes = { "B", "KB", "MB", "GB", "TB" };
            double len = bytes;
            int order = 0;
            while (len >= 1024 && order < sizes.Length - 1)
            {
                order++;
                len = len / 1024;
            }
            return $"{len:0.##} {sizes[order]}";
        }

        private async Task ProcessFileAsync(Guid fileId)
        {
            // Wait a bit to ensure transaction is committed if calling from same scope (though here it's fire-and-forget)
            await Task.Delay(1000); 
            
            using (var scope = _scopeFactory.CreateScope())
            {
                var context = scope.ServiceProvider.GetRequiredService<OmsContext>();
                var pgContext = scope.ServiceProvider.GetRequiredService<OmsPgContext>();
                var env = scope.ServiceProvider.GetRequiredService<IWebHostEnvironment>();
                var aiService = scope.ServiceProvider.GetRequiredService<IAiService>();

                var file = await context.KbFiles.FindAsync(fileId);
                
                if (file != null)
                {
                    try 
                    {
                        file.Status = "processing";
                        await context.SaveChangesAsync();

                        // 1. Determine physical path
                        var relativePath = file.Path.TrimStart('/', '\\')
                            .Replace('/', Path.DirectorySeparatorChar)
                            .Replace('\\', Path.DirectorySeparatorChar);
                        var physicalPath = Path.Combine(env.WebRootPath, relativePath);

                        if (!File.Exists(physicalPath))
                        {
                            file.Status = "error";
                            await context.SaveChangesAsync();
                            return;
                        }

                        // 2. Extract Text
                        string fullText = "";
                        var ext = file.Extension?.ToLower() ?? "";

                        try 
                        {
                            if (ext == ".txt" || ext == ".md" || ext == ".json" || ext == ".csv" || ext == ".xml")
                            {
                                fullText = await File.ReadAllTextAsync(physicalPath);
                            }
                            else if (ext == ".jpg" || ext == ".jpeg" || ext == ".png" || ext == ".bmp" || ext == ".gif")
                            {
                                try
                                {
                                    var bytes = await File.ReadAllBytesAsync(physicalPath);
                                    var mimeType = GetContentType(ext);
                                    fullText = $"[Image File: {file.Name}]\n";
                                    var description = await aiService.GetImageDescriptionAsync(bytes, mimeType);
                                    fullText += $"Image Description: {description}\n";
                                }
                                catch (Exception ex)
                                {
                                    fullText += $"[Error analyzing image: {ex.Message}]";
                                }
                            }
                            else if (ext == ".pdf")
                            {
                                using (var document = PdfDocument.Open(physicalPath))
                                {
                                    foreach (var page in document.GetPages())
                                    {
                                        fullText += page.Text + "\n";
                                        
                                        // Extract Images from Page
                                        try
                                        {
                                            foreach (var image in page.GetImages())
                                            {
                                                if (image.TryGetPng(out var pngBytes))
                                                {
                                                    var description = await aiService.GetImageDescriptionAsync(pngBytes, "image/png");
                                                    fullText += $"\n[Page {page.Number} Image Description]: {description}\n";
                                                }
                                                // If not PNG, TryGetBytes might be needed but PdfPig usually handles conversion for TryGetPng/TryGetJpeg
                                            }
                                        }
                                        catch (Exception imgEx)
                                        {
                                            Console.WriteLine($"Error processing pdf image on page {page.Number}: {imgEx.Message}");
                                        }
                                    }
                                    
                                }
                            }
                            else if (ext == ".docx")
                            {
                                using (var stream = File.OpenRead(physicalPath))
                                {
                                    var doc = new XWPFDocument(stream);
                                    foreach (var para in doc.Paragraphs)
                                    {
                                        fullText += para.ParagraphText + "\n";
                                    }

                                    // Extract Images
                                    foreach (var pic in doc.AllPictures)
                                    {
                                        try 
                                        {
                                            var imgExt = pic.SuggestFileExtension();
                                            var mimeType = $"image/{imgExt}";
                                            if (imgExt == "png" || imgExt == "jpeg" || imgExt == "jpg" || imgExt == "bmp" || imgExt == "gif")
                                            {
                                                var description = await aiService.GetImageDescriptionAsync(pic.Data, mimeType);
                                                fullText += $"\n[Embedded Image Description]: {description}\n";
                                            }
                                        }
                                        catch (Exception imgEx)
                                        {
                                            Console.WriteLine($"Error processing docx image: {imgEx.Message}");
                                        }
                                    }
                                }
                            }
                            else if (ext == ".doc")
                            {
                                // HWPF not available in current NPOI build
                                fullText = "[System]: .doc format support is temporarily unavailable (HWPF missing). Please convert to .docx or .pdf.";
                            }
                            else if (ext == ".xlsx")
                            {
                                using (var stream = File.OpenRead(physicalPath))
                                {
                                    var workbook = new XSSFWorkbook(stream);
                                    for (int i = 0; i < workbook.NumberOfSheets; i++)
                                    {
                                        var sheet = workbook.GetSheetAt(i);
                                        fullText += $"--- Sheet: {sheet.SheetName} ---\n";
                                        foreach (NPOI.SS.UserModel.IRow row in sheet)
                                        {
                                            foreach (NPOI.SS.UserModel.ICell cell in row)
                                            {
                                                fullText += cell.ToString() + "\t";
                                            }
                                            fullText += "\n";
                                        }
                                    }

                                    // Extract Images
                                    try 
                                    {
                                        var pictures = workbook.GetAllPictures();
                                        foreach (NPOI.SS.UserModel.IPictureData pic in pictures)
                                        {
                                            var mimeType = pic.MimeType;
                                            if (mimeType.StartsWith("image/"))
                                            {
                                                var description = await aiService.GetImageDescriptionAsync(pic.Data, mimeType);
                                                fullText += $"\n[Excel Embedded Image Description]: {description}\n";
                                            }
                                        }
                                    }
                                    catch (Exception imgEx)
                                    {
                                        Console.WriteLine($"Error processing xlsx image: {imgEx.Message}");
                                    }
                                }
                            }
                            else if (ext == ".xls")
                            {
                                using (var stream = File.OpenRead(physicalPath))
                                {
                                    var workbook = new HSSFWorkbook(stream);
                                    for (int i = 0; i < workbook.NumberOfSheets; i++)
                                    {
                                        var sheet = workbook.GetSheetAt(i);
                                        fullText += $"--- Sheet: {sheet.SheetName} ---\n";
                                        foreach (NPOI.SS.UserModel.IRow row in sheet)
                                        {
                                            foreach (NPOI.SS.UserModel.ICell cell in row)
                                            {
                                                fullText += cell.ToString() + "\t";
                                            }
                                            fullText += "\n";
                                        }
                                    }

                                    // Extract Images
                                    try 
                                    {
                                        var pictures = workbook.GetAllPictures();
                                        foreach (NPOI.SS.UserModel.IPictureData pic in pictures)
                                        {
                                            var mimeType = pic.MimeType;
                                            if (mimeType.StartsWith("image/"))
                                            {
                                                var description = await aiService.GetImageDescriptionAsync(pic.Data, mimeType);
                                                fullText += $"\n[Excel Embedded Image Description]: {description}\n";
                                            }
                                        }
                                    }
                                    catch (Exception imgEx)
                                    {
                                        Console.WriteLine($"Error processing xls image: {imgEx.Message}");
                                    }
                                }
                            }
                            else if (ext == ".pptx")
                            {
                                try 
                                {
                                    using (var doc = PresentationDocument.Open(physicalPath, false))
                                    {
                                        if (doc.PresentationPart != null)
                                        {
                                            foreach (var slidePart in doc.PresentationPart.SlideParts)
                                            {
                                                if (slidePart.Slide != null)
                                                {
                                                    // InnerText gets all text content
                                                    fullText += slidePart.Slide.InnerText + "\n";
                                                    
                                                    // Extract Images from Slide
                                                    foreach (var imagePart in slidePart.ImageParts)
                                                    {
                                                        try 
                                                        {
                                                            using (var stream = imagePart.GetStream())
                                                            {
                                                                using (var ms = new MemoryStream())
                                                                {
                                                                    stream.CopyTo(ms);
                                                                    var bytes = ms.ToArray();
                                                                    var mimeType = imagePart.ContentType;
                                                                    
                                                                    if (mimeType.StartsWith("image/"))
                                                                    {
                                                                        var description = await aiService.GetImageDescriptionAsync(bytes, mimeType);
                                                                        fullText += $"\n[Slide Image Description]: {description}\n";
                                                                    }
                                                                }
                                                            }
                                                        }
                                                        catch (Exception imgEx)
                                                        {
                                                            Console.WriteLine($"Error processing pptx image: {imgEx.Message}");
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                catch (Exception ex)
                                {
                                    fullText += $"[Error extracting PPTX: {ex.Message}]";
                                }
                            }
                            else if (ext == ".ppt")
                            {
                                // HSLF not available in current NPOI build
                                fullText = "[System]: .ppt format support is temporarily unavailable (HSLF missing). Please convert to .pptx or .pdf.";
                            }
                            else
                            {
                                fullText = $"[System]: Auto-extraction for {ext} is not supported.";
                            }
                        }
                        catch (Exception ex)
                        {
                            Console.WriteLine($"Error extracting text from {file.Name}: {ex.Message}");
                            fullText = $"[System]: Error extracting text: {ex.Message}";
                        }

                        // 3. Chunking
                        // Simple chunking by length (e.g., 500 chars) with overlap
                        const int CHUNK_SIZE = 800;
                        const int OVERLAP = 100;
                        var chunks = new List<string>();

                        if (fullText.Length <= CHUNK_SIZE)
                        {
                            chunks.Add(fullText);
                        }
                        else
                        {
                            for (int i = 0; i < fullText.Length; i += (CHUNK_SIZE - OVERLAP))
                            {
                                int length = Math.Min(CHUNK_SIZE, fullText.Length - i);
                                chunks.Add(fullText.Substring(i, length));
                            }
                        }

                        // 4. Save Nodes
                        // Remove old nodes for this file if any (though usually this is new)
                        // Use OmsPgContext for KbNodes
                        var oldNodes = await context.KbNodeSources
                            .Where(ns => ns.FileId == file.Id)
                            .Select(ns => ns.NodeId)
                            .ToListAsync();

                        if (oldNodes.Any())
                        {
                            var nodesToDelete = await pgContext.KbNodes.Where(n => oldNodes.Contains(n.Id)).ToListAsync();
                            pgContext.KbNodes.RemoveRange(nodesToDelete);
                            
                            var sourcesToDelete = await context.KbNodeSources.Where(ns => ns.FileId == file.Id).ToListAsync();
                            context.KbNodeSources.RemoveRange(sourcesToDelete);
                        }
                        
                        // We need to save MySQL changes (sources removal) before adding new ones
                        await context.SaveChangesAsync();
                        await pgContext.SaveChangesAsync();

                        // Batch Vectorization
                        List<float[]> vectors = new List<float[]>();
                        try
                        {
                            // Filter empty chunks before sending
                            var validChunks = chunks.Where(c => !string.IsNullOrWhiteSpace(c)).ToList();
                            if (validChunks.Any())
                            {
                                vectors = await aiService.GetEmbeddingsAsync(validChunks);
                            }
                        }
                        catch (Exception ex)
                        {
                            Console.WriteLine($"[KbService] Batch vectorization failed: {ex.Message}");
                            // Consider whether to fail the process or continue without vectors
                            // For now, continue without vectors so content is searchable by keyword
                        }

                        int sortOrder = 1;
                        int vectorIndex = 0;

                        foreach (var chunk in chunks)
                        {
                            if (string.IsNullOrWhiteSpace(chunk)) continue;

                            var node = new KbNode
                            {
                                Id = Guid.NewGuid(),
                                KbId = file.KbId,
                                Key = Guid.NewGuid().ToString(),
                                Title = $"{file.Name} - Part {sortOrder}",
                                Summary = chunk.Length > 50 ? chunk.Substring(0, 50) + "..." : chunk,
                                Content = chunk,
                                SortOrder = sortOrder
                            };
                            
                            // Assign vector if available
                            if (vectorIndex < vectors.Count)
                            {
                                var vec = vectors[vectorIndex];
                                if (vec != null && vec.Length > 0)
                                {
                                    node.Vector = new Vector(vec);
                                }
                                vectorIndex++;
                            }

                            pgContext.KbNodes.Add(node);
                            
                            context.KbNodeSources.Add(new KbNodeSource
                            {
                                Id = Guid.NewGuid(),
                                NodeId = node.Id,
                                FileId = file.Id,
                                Page = sortOrder
                            });
                            
                            sortOrder++;
                        }
                        
                        // Save both contexts
                        await pgContext.SaveChangesAsync();
                        await context.SaveChangesAsync();

                        file.Status = "ready";
                        await context.SaveChangesAsync();
                    }
                    catch (Exception ex)
                    {
                        file.Status = "error";
                        // Log error
                        Console.WriteLine($"Error processing file {fileId}: {ex.Message}");
                        await context.SaveChangesAsync();
                    }
                }
            }
        }
    }
}
