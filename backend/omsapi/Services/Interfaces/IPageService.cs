using omsapi.Models.Common;
using omsapi.Models.Dtos;

namespace omsapi.Services.Interfaces
{
    public interface IPageService
    {
        // Categories
        Task<List<PageCategoryDto>> GetCategoriesAsync();
        Task<PageCategoryDto?> CreateCategoryAsync(CreatePageCategoryDto dto);
        Task<PageCategoryDto?> UpdateCategoryAsync(long id, UpdatePageCategoryDto dto);
        Task<bool> DeleteCategoryAsync(long id);

        // Pages
        Task<PagedResult<PageDefinitionDto>> GetPagesAsync(long? categoryId, string? keyword, int page, int pageSize);
        Task<PageDefinitionDto?> GetPageByIdAsync(long id);
        Task<PageDefinitionDto> CreatePageAsync(CreatePageDefinitionDto dto);
        Task<PageDefinitionDto?> UpdatePageAsync(long id, UpdatePageDefinitionDto dto);
        Task<bool> DeletePageAsync(long id);
    }
}
