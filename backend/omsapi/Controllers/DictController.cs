using Microsoft.AspNetCore.Mvc;
using omsapi.Models.Common;
using omsapi.Models.Dtos.System;
using omsapi.Services.Interfaces;

namespace omsapi.Controllers
{
    /// <summary>
    /// 字典管理控制器
    /// </summary>
    [ApiController]
    [Route("api/system/dict")]
    public class DictController : ControllerBase
    {
        private readonly IDictService _dictService;

        public DictController(IDictService dictService)
        {
            _dictService = dictService;
        }

        // --- Category ---

        /// <summary>
        /// 获取字典分类列表/树
        /// </summary>
        [HttpGet("categories")]
        public async Task<ApiResponse<List<DictCategoryDto>>> GetCategoryTree()
        {
            var result = await _dictService.GetCategoryTreeAsync();
            return ApiResponse<List<DictCategoryDto>>.Success(result);
        }

        /// <summary>
        /// 获取字典分类详情
        /// </summary>
        [HttpGet("categories/{id}")]
        public async Task<ApiResponse<DictCategoryDto>> GetCategory(long id)
        {
            var result = await _dictService.GetCategoryAsync(id);
            return result != null
                ? ApiResponse<DictCategoryDto>.Success(result)
                : ApiResponse<DictCategoryDto>.Error("Category not found");
        }

        /// <summary>
        /// 创建字典分类
        /// </summary>
        [HttpPost("categories")]
        public async Task<ApiResponse<DictCategoryDto>> CreateCategory([FromBody] CreateDictCategoryDto dto)
        {
            var result = await _dictService.CreateCategoryAsync(dto);
            return ApiResponse<DictCategoryDto>.Success(result);
        }

        /// <summary>
        /// 更新字典分类
        /// </summary>
        [HttpPut("categories/{id}")]
        public async Task<ApiResponse<DictCategoryDto>> UpdateCategory(long id, [FromBody] UpdateDictCategoryDto dto)
        {
            var result = await _dictService.UpdateCategoryAsync(id, dto);
            return result != null
                ? ApiResponse<DictCategoryDto>.Success(result)
                : ApiResponse<DictCategoryDto>.Error("Category not found");
        }

        /// <summary>
        /// 删除字典分类
        /// </summary>
        [HttpDelete("categories/{id}")]
        public async Task<ApiResponse<bool>> DeleteCategory(long id)
        {
            try
            {
                var result = await _dictService.DeleteCategoryAsync(id);
                return result
                    ? ApiResponse<bool>.Success(true)
                    : ApiResponse<bool>.Error("Category not found");
            }
            catch (Exception ex)
            {
                return ApiResponse<bool>.Error(ex.Message);
            }
        }

        // --- Type ---

        /// <summary>
        /// 获取字典类型列表
        /// </summary>
        [HttpGet("types")]
        public async Task<ApiResponse<List<DictTypeDto>>> GetTypes([FromQuery] long? categoryId, [FromQuery] string? name, [FromQuery] string? code)
        {
            var result = await _dictService.GetTypesAsync(categoryId, name, code);
            return ApiResponse<List<DictTypeDto>>.Success(result);
        }

        /// <summary>
        /// 获取字典类型详情
        /// </summary>
        [HttpGet("types/{id}")]
        public async Task<ApiResponse<DictTypeDto>> GetType(long id)
        {
            var result = await _dictService.GetTypeAsync(id);
            return result != null
                ? ApiResponse<DictTypeDto>.Success(result)
                : ApiResponse<DictTypeDto>.Error("Type not found");
        }

        /// <summary>
        /// 创建字典类型
        /// </summary>
        [HttpPost("types")]
        public async Task<ApiResponse<DictTypeDto>> CreateType([FromBody] CreateDictTypeDto dto)
        {
            try
            {
                var result = await _dictService.CreateTypeAsync(dto);
                return ApiResponse<DictTypeDto>.Success(result);
            }
            catch (Exception ex)
            {
                return ApiResponse<DictTypeDto>.Error(ex.Message);
            }
        }

        /// <summary>
        /// 更新字典类型
        /// </summary>
        [HttpPut("types/{id}")]
        public async Task<ApiResponse<DictTypeDto>> UpdateType(long id, [FromBody] UpdateDictTypeDto dto)
        {
            try
            {
                var result = await _dictService.UpdateTypeAsync(id, dto);
                return result != null
                    ? ApiResponse<DictTypeDto>.Success(result)
                    : ApiResponse<DictTypeDto>.Error("Type not found");
            }
            catch (Exception ex)
            {
                return ApiResponse<DictTypeDto>.Error(ex.Message);
            }
        }

        /// <summary>
        /// 删除字典类型
        /// </summary>
        [HttpDelete("types/{id}")]
        public async Task<ApiResponse<bool>> DeleteType(long id)
        {
            var result = await _dictService.DeleteTypeAsync(id);
            return result
                ? ApiResponse<bool>.Success(true)
                : ApiResponse<bool>.Error("Type not found");
        }

        // --- Data ---

        /// <summary>
        /// 获取字典数据列表
        /// </summary>
        [HttpGet("data")]
        public async Task<ApiResponse<List<DictDataDto>>> GetDataList([FromQuery] long? typeId, [FromQuery] string? typeCode)
        {
            var result = await _dictService.GetDataListAsync(typeId, typeCode);
            return ApiResponse<List<DictDataDto>>.Success(result);
        }

        /// <summary>
        /// 获取字典数据详情
        /// </summary>
        [HttpGet("data/{id}")]
        public async Task<ApiResponse<DictDataDto>> GetData(long id)
        {
            var result = await _dictService.GetDataAsync(id);
            return result != null
                ? ApiResponse<DictDataDto>.Success(result)
                : ApiResponse<DictDataDto>.Error("Data not found");
        }

        /// <summary>
        /// 创建字典数据
        /// </summary>
        [HttpPost("data")]
        public async Task<ApiResponse<DictDataDto>> CreateData([FromBody] CreateDictDataDto dto)
        {
            var result = await _dictService.CreateDataAsync(dto);
            return ApiResponse<DictDataDto>.Success(result);
        }

        /// <summary>
        /// 更新字典数据
        /// </summary>
        [HttpPut("data/{id}")]
        public async Task<ApiResponse<DictDataDto>> UpdateData(long id, [FromBody] UpdateDictDataDto dto)
        {
            var result = await _dictService.UpdateDataAsync(id, dto);
            return result != null
                ? ApiResponse<DictDataDto>.Success(result)
                : ApiResponse<DictDataDto>.Error("Data not found");
        }

        /// <summary>
        /// 删除字典数据
        /// </summary>
        [HttpDelete("data/{id}")]
        public async Task<ApiResponse<bool>> DeleteData(long id)
        {
            var result = await _dictService.DeleteDataAsync(id);
            return result
                ? ApiResponse<bool>.Success(true)
                : ApiResponse<bool>.Error("Data not found");
        }
    }
}
