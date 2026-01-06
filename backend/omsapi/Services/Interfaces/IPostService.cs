using omsapi.Models.Dtos;

namespace omsapi.Services.Interfaces
{
    public interface IPostService
    {
        Task<(bool Success, string Message, List<PostDto>? Data)> GetAllPostsAsync(long userId, long? deptId = null);
        Task<(bool Success, string Message, PostDto? Data)> GetPostByIdAsync(long userId, long id);
        Task<(bool Success, string Message)> CreatePostAsync(long userId, CreatePostDto dto);
        Task<(bool Success, string Message)> UpdatePostAsync(long userId, long id, UpdatePostDto dto);
        Task<(bool Success, string Message)> DeletePostAsync(long userId, long id);
    }
}
