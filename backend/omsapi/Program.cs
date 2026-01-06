using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using omsapi.Data;
using omsapi.Infrastructure.Extensions;
using Serilog;
using Pgvector.EntityFrameworkCore;

Console.OutputEncoding = Encoding.UTF8;

var builder = WebApplication.CreateBuilder(args);

// 配置 Serilog
builder.Host.UseSerilog(
    (context, services, configuration) =>
        configuration
            .ReadFrom.Configuration(context.Configuration)
            .ReadFrom.Services(services)
            .Enrich.FromLogContext()
);

// Add services to the container.

builder.Services.AddDbContext<OmsContext>(
    options =>
        options.UseMySql(
            builder.Configuration.GetConnectionString("DefaultConnection"),
            new MySqlServerVersion(new Version(8, 0, 21)),
            mySqlOptions => mySqlOptions.EnableRetryOnFailure()
        )
);

builder.Services.AddDbContext<OmsPgContext>(
    options =>
        options.UseNpgsql(
            builder.Configuration.GetConnectionString("PgConnection"),
            o => o.UseVector()
        )
);

// 自动注册带有 [AutoInject] 特性的服务
builder.Services.AddAppServices();
builder.Services.AddHttpContextAccessor();

builder.Services.AddControllers(options =>
{
    options.Filters.Add<omsapi.Middleware.GlobalExceptionFilter>();
    options.Filters.Add<omsapi.Filters.AuditLogFilter>();
});

builder.Services.AddSignalR();
builder.Services.AddHttpClient(); // Add HttpClient

// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();

builder
    .Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
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
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"])
            )
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
app.MapHub<omsapi.Hubs.DebugHub>("/hubs/debug");
app.MapHub<omsapi.Hubs.ProjectHub>("/hubs/project");
app.MapHub<omsapi.Hubs.UserHub>("/hubs/user");

// 初始化数据库
using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    try
    {
        var context = services.GetRequiredService<omsapi.Data.OmsContext>();
        var pgContext = services.GetRequiredService<omsapi.Data.OmsPgContext>();
        
        // 自动应用迁移
        context.Database.Migrate();
        pgContext.Database.Migrate();

        // 初始化种子数据
        await omsapi.Data.DbInitializer.InitializeAsync(context, pgContext);
    }
    catch (Exception ex)
    {
        var logger = services.GetRequiredService<ILogger<Program>>();
        logger.LogError(ex, "An error occurred creating the DB.");
    }
}

Console.WriteLine("后端服务启动成功！");

app.Run();
