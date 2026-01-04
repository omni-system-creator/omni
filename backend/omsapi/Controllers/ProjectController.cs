using Microsoft.AspNetCore.Mvc;
using omsapi.Models.Dtos.Project;
using omsapi.Services.Interfaces;

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
        public async Task<ActionResult<List<ProjectListItemDto>>> GetProjects()
        {
            var projects = await _service.GetProjectsAsync();
            return Ok(projects);
        }

        /// <summary>
        /// 获取项目详情
        /// </summary>
        [HttpGet("{code}")]
        public async Task<ActionResult<ProjectFullDto>> GetProject(string code)
        {
            var project = await _service.GetProjectAsync(code);
            if (project == null) return NotFound();
            return Ok(project);
        }

        /// <summary>
        /// 保存项目
        /// </summary>
        [HttpPost]
        public async Task<ActionResult> SaveProject([FromBody] ProjectFullDto dto)
        {
            var result = await _service.SaveProjectAsync(dto);
            if (!result) return BadRequest("Save failed");
            return Ok();
        }
    }
}
