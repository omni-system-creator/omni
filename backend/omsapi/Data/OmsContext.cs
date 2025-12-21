using Microsoft.EntityFrameworkCore;
using omsapi.Models.Entities;

namespace omsapi.Data
{
    public class OmsContext : DbContext
    {
        public OmsContext(DbContextOptions<OmsContext> options) : base(options)
        {
        }

        public DbSet<User> Users { get; set; }
        public DbSet<AuditLog> AuditLogs { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // 配置 User 实体
            modelBuilder.Entity<User>(entity =>
            {
                entity.HasIndex(u => u.Username).IsUnique();
            });

            // 初始化超级管理员
            // 密码为 admin123 的 SHA256 哈希值
            // 这里为了简单演示，直接硬编码哈希值。实际项目中应使用更安全的密码哈希算法（如 BCrypt, PBKDF2）
            modelBuilder.Entity<User>().HasData(new User
            {
                Id = 1,
                Username = "admin",
                Password = "240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9", // admin123 的 SHA256
                Nickname = "超级管理员",
                IsActive = true,
                CreatedAt = new DateTime(2024, 1, 1)
            });
        }
    }
}
