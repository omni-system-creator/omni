using omsapi.Models.Common;
using omsapi.Models.Dtos.Forms;

namespace omsapi.Services.Interfaces
{
    public interface IFormService
    {
        // Category
        Task<List<FormCategoryDto>> GetCategoryTreeAsync();
        Task<FormCategoryDto?> GetCategoryByIdAsync(long id);
        Task<FormCategoryDto> CreateCategoryAsync(CreateFormCategoryDto dto, long userId);
        Task<FormCategoryDto?> UpdateCategoryAsync(long id, UpdateFormCategoryDto dto);
        Task<bool> DeleteCategoryAsync(long id);

        // Form Definition
        Task<PagedResult<FormDefinitionDto>> GetFormsAsync(long? userId, long? categoryId = null, string? sortBy = null, bool isDescending = true, int page = 1, int pageSize = 10);
        Task<FormDefinitionDto?> GetFormByIdAsync(long id, long? userId, string? submittedBy = null);
        Task<FormDefinitionDto> CreateFormAsync(CreateFormDefinitionDto dto, long userId);
        Task<FormDefinitionDto?> UpdateFormAsync(long id, UpdateFormDefinitionDto dto, long userId);
        Task<bool> DeleteFormAsync(long id, long userId);

        // Form Submission
        Task<FormResultDto> SubmitFormAsync(CreateFormResultDto dto, long? userId);
        Task<PagedResult<FormResultDto>> GetFormResultsAsync(long formId, long userId, int page = 1, int pageSize = 10);
    }
}
