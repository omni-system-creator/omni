using omsapi.Models.Dtos.Project;

namespace omsapi.Services.Interfaces
{
    public interface IProjectService
    {
        Task<List<ProjectListItemDto>> GetProjectsAsync(string username, bool isAdmin = false);
        Task<ProjectFullDto?> GetProjectAsync(string code, string username, bool isAdmin = false);
        Task<bool> SaveProjectAsync(ProjectFullDto projectDto, string username);
    }
}
