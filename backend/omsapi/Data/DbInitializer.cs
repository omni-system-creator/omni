using Microsoft.EntityFrameworkCore;
using omsapi.Models.Entities;

namespace omsapi.Data
{
    public static class DbInitializer
    {
        public static async Task InitializeAsync(OmsContext context)
        {
            // 确保数据库已创建
            await context.Database.EnsureCreatedAsync();

            // 如果已经有权限数据，则跳过
            if (await context.Permissions.AnyAsync())
            {
                return;
            }

            var permissions = new List<SystemPermission>();
            var now = DateTime.Now;

            // 辅助方法：添加菜单
            void AddMenu(string name, string code, string path, string component, string icon, long? parentId, int sortOrder, out long id)
            {
                var perm = new SystemPermission
                {
                    Name = name,
                    Code = code,
                    Type = "MENU",
                    Path = path,
                    Component = component,
                    Icon = icon,
                    ParentId = parentId,
                    SortOrder = sortOrder,
                    IsVisible = true,
                    CreatedAt = now
                };
                context.Permissions.Add(perm);
                context.SaveChanges(); // 需要立即保存以获取ID
                id = perm.Id;
                permissions.Add(perm);
            }

            // 辅助方法：添加功能点（按钮）
            void AddButton(string name, string code, long parentId)
            {
                var perm = new SystemPermission
                {
                    Name = name,
                    Code = code,
                    Type = "BUTTON",
                    ParentId = parentId,
                    IsVisible = false,
                    CreatedAt = now
                };
                context.Permissions.Add(perm);
            }

            // 1. 首页
            AddMenu("首页", "HomeView", "/", "views/HomeView.vue", "ant-design:desktop-outlined", null, 10, out long homeId);

            // 2. 个人中心
            AddMenu("个人中心", "personal", "/personal", "Layout", "ant-design:user-outlined", null, 20, out long personalId);
            AddMenu("任务事项", "PersonalTodo", "/personal/todo", "views/personal/TodoList.vue", null, personalId, 21, out _);
            AddMenu("组织结构", "PersonalOrganization", "/personal/organization", "views/personal/Organization.vue", null, personalId, 22, out _);
            AddMenu("消息中心", "PersonalMessages", "/personal/messages", "views/personal/Messages.vue", null, personalId, 23, out _);
            AddMenu("文件网盘", "PersonalDrive", "/personal/drive", "views/personal/Drive.vue", null, personalId, 24, out _);
            AddMenu("账号信息", "PersonalAccount", "/personal/account", "views/personal/Account.vue", null, personalId, 25, out _);

            // 3. 合同管理
            AddMenu("合同管理", "contract", "/contract", "Layout", "ant-design:file-text-outlined", null, 30, out long contractId);
            AddMenu("合同列表", "ContractTrack", "/contract/track", "views/contract/ContractTrack.vue", null, contractId, 31, out _);
            AddMenu("合同模板", "ContractTemplate", "/contract/template", "views/contract/ContractTemplate.vue", null, contractId, 32, out _);
            AddMenu("合同统计", "ContractStats", "/contract/stats", "views/contract/ContractStats.vue", null, contractId, 33, out _);
            AddMenu("合同知识库", "ContractKnowledge", "/contract/knowledge", "views/contract/ContractKnowledge.vue", null, contractId, 34, out _);

            // 4. 项目管理
            AddMenu("项目管理", "project", "/project", "Layout", "ant-design:project-outlined", null, 40, out long projectId);
            AddMenu("项目统筹", "ProjectList", "/project/list", "views/project/ProjectList.vue", null, projectId, 41, out _);
            AddMenu("文档协同", "ProjectDoc", "/project/doc", "views/project/ProjectDoc.vue", null, projectId, 42, out _);
            AddMenu("成本控制", "ProjectCost", "/project/cost", "views/project/ProjectCost.vue", null, projectId, 43, out _);

            // 5. 财务管理
            AddMenu("财务管理", "finance", "/finance", "Layout", "ant-design:pay-circle-outlined", null, 50, out long financeId);
            AddMenu("应收应付", "FinanceApAr", "/finance/ap-ar", "views/finance/FinanceApAr.vue", null, financeId, 51, out _);
            AddMenu("发票管理", "FinanceInvoice", "/finance/invoice", "views/finance/FinanceInvoice.vue", null, financeId, 52, out _);
            AddMenu("财务报表", "FinanceReport", "/finance/report", "views/finance/FinanceReport.vue", null, financeId, 53, out _);

            // 6. 销售管理
            AddMenu("销售管理", "sales", "/sales", "Layout", "ant-design:shopping-cart-outlined", null, 60, out long salesId);
            AddMenu("商机管理", "SalesOpportunity", "/sales/opportunity", "views/sales/Opportunity.vue", null, salesId, 61, out _);
            AddMenu("客户管理", "SalesCustomer", "/sales/customer", "views/sales/Customer.vue", null, salesId, 62, out _);
            AddMenu("销售资料", "SalesMaterials", "/sales/materials", "views/sales/Materials.vue", null, salesId, 63, out _);
            AddMenu("销售目标", "SalesTargets", "/sales/targets", "views/sales/Targets.vue", null, salesId, 64, out _);

            // 7. 采购管理
            AddMenu("采购管理", "procurement", "/procurement", "Layout", "ant-design:shopping-outlined", null, 70, out long procurementId);
            AddMenu("采购需求", "ProcurementRequest", "/procurement/request", "views/procurement/Request.vue", null, procurementId, 71, out _);
            AddMenu("采购订单", "ProcurementOrder", "/procurement/order", "views/procurement/Order.vue", null, procurementId, 72, out _);
            AddMenu("供应商管理", "ProcurementSupplier", "/procurement/supplier", "views/procurement/Supplier.vue", null, procurementId, 73, out _);
            AddMenu("历史采购", "ProcurementHistory", "/procurement/history", "views/procurement/History.vue", null, procurementId, 74, out _);

            // 8. 库存管理
            AddMenu("库存管理", "inventory", "/inventory", "Layout", "ant-design:shop-outlined", null, 80, out long inventoryId);
            AddMenu("仓库基础", "InventoryWarehouse", "/inventory/warehouse", "views/inventory/Warehouse.vue", null, inventoryId, 81, out _);
            AddMenu("库存物品", "InventoryProduct", "/inventory/product-info", "views/inventory/ProductInfo.vue", null, inventoryId, 82, out _);
            AddMenu("出入库管理", "InventoryInOut", "/inventory/in-out", "views/inventory/InOut.vue", null, inventoryId, 83, out _);
            AddMenu("库内作业", "InventoryInternal", "/inventory/internal", "views/inventory/InternalOps.vue", null, inventoryId, 84, out _);
            AddMenu("库存盘点", "InventoryStocktaking", "/inventory/stocktaking", "views/inventory/Stocktaking.vue", null, inventoryId, 85, out _);
            AddMenu("库存跟踪", "InventoryTrack", "/inventory/track", "views/inventory/InventoryTrack.vue", null, inventoryId, 86, out _);
            AddMenu("库存分析", "InventoryAnalysis", "/inventory/analysis", "views/inventory/Analysis.vue", null, inventoryId, 87, out _);

            // 9. 流程管理
            AddMenu("流程管理", "bpm", "/bpm", "Layout", "ant-design:apartment-outlined", null, 90, out long bpmId);
            AddMenu("审批流程", "BpmWorkflow", "/bpm/workflow", "views/bpm/BpmWorkflow.vue", null, bpmId, 91, out _);
            AddMenu("任务自动化", "BpmTask", "/bpm/task", "views/bpm/BpmTask.vue", null, bpmId, 92, out _);

            // 10. 数据分析
            AddMenu("数据分析", "bi", "/bi", "Layout", "ant-design:bar-chart-outlined", null, 100, out long biId);
            AddMenu("经营仪表盘", "BiDashboard", "/bi/dashboard", "views/bi/BiDashboard.vue", null, biId, 101, out _);
            AddMenu("销售分析", "BiSales", "/bi/sales", "views/bi/BiSales.vue", null, biId, 102, out _);
            AddMenu("财务分析", "BiFinance", "/bi/finance", "views/bi/BiFinance.vue", null, biId, 103, out _);

            // 11. 档案管理
            AddMenu("档案管理", "archive", "/archive", "Layout", "ant-design:folder-open-outlined", null, 110, out long archiveId);
            AddMenu("档案列表", "ArchiveList", "/archive/list", "views/archive/ArchiveList.vue", null, archiveId, 111, out _);

            // 12. 数据管理
            AddMenu("数据管理", "data", "/data", "Layout", "ant-design:database-outlined", null, 120, out long dataId);
            AddMenu("数据源管理", "DataSource", "/data/source", "views/data/DataSource.vue", null, dataId, 121, out _);
            AddMenu("外部接口管理", "DataInterface", "/data/interface", "views/data/DataInterface.vue", null, dataId, 122, out _);
            AddMenu("接口发布管理", "InterfacePublish", "/data/interface-publish", "views/data/InterfacePublish/Index.vue", null, dataId, 123, out _);
            AddMenu("ETL管理", "ETL", "/data/etl", "views/data/ETL/Index.vue", null, dataId, 124, out _);

            // 13. 系统管理
            AddMenu("系统管理", "system", "/system", "Layout", "ant-design:setting-outlined", null, 130, out long systemId);
            AddMenu("用户管理", "SysUser", "/system/user", "views/system/SysUser.vue", null, systemId, 131, out long sysUserId);
            AddMenu("角色管理", "SysRole", "/system/role", "views/system/SysRole.vue", null, systemId, 132, out long sysRoleId);
            AddMenu("岗位管理", "SysPost", "/system/post", "views/system/SysPost.vue", null, systemId, 133, out long sysPostId);
            AddMenu("权限管理", "SysPermission", "/system/permission", "views/system/SysPermission.vue", null, systemId, 134, out _);
            AddMenu("组织架构", "SysOrg", "/system/org", "views/system/SysOrg.vue", null, systemId, 135, out _);
            AddMenu("系统配置", "SysConfig", "/system/config", "views/system/SysConfig.vue", null, systemId, 136, out _);
            AddMenu("数据安全", "SysSecurity", "/system/security", "views/system/SysSecurity.vue", null, systemId, 137, out _);
            AddMenu("系统集成", "SysIntegration", "/system/integration", "views/system/SysIntegration.vue", null, systemId, 138, out _);

            // --- 示例：为用户管理添加功能点权限 ---
            AddButton("新增用户", "system:user:add", sysUserId);
            AddButton("编辑用户", "system:user:edit", sysUserId);
            AddButton("删除用户", "system:user:delete", sysUserId);
            AddButton("重置密码", "system:user:reset_pwd", sysUserId);

            // --- 示例：为角色管理添加功能点权限 ---
            AddButton("新增角色", "system:role:add", sysRoleId);
            AddButton("编辑角色", "system:role:edit", sysRoleId);
            AddButton("删除角色", "system:role:delete", sysRoleId);
            AddButton("分配权限", "system:role:assign_perm", sysRoleId);

            // --- 示例：为岗位管理添加功能点权限 ---
            AddButton("新增岗位", "system:post:add", sysPostId);
            AddButton("编辑岗位", "system:post:edit", sysPostId);
            AddButton("删除岗位", "system:post:delete", sysPostId);

            await context.SaveChangesAsync();

            // 默认给管理员角色分配所有权限
            // 获取管理员已有的权限ID
            var existingRolePermIds = await context.RolePermissions
                .Where(rp => rp.RoleId == 1)
                .Select(rp => rp.PermissionId)
                .ToListAsync();
            var existingRolePermIdsSet = new HashSet<long>(existingRolePermIds);

            // 获取所有权限（包括新添加的）
            var allPerms = await context.Permissions.ToListAsync();
            
            // 找出尚未分配给管理员的权限
            var newRolePerms = allPerms
                .Where(p => !existingRolePermIdsSet.Contains(p.Id))
                .Select(p => new SystemRolePermission
                {
                    RoleId = 1, // Admin Role ID
                    PermissionId = p.Id,
                    CreatedAt = now
                });
            
            if (newRolePerms.Any())
            {
                context.RolePermissions.AddRange(newRolePerms);
                await context.SaveChangesAsync();
            }
        }
    }
}
