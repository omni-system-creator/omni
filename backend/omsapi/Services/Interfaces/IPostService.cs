using omsapi.Models.Dtos;

namespace omsapi.Services.Interfaces
{
    public interface IPostService
    {
        Task<(bool Success, string Message, List<PostDto>? Data)> GetAllPostsAsync(long? deptId = null);
        Task<(bool Success, string Message, PostDto? Data)> GetPostByIdAsync(long id);
        Task<(bool Success, string Message)> CreatePostAsync(CreatePostDto dto);
        Task<(bool Success, string Message)> UpdatePostAsync(long id, UpdatePostDto dto);
        Task<(bool Success, string Message)> DeletePostAsync(long id);
    }
}
