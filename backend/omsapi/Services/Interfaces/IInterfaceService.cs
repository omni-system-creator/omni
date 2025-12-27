using omsapi.Models.Common;
using omsapi.Models.Dtos;

namespace omsapi.Services.Interfaces
{
    public interface IInterfaceService
    {
        // Categories
        Task<List<InterfaceCategoryDto>> GetCategoryTreeAsync();
        Task<InterfaceCategoryDto?> GetCategoryByIdAsync(long id);
        Task<InterfaceCategoryDto> CreateCategoryAsync(CreateInterfaceCategoryDto dto, long userId);
        Task<InterfaceCategoryDto?> UpdateCategoryAsync(long id, UpdateInterfaceCategoryDto dto);
        Task<bool> DeleteCategoryAsync(long id);

        // Interfaces
        Task<PagedResult<InterfaceDefinitionDto>> GetInterfacesAsync(long? categoryId = null, string? keyword = null, int page = 1, int pageSize = 10);
        Task<InterfaceDefinitionDto?> GetInterfaceByIdAsync(long id);
        Task<InterfaceDefinitionDto> CreateInterfaceAsync(CreateInterfaceDto dto, long userId);
        Task<InterfaceDefinitionDto?> UpdateInterfaceAsync(long id, UpdateInterfaceDto dto, long userId);
        Task<bool> DeleteInterfaceAsync(long id, long userId);
        Task<bool> PublishInterfaceAsync(long id, bool isPublished, long userId);
        Task<InterfaceDefinitionDto?> GetInterfaceByPathAsync(string path);
    }
}
