using omsapi.Models.Dtos.System;
using omsapi.Models.Entities.Dict;

namespace omsapi.Services.Interfaces
{
    public interface IDictService
    {
        // Category
        Task<List<DictCategoryDto>> GetCategoryTreeAsync();
        Task<DictCategoryDto?> GetCategoryAsync(long id);
        Task<DictCategoryDto> CreateCategoryAsync(CreateDictCategoryDto dto);
        Task<DictCategoryDto?> UpdateCategoryAsync(long id, UpdateDictCategoryDto dto);
        Task<bool> DeleteCategoryAsync(long id);

        // Type
        Task<List<DictTypeDto>> GetTypesAsync(long? categoryId = null, string? name = null, string? code = null);
        Task<DictTypeDto?> GetTypeAsync(long id);
        Task<DictTypeDto?> GetTypeByCodeAsync(string code);
        Task<DictTypeDto> CreateTypeAsync(CreateDictTypeDto dto);
        Task<DictTypeDto?> UpdateTypeAsync(long id, UpdateDictTypeDto dto);
        Task<bool> DeleteTypeAsync(long id);

        // Data
        Task<List<DictDataDto>> GetDataListAsync(long? typeId = null, string? typeCode = null);
        Task<DictDataDto?> GetDataAsync(long id);
        Task<DictDataDto> CreateDataAsync(CreateDictDataDto dto);
        Task<DictDataDto?> UpdateDataAsync(long id, UpdateDictDataDto dto);
        Task<bool> DeleteDataAsync(long id);
    }
}
