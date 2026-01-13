using Microsoft.EntityFrameworkCore;
using omsapi.Models.Entities;
using omsapi.Models.Entities.System;
using omsapi.Models.Entities.Archive;
using omsapi.Models.Entities.BigView;
using omsapi.Models.Entities.Data;
using omsapi.Models.Entities.Forms;
using omsapi.Models.Entities.Interfaces;
using omsapi.Models.Entities.Pages;
using omsapi.Models.Entities.Contract;
using omsapi.Models.Entities.Project;
using OmsApi.Models.Entities.Kb;
using omsapi.Models.Entities.Chat;

namespace omsapi.Data
{
    public class OmsContext : DbContext
    {
        public OmsContext(DbContextOptions<OmsContext> options) : base(options)
        {
        }

        protected OmsContext(DbContextOptions options) : base(options)
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
        public DbSet<SystemFile> Files { get; set; }
        public DbSet<SystemFileShare> FileShares { get; set; }
        public DbSet<omsapi.Models.Entities.System.SysOrgRegistration> OrgRegistrations { get; set; }
        public DbSet<SystemAnonce> Anonces { get; set; }
        public DbSet<AiGeneratedContent> AiGeneratedContents { get; set; }
        
        // Archive Entities
        public DbSet<ArchFond> ArchFonds { get; set; }
        public DbSet<ArchType> ArchTypes { get; set; }
        public DbSet<ArchFile> ArchFiles { get; set; }
        public DbSet<ArchAttachment> ArchAttachments { get; set; }
        public DbSet<ArchBox> ArchBoxes { get; set; }

        // Data Entities
        public DbSet<DataSourceConnection> DataSourceConnections { get; set; }

        // BigView Entities
        public DbSet<BigViewProject> BigViewProjects { get; set; }

        // Form Entities
        public DbSet<FormCategory> FormCategories { get; set; }
        public DbSet<FormDefinition> FormDefinitions { get; set; }
        public DbSet<FormResult> FormResults { get; set; }

        // Interface Entities
        public DbSet<InterfaceCategory> InterfaceCategories { get; set; }
        public DbSet<InterfaceDefinition> InterfaceDefinitions { get; set; }

        // Page Entities
        public DbSet<PageCategory> PageCategories { get; set; }
        public DbSet<PageDefinition> PageDefinitions { get; set; }

        // Contract Entities
        public DbSet<ContractMain> Contracts { get; set; }
        public DbSet<ContractTemplate> ContractTemplates { get; set; }
        public DbSet<ContractKnowledgeCategory> ContractKnowledgeCategories { get; set; }
        public DbSet<ContractKnowledgeFile> ContractKnowledgeFiles { get; set; }
        public DbSet<ContractStat> ContractStats { get; set; }
        public DbSet<ContractPaymentPlan> ContractPaymentPlans { get; set; }
        public DbSet<ContractPaymentRecord> ContractPaymentRecords { get; set; }
        public DbSet<ContractInvoice> ContractInvoices { get; set; }
        public DbSet<ContractContact> ContractContacts { get; set; }
        public DbSet<ContractAttachment> ContractAttachments { get; set; }

        // Project Flow Entities
        public DbSet<ProjectInfo> ProjectInfos { get; set; }
        public DbSet<ProjectPhase> ProjectPhases { get; set; }
        public DbSet<ProjectSwimlane> ProjectSwimlanes { get; set; }
        public DbSet<ProjectTask> ProjectTasks { get; set; }
        public DbSet<ProjectTaskDependency> ProjectTaskDependencies { get; set; }
        public DbSet<ProjectAttachment> ProjectAttachments { get; set; }

        // Sales Entities
        public DbSet<omsapi.Models.Entities.Sales.SalesCustomer> SalesCustomers { get; set; }
        public DbSet<omsapi.Models.Entities.Sales.SalesOpportunity> SalesOpportunities { get; set; }
        public DbSet<omsapi.Models.Entities.Sales.SalesScript> SalesScripts { get; set; }
        public DbSet<omsapi.Models.Entities.Sales.SalesProductDoc> SalesProductDocs { get; set; }
        public DbSet<omsapi.Models.Entities.Sales.SalesProcessRule> SalesProcessRules { get; set; }
        public DbSet<omsapi.Models.Entities.Sales.SalesTarget> SalesTargets { get; set; }
        public DbSet<omsapi.Models.Entities.Sales.SalesRegistration> SalesRegistrations { get; set; }
        public DbSet<omsapi.Models.Entities.Sales.SalesBidProject> SalesBidProjects { get; set; }
        public DbSet<omsapi.Models.Entities.Sales.SalesTenderAnalysis> SalesTenderAnalyses { get; set; }
        public DbSet<omsapi.Models.Entities.Sales.SalesTenderChapter> SalesTenderChapters { get; set; }
        public DbSet<omsapi.Models.Entities.Sales.SalesTenderAnalysisRun> SalesTenderAnalysisRuns { get; set; }
        public DbSet<omsapi.Models.Entities.Sales.SalesTenderAnalysisLog> SalesTenderAnalysisLogs { get; set; }

