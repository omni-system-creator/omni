using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace omsapi.Middleware
{
    public class JwtSlidingExpirationMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly IConfiguration _configuration;

        public JwtSlidingExpirationMiddleware(RequestDelegate next, IConfiguration configuration)
        {
            _next = next;
            _configuration = configuration;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            // Only check if user is authenticated
            if (context.User.Identity != null && context.User.Identity.IsAuthenticated)
            {
                var expClaim = context.User.FindFirst(JwtRegisteredClaimNames.Exp);
                if (expClaim != null && long.TryParse(expClaim.Value, out long exp))
                {
                    // JWT exp is in seconds since Unix epoch
                    var expDate = DateTimeOffset.FromUnixTimeSeconds(exp).LocalDateTime;
                    var timeRemaining = expDate - DateTime.Now;

                    // If less than 10 minutes remaining, refresh the token
                    // This creates a sliding window effect: 
                    // If user is active in the last 10 minutes of their session, they get a new 20-minute token.
                    if (timeRemaining.TotalMinutes < 10 && timeRemaining.TotalMinutes > 0)
                    {
                        var username = context.User.FindFirst(ClaimTypes.NameIdentifier)?.Value 
                                    ?? context.User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value;
                        
                        if (!string.IsNullOrEmpty(username))
                        {
                            var newToken = GenerateJwtToken(username);
                            // Add the new token to the response header
                            context.Response.Headers.Append("X-Refresh-Token", newToken);
                            // Also enable exposing this header to CORS if needed (often required for frontend to see it)
                            context.Response.Headers.Append("Access-Control-Expose-Headers", "X-Refresh-Token");
                        }
                    }
                }
            }

            await _next(context);
        }

        private string GenerateJwtToken(string username)
        {
            var key = _configuration["Jwt:Key"] ?? throw new InvalidOperationException("Jwt:Key is missing");
            var securityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key));
            var credentials = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256);

            var claims = new[]
            {
                new Claim(JwtRegisteredClaimNames.Sub, username),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
            };

            var token = new JwtSecurityToken(
                issuer: _configuration["Jwt:Issuer"],
                audience: _configuration["Jwt:Audience"],
                claims: claims,
                expires: DateTime.Now.AddMinutes(20),
                signingCredentials: credentials);

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}
