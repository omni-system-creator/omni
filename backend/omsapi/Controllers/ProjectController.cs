using Microsoft.AspNetCore.Mvc;
using omsapi.Models.Dtos.Project;
using omsapi.Services.Interfaces;

namespace omsapi.Controllers
{
    [ApiController]
    [Route("api/project")]
    public class ProjectController : ControllerBase
    {
        private readonly IProjectService _service;

        public ProjectController(IProjectService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<ActionResult<List<ProjectListItemDto>>> GetProjects()
        {
            var projects = await _service.GetProjectsAsync();
            return Ok(projects);
        }

        [HttpGet("{code}")]
        public async Task<ActionResult<ProjectFullDto>> GetProject(string code)
        {
            var project = await _service.GetProjectAsync(code);
            if (project == null) return NotFound();
            return Ok(project);
        }

        [HttpPost]
        public async Task<ActionResult> SaveProject([FromBody] ProjectFullDto dto)
        {
            var result = await _service.SaveProjectAsync(dto);
            if (!result) return BadRequest("Save failed");
            return Ok();
        }
    }
}
