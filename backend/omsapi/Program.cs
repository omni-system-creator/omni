using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using omsapi.Data;
using omsapi.Infrastructure.Extensions;
using Serilog;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// 配置 Serilog
builder.Host.UseSerilog((context, services, configuration) => configuration
    .ReadFrom.Configuration(context.Configuration)
    .ReadFrom.Services(services)
    .Enrich.FromLogContext());

// Add services to the container.

builder.Services.AddDbContext<OmsContext>(options =>
    options.UseMySql(builder.Configuration.GetConnectionString("DefaultConnection"),
        new MySqlServerVersion(new Version(8, 0, 21))));

// 自动注册带有 [AutoInject] 特性的服务
builder.Services.AddAppServices();
builder.Services.AddHttpContextAccessor();

builder.Services.AddControllers(options =>
{
    options.Filters.Add<omsapi.Middleware.GlobalExceptionFilter>();
    options.Filters.Add<omsapi.Filters.AuditLogFilter>();
});
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]))
        };

        // Configure custom response for 401/403
        omsapi.Middleware.JwtBearerEventsConfig.Configure(options);
    });

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseStaticFiles(); // 启用静态文件支持

app.UseSerilogRequestLogging(); // 记录 HTTP 请求日志

app.UseAuthentication();
app.UseAuthorization();

app.UseMiddleware<omsapi.Middleware.JwtSlidingExpirationMiddleware>();

app.MapControllers();

app.Run();
