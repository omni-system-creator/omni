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
    public class DeptController : ControllerBase
    {
        private readonly IDeptService _deptService;

        public DeptController(IDeptService deptService)
        {
            _deptService = deptService;
        }

        [HttpGet("tree")]
        public async Task<ActionResult<ApiResponse<List<DeptTreeDto>>>> GetDeptTree([FromQuery] long? rootId = null)
        {
            var userIdClaim = User.FindFirst("id");
            if (userIdClaim == null) return Unauthorized();
            long userId = long.Parse(userIdClaim.Value);

            var tree = await _deptService.GetDeptTreeAsync(userId, rootId);
            return Ok(ApiResponse<List<DeptTreeDto>>.Success(tree));
        }

        [HttpGet("roots")]
        [Authorize(Roles = "SuperAdmin")]
        public async Task<ActionResult<ApiResponse<List<DeptTreeDto>>>> GetRootDepts()
        {
            var roots = await _deptService.GetRootDeptsAsync();
            return Ok(ApiResponse<List<DeptTreeDto>>.Success(roots));
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<ApiResponse<DeptTreeDto>>> GetDept(long id)
        {
            var dept = await _deptService.GetDeptByIdAsync(id);
            if (dept == null) return Ok(ApiResponse<DeptTreeDto>.Error("Department not found", 404));
            return Ok(ApiResponse<DeptTreeDto>.Success(dept));
        }

        [HttpPost]
        public async Task<ActionResult<ApiResponse<DeptTreeDto>>> CreateDept(CreateDeptDto dto)
        {
            var isRoot = !dto.ParentId.HasValue || dto.ParentId.Value == 0;
            if (isRoot && !User.IsInRole("SuperAdmin"))
            {
                return Ok(ApiResponse<DeptTreeDto>.Error("只有平台超级管理员能新建顶级根组织", 403));
            }
            var result = await _deptService.CreateDeptAsync(dto);
            // CreatedAtAction usually returns 201. We can wrap the result.
            // But to keep "Unified Structure" usually 200 is preferred with code=200 in body.
            // Or 201 with body.
            // Let's stick to Ok() with Success for uniformity if strict 200 is required by frontend logic,
            // but CreatedAtAction is semantically correct. 
            // The frontend request.ts handles non-200 as error? 
            // "if (res.code && res.code !== 200) ...视为业务错误"
            // So if I return 201, res.code might be undefined if I don't put it in body.
            // If I return ApiResponse, Code=200.
            // So: return Ok(ApiResponse.Success(result));
            return Ok(ApiResponse<DeptTreeDto>.Success(result));
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<ApiResponse<object>>> UpdateDept(long id, UpdateDeptDto dto)
        {
            try 
            {
                var success = await _deptService.UpdateDeptAsync(id, dto);
                if (!success) return Ok(ApiResponse<object>.Error("Department not found", 404));
                return Ok(ApiResponse<object>.Success(null));
            }
            catch (ArgumentException ex)
            {
                return Ok(ApiResponse<object>.Error(ex.Message, 400));
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<ApiResponse<object>>> DeleteDept(long id)
        {
            try
            {
                var dept = await _deptService.GetDeptByIdAsync(id);
                if (dept == null) return Ok(ApiResponse<object>.Error("Department not found", 404));
                var isRoot = !dept.ParentId.HasValue || dept.ParentId.Value == 0;
                if (isRoot && !User.IsInRole("SuperAdmin"))
                {
                    return Ok(ApiResponse<object>.Error("只有平台超级管理员能删除顶级根组织", 403));
                }
                var success = await _deptService.DeleteDeptAsync(id);
                if (!success) return Ok(ApiResponse<object>.Error("Department not found", 404));
                return Ok(ApiResponse<object>.Success(null));
            }
            catch (InvalidOperationException ex)
            {
                return Ok(ApiResponse<object>.Error(ex.Message, 400));
            }
        }
        
        [HttpPut("structure")]
        public async Task<ActionResult<ApiResponse<object>>> UpdateStructure(List<UpdateDeptStructureDto> dtos)
        {
            await _deptService.BatchUpdateStructureAsync(dtos);
            return Ok(ApiResponse<object>.Success(null));
        }
    }
}
