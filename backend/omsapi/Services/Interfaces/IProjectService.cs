using omsapi.Models.Dtos.Project;

namespace omsapi.Services.Interfaces
{
    public interface IProjectService
    {
        Task<List<ProjectListItemDto>> GetProjectsAsync();
        Task<ProjectFullDto?> GetProjectAsync(string code);
        Task<bool> SaveProjectAsync(ProjectFullDto projectDto);
    }
}
