using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using omsapi.Data;
using omsapi.Infrastructure.Attributes;
using omsapi.Services.Interfaces;
using OmsApi.Models.Dtos.Kb;
using OmsApi.Models.Entities.Kb;

namespace omsapi.Services
{
    [AutoInject]
    public class KbService : IKbService
    {
        private readonly OmsContext _context;
        private readonly IWebHostEnvironment _env;
        private readonly IServiceScopeFactory _scopeFactory;

        public KbService(OmsContext context, IWebHostEnvironment env, IServiceScopeFactory scopeFactory)
        {
            _context = context;
            _env = env;
            _scopeFactory = scopeFactory;
        }

        // --- KB Management ---

        public async Task<List<KbInfoDto>> GetAllKbsAsync()
        {
            var kbs = await _context.KbInfos
                .Include(k => k.Files)
                .OrderByDescending(k => k.CreatedAt)
                .ToListAsync();

            return kbs.Select(k => new KbInfoDto
            {
                Id = k.Id,
                Name = k.Name,
                Description = k.Description,
                Category = k.Category,
                Type = k.Type,
                CreatedAt = k.CreatedAt,
                FileCount = k.Files.Count
            }).ToList();
        }

        public async Task<KbInfoDto?> GetKbByIdAsync(Guid id)
        {
            var k = await _context.KbInfos
                .Include(k => k.Files)
                .FirstOrDefaultAsync(x => x.Id == id);

            if (k == null) return null;

            return new KbInfoDto
            {
                Id = k.Id,
                Name = k.Name,
                Description = k.Description,
                Category = k.Category,
                Type = k.Type,
                CreatedAt = k.CreatedAt,
                FileCount = k.Files.Count
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
                CreatedAt = DateTime.UtcNow,
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
                CreatedAt = kb.CreatedAt,
                FileCount = 0
            };
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
                .OrderByDescending(f => f.UploadTime)
                .ToListAsync();

            return files.Select(f => new KbFileDto
            {
                Id = f.Id,
                Name = f.Name,
                Size = FormatSize(f.Size),
                Status = f.Status,
                UploadTime = f.UploadTime.ToString("yyyy-MM-dd HH:mm")
            }).ToList();
        }

        public async Task<KbFileDto> UploadFileAsync(Guid kbId, IFormFile file)
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
                Path = Path.Combine("/uploads/kb", kbId.ToString(), uniqueFileName),
                Status = "processing", // Simulate immediate processing start
                UploadTime = DateTime.UtcNow
            };

            _context.KbFiles.Add(kbFile);
            await _context.SaveChangesAsync();

            // Simulate AI processing in background (mock implementation)
            _ = SimulateAiProcessing(kbFile.Id);

            return new KbFileDto
            {
                Id = kbFile.Id,
                Name = kbFile.Name,
                Size = FormatSize(kbFile.Size),
                Status = kbFile.Status,
                UploadTime = kbFile.UploadTime.ToString("yyyy-MM-dd HH:mm")
            };
        }

        public async Task<bool> DeleteFileAsync(Guid fileId)
        {
            var file = await _context.KbFiles.FindAsync(fileId);
            if (file == null) return false;

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

        // --- Knowledge Node Management ---

        public async Task<List<KbNodeDto>> GetKbNodesAsync(Guid kbId)
        {
            var nodes = await _context.KbNodes
                .Where(n => n.KbId == kbId && n.ParentId == null)
                .Include(n => n.Children)
                .OrderBy(n => n.SortOrder)
                .ToListAsync();

            // Recursive mapping would be better, but for now 1-level deep or simple mapping
            return nodes.Select(n => MapNodeToDto(n)).ToList();
        }

        public async Task<KbNodeDto?> GetNodeDetailAsync(string key)
        {
            var node = await _context.KbNodes
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
                result.Add(new ChatMessageDto { Role = "user", Content = h.Question });
                result.Add(new ChatMessageDto { Role = "ai", Content = h.Answer ?? "..." });
            }

            return result;
        }

        public async Task<ChatMessageDto> SendMessageAsync(SendMessageDto dto, Guid? userId)
        {
            // 1. Save User Question
            var qa = new KbQaHistory
            {
                Id = Guid.NewGuid(),
                KbId = dto.KbId,
                UserId = userId,
                Question = dto.Message,
                CreatedAt = DateTime.UtcNow
            };
            
            // 2. Simulate AI Answer
            await Task.Delay(1000); // Simulate network
            qa.Answer = $"[模拟AI回答] 关于 '{dto.Message}' 的回复...\n这是一个基于 SiliconFlow API 模拟的回答。";
            
            // Mock sources
            var mockSources = new List<KbNodeSourceDto>
            {
                new KbNodeSourceDto { FileName = "MockFile.pdf", Page = 1 }
            };

            _context.KbQaHistories.Add(qa);
            await _context.SaveChangesAsync();

            return new ChatMessageDto
            {
                Role = "ai",
                Content = qa.Answer,
                Sources = mockSources
            };
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

        private async Task SimulateAiProcessing(Guid fileId)
        {
            await Task.Delay(5000); // Simulate processing time
            
            using (var scope = _scopeFactory.CreateScope())
            {
                var context = scope.ServiceProvider.GetRequiredService<OmsContext>();
                var file = await context.KbFiles.FindAsync(fileId);
                
                if (file != null)
                {
                    file.Status = "ready";
                    
                    // Create a dummy node for this file
                    var node = new KbNode
                    {
                        Id = Guid.NewGuid(),
                        KbId = file.KbId,
                        Key = Guid.NewGuid().ToString(),
                        Title = $"从 {file.Name} 提取的知识点",
                        Summary = "这是由 SiliconFlow API 自动生成的摘要信息。",
                        Content = $"<p>这里是关于 {file.Name} 的详细内容...</p>",
                        SortOrder = 0
                    };
                    context.KbNodes.Add(node);
                    
                    // Add source
                    var source = new KbNodeSource
                    {
                        Id = Guid.NewGuid(),
                        NodeId = node.Id,
                        FileId = file.Id,
                        Page = 1
                    };
                    context.KbNodeSources.Add(source);
                    
                    await context.SaveChangesAsync();
                }
            }
        }
    }
}
