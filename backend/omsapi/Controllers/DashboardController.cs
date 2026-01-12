using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using omsapi.Data;
using omsapi.Infrastructure.Extensions;
using omsapi.Models.Common;
using omsapi.Models.Entities.System;
using omsapi.Services.Interfaces;
using System.Security.Claims;

namespace omsapi.Controllers
{
    [ApiController]
    [Route("api/dashboard")]
    [Authorize]
    public class DashboardController : ControllerBase
    {
        private readonly IAiService _aiService;
        private readonly OmsContext _context;
        private readonly ILogger<DashboardController> _logger;

        public DashboardController(IAiService aiService, OmsContext context, ILogger<DashboardController> logger)
        {
            _aiService = aiService;
            _context = context;
            _logger = logger;
        }

        /// <summary>
        /// 获取 AI 生成的问候语
        /// </summary>
        /// <returns></returns>
        [HttpGet("greeting")]
        public async Task<ApiResponse<string>> GetAiGreeting()
        {
            try
            {
                // 尝试从缓存获取
                var cachedGreeting = await GetCachedContentAsync("greeting");
                if (!string.IsNullOrEmpty(cachedGreeting))
                {
                    return ApiResponse<string>.Success(cachedGreeting);
                }

                var prompt = $"请生成一句简短、温馨且专业的职场祝福语，适合显示在系统首页欢迎卡片上。要求：中文，20字以内，不要包含用户称呼（如“xxx你好”或“欢迎回来”），直接输出祝福内容，不包含引号，语气积极向上。";

                // 使用较快的模型，如果配置了的话
                var greeting = await _aiService.GetChatCompletionAsync(prompt);

                // 简单的错误检测（基于 AiService 的返回习惯）
                if (greeting.Contains("API Key missing") || greeting.Contains("Error"))
                {
                    // 回退到本地生成
                    return ApiResponse<string>.Success(GetLocalGreeting());
                }

                greeting = greeting.Trim().Trim('"');
                await SaveToCacheAsync("greeting", greeting);

                return ApiResponse<string>.Success(greeting);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error generating AI greeting");
                // 异常时回退到本地
                return ApiResponse<string>.Success(GetLocalGreeting());
            }
        }

        /// <summary>
        /// 获取 AI 生成的系统标语/介绍
        /// </summary>
        /// <returns></returns>
        [HttpGet("slogan")]
        public async Task<ApiResponse<string>> GetAiSlogan()
        {
            try
            {
                // 尝试从缓存获取
                var cachedSlogan = await GetCachedContentAsync("slogan");
                if (!string.IsNullOrEmpty(cachedSlogan))
                {
                    return ApiResponse<string>.Success(cachedSlogan);
                }

                // 简单的本地回退逻辑
                var localSlogan = "集中管理各种信息数据的系统，类似包括但不只是OA、ERP、WMS、CRM等，各种能做的都可以做。";
                
                var prompt = "请生成一句关于企业信息管理系统（OmniSystem）的短句或标语，强调数据集中管理、高效协作和全能性。要求：中文，40字以内，不包含引号，语气专业且富有科技感。";

                // 使用较快的模型
                var slogan = await _aiService.GetChatCompletionAsync(prompt);

                if (slogan.Contains("API Key missing") || slogan.Contains("Error"))
                {
                    return ApiResponse<string>.Success(localSlogan);
                }

                slogan = slogan.Trim().Trim('"');
                await SaveToCacheAsync("slogan", slogan);

                return ApiResponse<string>.Success(slogan);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error generating AI slogan");
                return ApiResponse<string>.Success("集中管理各种信息数据的系统，助力企业数字化转型。");
            }
        }

        private async Task<string?> GetCachedContentAsync(string type)
        {
            // 1. 检查总数
            var count = await _context.AiGeneratedContents.CountAsync(x => x.Type == type);
            if (count >= 100)
            {
                // 随机获取一条
                var random = new Random();
                var skip = random.Next(0, count);
                var item = await _context.AiGeneratedContents
                    .Where(x => x.Type == type)
                    .Skip(skip)
                    .Select(x => x.Content)
                    .FirstOrDefaultAsync();
                return item;
            }
            return null;
        }

        private async Task SaveToCacheAsync(string type, string content)
        {
            if (string.IsNullOrWhiteSpace(content)) return;

            // 检查重复
            var exists = await _context.AiGeneratedContents.AnyAsync(x => x.Type == type && x.Content == content);
            if (!exists)
            {
                var ip = HttpContext.GetClientIp();
                var user = User.Identity?.Name;

                _context.AiGeneratedContents.Add(new AiGeneratedContent
                {
                    Type = type,
                    Content = content,
                    IpAddress = ip,
                    CreatedBy = user,
                    CreatedAt = DateTime.Now
                });
                await _context.SaveChangesAsync();
            }
        }

        private string GetLocalGreeting()
        {
            var hour = DateTime.Now.Hour;
            string timeGreeting;
            if (hour < 6) timeGreeting = "夜深了，注意休息";
            else if (hour < 9) timeGreeting = "早上好";
            else if (hour < 12) timeGreeting = "上午好";
            else if (hour < 14) timeGreeting = "中午好";
            else if (hour < 18) timeGreeting = "下午好";
            else timeGreeting = "晚上好";

            return $"{timeGreeting}，祝您工作愉快！";
        }
    }
}
