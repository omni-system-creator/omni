using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Diagnostics;
using Microsoft.IdentityModel.Tokens;
using omsapi.Data;
using omsapi.Infrastructure.Extensions;
using Serilog;
using Pgvector.EntityFrameworkCore;

Console.OutputEncoding = Encoding.UTF8;
// 禁用默认的 Claim 类型映射，防止 "sub" 被映射为 ClaimTypes.NameIdentifier 等
System.IdentityModel.Tokens.Jwt.JwtSecurityTokenHandler.DefaultInboundClaimTypeMap.Clear();

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

var dbType = builder.Configuration["DatabaseType"]?.ToLower() ?? "mysql";
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection_"+dbType);

switch (dbType)
{
    case "sqlserver":
    case "mssql":
        builder.Services.AddDbContext<OmsContext, OmsContextSqlServer>(options =>
            options.UseSqlServer(
                connectionString,
                sqlOptions => sqlOptions.EnableRetryOnFailure()
            )
        );
        break;
    case "postgresql":
    case "postgres":
        builder.Services.AddDbContext<OmsContext, OmsContextPostgreSql>(options =>
            options.UseNpgsql(
                connectionString,
                pgOptions => pgOptions.EnableRetryOnFailure()
            )
        );
        break;
    case "mysql":
    default:
        builder.Services.AddDbContext<OmsContext>(options =>
            options.UseMySql(
                connectionString,
                new MySqlServerVersion(new Version(8, 0, 21)),
                mySqlOptions => mySqlOptions.EnableRetryOnFailure()
            )
        );
        break;
}

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

builder.Services.Configure<ForwardedHeadersOptions>(options =>
{
    options.ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto;
    // 信任所有代理（Docker 环境下通常需要这样配置，因为代理 IP 可能是动态的）
    options.KnownIPNetworks.Clear();
    options.KnownProxies.Clear();
});

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll",
        builder => builder
            .AllowAnyOrigin()
            .AllowAnyMethod()
            .AllowAnyHeader());
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

app.UseForwardedHeaders();

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
        // 注意：如果数据库中已存在表结构，Migrate() 可能会失败。
        // 在开发环境中，如果确认数据库结构是最新的，可以注释掉下面两行；
        // 或者先清空数据库再运行。
        try 
        {
            if (context.Database.IsRelational())
            {
                // 检查是否有待应用的迁移
                var pendingMigrations = await context.Database.GetPendingMigrationsAsync();
                if (pendingMigrations.Any())
                {
                    // context.Database.Migrate(); // 暂时注释，避免“对象已存在”错误
                    Console.WriteLine($"发现 {pendingMigrations.Count()} 个待应用的主数据库迁移，但已跳过自动执行。请手动确认数据库状态。");
                }
            }

            // OmsPgContext 总是使用 PostgreSQL
            var pgPendingMigrations = await pgContext.Database.GetPendingMigrationsAsync();
            if (pgPendingMigrations.Any())
            {
                // pgContext.Database.Migrate(); // 暂时注释
                Console.WriteLine($"发现 {pgPendingMigrations.Count()} 个待应用的向量数据库迁移，但已跳过自动执行。请手动确认数据库状态。");
            }

            // 初始化种子数据
            await omsapi.Data.DbInitializer.InitializeAsync(context, pgContext);
        }
        catch (Exception ex)
        {
             var logger = services.GetRequiredService<ILogger<Program>>();
             logger.LogError(ex, "An error occurred during database initialization.");
        }
    }
    catch (Exception ex)
    {
        var logger = services.GetRequiredService<ILogger<Program>>();
        logger.LogError(ex, "An error occurred creating the DB.");
    }
}

Console.WriteLine("后端服务启动成功！");

app.Run();
