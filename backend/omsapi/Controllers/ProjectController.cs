using Microsoft.AspNetCore.Mvc;
using omsapi.Models.Common;
using omsapi.Models.Dtos;
using omsapi.Models.Dtos.Project;
using omsapi.Services.Interfaces;
using System.Security.Claims;

namespace omsapi.Controllers
{
    /// <summary>
    /// 项目管理控制器
    /// </summary>
    [ApiController]
    [Route("api/project")]
    public class ProjectController : ControllerBase
    {
        private readonly IProjectService _service;

        public ProjectController(IProjectService service)
        {
            _service = service;
        }

        /// <summary>
        /// 获取项目列表
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<ApiResponse<List<ProjectListItemDto>>>> GetProjects()
        {
            var username = User.FindFirst(ClaimTypes.Name)?.Value;
            if (string.IsNullOrEmpty(username)) return Unauthorized(ApiResponse<object>.Error("Unauthorized", 401));

            var isAdmin = User.IsInRole("SuperAdmin");
            var projects = await _service.GetProjectsAsync(username, isAdmin);
            return Ok(ApiResponse<List<ProjectListItemDto>>.Success(projects));
        }

        /// <summary>
        /// 获取项目详情
        /// </summary>
        [HttpGet("{code}")]
        public async Task<ActionResult<ApiResponse<ProjectFullDto>>> GetProject(string code)
        {
            var username = User.FindFirst(ClaimTypes.Name)?.Value;
            if (string.IsNullOrEmpty(username)) return Unauthorized(ApiResponse<object>.Error("Unauthorized", 401));

            var isAdmin = User.IsInRole("SuperAdmin");
            var project = await _service.GetProjectAsync(code, username, isAdmin);
            if (project == null) return NotFound(ApiResponse<object>.Error("Project not found", 404));
            return Ok(ApiResponse<ProjectFullDto>.Success(project));
        }

        /// <summary>
        /// 保存项目
        /// </summary>
        [HttpPost]
        public async Task<ActionResult<ApiResponse<object>>> SaveProject([FromBody] ProjectFullDto dto)
        {
            var username = User.FindFirst(ClaimTypes.Name)?.Value;
            if (string.IsNullOrEmpty(username)) return Unauthorized(ApiResponse<object>.Error("Unauthorized", 401));

            var result = await _service.SaveProjectAsync(dto, username);
            if (!result) return BadRequest(ApiResponse<object>.Error("Save failed"));
            return Ok(ApiResponse<object>.Success(null));
        }
    }
}