        // Dict Entities
        public DbSet<omsapi.Models.Entities.Dict.SysDictCategory> DictCategories { get; set; }
        public DbSet<omsapi.Models.Entities.Dict.SysDictType> DictTypes { get; set; }
        public DbSet<omsapi.Models.Entities.Dict.SysDictData> DictDatas { get; set; }

        // Pdm Entities
        public DbSet<omsapi.Models.Entities.Pdm.PdmEbomItem> PdmEbomItems { get; set; }
        public DbSet<omsapi.Models.Entities.Pdm.PdmEbomStructure> PdmEbomStructures { get; set; }
        public DbSet<omsapi.Models.Entities.Pdm.PdmEbomDocument> PdmEbomDocuments { get; set; }

        // Kb Entities
        public DbSet<KbInfo> KbInfos { get; set; }
        public DbSet<KbFile> KbFiles { get; set; }
        // public DbSet<KbNode> KbNodes { get; set; } // 移至 PgContext
        public DbSet<KbNodeSource> KbNodeSources { get; set; }
        public DbSet<KbQaHistory> KbQaHistories { get; set; }
        
        // Chat Entities
        public DbSet<ChatMessage> ChatMessages { get; set; }
        public DbSet<ChatConversation> ChatConversations { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            var isSqlServer = this.Database.IsSqlServer();
            var isPostgres = this.Database.IsNpgsql();
            var isMySql = !isSqlServer && !isPostgres; // Assume MySQL if not SQL Server or Postgres

            string longTextType;
            string textType;

            if (isSqlServer)
            {
                longTextType = "nvarchar(max)";
                textType = "nvarchar(max)";
            }
            else if (isPostgres)
            {
                longTextType = "text";
                textType = "text";
            }
            else // MySQL
            {
                longTextType = "longtext";
                textType = "text";
            }

            // MySQL DateTime precision fix
            if (isMySql)
            {
                // Fix for MySQL datetime precision issue
                // "datetime2" is a SQL Server type, MySQL uses "datetime(6)" for high precision or just "datetime"
                // EF Core 8+ for MySQL might default to datetime(6) which is fine, 
                // but if there are explicit column type definitions they need to be handled.
                // The error suggests some migration or code is trying to use 'datetime2' on MySQL.
                
                // Inspect all entities and properties to ensure no 'datetime2' is explicitly set for MySQL
                foreach (var entityType in modelBuilder.Model.GetEntityTypes())
                {
                    foreach (var property in entityType.GetProperties())
                    {
                        if (property.GetColumnType() == "datetime2")
                        {
                            property.SetColumnType("datetime(6)");
                        }
                    }
                }
            }

            modelBuilder.Entity<InterfaceDefinition>().Property(p => p.FlowConfig).HasColumnType(longTextType);
            
            modelBuilder.Entity<KbQaHistory>().Property(p => p.Answer).HasColumnType(longTextType);
            modelBuilder.Entity<KbQaHistory>().Property(p => p.Question).HasColumnType(textType);
            modelBuilder.Entity<KbQaHistory>().Property(p => p.SourcesJson).HasColumnType(textType);

            modelBuilder.Entity<PageDefinition>().Property(p => p.Code).HasColumnType(longTextType);
            modelBuilder.Entity<PageDefinition>().Property(p => p.Config).HasColumnType(longTextType);
            modelBuilder.Entity<PageDefinition>().Property(p => p.ApiBindings).HasColumnType(longTextType);

            modelBuilder.Entity<FormDefinition>().Property(p => p.FormItems).HasColumnType(longTextType);

            if (isSqlServer)
            {
                modelBuilder.Entity<SystemFileShare>()
                    .HasOne(p => p.SharedByUser)
                    .WithMany()
                    .HasForeignKey(p => p.SharedByUserId)
                    .OnDelete(DeleteBehavior.NoAction);

                modelBuilder.Entity<SystemFileShare>()
                    .HasOne(p => p.SharedToUser)
                    .WithMany()
                    .HasForeignKey(p => p.SharedToUserId)
                    .OnDelete(DeleteBehavior.NoAction);
            }

            // Ignore KbNode as it is managed by OmsPgContext
            modelBuilder.Ignore<KbNode>();

            // Configure Dict Entities
            modelBuilder.Entity<omsapi.Models.Entities.Dict.SysDictType>(entity =>
            {
                entity.HasIndex(e => e.Code).IsUnique();
            });

            modelBuilder.Entity<omsapi.Models.Entities.Dict.SysDictData>(entity =>
            {
                entity.HasIndex(e => new { e.DictTypeId, e.Value }).IsUnique();
            });



            // 配置 ChatConversation
            modelBuilder.Entity<ChatConversation>(entity =>
            {
                entity.HasIndex(e => e.ConversationKey).IsUnique();
                entity.HasIndex(e => e.User1Id);
                entity.HasIndex(e => e.User2Id);
                entity.HasIndex(e => e.RelatedId);
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

            // 配置 SalesOpportunity
            modelBuilder.Entity<omsapi.Models.Entities.Sales.SalesOpportunity>(entity =>
            {
                entity.Property(e => e.Amount).HasPrecision(18, 2);
            });

            // 配置 SalesRegistration
            modelBuilder.Entity<omsapi.Models.Entities.Sales.SalesRegistration>(entity =>
            {
                entity.Property(e => e.Amount).HasPrecision(18, 2);
            });

            // 配置 SalesTenderChapter
            modelBuilder.Entity<omsapi.Models.Entities.Sales.SalesTenderChapter>(entity =>
            {
                entity.Property(e => e.ScoreWeight).HasPrecision(18, 2);
            });

            // 配置 SystemConfig
            modelBuilder.Entity<SystemConfig>(entity =>
            {
                // unique index on Key and OrgId
                // Note: In MySQL, (Key, OrgId) with OrgId=NULL allows duplicates. 
                // We rely on application logic to enforce single global config per key.
                entity.HasIndex(c => new { c.Key, c.OrgId }).IsUnique();
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

            // Archive Configs
            modelBuilder.Entity<ArchFond>(entity => {
                entity.HasIndex(e => e.Code).IsUnique();
            });
            modelBuilder.Entity<ArchType>(entity => {
                entity.HasIndex(e => e.Code).IsUnique();
            });
            modelBuilder.Entity<ArchFile>(entity => {
                entity.HasIndex(e => e.ArchCode).IsUnique();
            });
            modelBuilder.Entity<ArchBox>(entity => {
                entity.HasIndex(e => e.BoxCode).IsUnique();
            });

            // Chat Configs
            modelBuilder.Entity<ChatMessage>(entity => {
                entity.HasIndex(e => e.ConversationKey);
                entity.Property(e => e.Content).HasMaxLength(2000);
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
                CreatedAt = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc)
            });

            // 初始化超级管理员角色
            modelBuilder.Entity<SystemRole>().HasData(new SystemRole
            {
                Id = 1,
                Name = "超级管理员",
                Code = "ADMIN",
                Description = "系统最高权限",
                IsSystem = true,
                CreatedAt = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc)
            });

            // 关联超级管理员用户和角色
            modelBuilder.Entity<SystemUserRole>().HasData(new SystemUserRole
            {
                UserId = 1,
                RoleId = 1,
                CreatedAt = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc)
            });

            // 初始化系统配置
            modelBuilder.Entity<SystemConfig>().HasData(
                new SystemConfig { Id = 1, Category = "Basic", Key = "SystemName", Value = "金兰®综合信息管理系统", Description = "系统名称", IsSystem = true, CreatedAt = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc) },
                new SystemConfig { Id = 2, Category = "Basic", Key = "SystemLogo", Value = "/logo.svg", Description = "系统Logo路径", IsSystem = true, CreatedAt = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc) },
                new SystemConfig { Id = 3, Category = "Basic", Key = "Copyright", Value = "©2025 Created by jinlan.info", Description = "底部版权信息", IsSystem = true, CreatedAt = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc) },
                new SystemConfig { Id = 4, Category = "Security", Key = "PasswordMinLength", Value = "6", Description = "密码最小长度", IsSystem = true, CreatedAt = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc) },
                new SystemConfig { Id = 5, Category = "Security", Key = "SessionTimeout", Value = "30", Description = "会话超时时间(分钟)", IsSystem = true, CreatedAt = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc) }
            );

            // Seed Archive Permissions
            // 注意：档案模块菜单（Id: 46, 47, 74）由历史数据脚本初始化（见 oms.sql），
            // 这里仅新增按钮级权限（Id: 102–113），避免与现有主键/唯一键冲突。
            var fixedDate = new DateTime(2025, 12, 22, 12, 0, 0, DateTimeKind.Utc);
            modelBuilder.Entity<SystemPermission>().HasData(
                // Buttons for Manage
                new SystemPermission { Id = 102, ParentId = 47, Name = "全宗查看", Code = "archive:fond:view", Type = "BUTTON", SortOrder = 1, IsVisible = false, CreatedAt = fixedDate },
                new SystemPermission { Id = 103, ParentId = 47, Name = "全宗新增", Code = "archive:fond:add", Type = "BUTTON", SortOrder = 2, IsVisible = false, CreatedAt = fixedDate },
                new SystemPermission { Id = 104, ParentId = 47, Name = "全宗编辑", Code = "archive:fond:edit", Type = "BUTTON", SortOrder = 3, IsVisible = false, CreatedAt = fixedDate },
                new SystemPermission { Id = 105, ParentId = 47, Name = "全宗删除", Code = "archive:fond:delete", Type = "BUTTON", SortOrder = 4, IsVisible = false, CreatedAt = fixedDate },
                
                new SystemPermission { Id = 108, ParentId = 47, Name = "档案查看", Code = "archive:file:view", Type = "BUTTON", SortOrder = 5, IsVisible = false, CreatedAt = fixedDate },
                new SystemPermission { Id = 109, ParentId = 47, Name = "档案新增", Code = "archive:file:add", Type = "BUTTON", SortOrder = 6, IsVisible = false, CreatedAt = fixedDate },
                new SystemPermission { Id = 110, ParentId = 47, Name = "档案编辑", Code = "archive:file:edit", Type = "BUTTON", SortOrder = 7, IsVisible = false, CreatedAt = fixedDate },
                new SystemPermission { Id = 111, ParentId = 47, Name = "档案删除", Code = "archive:file:delete", Type = "BUTTON", SortOrder = 8, IsVisible = false, CreatedAt = fixedDate },

                // Buttons for Category
                new SystemPermission { Id = 106, ParentId = 74, Name = "分类查看", Code = "archive:type:view", Type = "BUTTON", SortOrder = 1, IsVisible = false, CreatedAt = fixedDate },
                new SystemPermission { Id = 107, ParentId = 74, Name = "分类新增", Code = "archive:type:add", Type = "BUTTON", SortOrder = 2, IsVisible = false, CreatedAt = fixedDate },
                new SystemPermission { Id = 112, ParentId = 74, Name = "分类编辑", Code = "archive:type:edit", Type = "BUTTON", SortOrder = 3, IsVisible = false, CreatedAt = fixedDate },
                new SystemPermission { Id = 113, ParentId = 74, Name = "分类删除", Code = "archive:type:delete", Type = "BUTTON", SortOrder = 4, IsVisible = false, CreatedAt = fixedDate }
            );

            // Assign new Archive button permissions to Admin Role (Id=1)
            modelBuilder.Entity<SystemRolePermission>().HasData(
                new SystemRolePermission { RoleId = 1, PermissionId = 102, CreatedAt = fixedDate },
                new SystemRolePermission { RoleId = 1, PermissionId = 103, CreatedAt = fixedDate },
                new SystemRolePermission { RoleId = 1, PermissionId = 104, CreatedAt = fixedDate },
                new SystemRolePermission { RoleId = 1, PermissionId = 105, CreatedAt = fixedDate },
                new SystemRolePermission { RoleId = 1, PermissionId = 106, CreatedAt = fixedDate },
                new SystemRolePermission { RoleId = 1, PermissionId = 107, CreatedAt = fixedDate },
                new SystemRolePermission { RoleId = 1, PermissionId = 112, CreatedAt = fixedDate },
                new SystemRolePermission { RoleId = 1, PermissionId = 113, CreatedAt = fixedDate },
                new SystemRolePermission { RoleId = 1, PermissionId = 108, CreatedAt = fixedDate },
                new SystemRolePermission { RoleId = 1, PermissionId = 109, CreatedAt = fixedDate },
                new SystemRolePermission { RoleId = 1, PermissionId = 110, CreatedAt = fixedDate },
                new SystemRolePermission { RoleId = 1, PermissionId = 111, CreatedAt = fixedDate }
            );

            // Project Configurations
            modelBuilder.Entity<ProjectPhase>().HasKey(p => new { p.Id, p.ProjectCode });
            modelBuilder.Entity<ProjectSwimlane>().HasKey(s => new { s.Id, s.ProjectCode });
            modelBuilder.Entity<ProjectTask>().HasKey(t => new { t.Id, t.ProjectCode });

            // Apply XML Documentation Comments to Database Tables and Columns
            modelBuilder.ApplyXmlDocumentation();
        }
    }
}
