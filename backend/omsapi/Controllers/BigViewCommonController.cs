using Microsoft.AspNetCore.Mvc;
using omsapi.Models.Common;

namespace omsapi.Controllers
{
    /// <summary>
    /// 大屏公共控制器
    /// </summary>
    [Route("api/bigview")]
    [ApiController]
    public class BigViewCommonController : ControllerBase
    {
        private readonly IWebHostEnvironment _environment;

        public BigViewCommonController(IWebHostEnvironment environment)
        {
            _environment = environment;
        }

        /// <summary>
        /// 获取OSS信息
        /// </summary>
        [HttpGet("getOssInfo")]
        public ApiResponse<object> GetOssInfo()
        {
            var request = HttpContext.Request;
            // Construct base URL for the bigview uploads directory
            // Note: This URL must be accessible by the browser
            var baseUrl = "/uploads/bigview/";
            
            return ApiResponse<object>.Success(new { bucketURL = baseUrl });
        }

        /// <summary>
        /// 上传文件
        /// </summary>
        [HttpPost("upload")]
        public async Task<ApiResponse<object>> Upload([FromForm] IFormFile file, [FromForm] string? projectId)
        {
             if (file == null || file.Length == 0)
                 return ApiResponse<object>.Error("请选择文件");

             try 
             {
                 var webRootPath = _environment.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
                 var uploadFolder = Path.Combine(webRootPath, "uploads", "bigview");
                 
                 if (!Directory.Exists(uploadFolder))
                     Directory.CreateDirectory(uploadFolder);

                 var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
                 
                 // If projectId is provided, use it as filename (overwriting existing file)
                 // Otherwise, generate a new GUID
                 var fileName = !string.IsNullOrEmpty(projectId) 
                     ? $"{projectId}{extension}" 
                     : $"{Guid.NewGuid()}{extension}";
                     
                 var filePath = Path.Combine(uploadFolder, fileName);

                 using (var stream = new FileStream(filePath, FileMode.Create))
                 {
                     await file.CopyToAsync(stream);
                 }
                 
                 var baseUrl = "/uploads/bigview/";
                 var fileUrl = $"{baseUrl}{fileName}";

                 return ApiResponse<object>.Success(new 
                 { 
                     fileName = fileName,
                     fileurl = fileUrl
                 });
             }
             catch (Exception ex)
             {
                 return ApiResponse<object>.Error(ex.Message);
             }
        }
    }
}
