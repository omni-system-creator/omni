using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Primitives;

namespace omsapi.Infrastructure.Extensions
{
    public static class HttpContextExtensions
    {
        /// <summary>
        /// 获取客户端真实IP地址 (支持代理)
        /// </summary>
        /// <param name="context"></param>
        /// <returns></returns>
        public static string GetClientIp(this HttpContext context)
        {
            if (context == null) return string.Empty;

            string ip = string.Empty;

            // 1. 优先尝试 X-Real-IP (Nginx 常用)
            if (context.Request.Headers.TryGetValue("X-Real-IP", out StringValues realIp))
            {
                ip = realIp.ToString();
                if (IsValidIp(ip))
                {
                    return ip;
                }
            }

            // 2. 尝试 X-Forwarded-For
            if (context.Request.Headers.TryGetValue("X-Forwarded-For", out StringValues forwardedFor))
            {
                // X-Forwarded-For 格式: client, proxy1, proxy2
                var ipList = forwardedFor.ToString().Split(',', StringSplitOptions.RemoveEmptyEntries);
                if (ipList.Length > 0)
                {
                    ip = ipList[0].Trim();
                    if (IsValidIp(ip))
                    {
                        return ip;
                    }
                }
            }

            // 3. 回退到 RemoteIpAddress
            if (context.Connection.RemoteIpAddress != null)
            {
                ip = context.Connection.RemoteIpAddress.ToString();
                // 处理 IPv6 本地回环 ::1
                if (ip == "::1") return "127.0.0.1";
                return ip;
            }

            return ip;
        }

        private static bool IsValidIp(string ip)
        {
            return !string.IsNullOrWhiteSpace(ip) && ip.ToLower() != "unknown";
        }
    }
}
