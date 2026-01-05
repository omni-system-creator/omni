using Microsoft.EntityFrameworkCore;
using OmsApi.Models.Entities.Kb;

namespace omsapi.Data
{
    public class OmsPgContext : DbContext
    {
        public OmsPgContext(DbContextOptions<OmsPgContext> options) : base(options)
        {
        }

        public DbSet<KbNode> KbNodes { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            
            // 启用 pgvector 扩展
            modelBuilder.HasPostgresExtension("vector");

            // Ignore entities not in this context
            modelBuilder.Ignore<KbInfo>();
            modelBuilder.Ignore<KbNodeSource>();
            modelBuilder.Ignore<KbFile>(); // Indirectly referenced by KbNodeSource if not ignored

            modelBuilder.Entity<KbNode>(entity =>
            {
                entity.ToTable("sys_kb_node"); // 复用同一个表名，或者使用不同的表名
                entity.HasKey(e => e.Id);
                
                // Ignore navigation properties to other contexts
                entity.Ignore(e => e.Kb);
                entity.Ignore(e => e.Sources);
                
                // 确保向量列被正确配置
                // 注意：在 MySQL 中这个属性被忽略，在 PG 中被使用
            });
        }
    }
}
