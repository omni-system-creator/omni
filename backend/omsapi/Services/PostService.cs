using Microsoft.EntityFrameworkCore;
using omsapi.Data;
using omsapi.Infrastructure.Attributes;
using omsapi.Models.Dtos;
using omsapi.Models.Entities;
using omsapi.Services.Interfaces;

namespace omsapi.Services
{
    [AutoInject(ServiceLifetime.Scoped)]
    public class PostService : IPostService
    {
        private readonly OmsContext _context;

        public PostService(OmsContext context)
        {
            _context = context;
        }

        public async Task<(bool Success, string Message, List<PostDto>? Data)> GetAllPostsAsync(long? deptId = null)
        {
            var query = _context.Posts.AsQueryable();

            if (deptId.HasValue)
            {
                query = query.Where(p => p.DeptId == deptId);
            }

            var posts = await query
                .Include(p => p.Dept)
                .OrderBy(p => p.SortOrder)
                .Select(p => new PostDto
                {
                    Id = p.Id,
                    Code = p.Code,
                    Name = p.Name,
                    SortOrder = p.SortOrder,
                    IsActive = p.IsActive,
                    Remark = p.Remark,
                    DeptId = p.DeptId,
                    DeptName = p.Dept != null ? p.Dept.Name : null,
                    CreatedAt = p.CreatedAt
                })
                .ToListAsync();

            return (true, "获取成功", posts);
        }

        public async Task<(bool Success, string Message, PostDto? Data)> GetPostByIdAsync(long id)
        {
            var post = await _context.Posts
                .Include(p => p.Dept)
                .FirstOrDefaultAsync(p => p.Id == id);
            
            if (post == null) return (false, "岗位不存在", null);

            return (true, "获取成功", new PostDto
            {
                Id = post.Id,
                Code = post.Code,
                Name = post.Name,
                SortOrder = post.SortOrder,
                IsActive = post.IsActive,
                Remark = post.Remark,
                DeptId = post.DeptId,
                DeptName = post.Dept != null ? post.Dept.Name : null,
                CreatedAt = post.CreatedAt
            });
        }

        public async Task<(bool Success, string Message)> CreatePostAsync(CreatePostDto dto)
        {
            if (await _context.Posts.AnyAsync(p => p.Code == dto.Code))
            {
                return (false, "岗位编码已存在");
            }

            var post = new SystemPost
            {
                Code = dto.Code,
                Name = dto.Name,
                SortOrder = dto.SortOrder,
                IsActive = dto.IsActive,
                Remark = dto.Remark,
                DeptId = dto.DeptId,
                CreatedAt = DateTime.Now
            };

            _context.Posts.Add(post);
            await _context.SaveChangesAsync();
            return (true, "创建成功");
        }

        public async Task<(bool Success, string Message)> UpdatePostAsync(long id, UpdatePostDto dto)
        {
            var post = await _context.Posts.FindAsync(id);
            if (post == null) return (false, "岗位不存在");

            if (dto.Code != null && dto.Code != post.Code)
            {
                if (await _context.Posts.AnyAsync(p => p.Code == dto.Code))
                {
                    return (false, "岗位编码已存在");
                }
                post.Code = dto.Code;
            }

            if (dto.Name != null) post.Name = dto.Name;
            if (dto.SortOrder.HasValue) post.SortOrder = dto.SortOrder.Value;
            if (dto.IsActive.HasValue) post.IsActive = dto.IsActive.Value;
            if (dto.Remark != null) post.Remark = dto.Remark;
            if (dto.DeptId.HasValue) post.DeptId = dto.DeptId;
            
            post.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();
            return (true, "更新成功");
        }

        public async Task<(bool Success, string Message)> DeletePostAsync(long id)
        {
            var post = await _context.Posts.FindAsync(id);
            if (post == null) return (false, "岗位不存在");

            // Check if users are assigned to this post
            if (await _context.UserPosts.AnyAsync(up => up.PostId == id))
            {
                return (false, "该岗位下存在用户，无法删除");
            }

            _context.Posts.Remove(post);
            await _context.SaveChangesAsync();
            return (true, "删除成功");
        }
    }
}