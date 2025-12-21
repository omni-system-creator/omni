using Microsoft.EntityFrameworkCore;
using omsapi.Models.Entities;

namespace omsapi.Data
{
    public class OmsContext : DbContext
    {
        public OmsContext(DbContextOptions<OmsContext> options) : base(options)
        {
        }

        public DbSet<SystemUser> Users { get; set; }
        public DbSet<SystemRole> Roles { get; set; }
        public DbSet<SystemPermission> Permissions { get; set; }
        public DbSet<SystemUserRole> UserRoles { get; set; }
        public DbSet<SystemRolePermission> RolePermissions { get; set; }
        public DbSet<SystemAuditLog> AuditLogs { get; set; }
        public DbSet<SystemConfig> SystemConfigs { get; set; }
        public DbSet<SystemDept> Depts { get; set; }
        public DbSet<SystemPost> Posts { get; set; }
        public DbSet<SystemUserPost> UserPosts { get; set; }
        public DbSet<SystemRoleInheritance> RoleInheritances { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // 配置 SystemConfig
            modelBuilder.Entity<SystemConfig>(entity =>
            {
                entity.HasIndex(e => e.Key).IsUnique();
            });

            // 配置 User 实体
            modelBuilder.Entity<SystemUser>(entity =>
            {
                entity.HasIndex(u => u.Username).IsUnique();
            });

            // 配置 Role 实体
            modelBuilder.Entity<SystemRole>(entity =>
            {
                entity.HasIndex(r => r.Code).IsUnique();
            });

            // 配置 Permission 实体
            modelBuilder.Entity<SystemPermission>(entity =>
            {
                entity.HasIndex(p => p.Code).IsUnique();
            });

            // 配置 UserRole 关联
            modelBuilder.Entity<SystemUserRole>(entity =>
            {
                entity.HasKey(ur => new { ur.UserId, ur.RoleId });
            });

            // 配置 RolePermission 关联
            modelBuilder.Entity<SystemRolePermission>(entity =>
            {
                entity.HasKey(rp => new { rp.RoleId, rp.PermissionId });
            });

            // 配置 SystemDept
            modelBuilder.Entity<SystemDept>(entity =>
            {
                entity.HasIndex(d => d.ParentId);
            });

            // 配置 SystemPost
            modelBuilder.Entity<SystemPost>(entity =>
            {
                entity.HasIndex(p => p.Code).IsUnique();
            });

            // 配置 SystemUserPost
            modelBuilder.Entity<SystemUserPost>(entity =>
            {
                entity.HasKey(up => new { up.UserId, up.PostId, up.DeptId });
            });

            // 配置 SystemRoleInheritance
            modelBuilder.Entity<SystemRoleInheritance>(entity =>
            {
                entity.HasKey(ri => new { ri.ParentRoleId, ri.ChildRoleId });
                
                entity.HasOne(ri => ri.ParentRole)
                    .WithMany(r => r.ChildRoleRelations)
                    .HasForeignKey(ri => ri.ParentRoleId)
                    .OnDelete(DeleteBehavior.Restrict);

                entity.HasOne(ri => ri.ChildRole)
                    .WithMany(r => r.ParentRoleRelations)
                    .HasForeignKey(ri => ri.ChildRoleId)
                    .OnDelete(DeleteBehavior.Restrict);
            });

            // 初始化超级管理员
            // 密码为 admin123 的 SHA256 哈希值
            // 这里为了简单演示，直接硬编码哈希值。实际项目中应使用更安全的密码哈希算法（如 BCrypt, PBKDF2）
            modelBuilder.Entity<SystemUser>().HasData(new SystemUser
            {
                Id = 1,
                Username = "admin",
                Password = "240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9", // admin123 的 SHA256
                Nickname = "超级管理员",
                IsActive = true,
                CreatedAt = new DateTime(2024, 1, 1)
            });

            // 初始化超级管理员角色
            modelBuilder.Entity<SystemRole>().HasData(new SystemRole
            {
                Id = 1,
                Name = "超级管理员",
                Code = "ADMIN",
                Description = "系统最高权限",
                IsSystem = true,
                CreatedAt = new DateTime(2024, 1, 1)
            });

            // 关联超级管理员用户和角色
            modelBuilder.Entity<SystemUserRole>().HasData(new SystemUserRole
            {
                UserId = 1,
                RoleId = 1,
                CreatedAt = new DateTime(2024, 1, 1)
            });

            // 初始化系统配置
            modelBuilder.Entity<SystemConfig>().HasData(
                new SystemConfig { Id = 1, Category = "Basic", Key = "SystemName", Value = "金兰®综合信息管理系统", Description = "系统名称", IsSystem = true, CreatedAt = new DateTime(2024, 1, 1) },
                new SystemConfig { Id = 2, Category = "Basic", Key = "SystemLogo", Value = "/logo.svg", Description = "系统Logo路径", IsSystem = true, CreatedAt = new DateTime(2024, 1, 1) },
                new SystemConfig { Id = 3, Category = "Basic", Key = "Copyright", Value = "©2025 Created by jinlan.info", Description = "底部版权信息", IsSystem = true, CreatedAt = new DateTime(2024, 1, 1) },
                new SystemConfig { Id = 4, Category = "Security", Key = "PasswordMinLength", Value = "6", Description = "密码最小长度", IsSystem = true, CreatedAt = new DateTime(2024, 1, 1) },
                new SystemConfig { Id = 5, Category = "Security", Key = "SessionTimeout", Value = "30", Description = "会话超时时间(分钟)", IsSystem = true, CreatedAt = new DateTime(2024, 1, 1) }
            );
        }
    }
}
