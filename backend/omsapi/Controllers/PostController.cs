using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using omsapi.Models.Common;
using omsapi.Models.Dtos;
using omsapi.Services.Interfaces;

namespace omsapi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class PostController : ControllerBase
    {
        private readonly IPostService _postService;

        public PostController(IPostService postService)
        {
            _postService = postService;
        }

        [HttpGet]
        public async Task<ApiResponse<List<PostDto>>> GetAll([FromQuery] long? deptId = null)
        {
            var userIdClaim = User.FindFirst("id");
            if (userIdClaim == null) return ApiResponse<List<PostDto>>.Error("未登录");
            long userId = long.Parse(userIdClaim.Value);
            var (success, message, data) = await _postService.GetAllPostsAsync(userId, deptId);
            if (!success) return ApiResponse<List<PostDto>>.Error(message);
            return ApiResponse<List<PostDto>>.Success(data!);
        }

        [HttpGet("{id}")]
        public async Task<ApiResponse<PostDto>> GetById(long id)
        {
            var userIdClaim = User.FindFirst("id");
            if (userIdClaim == null) return ApiResponse<PostDto>.Error("未登录");
            long userId = long.Parse(userIdClaim.Value);
            var (success, message, data) = await _postService.GetPostByIdAsync(userId, id);
            if (!success) return ApiResponse<PostDto>.Error(message);
            return ApiResponse<PostDto>.Success(data!);
        }

        [HttpPost]
        public async Task<ApiResponse<object>> Create([FromBody] CreatePostDto dto)
        {
            var userIdClaim = User.FindFirst("id");
            if (userIdClaim == null) return ApiResponse<object>.Error("未登录");
            long userId = long.Parse(userIdClaim.Value);
            var (success, message) = await _postService.CreatePostAsync(userId, dto);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null, message);
        }

        [HttpPut("{id}")]
        public async Task<ApiResponse<object>> Update(long id, [FromBody] UpdatePostDto dto)
        {
            var userIdClaim = User.FindFirst("id");
            if (userIdClaim == null) return ApiResponse<object>.Error("未登录");
            long userId = long.Parse(userIdClaim.Value);
            var (success, message) = await _postService.UpdatePostAsync(userId, id, dto);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null, message);
        }

        [HttpDelete("{id}")]
        public async Task<ApiResponse<object>> Delete(long id)
        {
            var userIdClaim = User.FindFirst("id");
            if (userIdClaim == null) return ApiResponse<object>.Error("未登录");
            long userId = long.Parse(userIdClaim.Value);
            var (success, message) = await _postService.DeletePostAsync(userId, id);
            if (!success) return ApiResponse<object>.Error(message);
            return ApiResponse<object>.Success(null, message);
        }
    }
}
