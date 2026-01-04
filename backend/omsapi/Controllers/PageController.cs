using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using omsapi.Models.Common;
using omsapi.Models.Dtos;
using omsapi.Services.Interfaces;

namespace omsapi.Controllers
{
    /// <summary>
    /// 页面管理控制器
    /// </summary>
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class PageController : ControllerBase
    {
        private readonly IPageService _pageService;

        public PageController(IPageService pageService)
        {
            _pageService = pageService;
        }

        #region Categories

        /// <summary>
        /// 获取页面分类列表
        /// </summary>
        [HttpGet("categories")]
        public async Task<ActionResult<ApiResponse<List<PageCategoryDto>>>> GetCategories()
        {
            var data = await _pageService.GetCategoriesAsync();
            return Ok(ApiResponse<List<PageCategoryDto>>.Success(data));
        }

        /// <summary>
        /// 创建页面分类
        /// </summary>
        [HttpPost("categories")]
        public async Task<ActionResult<ApiResponse<PageCategoryDto>>> CreateCategory([FromBody] CreatePageCategoryDto dto)
        {
            var data = await _pageService.CreateCategoryAsync(dto);
            if (data == null) return BadRequest(ApiResponse<object>.Error("Failed to create category"));
            return Ok(ApiResponse<PageCategoryDto>.Success(data));
        }

        /// <summary>
        /// 更新页面分类
        /// </summary>
        [HttpPut("categories/{id}")]
        public async Task<ActionResult<ApiResponse<PageCategoryDto>>> UpdateCategory(long id, [FromBody] UpdatePageCategoryDto dto)
        {
            var data = await _pageService.UpdateCategoryAsync(id, dto);
            if (data == null) return NotFound(ApiResponse<object>.Error("Category not found"));
            return Ok(ApiResponse<PageCategoryDto>.Success(data));
        }

        /// <summary>
        /// 删除页面分类
        /// </summary>
        [HttpDelete("categories/{id}")]
        public async Task<ActionResult<ApiResponse<object>>> DeleteCategory(long id)
        {
            var success = await _pageService.DeleteCategoryAsync(id);
            if (!success) return BadRequest(ApiResponse<object>.Error("Failed to delete category. It may contain children or pages."));
            return Ok(ApiResponse<object>.Success(null, "Category deleted successfully"));
        }

        #endregion

        #region Pages

        /// <summary>
        /// 获取页面列表
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<ApiResponse<PagedResult<PageDefinitionDto>>>> GetPages(
            [FromQuery] long? categoryId,
            [FromQuery] string? keyword,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10)
        {
            var data = await _pageService.GetPagesAsync(categoryId, keyword, page, pageSize);
            return Ok(ApiResponse<PagedResult<PageDefinitionDto>>.Success(data));
        }

        /// <summary>
        /// 获取页面详情
        /// </summary>
        [HttpGet("{id}")]
        public async Task<ActionResult<ApiResponse<PageDefinitionDto>>> GetPage(long id)
        {
            var data = await _pageService.GetPageByIdAsync(id);
            if (data == null) return NotFound(ApiResponse<object>.Error("Page not found"));
            return Ok(ApiResponse<PageDefinitionDto>.Success(data));
        }

        /// <summary>
        /// 创建页面
        /// </summary>
        [HttpPost]
        public async Task<ActionResult<ApiResponse<PageDefinitionDto>>> CreatePage([FromBody] CreatePageDefinitionDto dto)
        {
            var data = await _pageService.CreatePageAsync(dto);
            return Ok(ApiResponse<PageDefinitionDto>.Success(data));
        }

        /// <summary>
        /// 更新页面
        /// </summary>
        [HttpPut("{id}")]
        public async Task<ActionResult<ApiResponse<PageDefinitionDto>>> UpdatePage(long id, [FromBody] UpdatePageDefinitionDto dto)
        {
            var data = await _pageService.UpdatePageAsync(id, dto);
            if (data == null) return NotFound(ApiResponse<object>.Error("Page not found"));
            return Ok(ApiResponse<PageDefinitionDto>.Success(data));
        }

        /// <summary>
        /// 删除页面
        /// </summary>
        [HttpDelete("{id}")]
        public async Task<ActionResult<ApiResponse<object>>> DeletePage(long id)
        {
            var success = await _pageService.DeletePageAsync(id);
            if (!success) return NotFound(ApiResponse<object>.Error("Page not found"));
            return Ok(ApiResponse<object>.Success(null, "Page deleted successfully"));
        }

        #endregion
    }
}
