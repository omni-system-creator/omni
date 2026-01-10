using System.Collections.Concurrent;
using System.Text.Json;
using DocumentFormat.OpenXml.Packaging;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
// using NPOI.HWPF.UserModel;
using NPOI.XWPF.UserModel;
using omsapi.Data;
using omsapi.Infrastructure.Attributes;
using omsapi.Models.Dtos;
using omsapi.Models.Dtos.Sales;
using omsapi.Models.Entities.Sales;
using omsapi.Services.Interfaces;
using UglyToad.PdfPig;
using UglyToad.PdfPig.Content;

namespace omsapi.Services
{
    [AutoInject]
    public class SalesTenderAnalysisService : ISalesTenderAnalysisService
    {
        private readonly OmsContext _context;
        private readonly IFileService _fileService;
        private readonly IWebHostEnvironment _env;
        private readonly IServiceScopeFactory _scopeFactory;

        private static readonly ConcurrentDictionary<
            string,
            CancellationTokenSource
        > AnalysisCtsByBidProjectId = new();

        public SalesTenderAnalysisService(
            OmsContext context,
            IFileService fileService,
            IWebHostEnvironment env,
            IServiceScopeFactory scopeFactory
        )
        {
            _context = context;
            _fileService = fileService;
            _env = env;
            _scopeFactory = scopeFactory;
        }

        public async Task<SalesTenderAnalysisDto?> GetByBidProjectIdAsync(string bidProjectId)
        {
            var entity = await _context
                .SalesTenderAnalyses.Include(a => a.Chapters)
                .FirstOrDefaultAsync(a => a.BidProjectId == bidProjectId);

            if (entity == null)
                return null;

            return MapToDto(entity);
        }

        public async Task<SalesTenderAnalysisDto> CreateOrUpdateAsync(
            CreateSalesTenderAnalysisDto dto
        )
        {
            var existing = await _context
                .SalesTenderAnalyses.Include(a => a.Chapters)
                .FirstOrDefaultAsync(a => a.BidProjectId == dto.BidProjectId);

            if (existing != null)
            {
                // Remove existing chapters (simple replace strategy for now)
                _context.SalesTenderChapters.RemoveRange(existing.Chapters);
                _context.SalesTenderAnalyses.Remove(existing);
                await _context.SaveChangesAsync();
            }

            var analysis = new SalesTenderAnalysis
            {
                BidProjectId = dto.BidProjectId,
                TenderType = dto.TenderType,
                FileName = dto.FileName,
                FileUrl = dto.FileUrl,
                Deadline = dto.Deadline,
                BidBond = dto.BidBond,
                Budget = dto.Budget,
                Qualification = dto.Qualification,
                BidStartTime = dto.BidStartTime,
                BidEndTime = dto.BidEndTime,
                TenderStartTime = dto.TenderStartTime,
                OpenBidTime = dto.OpenBidTime,
                PublishTime = dto.PublishTime,
                ContactName = dto.ContactName,
                ContactPhone = dto.ContactPhone,
                AgencyName = dto.AgencyName,
                CreatedAt = DateTime.Now,
                UpdatedAt = DateTime.Now
            };

            _context.SalesTenderAnalyses.Add(analysis);
            await _context.SaveChangesAsync();

            // Add Chapters recursively
            if (dto.Chapters != null)
            {
                int sortOrder = 0;
                foreach (var chapterDto in dto.Chapters)
                {
                    await AddChapterRecursively(analysis.Id, null, chapterDto, sortOrder++);
                }
                await _context.SaveChangesAsync();
            }

            // Reload with chapters
            var result = await _context
                .SalesTenderAnalyses.Include(a => a.Chapters)
                .FirstAsync(a => a.Id == analysis.Id);

            return MapToDto(result);
        }

