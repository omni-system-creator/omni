using Microsoft.AspNetCore.Mvc;
using omsapi.Models.Common;
using omsapi.Models.Dtos.Forms;
using omsapi.Services.Interfaces;
using omsapi.Infrastructure.Attributes;

namespace omsapi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [AutoInject]
    public class FormController : ControllerBase
    {
        private readonly IFormService _formService;
        private readonly IUserService _userService;

        public FormController(IFormService formService, IUserService userService)
        {
            _formService = formService;
            _userService = userService;
        }

        private long GetCurrentUserId()
        {
            // Assuming we can get user ID from claims, or use a helper.
            // For now, let's try to parse from User.Identity if available, or default to 1 (admin) if dev/test without auth context.
            // In a real scenario, this should come from ICurrentUserService or HttpContext.User.Claims.
            // Looking at other controllers might help.
            if (User.Identity != null && User.Identity.IsAuthenticated)
            {
                var idClaim = User.Claims.FirstOrDefault(c => c.Type == "Id"); // Adjust claim type based on Auth implementation
                if (idClaim != null && long.TryParse(idClaim.Value, out long id))
                {
                    return id;
                }
            }
            return 1; // Fallback for dev/testing
        }

        // Categories

        [HttpGet("categories/tree")]
        public async Task<ActionResult<ApiResponse<List<FormCategoryDto>>>> GetCategoryTree()
        {
            var result = await _formService.GetCategoryTreeAsync();
            return Ok(ApiResponse<List<FormCategoryDto>>.Success(result));
        }

        [HttpPost("categories")]
        public async Task<ActionResult<ApiResponse<FormCategoryDto>>> CreateCategory([FromBody] CreateFormCategoryDto dto)
        {
            var result = await _formService.CreateCategoryAsync(dto, GetCurrentUserId());
            return Ok(ApiResponse<FormCategoryDto>.Success(result, "Created successfully"));
        }

        [HttpPut("categories/{id}")]
        public async Task<ActionResult<ApiResponse<FormCategoryDto>>> UpdateCategory(long id, [FromBody] UpdateFormCategoryDto dto)
        {
            var result = await _formService.UpdateCategoryAsync(id, dto);
            if (result == null) return NotFound(ApiResponse<object>.Error("Category not found", 404));
            return Ok(ApiResponse<FormCategoryDto>.Success(result, "Updated successfully"));
        }

        [HttpDelete("categories/{id}")]
        public async Task<ActionResult<ApiResponse<bool>>> DeleteCategory(long id)
        {
            var result = await _formService.DeleteCategoryAsync(id);
            if (!result) return BadRequest(ApiResponse<object>.Error("Cannot delete category. It may have children or forms.", 400));
            return Ok(ApiResponse<bool>.Success(true, "Deleted successfully"));
        }

        // Forms

        [HttpGet("definitions")]
        public async Task<ActionResult<ApiResponse<PagedResult<FormDefinitionDto>>>> GetForms(
            [FromQuery] long? categoryId, 
            [FromQuery] string? sortBy, 
            [FromQuery] bool isDescending = true,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10)
        {
            var result = await _formService.GetFormsAsync(categoryId, sortBy, isDescending, page, pageSize);
            return Ok(ApiResponse<PagedResult<FormDefinitionDto>>.Success(result));
        }

        [HttpGet("definitions/{id}")]
        public async Task<ActionResult<ApiResponse<FormDefinitionDto>>> GetForm(long id)
        {
            var result = await _formService.GetFormByIdAsync(id);
            if (result == null) return NotFound(ApiResponse<object>.Error("Form not found", 404));
            return Ok(ApiResponse<FormDefinitionDto>.Success(result));
        }

        [HttpPost("definitions")]
        public async Task<ActionResult<ApiResponse<FormDefinitionDto>>> CreateForm([FromBody] CreateFormDefinitionDto dto)
        {
            var result = await _formService.CreateFormAsync(dto, GetCurrentUserId());
            return Ok(ApiResponse<FormDefinitionDto>.Success(result, "Created successfully"));
        }

        [HttpPut("definitions/{id}")]
        public async Task<ActionResult<ApiResponse<FormDefinitionDto>>> UpdateForm(long id, [FromBody] UpdateFormDefinitionDto dto)
        {
            var result = await _formService.UpdateFormAsync(id, dto, GetCurrentUserId());
            if (result == null) return NotFound(ApiResponse<object>.Error("Form not found", 404));
            return Ok(ApiResponse<FormDefinitionDto>.Success(result, "Updated successfully"));
        }

        [HttpDelete("definitions/{id}")]
        public async Task<ActionResult<ApiResponse<bool>>> DeleteForm(long id)
        {
            var result = await _formService.DeleteFormAsync(id);
            if (!result) return NotFound(ApiResponse<object>.Error("Form not found", 404));
            return Ok(ApiResponse<bool>.Success(true, "Deleted successfully"));
        }

        [HttpPost("submit")]
        public async Task<ActionResult<ApiResponse<FormResultDto>>> SubmitForm([FromBody] CreateFormResultDto dto)
        {
            try 
            {
                // If submittedBy is not provided, try to use current user
                if (string.IsNullOrEmpty(dto.SubmittedBy))
                {
                    // For anonymous submission, we might use IP or just "Anonymous"
                    // Here we assume if they are logged in we use username, else "Anonymous"
                    if (User.Identity != null && User.Identity.IsAuthenticated)
                    {
                        dto.SubmittedBy = User.Identity.Name ?? "User " + GetCurrentUserId();
                    }
                    else
                    {
                         dto.SubmittedBy = "Anonymous";
                    }
                }
                
                var result = await _formService.SubmitFormAsync(dto);
                return Ok(ApiResponse<FormResultDto>.Success(result, "Submitted successfully"));
            }
            catch (Exception ex)
            {
                return BadRequest(ApiResponse<object>.Error(ex.Message));
            }
        }

        [HttpGet("results/{formId}")]
        public async Task<ActionResult<ApiResponse<List<FormResultDto>>>> GetFormResults(long formId)
        {
            var result = await _formService.GetFormResultsAsync(formId);
            return Ok(ApiResponse<List<FormResultDto>>.Success(result));
        }
    }
}
