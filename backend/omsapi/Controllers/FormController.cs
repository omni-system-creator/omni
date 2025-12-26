using Microsoft.AspNetCore.Mvc;
using omsapi.Models.Common;
using omsapi.Models.Dtos.Forms;
using omsapi.Services.Interfaces;
using omsapi.Infrastructure.Extensions;
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
            var result = await _formService.CreateCategoryAsync(dto, User.GetUserId());
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
            long? userId = User.Identity?.IsAuthenticated == true ? User.GetUserId() : null;
            var result = await _formService.GetFormsAsync(userId, categoryId, sortBy, isDescending, page, pageSize);
            return Ok(ApiResponse<PagedResult<FormDefinitionDto>>.Success(result));
        }

        [HttpGet("definitions/{id}")]
        public async Task<ActionResult<ApiResponse<FormDefinitionDto>>> GetForm(long id)
        {
            string? username = User.GetUsername();
            long? userId = User.Identity?.IsAuthenticated == true ? User.GetUserId() : null;
            var result = await _formService.GetFormByIdAsync(id, userId, username);
            if (result == null) return NotFound(ApiResponse<object>.Error("Form not found or access denied", 404));
            return Ok(ApiResponse<FormDefinitionDto>.Success(result));
        }

        [HttpPost("definitions")]
        public async Task<ActionResult<ApiResponse<FormDefinitionDto>>> CreateForm([FromBody] CreateFormDefinitionDto dto)
        {
            var result = await _formService.CreateFormAsync(dto, User.GetUserId());
            return Ok(ApiResponse<FormDefinitionDto>.Success(result, "Created successfully"));
        }

        [HttpPut("definitions/{id}")]
        public async Task<ActionResult<ApiResponse<FormDefinitionDto>>> UpdateForm(long id, [FromBody] UpdateFormDefinitionDto dto)
        {
            var result = await _formService.UpdateFormAsync(id, dto, User.GetUserId());
            if (result == null) return NotFound(ApiResponse<object>.Error("Form not found", 404));
            return Ok(ApiResponse<FormDefinitionDto>.Success(result, "Updated successfully"));
        }

        [HttpDelete("definitions/{id}")]
        public async Task<ActionResult<ApiResponse<bool>>> DeleteForm(long id)
        {
            var result = await _formService.DeleteFormAsync(id, User.GetUserId());
            if (!result) return NotFound(ApiResponse<object>.Error("Form not found or access denied", 404));
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
                        dto.SubmittedBy = User.GetUsername() ?? "User " + User.GetUserId();
                    }
                    else
                    {
                         dto.SubmittedBy = "Anonymous";
                    }
                }
                
                long? userId = User.Identity?.IsAuthenticated == true ? User.GetUserId() : null;
                var result = await _formService.SubmitFormAsync(dto, userId);
                return Ok(ApiResponse<FormResultDto>.Success(result, "Submitted successfully"));
            }
            catch (Exception ex)
            {
                return BadRequest(ApiResponse<object>.Error(ex.Message));
            }
        }

        [HttpGet("results/{formId}")]
        public async Task<ActionResult<ApiResponse<PagedResult<FormResultDto>>>> GetFormResults(
            long formId,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10)
        {
            try
            {
                var result = await _formService.GetFormResultsAsync(formId, User.GetUserId(), page, pageSize);
                return Ok(ApiResponse<PagedResult<FormResultDto>>.Success(result));
            }
            catch (Exception ex)
            {
                return BadRequest(ApiResponse<object>.Error(ex.Message));
            }
        }
    }
}