        public async Task<SalesTenderAnalysisDto> UploadTenderDocAsync(
            string bidProjectId,
            IFormFile file,
            long userId
        )
        {
            if (file == null || file.Length == 0)
                throw new Exception("Please select a file");

            // Define upload path: uploads/sales/tender/{bidProjectId}/
            var uploadDir = Path.Combine(
                _env.WebRootPath,
                "uploads",
                "sales",
                "bid",
                bidProjectId,
                "tender"
            );
            if (!Directory.Exists(uploadDir))
            {
                Directory.CreateDirectory(uploadDir);
            }

            var fileName = file.FileName;
            foreach (var existingFilePath in Directory.GetFiles(uploadDir))
            {
                File.Delete(existingFilePath);
            }

            var filePath = Path.Combine(uploadDir, fileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            // Update SalesTenderAnalysis
            var analysis = await _context.SalesTenderAnalyses.FirstOrDefaultAsync(
                a => a.BidProjectId == bidProjectId
            );

            var project = await _context.SalesBidProjects.FindAsync(bidProjectId);
            var tenderType = project?.Type ?? "other";

            if (analysis == null)
            {
                analysis = new SalesTenderAnalysis
                {
                    BidProjectId = bidProjectId,
                    TenderType = tenderType,
                    CreatedAt = DateTime.Now,
                    UpdatedAt = DateTime.Now
                };
                _context.SalesTenderAnalyses.Add(analysis);
            }
            else
            {
                if (!string.IsNullOrEmpty(tenderType))
                    analysis.TenderType = tenderType;
            }

            analysis.FileName = fileName;
            analysis.FileUrl = $"/api/sales/tender-analysis/{bidProjectId}/download";
            analysis.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();

            await StartNewRunAsync(bidProjectId, userId);

            // Return updated DTO
            var result = await _context
                .SalesTenderAnalyses.Include(a => a.Chapters)
                .FirstAsync(a => a.Id == analysis.Id);

            return MapToDto(result);
        }

        public async Task<SalesTenderAnalysisStatusDto> GetStatusAsync(
            string bidProjectId,
            long userId
        )
        {
            var run = await _context
                .SalesTenderAnalysisRuns.AsNoTracking()
                .Where(r => r.BidProjectId == bidProjectId)
                .OrderByDescending(r => r.Id)
                .FirstOrDefaultAsync();

            if (run == null)
            {
                return new SalesTenderAnalysisStatusDto { IsAnalyzing = false, Status = "none" };
            }

            return new SalesTenderAnalysisStatusDto
            {
                IsAnalyzing = string.Equals(
                    run.Status,
                    "running",
                    StringComparison.OrdinalIgnoreCase
                ),
                Status = run.Status,
                RunId = run.Id,
                StartedAt = run.StartedAt,
                FinishedAt = run.FinishedAt
            };
        }

        public async Task CancelAnalysisAsync(string bidProjectId, long userId)
        {
            // 1. Try to cancel active task via CTS
            if (AnalysisCtsByBidProjectId.TryGetValue(bidProjectId, out var cts))
            {
                cts.Cancel();
                // We don't remove it here immediately, let the running task handle cleanup or overwrite it on new run
            }

            // 2. Update database status for any "running" task for this project
            // This handles the case where server restarted and CTS is lost.
            var runningRuns = await _context
                .SalesTenderAnalysisRuns.Where(r => r.BidProjectId == bidProjectId && r.Status == "running")
                .ToListAsync();

            if (runningRuns.Any())
            {
                foreach (var run in runningRuns)
                {
                    run.Status = "cancelled";
                    run.FinishedAt = DateTime.Now;
                    
                    // Add a log entry
                    var log = new SalesTenderAnalysisLog
                    {
                        RunId = run.Id,
                        BidProjectId = bidProjectId,
                        Message = "任务已被用户手动取消",
                        CreatedAt = DateTime.Now
                    };
                    _context.SalesTenderAnalysisLogs.Add(log);
                }
                await _context.SaveChangesAsync();
            }
        }

        public async Task<SalesTenderAnalysisStatusDto> StartReanalyzeAsync(
            string bidProjectId,
            long userId
        )
        {
            await StartNewRunAsync(bidProjectId, userId);
            return await GetStatusAsync(bidProjectId, userId);
        }

        public async Task<List<SalesTenderAnalysisLogDto>> GetLogsAsync(
            string bidProjectId,
            long? runId,
            long? afterId,
            int take,
            long userId
        )
        {
            long? resolvedRunId = runId;
            if (resolvedRunId == null)
            {
                resolvedRunId = await _context
                    .SalesTenderAnalysisRuns.Where(r => r.BidProjectId == bidProjectId)
                    .OrderByDescending(r => r.Id)
                    .Select(r => (long?)r.Id)
                    .FirstOrDefaultAsync();
            }

            if (resolvedRunId == null)
                return new List<SalesTenderAnalysisLogDto>();

            var query = _context.SalesTenderAnalysisLogs.AsNoTracking().Where(
                l => l.BidProjectId == bidProjectId && l.RunId == resolvedRunId.Value
            );

            if (afterId.HasValue)
            {
                query = query.Where(l => l.Id > afterId.Value);
            }

            var items = await query
                .OrderBy(l => l.Id)
                .Take(Math.Clamp(take, 1, 500))
                .Select(
                    l =>
                        new SalesTenderAnalysisLogDto
                        {
                            Id = l.Id,
                            RunId = l.RunId,
                            Message = l.Message,
                            CreatedAt = l.CreatedAt
                        }
                )
                .ToListAsync();

            return items;
        }

        public async Task<(
            bool success,
            string message,
            string? contentType,
            Stream? stream,
            string? fileName
        )> DownloadTenderDocAsync(string bidProjectId, long userId)
        {
            var analysis = await _context.SalesTenderAnalyses.FirstOrDefaultAsync(
                a => a.BidProjectId == bidProjectId
            );

            if (analysis == null)
            {
                return (false, "Tender document not found", null, null, null);
            }

            if (string.IsNullOrEmpty(analysis.FileName))
            {
                return (false, "File record missing", null, null, null);
            }

            var filePath = Path.Combine(
                _env.WebRootPath,
                "uploads",
                "sales",
                "bid",
                bidProjectId,
                "tender",
                analysis.FileName
            );
            if (!File.Exists(filePath))
            {
                return (false, "Physical file missing", null, null, null);
            }

            var stream = new FileStream(filePath, FileMode.Open, FileAccess.Read);
            var contentType = "application/octet-stream";

            var ext = Path.GetExtension(analysis.FileName).ToLowerInvariant();
            if (ext == ".pdf")
                contentType = "application/pdf";
            else if (ext == ".doc")
                contentType = "application/msword";
            else if (ext == ".docx")
                contentType =
                    "application/vnd.openxmlformats-officedocument.wordprocessingml.document";

            return (true, "Success", contentType, stream, analysis.FileName);
        }

        private async Task AddChapterRecursively(
            long analysisId,
            long? parentId,
            CreateSalesTenderChapterDto dto,
            int sortOrder
        )
        {
            var chapter = new SalesTenderChapter
            {
                AnalysisId = analysisId,
                ParentId = parentId,
                Title = dto.Title,
                ChapterType = dto.Type,
                Content = dto.Content,
                AnalysisResult = dto.Analysis,
                RiskLevel = dto.RiskLevel,
                IsVeto = dto.IsVeto,
                ScoreWeight = dto.ScoreWeight,
                SortOrder = sortOrder,
                ExtractionsJson =
                    dto.Extraction != null ? JsonSerializer.Serialize(dto.Extraction) : null
            };

            _context.SalesTenderChapters.Add(chapter);
            await _context.SaveChangesAsync();

            if (dto.Children != null)
            {
                int childOrder = 0;
                foreach (var childDto in dto.Children)
                {
                    await AddChapterRecursively(analysisId, chapter.Id, childDto, childOrder++);
                }
            }
        }

        private SalesTenderAnalysisDto MapToDto(SalesTenderAnalysis entity)
        {
            var dto = new SalesTenderAnalysisDto
            {
                Id = entity.Id,
                BidProjectId = entity.BidProjectId,
                TenderType = entity.TenderType,
                FileName = entity.FileName,
                FileUrl = entity.FileUrl,
                Deadline = entity.Deadline,
                BidBond = entity.BidBond,
                Budget = entity.Budget,
                Qualification = entity.Qualification,
                BidStartTime = entity.BidStartTime,
                BidEndTime = entity.BidEndTime,
                TenderStartTime = entity.TenderStartTime,
                OpenBidTime = entity.OpenBidTime,
                PublishTime = entity.PublishTime,
                ContactName = entity.ContactName,
                ContactPhone = entity.ContactPhone,
                AgencyName = entity.AgencyName,
                CreatedAt = entity.CreatedAt,
                Chapters = new List<SalesTenderChapterDto>()
            };

            // Reconstruct tree from flat list
            var allChapters = entity.Chapters.OrderBy(c => c.SortOrder).ToList();
            var chapterMap = new Dictionary<long, SalesTenderChapterDto>();
            var rootChapters = new List<SalesTenderChapterDto>();

            // First pass: create DTOs
            foreach (var ch in allChapters)
            {
                var chDto = new SalesTenderChapterDto
                {
                    Id = ch.Id,
                    Key = ch.Id.ToString(),
                    Title = ch.Title,
                    Type = ch.ChapterType,
                    Content = ch.Content,
                    Analysis = ch.AnalysisResult,
                    RiskLevel = ch.RiskLevel,
                    IsVeto = ch.IsVeto,
                    ScoreWeight = ch.ScoreWeight,
                    Extraction = !string.IsNullOrEmpty(ch.ExtractionsJson)
                        ? JsonSerializer.Deserialize<List<SalesTenderExtractionDto>>(
                            ch.ExtractionsJson
                        ) ?? new List<SalesTenderExtractionDto>()
                        : new List<SalesTenderExtractionDto>()
                };
                chapterMap[ch.Id] = chDto;
            }

            // Second pass: build hierarchy
            foreach (var ch in allChapters)
            {
                var chDto = chapterMap[ch.Id];
                if (ch.ParentId.HasValue && chapterMap.ContainsKey(ch.ParentId.Value))
                {
                    chapterMap[ch.ParentId.Value].Children.Add(chDto);
                }
                else
                {
                    rootChapters.Add(chDto);
                }
            }

            dto.Chapters = rootChapters;
            return dto;
        }

        private async Task<long> StartNewRunAsync(string bidProjectId, long userId)
        {
            if (AnalysisCtsByBidProjectId.TryGetValue(bidProjectId, out var existingCts))
            {
                existingCts.Cancel();
                existingCts.Dispose();
            }

            var cts = new CancellationTokenSource();
            AnalysisCtsByBidProjectId[bidProjectId] = cts;

            var run = new SalesTenderAnalysisRun
            {
                BidProjectId = bidProjectId,
                Status = "running",
                StartedAt = DateTime.Now,
                CreatedBy = userId
            };

            _context.SalesTenderAnalysisRuns.Add(run);
            await _context.SaveChangesAsync();

            _ = Task.Run(() => RunAnalysisAsync(bidProjectId, run.Id, cts.Token), cts.Token);

            return run.Id;
        }

        private async Task RunAnalysisAsync(
            string bidProjectId,
            long runId,
            CancellationToken cancellationToken
        )
        {
            using var scope = _scopeFactory.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<OmsContext>();
            var env = scope.ServiceProvider.GetRequiredService<IWebHostEnvironment>();
            var aiService = scope.ServiceProvider.GetRequiredService<IAiService>();

            async Task AppendLogAsync(string msg)
            {
                var log = new SalesTenderAnalysisLog
                {
                    RunId = runId,
                    BidProjectId = bidProjectId,
                    Message = msg,
                    CreatedAt = DateTime.Now
                };
                context.SalesTenderAnalysisLogs.Add(log);
                await context.SaveChangesAsync(cancellationToken);
            }

            try
            {
                await AppendLogAsync("开始分析招标文件");

                var analysis = await context
                    .SalesTenderAnalyses.Include(a => a.Chapters)
                    .FirstOrDefaultAsync(a => a.BidProjectId == bidProjectId, cancellationToken);

                if (analysis == null)
                {
                    await AppendLogAsync("未找到分析记录");
                    await FinishRunAsync(context, runId, "failed", cancellationToken);
                    return;
                }

                if (string.IsNullOrEmpty(analysis.FileName))
                {
                    await AppendLogAsync("未找到已上传的招标文件");
                    await FinishRunAsync(context, runId, "failed", cancellationToken);
                    return;
                }

                var filePath = Path.Combine(
                    env.WebRootPath,
                    "uploads",
                    "sales",
                    "bid",
                    bidProjectId,
                    "tender",
                    analysis.FileName
                );
                if (!File.Exists(filePath))
                {
                    await AppendLogAsync("招标文件不存在");
                    await FinishRunAsync(context, runId, "failed", cancellationToken);
                    return;
                }

                await AppendLogAsync("读取文件并识别内容...");
                var fullText = new System.Text.StringBuilder();
                var ext = Path.GetExtension(analysis.FileName).ToLowerInvariant();
                var hasImages = false;

                if (ext == ".pdf")
                {
                    try
                    {
                        using (var document = PdfDocument.Open(filePath))
                        {
                            foreach (var page in document.GetPages())
                            {
                                // Collect all elements (words and images) with their positions
                                var pageElements =
                                    new List<(double Y, double X, string Type, object Content)>();

                                // 1. Add Words
                                foreach (var word in page.GetWords())
                                {
                                    // PdfPig coordinates: (0,0) is bottom-left. Higher Y is higher on page.
                                    // We want to sort by Y descending (Top to Bottom).
                                    pageElements.Add(
                                        (
                                            word.BoundingBox.Top,
                                            word.BoundingBox.Left,
                                            "text",
                                            word.Text
                                        )
                                    );
                                }

                                // 2. Add Images
                                var images = page.GetImages().ToList();
                                if (images.Any())
                                {
                                    if (!hasImages)
                                    {
                                        await AppendLogAsync("检测到图片内容，正在识别处理...");
                                        hasImages = true;
                                    }

                                    var validImages = new List<(IPdfImage Image, byte[] Bytes)>();
                                    foreach (var img in images)
                                    {
                                        if (img.Bounds.Width < 50 || img.Bounds.Height < 50)
                                            continue;

                                        byte[]? imgBytes = null;
                                        try
                                        {
                                            if (img.TryGetPng(out var png))
                                                imgBytes = png;
                                            else
                                                imgBytes = img.RawBytes.ToArray();
                                        }
                                        catch { }

                                        if (imgBytes != null)
                                            validImages.Add((img, imgBytes));
                                    }

                                    // Run OCR in parallel
                                    var ocrTasks = validImages.Select(async item =>
                                    {
                                        var text = await aiService.GetImageAnalysisAsync(
                                            item.Bytes
                                        );
                                        return new { item.Image, Text = text };
                                    });

                                    var ocrResults = await Task.WhenAll(ocrTasks);

                                    foreach (var res in ocrResults)
                                    {
                                        if (!string.IsNullOrWhiteSpace(res.Text))
                                        {
                                            pageElements.Add(
                                                (
                                                    res.Image.Bounds.Top,
                                                    res.Image.Bounds.Left,
                                                    "ocr_text",
                                                    $"[图片内容]: {res.Text}"
                                                )
                                            );
                                        }
                                    }
                                }

                                // 3. Sort by Y descending (Top to Bottom), then X ascending (Left to Right)
                                // Group by Line (approximate Y) could be better, but simple sort is a good start for interleaving large blocks.
                                // For mixed text/image, usually images are distinct blocks.
                                var sortedElements = pageElements
                                    .OrderByDescending(e => e.Y)
                                    .ThenBy(e => e.X)
                                    .ToList();

                                // 4. Process in order
                                double lastY = -1;
                                foreach (var element in sortedElements)
                                {
                                    if (lastY != -1 && Math.Abs(lastY - element.Y) > 20) // New line threshold
                                    {
                                        fullText.AppendLine();
                                    }
                                    lastY = element.Y;

                                    if (element.Type == "text")
                                    {
                                        fullText.Append(element.Content + " ");
                                    }
                                    else if (element.Type == "ocr_text")
                                    {
                                        fullText.AppendLine($"\n{element.Content}\n");
                                    }
                                }
                                fullText.AppendLine(); // End of page
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        await AppendLogAsync($"PDF解析失败: {ex.Message}");
                    }
                }
                else if (ext == ".docx")
                {
                    try
                    {
                        using (var fs = File.OpenRead(filePath))
                        {
                            var doc = new XWPFDocument(fs);
                            foreach (var para in doc.Paragraphs)
                            {
                                fullText.AppendLine(para.ParagraphText);
                            }
                            foreach (var table in doc.Tables)
                            {
                                foreach (var row in table.Rows)
                                {
                                    foreach (var cell in row.GetTableCells())
                                    {
                                        foreach (var para in cell.Paragraphs)
                                        {
                                            fullText.Append(para.ParagraphText + " ");
                                        }
                                    }
                                    fullText.AppendLine();
                                }
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        await AppendLogAsync($"DOCX解析失败: {ex.Message}");
                    }
                }
                else if (ext == ".doc")
                {
                    await AppendLogAsync("DOC格式解析暂未支持（缺少组件），请转换为DOCX或PDF格式");
                    /*
                     try
                    {
                        using (var fs = File.OpenRead(filePath))
                        {
                            // var doc = new HWPFDocument(fs);
                            // fullText.Append(doc.GetRange().Text);
                        }
                    }
                    catch (Exception ex)
                    {
                         await AppendLogAsync($"DOC解析失败: {ex.Message}");
                    }
                    */
                }

                var extractedText = fullText.ToString();
                if (string.IsNullOrWhiteSpace(extractedText))
                {
                    await AppendLogAsync("警告：未能从文件中提取到有效文本");
                }
                else
                {
                    await AppendLogAsync($"文件读取完成，提取字符数: {extractedText.Length}");
                }

                await AppendLogAsync("正在进行深度分析...");

                // Step 1: Extract Basic Info (using first 20k chars)
                var infoText =
                    extractedText.Length > 20000
                        ? extractedText.Substring(0, 20000)
                        : extractedText;
                var infoSystemPrompt =
                    @"你是一位资深招投标专家。请从以下招标文件片段中提取招标项目的基本信息。
请严格按照以下JSON格式返回结果（不要返回Markdown代码块，直接返回JSON字符串）：
{
  ""projectCode"": ""项目编号"",
  ""projectName"": ""项目名称"",
  ""customerName"": ""招标人名称"",
  ""region"": ""项目所属地区(省/市)"",
  ""projectType"": ""项目类型(如：货物/工程/服务/监理/其他)"",
  ""deadline"": ""投标截止时间(yyyy-MM-dd HH:mm)"",
  ""bidBond"": ""投标保证金"",
  ""budget"": ""项目预算"",
  ""qualification"": ""投标人资格要求简述"",
  ""projectLeader"": ""项目负责人/项目经理要求"",
  ""projectBackground"": ""项目背景简述"",
  ""bidStartTime"": ""投标开始时间"",
  ""bidEndTime"": ""投标截止时间"",
  ""tenderStartTime"": ""获取招标文件开始时间"",
  ""openBidTime"": ""开标时间"",
  ""publishTime"": ""发布时间"",
  ""contactName"": ""联系人"",
  ""contactPhone"": ""联系电话"",
  ""agencyName"": ""代理机构""
}";
                var infoUserMessage = $"招标文件前部内容：\n{infoText}";

                AiTenderAnalysisResultDto? finalResult = null;

                try
                {
                    await AppendLogAsync("正在提取基本信息...");
                    var infoJson = await aiService.GetChatCompletionAsync(
                        message: infoUserMessage,
                        systemPrompt: infoSystemPrompt
                    );

                    // Cleanup JSON
                    var start = infoJson.IndexOf('{');
                    var end = infoJson.LastIndexOf('}');
                    if (start >= 0 && end > start)
                    {
                        infoJson = infoJson.Substring(start, end - start + 1);
                    }
                    else
                    {
                        infoJson = infoJson.Replace("```json", "").Replace("```", "").Trim();
                        if (!infoJson.StartsWith("{"))
                        {
                            throw new Exception("分析结果数据不包含有效的可读对象");
                        }
                    }

                    var options = new JsonSerializerOptions
                    {
                        PropertyNameCaseInsensitive = true,
                        ReadCommentHandling = JsonCommentHandling.Skip,
                        AllowTrailingCommas = true
                    };
                    finalResult = JsonSerializer.Deserialize<AiTenderAnalysisResultDto>(
                        infoJson,
                        options
                    );
                }
                catch (Exception ex)
                {
                    await AppendLogAsync($"基本信息提取失败: {ex.Message}");
                    finalResult = new AiTenderAnalysisResultDto(); // Fallback
                }

                if (finalResult == null)
                    finalResult = new AiTenderAnalysisResultDto();
                finalResult.Chapters = new List<AiTenderChapterDto>();

                // Step 2: Task-Based Parallel Analysis (Full Context)
                // Instead of chunking text (which loses context), we pass full text to parallel tasks focusing on different modules.
                // DeepSeek-V3 supports 64k+ context, so passing ~100k chars is safe.
                var analysisContext =
                    extractedText.Length > 150000
                        ? extractedText.Substring(0, 150000)
                        : extractedText;

                await AppendLogAsync($"正在进行分模块深度分析 (文本长度: {analysisContext.Length})...");

                // 1. Get Template based on Tender Type
                var templateModules = GetTemplateByType(analysis.TenderType);

                // 2. Initialize Database with Root Modules (Skeleton)
                // Clear old chapters first
                var oldChapters = await context
                    .SalesTenderChapters.Where(c => c.AnalysisId == analysis.Id)
                    .ToListAsync(cancellationToken);
                context.SalesTenderChapters.RemoveRange(oldChapters);
                await context.SaveChangesAsync(cancellationToken);

                var savedRootChapters = new List<SalesTenderChapter>();
                int rootSort = 0;
                foreach (var template in templateModules)
                {
                    var rootChapter = new SalesTenderChapter
                    {
                        AnalysisId = analysis.Id,
                        Title = template.Title,
                        ChapterType = template.Type,
                        SortOrder = rootSort++
                    };
                    context.SalesTenderChapters.Add(rootChapter);
                    savedRootChapters.Add(rootChapter);
                }
                await context.SaveChangesAsync(cancellationToken);

                // 3. Progressive Analysis (Module by Module)
                var baseSystemPrompt =
                    @"你是一位资深招投标专家。请根据招标文件内容，提取并分析指定模块下的二级章节。
请遵循以下原则：
1. **详尽拆分**：请详细拆分二级章节，不要过度合并。如果原文中有明确的小节标题（如 1.1, 1.2 或 (1), (2)），请尽量作为独立的二级章节提取，尽量直接使用原文标题，20字以内。
2. **完整性**：确保提取内容的完整性，不要遗漏关键条款。
3. **结构化**：输出内容必须严格符合JSON格式。

JSON格式要求（必须严格遵守，返回一个对象，不要包含Markdown格式标记）：
{
    ""summary"": ""本模块整体内容概述（100字以内）"",
    ""chapters"": [
        {
            ""title"": ""二级章节标题（尽量直接使用原文小标题，20字以内，如：1.1 项目概况），但是重新按顺序编号"",
            ""type"": ""二级目录"",
            ""analysis"": ""核心内容分析（简练总结该小节的核心要求）"",
            ""riskLevel"": ""low/medium/high"",
            ""isVeto"": false, // 是否为废标项/一票否决项
            ""content"": ""原文摘要(保留关键原文片段，不要自己重写，尤其是数值和硬性要求)"",
            ""extraction"": [ { ""label"": ""关键项"", ""value"": ""提取值"" } ]
        }
    ]
}
注意：
有些招标文件或磋商文件把“投标”称为“响应”，请在分析时注意这一点。
1. 请在summary字段中对当前模块进行简要概述。
2. chapters数组中包含二级章节。
3. 请确保返回的是标准的JSON格式，不要输出 ```json ... ``` 这样的代码块标记。
4. 如果该模块没有找到相关内容，chapters返回空数组 []。";

                for (int i = 0; i < savedRootChapters.Count; i++)
                {
                    var rootChapter = savedRootChapters[i];
                    var templateNode = templateModules[i];

                    await AppendLogAsync(
                        $"正在分析模块 ({i + 1}/{savedRootChapters.Count}): {rootChapter.Title}..."
                    );

                    // Build specific prompt for this module
                    var modulePrompt = $"{baseSystemPrompt}\n\n当前分析模块：{rootChapter.Title}\n";
                    
                    if (!string.IsNullOrEmpty(templateNode.Analysis))
                    {
                         modulePrompt += $"(注意：该模块在文档中可能出现的别名包括但不限于：{templateNode.Analysis}。请灵活识别相关内容)\n";
                    }

                    modulePrompt += "请务必详细扫描文档，尽量提取以下关键内容点（如果存在），并将其作为独立的二级章节返回：\n";
                    modulePrompt += "如果文档中没有完全匹配的标题，请根据内容相关性进行提取。只要内容符合描述，即可作为该章节提取。\n";
                    foreach (var child in templateNode.Children)
                    {
                        modulePrompt += $"- {child.Title} (关注点: {child.Analysis})\n";
                    }

                    try
                    {
                        var moduleMsg = $"招标文件全文：\n{analysisContext}";
                        // Use a slightly lower temperature for structured extraction
                        var jsonResult = await aiService.GetChatCompletionAsync(
                            message: moduleMsg,
                            systemPrompt: modulePrompt,
                            temperature: 0.3
                        );
                        
                        var (summary, extractedChapters) = ParseChaptersResult(jsonResult);
                        
                        // Update root chapter summary
                        if (!string.IsNullOrEmpty(summary))
                        {
                            rootChapter.AnalysisResult = summary;
                            // context.Update(rootChapter); // Attached, so direct property set works
                        }

                        if (extractedChapters != null && extractedChapters.Any())
                        {
                            int childSort = 0;
                            foreach (var chDto in extractedChapters)
                            {
                                await AddChapterRecursivelyWithContext(
                                    context,
                                    analysis.Id,
                                    rootChapter.Id,
                                    MapToCreateDto(chDto),
                                    childSort++,
                                    cancellationToken
                                );
                            }
                            await AppendLogAsync(
                                $"模块 {rootChapter.Title} 分析完成，提取了 {extractedChapters.Count} 个章节"
                            );
                        }
                        else
                        {
                            await AppendLogAsync($"模块 {rootChapter.Title} 未提取到相关章节");
                        }
                        
                        // Save changes for this module (including root summary and children)
                        await context.SaveChangesAsync(cancellationToken);
                    }
                    catch (Exception ex)
                    {
                        await AppendLogAsync($"模块 {rootChapter.Title} 分析出错: {ex.Message}");
                    }
                }

                // Finalize
                // Update basic info one last time if needed, or assume it was done in Step 1
                bool isSuccess = true;
                var resultDto = finalResult;

                if (isSuccess)
                {
                    analysis.Deadline = ParseAiDate(resultDto.Deadline);
                    analysis.BidBond = resultDto.BidBond;
                    analysis.Budget = resultDto.Budget;
                    analysis.Qualification = resultDto.Qualification;
                    analysis.BidStartTime = ParseAiDate(resultDto.BidStartTime);
                    analysis.BidEndTime = ParseAiDate(resultDto.BidEndTime);
                    analysis.TenderStartTime = ParseAiDate(resultDto.TenderStartTime);
                    analysis.OpenBidTime = ParseAiDate(resultDto.OpenBidTime);
                    analysis.PublishTime = ParseAiDate(resultDto.PublishTime);
                    analysis.ContactName = resultDto.ContactName;
                    analysis.ContactPhone = resultDto.ContactPhone;
                    analysis.AgencyName = resultDto.AgencyName;
                    analysis.UpdatedAt = DateTime.Now;

                    // Update linked Bid Project basic info
                    var bidProject = await context.SalesBidProjects.FindAsync(new object[] { bidProjectId }, cancellationToken);
                    if (bidProject != null)
                    {
                        if (!string.IsNullOrEmpty(resultDto.ProjectCode)) bidProject.Code = resultDto.ProjectCode;
                        if (!string.IsNullOrEmpty(resultDto.ProjectName)) bidProject.Name = resultDto.ProjectName;
                        if (!string.IsNullOrEmpty(resultDto.CustomerName)) bidProject.Customer = resultDto.CustomerName;
                        if (!string.IsNullOrEmpty(resultDto.Region)) bidProject.Region = resultDto.Region;
                        if (!string.IsNullOrEmpty(resultDto.ProjectType)) bidProject.Type = resultDto.ProjectType;
                        if (!string.IsNullOrEmpty(resultDto.Budget)) bidProject.Budget = resultDto.Budget;
                        if (!string.IsNullOrEmpty(resultDto.ProjectLeader)) bidProject.Leader = resultDto.ProjectLeader;
                        if (!string.IsNullOrEmpty(resultDto.ProjectBackground)) bidProject.Description = resultDto.ProjectBackground;

                        var bidTime = analysis.OpenBidTime ?? analysis.BidEndTime ?? analysis.Deadline;
                        if (bidTime.HasValue)
                        {
                            bidProject.BidTime = bidTime.Value;
                        }
                        bidProject.UpdatedAt = DateTime.Now;
                    }

                    await context.SaveChangesAsync(cancellationToken);
                }

                if (isSuccess)
                {
                    await AppendLogAsync("分析完成，结构化数据已生成");
                    await FinishRunAsync(context, runId, "completed", cancellationToken);
                }
                else
                {
                    await AppendLogAsync("分析结果为空");
                    await FinishRunAsync(context, runId, "failed", cancellationToken);
                }
            }
            catch (OperationCanceledException)
            {
                await FinishRunAsync(context, runId, "cancelled", CancellationToken.None);
            }
            catch (Exception ex)
            {
                try
                {
                    await AppendLogAsync($"分析失败：{ex.Message}");
                }
                catch { }
                await FinishRunAsync(context, runId, "failed", CancellationToken.None);
            }
        }

        private CreateSalesTenderChapterDto MapToCreateDto(SalesTenderChapterDto dto)
        {
            return new CreateSalesTenderChapterDto
            {
                Title = dto.Title,
                Type = dto.Type,
                Analysis = dto.Analysis,
                RiskLevel = dto.RiskLevel,
                IsVeto = dto.IsVeto,
                Content = dto.Content,
                Extraction = dto.Extraction,
                Children =
                    dto.Children?.Select(c => MapToCreateDto(c)).ToList()
                    ?? new List<CreateSalesTenderChapterDto>()
            };
        }

        private CreateSalesTenderChapterDto MapToCreateDto(AiTenderChapterDto dto)
        {
            return new CreateSalesTenderChapterDto
            {
                Title = dto.Title,
                Type = dto.Type,
                Analysis = dto.Analysis,
                RiskLevel = dto.RiskLevel,
                IsVeto = dto.IsVeto,
                Content = dto.Content,
                Extraction = dto.Extraction,
                Children =
                    dto.Children?.Select(c => MapToCreateDto(c)).ToList()
                    ?? new List<CreateSalesTenderChapterDto>()
            };
        }

        private async Task FinishRunAsync(
            OmsContext context,
            long runId,
            string status,
            CancellationToken cancellationToken
        )
        {
            var run = await context.SalesTenderAnalysisRuns.FirstOrDefaultAsync(
                r => r.Id == runId,
                cancellationToken
            );
            if (run == null)
                return;
            run.Status = status;
            run.FinishedAt = DateTime.Now;
            await context.SaveChangesAsync(cancellationToken);
        }

        private async Task AddChapterRecursivelyWithContext(
            OmsContext context,
            long analysisId,
            long? parentId,
            CreateSalesTenderChapterDto dto,
            int sortOrder,
            CancellationToken cancellationToken
        )
        {
            var chapter = new SalesTenderChapter
            {
                AnalysisId = analysisId,
                ParentId = parentId,
                Title = dto.Title,
                ChapterType = dto.Type,
                Content = dto.Content,
                AnalysisResult = dto.Analysis,
                RiskLevel = dto.RiskLevel,
                IsVeto = dto.IsVeto,
                ScoreWeight = dto.ScoreWeight,
                SortOrder = sortOrder,
                ExtractionsJson =
                    dto.Extraction != null ? JsonSerializer.Serialize(dto.Extraction) : null
            };

            context.SalesTenderChapters.Add(chapter);
            await context.SaveChangesAsync(cancellationToken);

            if (dto.Children != null)
            {
                int childOrder = 0;
                foreach (var childDto in dto.Children)
                {
                    await AddChapterRecursivelyWithContext(
                        context,
                        analysisId,
                        chapter.Id,
                        childDto,
                        childOrder++,
                        cancellationToken
                    );
                }
            }
        }

        private (string Summary, List<AiTenderChapterDto> Chapters) ParseChaptersResult(string json)
        {
            try
            {
                var start = json.IndexOf('{');
                var end = json.LastIndexOf('}');
                if (start >= 0 && end > start)
                {
                    json = json.Substring(start, end - start + 1);
                    var options = new JsonSerializerOptions
                    {
                        PropertyNameCaseInsensitive = true,
                        ReadCommentHandling = JsonCommentHandling.Skip,
                        AllowTrailingCommas = true
                    };
                    
                    var result = JsonSerializer.Deserialize<AiTenderModuleResultDto>(json, options);
                    if (result != null)
                    {
                        return (result.Summary, result.Chapters ?? new List<AiTenderChapterDto>());
                    }
                }
                // Fallback for array only (old format compatibility or model hallucination)
                var arrayStart = json.IndexOf('[');
                var arrayEnd = json.LastIndexOf(']');
                if (arrayStart >= 0 && arrayEnd > arrayStart)
                {
                    var arrayJson = json.Substring(arrayStart, arrayEnd - arrayStart + 1);
                    var options = new JsonSerializerOptions
                    {
                        PropertyNameCaseInsensitive = true,
                        ReadCommentHandling = JsonCommentHandling.Skip,
                        AllowTrailingCommas = true
                    };
                    var chapters = JsonSerializer.Deserialize<List<AiTenderChapterDto>>(arrayJson, options);
                    return ("", chapters ?? new List<AiTenderChapterDto>());
                }
            }
            catch { }
            return ("", new List<AiTenderChapterDto>());
        }

        private class AiTenderModuleResultDto
        {
            public string Summary { get; set; } = string.Empty;
            public List<AiTenderChapterDto> Chapters { get; set; } = new List<AiTenderChapterDto>();
        }

        private List<AiTenderChapterDto> GetTemplateByType(string type)
        {
            var modules = new List<AiTenderChapterDto>();

            if (type == "engineering") // 工程类
            {
                modules.Add(
                    new AiTenderChapterDto
                    {
                        Title = "一、 项目概况与建设条件",
                        Type = "一级目录",
                        Analysis = "项目基本信息、建设地点、规模、建设条件",
                        Children = new List<AiTenderChapterDto>
                        {
                            new AiTenderChapterDto
                            {
                                Title = "项目基本信息",
                                Analysis = "项目名称、编号、建设地点、规模"
                            },
                            new AiTenderChapterDto { Title = "建设条件", Analysis = "现场条件、周边环境、三通一平情况" }
                        }
                    }
                );
                modules.Add(
                    new AiTenderChapterDto
                    {
                        Title = "二、 工程技术要求与规范",
                        Type = "一级目录",
                        Analysis = "技术规范、图纸与设计要求、材料设备要求",
                        Children = new List<AiTenderChapterDto>
                        {
                            new AiTenderChapterDto { Title = "技术规范", Analysis = "执行的国家标准、行业标准" },
                            new AiTenderChapterDto { Title = "图纸与设计要求", Analysis = "设计图纸清单、技术参数" },
                            new AiTenderChapterDto { Title = "材料设备要求", Analysis = "主要材料品牌、规格、质量等级" }
                        }
                    }
                );
                modules.Add(
                    new AiTenderChapterDto
                    {
                        Title = "三、 工期、质量与安全要求",
                        Type = "一级目录",
                        Analysis = "工期要求、质量标准、安全文明施工",
                        Children = new List<AiTenderChapterDto>
                        {
                            new AiTenderChapterDto { Title = "工期要求", Analysis = "计划开工日期、竣工日期、总工期" },
                            new AiTenderChapterDto { Title = "质量标准", Analysis = "质量目标（合格/优良/创杯）" },
                            new AiTenderChapterDto { Title = "安全文明施工", Analysis = "安全生产目标、文明施工费要求" }
                        }
                    }
                );
                modules.Add(
                    new AiTenderChapterDto
                    {
                        Title = "四、 投标要求",
                        Type = "一级目录",
                        Analysis = "响应要求、响应文件、企业资质、团队要求、业绩要求、投标人资格与项目班、投标文件格式要求、投标文件内容要求",
                        Children = new List<AiTenderChapterDto>
                        {
                            new AiTenderChapterDto
                            {
                                Title = "企业资质",
                                Analysis = "资质等级、营业执照、安全生产许可证"
                            },
                            new AiTenderChapterDto { Title = "业绩要求", Analysis = "近年类似工程业绩" },
                            new AiTenderChapterDto { Title = "项目经理", Analysis = "建造师级别、安全B证、社保要求" },
                            new AiTenderChapterDto { Title = "技术负责人", Analysis = "职称、经验要求" }
                        }
                    }
                );
                modules.Add(
                    new AiTenderChapterDto
                    {
                        Title = "五、 商务条款与合同",
                        Type = "一级目录",
                        Analysis = "合同条款及格式、合同协议书模版、商务部分、合同内容",
                        Children = new List<AiTenderChapterDto>
                        {
                            new AiTenderChapterDto { Title = "报价要求", Analysis = "工程量清单、计价方式、暂列金" },
                            new AiTenderChapterDto { Title = "付款方式", Analysis = "预付款、进度款、结算款、质保金" },
                            new AiTenderChapterDto { Title = "履约担保", Analysis = "形式、金额、退还时间" }
                        }
                    }
                );
                modules.Add(
                    new AiTenderChapterDto
                    {
                        Title = "六、 评标办法与风险",
                        Type = "一级目录",
                        Analysis = "评标办法、风险评估、合同条款",
                        Children = new List<AiTenderChapterDto>
                        {
                            new AiTenderChapterDto
                            {
                                Title = "评标办法",
                                Analysis = "综合评估法/经评审的最低投标价法"
                            },
                            new AiTenderChapterDto { Title = "废标条款", Analysis = "否决投标的具体情形" }
                        }
                    }
                );
            }
            else if (type == "goods") // 货物类
            {
                modules.Add(
                    new AiTenderChapterDto
                    {
                        Title = "一、 项目基础与采购概况",
                        Type = "一级目录",
                        Analysis = "项目基本信息、采购内容、资金与预算",
                        Children = new List<AiTenderChapterDto>
                        {
                            new AiTenderChapterDto { Title = "采购内容", Analysis = "货物名称、数量、简要技术需求" },
                            new AiTenderChapterDto { Title = "资金与预算", Analysis = "资金来源、最高限价" }
                        }
                    }
                );
                modules.Add(
                    new AiTenderChapterDto
                    {
                        Title = "二、 货物技术参数与要求",
                        Type = "一级目录",
                        Analysis = "技术规格、标准与认证",
                        Children = new List<AiTenderChapterDto>
                        {
                            new AiTenderChapterDto { Title = "技术规格", Analysis = "详细参数、偏离表要求" },
                            new AiTenderChapterDto { Title = "标准与认证", Analysis = "国标、行业标准、3C认证等" }
                        }
                    }
                );
                modules.Add(
                    new AiTenderChapterDto
                    {
                        Title = "三、 供货范围与售后服务",
                        Type = "一级目录",
                        Analysis = "供货范围、交货要求、售后服务",
                        Children = new List<AiTenderChapterDto>
                        {
                            new AiTenderChapterDto { Title = "供货范围", Analysis = "主机、配件、工具、备品备件" },
                            new AiTenderChapterDto { Title = "交货要求", Analysis = "交货时间、地点、运输方式" },
                            new AiTenderChapterDto { Title = "售后服务", Analysis = "质保期、响应时间、培训要求" }
                        }
                    }
                );
                modules.Add(
                    new AiTenderChapterDto
                    {
                        Title = "四、 投标要求",
                        Type = "一级目录",
                        Analysis = "响应要求、响应文件、企业资质、团队要求、业绩要求、投标人资格要求、投标文件格式要求、投标文件内容要求",
                        Children = new List<AiTenderChapterDto>
                        {
                            new AiTenderChapterDto { Title = "基本资格", Analysis = "营业执照、财务状况、纳税社保" },
                            new AiTenderChapterDto
                            {
                                Title = "特定资格",
                                Analysis = "代理授权书、生产许可证、医疗器械注册证"
                            },
                            new AiTenderChapterDto { Title = "业绩要求", Analysis = "同类货物供货业绩" }
                        }
                    }
                );
                modules.Add(
                    new AiTenderChapterDto
                    {
                        Title = "五、 商务条款与合同",
                        Type = "一级目录",
                        Analysis = "合同条款及格式、合同协议书模版、商务部分、合同内容",
                        Children = new List<AiTenderChapterDto>
                        {
                            new AiTenderChapterDto { Title = "付款条款", Analysis = "预付、到货款、验收款、质保金" },
                            new AiTenderChapterDto { Title = "验收标准", Analysis = "验收程序、异议处理" }
                        }
                    }
                );
                modules.Add(
                    new AiTenderChapterDto
                    {
                        Title = "六、 评标与验收标准",
                        Type = "一级目录",
                        Analysis = "评标标准、验收标准",                        
                        Children = new List<AiTenderChapterDto>
                        {
                            new AiTenderChapterDto { Title = "评分标准", Analysis = "价格分、技术分、商务分权重" },
                            new AiTenderChapterDto { Title = "废标情形", Analysis = "无效投标的认定" }
                        }
                    }
                );
            }
            else if (type == "service") // 服务类
            {
                modules.Add(
                    new AiTenderChapterDto
                    {
                        Title = "一、 项目基础与服务目标",
                        Type = "一级目录",
                        Analysis = "项目背景、服务期限、服务内容、技术要求",
                        Children = new List<AiTenderChapterDto>
                        {
                            new AiTenderChapterDto { Title = "项目背景", Analysis = "项目来源、建设目标" },
                            new AiTenderChapterDto { Title = "服务期限", Analysis = "开始时间、总服务期" }
                        }
                    }
                );
                modules.Add(
                    new AiTenderChapterDto
                    {
                        Title = "二、 服务内容与技术要求",
                        Type = "一级目录",
                        Analysis = "系统功能清单、技术标准及要求、功能需求、技术部分、技术方案、测试与验收",
                        Children = new List<AiTenderChapterDto>
                        {
                            new AiTenderChapterDto { Title = "服务范围", Analysis = "具体服务事项清单、系统功能清单" },
                            new AiTenderChapterDto
                            {
                                Title = "技术要求",
                                Analysis = "服务标准、技术指标、成果文件要求、技术标准及要求"
                            },
                            new AiTenderChapterDto { Title = "考核标准", Analysis = "服务质量考核指标" }
                        }
                    }
                );
                modules.Add(
                    new AiTenderChapterDto
                    {
                        Title = "三、 投标要求",
                        Type = "一级目录",
                        Analysis = "响应要求、响应文件、企业资质、团队要求、业绩要求、投标人资格与人员要求、投标文件格式要求、投标文件内容要求",
                        Children = new List<AiTenderChapterDto>
                        {
                            new AiTenderChapterDto { Title = "企业资质", Analysis = "相关行业资质、体系认证" },
                            new AiTenderChapterDto { Title = "团队要求", Analysis = "项目负责人、核心成员资格与经验" },
                            new AiTenderChapterDto { Title = "业绩要求", Analysis = "类似服务项目业绩" }
                        }
                    }
                );
                modules.Add(
                    new AiTenderChapterDto
                    {
                        Title = "四、 商务条款与合同",
                        Type = "一级目录",
                        Analysis = "合同条款及格式、合同协议书模版、商务部分、合同内容",
                        Children = new List<AiTenderChapterDto>
                        {
                            new AiTenderChapterDto { Title = "报价要求", Analysis = "总价包干/单价包干、取费标准" },
                            new AiTenderChapterDto { Title = "支付条款", Analysis = "分阶段付款比例与条件" },
                            new AiTenderChapterDto { Title = "知识产权", Analysis = "成果归属约定" }
                        }
                    }
                );
                modules.Add(
                    new AiTenderChapterDto
                    {
                        Title = "五、 评标标准与方法",
                        Type = "一级目录",
                        Analysis = "评标标准、评标方法、评标流程",
                        Children = new List<AiTenderChapterDto>
                        {
                            new AiTenderChapterDto { Title = "评分细则", Analysis = "方案、团队、业绩、价格的分值" },
                            new AiTenderChapterDto { Title = "演示要求", Analysis = "是否需要现场述标/演示" }
                        }
                    }
                );
                modules.Add(
                    new AiTenderChapterDto
                    {
                        Title = "六、 风险与合规",
                        Type = "一级目录",
                        Analysis = "风险控制、合规要求、否决条款、违约责任",
                        Children = new List<AiTenderChapterDto>
                        {
                            new AiTenderChapterDto { Title = "否决条款", Analysis = "资格审查不通过情形" },
                            new AiTenderChapterDto { Title = "违约责任", Analysis = "服务中断、质量不达标的处罚" }
                        }
                    }
                );
            }
            else if (type == "supervision") // 监理类
            {
                modules.Add(
                    new AiTenderChapterDto
                    {
                        Title = "一、 项目概况与监理范围",
                        Type = "一级目录",
                        Analysis = "项目基本信息、监理范围、监理内容",
                        Children = new List<AiTenderChapterDto>
                        {
                            new AiTenderChapterDto { Title = "工程概况", Analysis = "工程规模、投资额、工期" },
                            new AiTenderChapterDto { Title = "监理范围", Analysis = "监理阶段（施工、保修）、监理内容" }
                        }
                    }
                );
                modules.Add(
                    new AiTenderChapterDto
                    {
                        Title = "二、 监理依据与工作内容",
                        Type = "一级目录",
                        Analysis = "监理依据、监理内容、监理工作",
                        Children = new List<AiTenderChapterDto>
                        {
                            new AiTenderChapterDto { Title = "监理依据", Analysis = "法律法规、规范标准、设计文件" },
                            new AiTenderChapterDto
                            {
                                Title = "三控三管一协调",
                                Analysis = "质量、进度、投资控制，安全、合同、信息管理"
                            }
                        }
                    }
                );
                modules.Add(
                    new AiTenderChapterDto
                    {
                        Title = "三、 监理机构与人员配备",
                        Type = "一级目录",
                        Analysis = "监理机构、总监要求、专监、监理员、配套人员",
                        Children = new List<AiTenderChapterDto>
                        {
                            new AiTenderChapterDto
                            {
                                Title = "总监要求",
                                Analysis = "注册监理工程师、职称、业绩、押证要求"
                            },
                            new AiTenderChapterDto { Title = "配套人员", Analysis = "专监、监理员数量及专业配置" }
                        }
                    }
                );
                modules.Add(
                    new AiTenderChapterDto
                    {
                        Title = "四、 投标要求",
                        Type = "一级目录",
                        Analysis = "响应要求、响应文件、企业资质、团队要求、业绩要求、投标人资格与人员要求、投标文件格式要求、投标文件内容要求",
                        Children = new List<AiTenderChapterDto>
                        {
                            new AiTenderChapterDto { Title = "企业资质", Analysis = "相关行业资质、体系认证" },
                            new AiTenderChapterDto { Title = "团队要求", Analysis = "项目负责人、核心成员资格与经验" },
                            new AiTenderChapterDto { Title = "业绩要求", Analysis = "类似服务项目业绩" }
                        }
                    }
                );
                modules.Add(
                    new AiTenderChapterDto
                    {
                        Title = "五、 设施配备与检测手段",
                        Type = "一级目录",
                        Analysis = "检测设备、办公设备、旁站监理",
                        Children = new List<AiTenderChapterDto>
                        {
                            new AiTenderChapterDto { Title = "检测设备", Analysis = "常规检测仪器、办公设备" },
                            new AiTenderChapterDto { Title = "旁站监理", Analysis = "关键部位旁站计划" }
                        }
                    }
                );
                modules.Add(
                    new AiTenderChapterDto
                    {
                        Title = "六、 商务条款与合同",
                        Type = "一级目录",
                        Analysis = "合同条款及格式、合同协议书模版、商务部分、合同内容",
                        Children = new List<AiTenderChapterDto>
                        {
                            new AiTenderChapterDto { Title = "监理费报价", Analysis = "取费费率、总价" },
                            new AiTenderChapterDto { Title = "支付方式", Analysis = "按进度支付" }
                        }
                    }
                );
                modules.Add(
                    new AiTenderChapterDto
                    {
                        Title = "七、 评标标准",
                        Type = "一级目录",
                        Analysis = "评分办法、人员、业绩、费率",
                        Children = new List<AiTenderChapterDto>
                        {
                            new AiTenderChapterDto { Title = "评分办法", Analysis = "大纲、人员、业绩、费率" }
                        }
                    }
                );
            }
            else // 其他类 or default
            {
                modules.Add(
                    new AiTenderChapterDto
                    {
                        Title = "一：项目与程序基础",
                        Type = "一级目录",
                        Analysis = "项目信息、投标程序",
                        Children = new List<AiTenderChapterDto>
                        {
                            new AiTenderChapterDto { Title = "项目信息", Analysis = "项目名称、编号、概况" },
                            new AiTenderChapterDto { Title = "投标程序", Analysis = "时间表、流程" }
                        }
                    }
                );
                modules.Add(
                    new AiTenderChapterDto
                    {
                        Title = "二：投标要求",
                        Type = "一级目录",
                        Analysis = "响应要求、响应文件、资格要求、禁止条款、投标人资格与人员要求、投标文件格式要求、投标文件内容要求",
                        Children = new List<AiTenderChapterDto>
                        {
                            new AiTenderChapterDto { Title = "资格要求", Analysis = "资质、业绩、人员" },
                            new AiTenderChapterDto { Title = "禁止条款", Analysis = "联合体、关联关系" }
                        }
                    }
                );
                modules.Add(
                    new AiTenderChapterDto
                    {
                        Title = "三：投标文件编制与格式",
                        Type = "一级目录",
                        Analysis = "编制要求、封装盖章",
                        Children = new List<AiTenderChapterDto>
                        {
                            new AiTenderChapterDto { Title = "编制要求", Analysis = "份数、语言、币种" },
                            new AiTenderChapterDto { Title = "封装盖章", Analysis = "签字盖章要求、包封要求" }
                        }
                    }
                );
                modules.Add(
                    new AiTenderChapterDto
                    {
                        Title = "四：评标办法与标准",
                        Type = "一级目录",
                        Analysis = "评分标准、评标程序",
                        Children = new List<AiTenderChapterDto>
                        {
                            new AiTenderChapterDto { Title = "评分标准", Analysis = "详细评分细则" },
                            new AiTenderChapterDto { Title = "评标程序", Analysis = "初审、详审" }
                        }
                    }
                );
                modules.Add(
                    new AiTenderChapterDto
                    {
                        Title = "五：合同主要条款",
                        Type = "一级目录",
                        Analysis = "专用条款、通用条款",
                        Children = new List<AiTenderChapterDto>
                        {
                            new AiTenderChapterDto { Title = "专用条款", Analysis = "付款、工期、违约" },
                            new AiTenderChapterDto { Title = "通用条款", Analysis = "引用标准" }
                        }
                    }
                );
                modules.Add(
                    new AiTenderChapterDto
                    {
                        Title = "六：风险与合规检查",
                        Type = "一级目录",
                        Analysis = "废标条款、合规检查",
                        Children = new List<AiTenderChapterDto>
                        {
                            new AiTenderChapterDto { Title = "废标条款", Analysis = "否决项汇总" },
                            new AiTenderChapterDto { Title = "合规检查", Analysis = "串标风险" }
                        }
                    }
                );
            }

            return modules;
        }

        private DateTime? ParseAiDate(string? dateStr)
        {
            if (string.IsNullOrWhiteSpace(dateStr) || dateStr.Contains("未") || dateStr.Length < 4)
                return null;

            // Normalize separators
            dateStr = dateStr
                .Replace("年", "-")
                .Replace("月", "-")
                .Replace("日", "")
                .Replace(".", "-")
                .Replace("/", "-");

            // Try common formats
            if (DateTime.TryParse(dateStr, out var dt))
                return dt;

            // Try extracting date pattern using regex if simple parse fails
            try
            {
                var match = System.Text.RegularExpressions.Regex.Match(
                    dateStr,
                    @"\d{4}-\d{1,2}-\d{1,2}(\s+\d{1,2}:\d{1,2})?"
                );
                if (match.Success)
                {
                    if (DateTime.TryParse(match.Value, out var dt2))
                        return dt2;
                }
            }
            catch { }

            return null;
        }

        private TenderAnalysisResult BuildMockAnalysis(string tenderType)
        {
            var now = DateTime.Now;

            // Generate the chapters structure based on the user's "Directory List"
            // The structure is generic for all types for now, but we can customize if needed.
            // Using the user provided structure:

            var chapters = new List<CreateSalesTenderChapterDto>
            {
                // 一、 项目与程序基础
                new CreateSalesTenderChapterDto
                {
                    Title = "一、 项目与程序基础",
                    Type = "一级目录",
                    Analysis = "包含项目基本信息、招标范围、资金来源及投标程序要求。",
                    RiskLevel = "low",
                    Content = "<p>项目与程序基础章节概述...</p>",
                    Children = new List<CreateSalesTenderChapterDto>
                    {
                        new CreateSalesTenderChapterDto
                        {
                            Title = "1. 项目基本信息",
                            Type = "二级目录",
                            Analysis = "提取项目名称、编号、招标内容等核心信息。",
                            Extraction = new List<SalesTenderExtractionDto>
                            {
                                new SalesTenderExtractionDto
                                {
                                    Label = "项目名称",
                                    Value = "示例信息化建设项目"
                                },
                                new SalesTenderExtractionDto
                                {
                                    Label = "项目编号",
                                    Value = "ZB-2024-001"
                                },
                                new SalesTenderExtractionDto { Label = "招标人", Value = "某政府部门" },
                                new SalesTenderExtractionDto { Label = "资金来源", Value = "财政拨款，已落实" }
                            },
                            Content = "<p>1.1 项目名称、编号、招标人... 1.2 招标内容与范围... 1.3 资金来源...</p>"
                        },
                        new CreateSalesTenderChapterDto
                        {
                            Title = "2. 投标程序要求",
                            Type = "二级目录",
                            Analysis = "关注投标截止时间、保证金及文件获取方式。",
                            RiskLevel = "medium",
                            Extraction = new List<SalesTenderExtractionDto>
                            {
                                new SalesTenderExtractionDto { Label = "文件获取", Value = "线上平台下载" },
                                new SalesTenderExtractionDto
                                {
                                    Label = "投标截止",
                                    Value = now.AddDays(20).ToString("yyyy-MM-dd HH:mm")
                                },
                                new SalesTenderExtractionDto
                                {
                                    Label = "保证金",
                                    Value = "20,000元，支持保函"
                                }
                            },
                            Content = "<p>2.1 招标文件获取... 2.2 截止与开标... 2.3 有效期与保证金...</p>"
                        }
                    }
                },
                // 二、 投标资格与条件
                new CreateSalesTenderChapterDto
                {
                    Title = "二、 投标资格与条件",
                    Type = "一级目录",
                    Analysis = "强制性资格要求与禁止性条款，直接关系投标有效性。",
                    RiskLevel = "high",
                    IsVeto = true,
                    Content = "<p>本章规定了合格投标人的必要条件。</p>",
                    Children = new List<CreateSalesTenderChapterDto>
                    {
                        new CreateSalesTenderChapterDto
                        {
                            Title = "3. 强制性资格条件",
                            Type = "二级目录",
                            Analysis = "必须满足的资质、业绩及人员要求。",
                            RiskLevel = "high",
                            IsVeto = true,
                            Extraction = new List<SalesTenderExtractionDto>
                            {
                                new SalesTenderExtractionDto
                                {
                                    Label = "企业资质",
                                    Value = "电子与智能化工程专业承包二级"
                                },
                                new SalesTenderExtractionDto
                                {
                                    Label = "业绩要求",
                                    Value = "近3年类似项目业绩2个"
                                },
                                new SalesTenderExtractionDto
                                {
                                    Label = "项目经理",
                                    Value = "机电工程专业一级建造师"
                                }
                            },
                            Content = "<p>3.1 企业资质... 3.2 业绩要求... 3.3 人员要求...</p>"
                        },
                        new CreateSalesTenderChapterDto
                        {
                            Title = "4. 合规性禁止条款",
                            Type = "二级目录",
                            Analysis = "检查是否存在排斥潜在投标人的条款。",
                            RiskLevel = "medium",
                            Extraction = new List<SalesTenderExtractionDto>
                            {
                                new SalesTenderExtractionDto
                                {
                                    Label = "排斥性条款",
                                    Value = "未发现明显指向性品牌"
                                }
                            },
                            Content = "<p>4.1 限制排斥条款... 4.2 规模条件设置...</p>"
                        }
                    }
                },
                // 三、 投标文件编制与格式
                new CreateSalesTenderChapterDto
                {
                    Title = "三、 投标文件编制与格式",
                    Type = "一级目录",
                    Analysis = "遵循格式要求，避免因格式错误导致废标。",
                    RiskLevel = "medium",
                    Content = "<p>投标文件编制的具体要求。</p>",
                    Children = new List<CreateSalesTenderChapterDto>
                    {
                        new CreateSalesTenderChapterDto
                        {
                            Title = "5. 文件组成与格式",
                            Type = "二级目录",
                            Analysis = "注意签字盖章及电子签章要求。",
                            Extraction = new List<SalesTenderExtractionDto>
                            {
                                new SalesTenderExtractionDto { Label = "封装要求", Value = "电子标书加密上传" },
                                new SalesTenderExtractionDto { Label = "特殊要求", Value = "使用指定CA锁签章" }
                            },
                            Content = "<p>5.1 内容清单... 5.2 签署盖章... 5.3 电子投标...</p>"
                        },
                        new CreateSalesTenderChapterDto
                        {
                            Title = "6. 技术标编制要求",
                            Type = "二级目录",
                            Analysis = "技术方案深度及暗标评审要求。",
                            RiskLevel = "high",
                            Extraction = new List<SalesTenderExtractionDto>
                            {
                                new SalesTenderExtractionDto
                                {
                                    Label = "暗标评审",
                                    Value = "是 (不得出现企业标识)"
                                },
                                new SalesTenderExtractionDto { Label = "佐证材料", Value = "需提供原件扫描件" }
                            },
                            Content = "<p>6.1 方案深度... 6.2 暗标评审... 6.3 佐证材料...</p>"
                        },
                        new CreateSalesTenderChapterDto
                        {
                            Title = "7. 商务与报价标要求",
                            Type = "二级目录",
                            Analysis = "报价方式及清单填写规范。",
                            Extraction = new List<SalesTenderExtractionDto>
                            {
                                new SalesTenderExtractionDto { Label = "报价方式", Value = "固定总价" },
                                new SalesTenderExtractionDto { Label = "备选方案", Value = "不允许" }
                            },
                            Content = "<p>7.1 报价方式... 7.2 工程量清单... 7.3 备选方案...</p>"
                        }
                    }
                },
                // 四、 评标办法与标准
                new CreateSalesTenderChapterDto
                {
                    Title = "四、 评标办法与标准",
                    Type = "一级目录",
                    Analysis = "详细解析评分细则，指导高分应答。",
                    RiskLevel = "high",
                    ScoreWeight = 100,
                    Content = "<p>本项目采用综合评估法。</p>",
                    Children = new List<CreateSalesTenderChapterDto>
                    {
                        new CreateSalesTenderChapterDto
                        {
                            Title = "8. 评标方法",
                            Type = "二级目录",
                            Analysis = "综合评估法：商务20分 + 技术50分 + 价格30分。",
                            Content = "<p>8.1 评标方法说明...</p>"
                        },
                        new CreateSalesTenderChapterDto
                        {
                            Title = "9. 评标标准与分值",
                            Type = "二级目录",
                            Analysis = "各评分项具体标准及分值分布。",
                            RiskLevel = "high",
                            Extraction = new List<SalesTenderExtractionDto>
                            {
                                new SalesTenderExtractionDto
                                {
                                    Label = "技术分",
                                    Value = "50分 (方案20+实施15+团队15)"
                                },
                                new SalesTenderExtractionDto
                                {
                                    Label = "商务分",
                                    Value = "20分 (业绩10+信誉5+财务5)"
                                },
                                new SalesTenderExtractionDto { Label = "价格分", Value = "30分" }
                            },
                            Content = "<p>9.1 评分因素... 9.2 具体得分点... 9.3 主观分区间...</p>"
                        }
                    }
                },
                // 五、 合同主要条款
                new CreateSalesTenderChapterDto
                {
                    Title = "五、 合同主要条款",
                    Type = "一级目录",
                    Analysis = "关注付款方式、工期及履约担保。",
                    RiskLevel = "medium",
                    Content = "<p>合同核心条款摘要。</p>",
                    Children = new List<CreateSalesTenderChapterDto>
                    {
                        new CreateSalesTenderChapterDto
                        {
                            Title = "10. 核心合同条件",
                            Type = "二级目录",
                            Analysis = "付款比例及验收标准。",
                            Extraction = new List<SalesTenderExtractionDto>
                            {
                                new SalesTenderExtractionDto
                                {
                                    Label = "付款方式",
                                    Value = "3-3-3-1 (预付30%)"
                                },
                                new SalesTenderExtractionDto { Label = "履约担保", Value = "中标价的10%" }
                            },
                            Content = "<p>10.1 价款与支付... 10.2 工期与质量... 10.3 履约担保...</p>"
                        }
                    }
                },
                // 六、 风险与合规检查
                new CreateSalesTenderChapterDto
                {
                    Title = "六、 风险与合规检查",
                    Type = "一级目录",
                    Analysis = "重点审查废标条款及串围标风险。",
                    RiskLevel = "high",
                    IsVeto = true,
                    Content = "<p>风险提示与合规性检查。</p>",
                    Children = new List<CreateSalesTenderChapterDto>
                    {
                        new CreateSalesTenderChapterDto
                        {
                            Title = "11. 否决投标条款",
                            Type = "二级目录",
                            Analysis = "汇总所有可能导致废标的“*”号条款。",
                            RiskLevel = "high",
                            IsVeto = true,
                            Extraction = new List<SalesTenderExtractionDto>
                            {
                                new SalesTenderExtractionDto { Label = "否决项1", Value = "未提供保证金" },
                                new SalesTenderExtractionDto { Label = "否决项2", Value = "超过最高限价" },
                                new SalesTenderExtractionDto { Label = "否决项3", Value = "无行贿犯罪记录" }
                            },
                            Content = "<p>11.1 否决条款汇总... 11.2 实质性响应要求...</p>"
                        },
                        new CreateSalesTenderChapterDto
                        {
                            Title = "12. 串标围标风险提示",
                            Type = "二级目录",
                            Analysis = "电子招投标防串标技术检测预警。",
                            RiskLevel = "high",
                            Extraction = new List<SalesTenderExtractionDto>
                            {
                                new SalesTenderExtractionDto { Label = "MAC/IP检测", Value = "严禁雷同" },
                                new SalesTenderExtractionDto
                                {
                                    Label = "文件雷同性",
                                    Value = "机器码一致将视为串标"
                                }
                            },
                            Content = "<p>12.1 IP/MAC地址警示... 12.2 文件雷同认定...</p>"
                        }
                    }
                }
            };

            // Customize based on tenderType if needed (optional, just varying some values)
            if (tenderType == "goods")
            {
                // Modify some values for goods
            }
            else if (tenderType == "engineering")
            {
                // Modify some values for engineering
            }

            return new TenderAnalysisResult
            {
                Deadline = now.AddDays(20),
                BidBond = "20,000 元",
                Budget = "300.00 万元",
                Qualification = "相关资质证书",
                BidStartTime = now,
                BidEndTime = now.AddDays(20),
                TenderStartTime = now,
                OpenBidTime = now.AddDays(21),
                PublishTime = now.AddDays(-2),
                ContactName = "张经理",
                ContactPhone = "010-12345678",
                AgencyName = "某招标代理公司",
                Chapters = chapters
            };
        }

        private class TenderAnalysisResult
        {
            public DateTime? Deadline { get; set; }
            public string? BidBond { get; set; }
            public string? Budget { get; set; }
            public string? Qualification { get; set; }
            public DateTime? BidStartTime { get; set; }
            public DateTime? BidEndTime { get; set; }
            public DateTime? TenderStartTime { get; set; }
            public DateTime? OpenBidTime { get; set; }
            public DateTime? PublishTime { get; set; }
            public string? ContactName { get; set; }
            public string? ContactPhone { get; set; }
            public string? AgencyName { get; set; }
            public List<CreateSalesTenderChapterDto> Chapters { get; set; } =
                new List<CreateSalesTenderChapterDto>();
        }
    }
}
