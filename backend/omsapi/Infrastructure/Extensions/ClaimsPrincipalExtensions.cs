using System.Security.Claims;
using System.IdentityModel.Tokens.Jwt;

namespace omsapi.Infrastructure.Extensions
{
    public static class ClaimsPrincipalExtensions
    {
        /// <summary>
        /// 获取当前用户ID
        /// </summary>
        /// <param name="principal"></param>
        /// <returns>如果未登录或获取失败，默认返回 1 (开发环境fallback)</returns>
        public static long GetUserId(this ClaimsPrincipal principal)
        {
            if (principal.Identity != null && principal.Identity.IsAuthenticated)
            {
                // 优先查找 "id" claim
                var idClaim = principal.FindFirst("id");
                if (idClaim != null && long.TryParse(idClaim.Value, out long id))
                {
                    return id;
                }
                
                // 尝试查找 NameIdentifier
                var nameIdClaim = principal.FindFirst(ClaimTypes.NameIdentifier);
                if (nameIdClaim != null && long.TryParse(nameIdClaim.Value, out long nameId))
                {
                    return nameId;
                }
            }
            
            // Fallback for dev/testing as per original code logic
            return 1;
        }

        /// <summary>
        /// 获取当前用户名
        /// </summary>
        /// <param name="principal"></param>
        /// <returns></returns>
        public static string? GetUsername(this ClaimsPrincipal principal)
        {
            if (principal.Identity != null && principal.Identity.IsAuthenticated)
            {
                var name = principal.Identity.Name;
                if (string.IsNullOrEmpty(name))
                {
                    name = principal.FindFirst(ClaimTypes.NameIdentifier)?.Value 
                           ?? principal.FindFirst("sub")?.Value
                           ?? principal.FindFirst(JwtRegisteredClaimNames.Sub)?.Value
                           ?? principal.FindFirst(ClaimTypes.Name)?.Value;
                }
                return name;
            }
            return null;
        }
    }
}
