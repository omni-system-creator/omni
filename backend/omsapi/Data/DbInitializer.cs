using Microsoft.EntityFrameworkCore;
using omsapi.Models.Entities;
using omsapi.Models.Entities.Contract;
using omsapi.Models.Entities.Dict;

namespace omsapi.Data
{
    public static class DbInitializer
    {
        public static async Task InitializeAsync(OmsContext context)
        {
            // 确保数据库已创建
            await context.Database.EnsureCreatedAsync();

            // 初始化合同模块数据
            await SeedContractDataAsync(context);

            // 初始化销售模块数据
            await SeedSalesDataAsync(context);

            // 初始化字典模块数据
            await SeedDictDataAsync(context);

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

        private static async Task SeedDictDataAsync(OmsContext context)
        {
            var now = DateTime.Now;

            // 1. 字典分类 (SysDictCategory)
            var categories = new List<SysDictCategory>
            {
                new SysDictCategory { Code = "sys_common", Name = "系统通用", Sort = 1, Remark = "系统通用的字典数据", CreatedAt = now, UpdatedAt = now },
                new SysDictCategory { Code = "biz_module", Name = "业务模块", Sort = 2, Remark = "业务模块相关的字典数据", CreatedAt = now, UpdatedAt = now },
                new SysDictCategory { Code = "contract_mgmt", Name = "合同管理", Sort = 3, Remark = "合同管理相关的字典数据", CreatedAt = now, UpdatedAt = now },
                new SysDictCategory { Code = "project_mgmt", Name = "项目管理", Sort = 4, Remark = "项目管理相关的字典数据", CreatedAt = now, UpdatedAt = now },
                new SysDictCategory { Code = "finance_mgmt", Name = "财务管理", Sort = 5, Remark = "财务管理相关的字典数据", CreatedAt = now, UpdatedAt = now },
                new SysDictCategory { Code = "scm_mgmt", Name = "供应链管理", Sort = 6, Remark = "采购与库存相关的字典数据", CreatedAt = now, UpdatedAt = now },
                new SysDictCategory { Code = "asset_mgmt", Name = "资产管理", Sort = 7, Remark = "固定资产相关的字典数据", CreatedAt = now, UpdatedAt = now },
                new SysDictCategory { Code = "bpm_mgmt", Name = "流程管理", Sort = 8, Remark = "工作流相关的字典数据", CreatedAt = now, UpdatedAt = now },
                new SysDictCategory { Code = "archive_mgmt", Name = "档案管理", Sort = 9, Remark = "档案资料相关的字典数据", CreatedAt = now, UpdatedAt = now },
                new SysDictCategory { Code = "data_mgmt", Name = "数据管理", Sort = 10, Remark = "数据集成与治理相关的字典数据", CreatedAt = now, UpdatedAt = now },
                new SysDictCategory { Code = "sys_security", Name = "系统安全", Sort = 11, Remark = "系统安全相关的字典数据", CreatedAt = now, UpdatedAt = now },
                new SysDictCategory { Code = "sales_mgmt", Name = "销售管理", Sort = 12, Remark = "销售与CRM相关的字典数据", CreatedAt = now, UpdatedAt = now },
                new SysDictCategory { Code = "personal_mgmt", Name = "个人办公", Sort = 13, Remark = "个人办公与消息相关的字典数据", CreatedAt = now, UpdatedAt = now }
            };

            foreach (var cat in categories)
            {
                if (!await context.DictCategories.AnyAsync(c => c.Code == cat.Code))
                {
                    context.DictCategories.Add(cat);
                }
            }
            await context.SaveChangesAsync();

            // 重新获取分类以获取ID
            var dbCategories = await context.DictCategories.ToListAsync();
            
            // 辅助方法：获取分类ID
            long? GetCatId(string code) => dbCategories.FirstOrDefault(c => c.Code == code)?.Id;

            // 2. 字典类型 (SysDictType)
            var types = new List<SysDictType>();

            void AddType(string catCode, string code, string name, string remark)
            {
                var catId = GetCatId(catCode);
                if (catId.HasValue)
                {
                    types.Add(new SysDictType { CategoryId = catId.Value, Code = code, Name = name, Status = "normal", Remark = remark, CreatedAt = now, UpdatedAt = now });
                }
            }

            AddType("sys_common", "sys_user_status", "用户状态", "系统用户的状态");
            AddType("sys_common", "sys_user_gender", "用户性别", "用户的性别");
            AddType("sales_mgmt", "crm_customer_level", "客户等级", "CRM客户等级分类");
            AddType("contract_mgmt", "contract_type", "合同类型", "合同的业务类型");
            AddType("contract_mgmt", "contract_status", "合同状态", "合同的生命周期状态");
            AddType("project_mgmt", "project_status", "项目状态", "项目的当前状态");
            AddType("project_mgmt", "project_priority", "项目优先级", "项目的紧急程度");
            AddType("finance_mgmt", "finance_invoice_type", "发票类型", "增值税发票类型");
            AddType("finance_mgmt", "finance_payment_method", "支付方式", "收付款的方式");
            AddType("scm_mgmt", "scm_supplier_level", "供应商等级", "供应商的重要性分级");
            AddType("scm_mgmt", "scm_warehouse_type", "仓库类型", "仓库的功能分类");
            AddType("asset_mgmt", "asset_status", "资产状态", "固定资产的使用状态");
            AddType("bpm_mgmt", "bpm_urgency", "紧急程度", "流程任务的紧急程度");
            AddType("archive_mgmt", "archive_type", "档案类型", "档案的分类");
            AddType("archive_mgmt", "archive_security_level", "密级", "档案的保密级别");
            AddType("data_mgmt", "data_source_type", "数据源类型", "数据库或接口类型");
            AddType("data_mgmt", "etl_status", "ETL状态", "ETL任务的执行状态");
            AddType("sys_security", "sys_login_status", "登录状态", "用户登录的结果状态");
            AddType("sys_security", "sys_oper_type", "操作类型", "系统操作日志的操作类型");
            AddType("sales_mgmt", "sales_opportunity_stage", "商机阶段", "销售商机的进展阶段");
            AddType("sales_mgmt", "sales_customer_source", "客户来源", "客户信息的获取渠道");
            AddType("personal_mgmt", "personal_todo_priority", "待办优先级", "个人待办事项的优先级");
            AddType("personal_mgmt", "personal_msg_type", "消息类型", "站内消息的类型");

            foreach (var t in types)
            {
                if (!await context.DictTypes.AnyAsync(x => x.Code == t.Code))
                {
                    context.DictTypes.Add(t);
                }
            }
            await context.SaveChangesAsync();

            // 3. 字典数据 (SysDictData)
            var dbTypes = await context.DictTypes.ToListAsync();

            async Task AddData(string typeCode, List<SysDictData> datas)
            {
                var type = dbTypes.FirstOrDefault(t => t.Code == typeCode);
                if (type != null && !await context.DictDatas.AnyAsync(d => d.DictTypeId == type.Id))
                {
                    foreach (var data in datas)
                    {
                        data.DictTypeId = type.Id;
                        data.CreatedAt = now;
                        data.UpdatedAt = now;
                    }
                    context.DictDatas.AddRange(datas);
                }
            }

            // 系统通用
            await AddData("sys_user_status", new List<SysDictData>
            {
                new SysDictData { Label = "正常", Value = "1", Sort = 1, IsDefault = true, Status = "normal" },
                new SysDictData { Label = "停用", Value = "0", Sort = 2, IsDefault = false, Status = "normal" }
            });
            await AddData("sys_user_gender", new List<SysDictData>
            {
                new SysDictData { Label = "男", Value = "1", Sort = 1, IsDefault = true, Status = "normal" },
                new SysDictData { Label = "女", Value = "2", Sort = 2, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "未知", Value = "0", Sort = 3, IsDefault = false, Status = "normal" }
            });

            // 业务模块
            await AddData("crm_customer_level", new List<SysDictData>
            {
                new SysDictData { Label = "重点客户", Value = "A", Sort = 1, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "普通客户", Value = "B", Sort = 2, IsDefault = true, Status = "normal" },
                new SysDictData { Label = "低价值客户", Value = "C", Sort = 3, IsDefault = false, Status = "normal" }
            });

            // 合同管理
            await AddData("contract_type", new List<SysDictData>
            {
                new SysDictData { Label = "销售合同", Value = "sales", Sort = 1, IsDefault = true, Status = "normal" },
                new SysDictData { Label = "采购合同", Value = "purchase", Sort = 2, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "服务合同", Value = "service", Sort = 3, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "劳动合同", Value = "labor", Sort = 4, IsDefault = false, Status = "normal" }
            });
            await AddData("contract_status", new List<SysDictData>
            {
                new SysDictData { Label = "草稿", Value = "draft", Sort = 1, IsDefault = true, Status = "normal" },
                new SysDictData { Label = "审核中", Value = "review", Sort = 2, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "执行中", Value = "active", Sort = 3, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "已完成", Value = "completed", Sort = 4, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "已终止", Value = "terminated", Sort = 5, IsDefault = false, Status = "normal" }
            });

            // 项目管理
            await AddData("project_status", new List<SysDictData>
            {
                new SysDictData { Label = "规划中", Value = "planning", Sort = 1, IsDefault = true, Status = "normal" },
                new SysDictData { Label = "进行中", Value = "in_progress", Sort = 2, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "暂停", Value = "on_hold", Sort = 3, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "已完成", Value = "completed", Sort = 4, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "已归档", Value = "archived", Sort = 5, IsDefault = false, Status = "normal" }
            });
            await AddData("project_priority", new List<SysDictData>
            {
                new SysDictData { Label = "高", Value = "high", Sort = 1, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "中", Value = "medium", Sort = 2, IsDefault = true, Status = "normal" },
                new SysDictData { Label = "低", Value = "low", Sort = 3, IsDefault = false, Status = "normal" }
            });

            // 财务管理
            await AddData("finance_invoice_type", new List<SysDictData>
            {
                new SysDictData { Label = "增值税专用发票", Value = "vat_special", Sort = 1, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "增值税普通发票", Value = "vat_normal", Sort = 2, IsDefault = true, Status = "normal" },
                new SysDictData { Label = "电子发票", Value = "electronic", Sort = 3, IsDefault = false, Status = "normal" }
            });
            await AddData("finance_payment_method", new List<SysDictData>
            {
                new SysDictData { Label = "银行转账", Value = "bank", Sort = 1, IsDefault = true, Status = "normal" },
                new SysDictData { Label = "现金", Value = "cash", Sort = 2, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "支票", Value = "check", Sort = 3, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "支付宝", Value = "alipay", Sort = 4, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "微信支付", Value = "wechat", Sort = 5, IsDefault = false, Status = "normal" }
            });

            // 供应链管理
            await AddData("scm_supplier_level", new List<SysDictData>
            {
                new SysDictData { Label = "战略供应商", Value = "strategic", Sort = 1, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "核心供应商", Value = "core", Sort = 2, IsDefault = true, Status = "normal" },
                new SysDictData { Label = "备选供应商", Value = "backup", Sort = 3, IsDefault = false, Status = "normal" }
            });
            await AddData("scm_warehouse_type", new List<SysDictData>
            {
                new SysDictData { Label = "成品库", Value = "finished", Sort = 1, IsDefault = true, Status = "normal" },
                new SysDictData { Label = "原料库", Value = "raw", Sort = 2, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "中转库", Value = "transit", Sort = 3, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "废品库", Value = "defective", Sort = 4, IsDefault = false, Status = "normal" }
            });

            // 资产管理
            await AddData("asset_status", new List<SysDictData>
            {
                new SysDictData { Label = "使用中", Value = "in_use", Sort = 1, IsDefault = true, Status = "normal" },
                new SysDictData { Label = "闲置", Value = "idle", Sort = 2, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "维修中", Value = "maintenance", Sort = 3, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "已报废", Value = "scrapped", Sort = 4, IsDefault = false, Status = "normal" }
            });

            // 流程管理
            await AddData("bpm_urgency", new List<SysDictData>
            {
                new SysDictData { Label = "紧急", Value = "urgent", Sort = 1, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "普通", Value = "normal", Sort = 2, IsDefault = true, Status = "normal" }
            });

            // 档案管理
            await AddData("archive_type", new List<SysDictData>
            {
                new SysDictData { Label = "合同档案", Value = "contract", Sort = 1, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "人事档案", Value = "personnel", Sort = 2, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "财务档案", Value = "finance", Sort = 3, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "项目档案", Value = "project", Sort = 4, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "行政档案", Value = "admin", Sort = 5, IsDefault = true, Status = "normal" }
            });
            await AddData("archive_security_level", new List<SysDictData>
            {
                new SysDictData { Label = "公开", Value = "public", Sort = 1, IsDefault = true, Status = "normal" },
                new SysDictData { Label = "内部", Value = "internal", Sort = 2, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "秘密", Value = "secret", Sort = 3, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "机密", Value = "top_secret", Sort = 4, IsDefault = false, Status = "normal" }
            });

            // 数据管理
            await AddData("data_source_type", new List<SysDictData>
            {
                new SysDictData { Label = "MySQL", Value = "mysql", Sort = 1, IsDefault = true, Status = "normal" },
                new SysDictData { Label = "PostgreSQL", Value = "postgresql", Sort = 2, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "Oracle", Value = "oracle", Sort = 3, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "SQL Server", Value = "sqlserver", Sort = 4, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "REST API", Value = "api", Sort = 5, IsDefault = false, Status = "normal" }
            });
            await AddData("etl_status", new List<SysDictData>
            {
                new SysDictData { Label = "运行中", Value = "running", Sort = 1, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "成功", Value = "success", Sort = 2, IsDefault = true, Status = "normal" },
                new SysDictData { Label = "失败", Value = "failed", Sort = 3, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "等待中", Value = "pending", Sort = 4, IsDefault = false, Status = "normal" }
            });

            // 系统安全
            await AddData("sys_login_status", new List<SysDictData>
            {
                new SysDictData { Label = "成功", Value = "success", Sort = 1, IsDefault = true, Status = "normal" },
                new SysDictData { Label = "失败", Value = "failed", Sort = 2, IsDefault = false, Status = "normal" }
            });
            await AddData("sys_oper_type", new List<SysDictData>
            {
                new SysDictData { Label = "查询", Value = "query", Sort = 1, IsDefault = true, Status = "normal" },
                new SysDictData { Label = "新增", Value = "insert", Sort = 2, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "修改", Value = "update", Sort = 3, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "删除", Value = "delete", Sort = 4, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "导出", Value = "export", Sort = 5, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "导入", Value = "import", Sort = 6, IsDefault = false, Status = "normal" }
            });

            // 销售管理
            await AddData("sales_opportunity_stage", new List<SysDictData>
            {
                new SysDictData { Label = "初步接触", Value = "discovery", Sort = 1, IsDefault = true, Status = "normal" },
                new SysDictData { Label = "需求分析", Value = "needs_analysis", Sort = 2, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "方案报价", Value = "proposal", Sort = 3, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "商务谈判", Value = "negotiation", Sort = 4, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "赢单", Value = "won", Sort = 5, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "输单", Value = "lost", Sort = 6, IsDefault = false, Status = "normal" }
            });
            await AddData("sales_customer_source", new List<SysDictData>
            {
                new SysDictData { Label = "公司资源", Value = "company", Sort = 1, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "网络推广", Value = "web", Sort = 2, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "客户介绍", Value = "referral", Sort = 3, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "电话销售", Value = "cold_call", Sort = 4, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "展会活动", Value = "exhibition", Sort = 5, IsDefault = false, Status = "normal" }
            });

            // 个人办公
            await AddData("personal_todo_priority", new List<SysDictData>
            {
                new SysDictData { Label = "高", Value = "high", Sort = 1, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "中", Value = "medium", Sort = 2, IsDefault = true, Status = "normal" },
                new SysDictData { Label = "低", Value = "low", Sort = 3, IsDefault = false, Status = "normal" }
            });
            await AddData("personal_msg_type", new List<SysDictData>
            {
                new SysDictData { Label = "系统通知", Value = "system", Sort = 1, IsDefault = true, Status = "normal" },
                new SysDictData { Label = "私人消息", Value = "private", Sort = 2, IsDefault = false, Status = "normal" },
                new SysDictData { Label = "任务提醒", Value = "task", Sort = 3, IsDefault = false, Status = "normal" }
            });

            await context.SaveChangesAsync();
        }

        private static async Task SeedSalesDataAsync(OmsContext context)
        {
            var now = DateTime.Now;

            // 1. 客户数据
            if (!await context.SalesCustomers.AnyAsync())
            {
                context.SalesCustomers.AddRange(
                    new omsapi.Models.Entities.Sales.SalesCustomer
                    {
                        Name = "杭州金兰科技有限公司",
                        Contact = "张总",
                        Phone = "13800138000",
                        Email = "zhang@jinlan.com",
                        Industry = "IT/互联网",
                        Level = "A", // A类客户
                        Status = "potential", // 潜在客户
                        Address = "浙江省杭州市西湖区科技园",
                        Source = "网络推广",
                        Description = "对ERP系统有强烈需求，预计下月启动招标",
                        Owner = "admin",
                        CreatedAt = now,
                        UpdatedAt = now
                    },
                    new omsapi.Models.Entities.Sales.SalesCustomer
                    {
                        Name = "上海未来智造有限公司",
                        Contact = "李经理",
                        Phone = "13900139000",
                        Email = "li@futuremfg.com",
                        Industry = "智能制造",
                        Level = "B",
                        Status = "existing", // 现有客户
                        Address = "上海市浦东新区张江高科",
                        Source = "老客户推荐",
                        Description = "已购买一期产品，目前在谈二期扩容",
                        Owner = "admin",
                        CreatedAt = now.AddDays(-10),
                        UpdatedAt = now
                    },
                    new omsapi.Models.Entities.Sales.SalesCustomer
                    {
                        Name = "北京云端网络技术部",
                        Contact = "王工",
                        Phone = "13700137000",
                        Email = "wang@cloudnet.bj",
                        Industry = "云计算",
                        Level = "A",
                        Status = "high_intent", // 高意向
                        Address = "北京市海淀区中关村",
                        Source = "展会",
                        Description = "技术负责人非常认可我们的架构",
                        Owner = "admin",
                        CreatedAt = now.AddDays(-5),
                        UpdatedAt = now
                    }
                );
                await context.SaveChangesAsync();
            }

            // 2. 商机数据
            // 需要先获取客户ID
            var customers = await context.SalesCustomers.ToListAsync();
            if (!await context.SalesOpportunities.AnyAsync() && customers.Any())
            {
                var cust1 = customers.FirstOrDefault(c => c.Name.Contains("金兰"));
                var cust2 = customers.FirstOrDefault(c => c.Name.Contains("未来智造"));

                if (cust1 != null)
                {
                    context.SalesOpportunities.Add(new omsapi.Models.Entities.Sales.SalesOpportunity
                    {
                        Title = "金兰科技ERP系统采购项目",
                        CustomerId = cust1.Id,
                        Customer = cust1.Name,
                        Amount = 500000,
                        Stage = "negotiation", // 商务谈判
                        WinRate = 80,
                        EstimatedCloseDate = now.AddMonths(1),
                        Owner = "admin",
                        Description = "竞争对手只有一家，我方优势明显",
                        CreatedAt = now,
                        UpdatedAt = now
                    });
                }

                if (cust2 != null)
                {
                    context.SalesOpportunities.Add(new omsapi.Models.Entities.Sales.SalesOpportunity
                    {
                        Title = "未来智造CRM升级服务",
                        CustomerId = cust2.Id,
                        Customer = cust2.Name,
                        Amount = 200000,
                        Stage = "proposal", // 方案制定
                        WinRate = 50,
                        EstimatedCloseDate = now.AddMonths(2),
                        Owner = "admin",
                        Description = "需定制开发部分功能模块",
                        CreatedAt = now,
                        UpdatedAt = now
                    });
                }
                
                // 添加更多商机以丰富看板
                if (cust1 != null)
                {
                     context.SalesOpportunities.Add(new omsapi.Models.Entities.Sales.SalesOpportunity
                    {
                        Title = "金兰科技数据中台咨询",
                        CustomerId = cust1.Id,
                        Customer = cust1.Name,
                        Amount = 150000,
                        Stage = "initial", // 初步接触
                        WinRate = 20,
                        EstimatedCloseDate = now.AddMonths(3),
                        Owner = "admin",
                        Description = "初步意向沟通",
                        CreatedAt = now,
                        UpdatedAt = now
                    });
                }

                // 添加一个已成交的商机
                 if (cust2 != null)
                {
                     context.SalesOpportunities.Add(new omsapi.Models.Entities.Sales.SalesOpportunity
                    {
                        Title = "未来智造一期项目增补",
                        CustomerId = cust2.Id,
                        Customer = cust2.Name,
                        Amount = 80000,
                        Stage = "won", // 已成交
                        WinRate = 100,
                        EstimatedCloseDate = now.AddDays(-2),
                        Owner = "admin",
                        Description = "增补许可授权",
                        CreatedAt = now.AddDays(-5),
                        UpdatedAt = now
                    });
                }

                await context.SaveChangesAsync();
            }

            // 3. 销售话术
            if (!await context.SalesScripts.AnyAsync())
            {
                context.SalesScripts.AddRange(
                    new omsapi.Models.Entities.Sales.SalesScript
                    {
                        Title = "通用电话开场白",
                        Category = "初次接触",
                        Content = "您好，我是[公司名]的销售顾问[姓名]，打扰您两分钟。我们公司专注于为企业提供数字化转型解决方案，近期我们服务了[知名同行企业]，帮助他们提升了30%的运营效率。想请教一下贵公司在信息化管理方面目前主要关注哪些领域呢？",
                        CreatedAt = now
                    },
                    new omsapi.Models.Entities.Sales.SalesScript
                    {
                        Title = "产品核心优势介绍（30秒电梯演讲）",
                        Category = "产品介绍",
                        Content = "我们的OMS系统有三大核心优势：第一是全流程一体化，打通了从CRM到ERP再到财务的全链路；第二是高度可配置，90%的业务变更无需写代码；第三是极致的用户体验，界面简洁易用，员工上手无需培训。这能直接为您解决数据孤岛和系统维护成本高的问题。",
                        CreatedAt = now
                    },
                    new omsapi.Models.Entities.Sales.SalesScript
                    {
                        Title = "价格异议处理话术",
                        Category = "异议处理",
                        Content = "非常理解您对预算的考量。不过，单纯看价格可能不够全面，我们更建议看投入产出比（ROI）。我们的系统虽然初期投入稍高，但由于采用了自动化流程，预计每年能为您节省人工成本约50万元，系统上线半年即可收回成本。我们可以为您做一个详细的ROI分析报告。",
                        CreatedAt = now
                    },
                    new omsapi.Models.Entities.Sales.SalesScript
                    {
                        Title = "竞品对比回应（针对某友商）",
                        Category = "竞品分析",
                        Content = "友商在财务软件领域确实很知名，但在业务运营（OMS）这块，我们的架构更灵活，更贴合当下互联网+的业务模式。例如在多渠道订单归集和复杂的库存调度策略上，我们是原生支持的，而他们可能需要大量的二次开发。",
                        CreatedAt = now
                    },
                     new omsapi.Models.Entities.Sales.SalesScript
                    {
                        Title = "邀约客户考察话术",
                        Category = "客户邀约",
                        Content = "为了让您更直观地了解系统如何落地，诚挚邀请您下周二来我们公司参观考察。届时我们的技术总监会亲自为您演示最新版本，并且您可以和我们的产品团队直接交流您的定制化需求。您看上午10点还是下午2点比较方便？",
                        CreatedAt = now
                    }
                );
                await context.SaveChangesAsync();
            }

            // 4. 产品资料
            if (!await context.SalesProductDocs.AnyAsync())
            {
                context.SalesProductDocs.AddRange(
                    new omsapi.Models.Entities.Sales.SalesProductDoc
                    {
                        Title = "OMS智能管理系统_产品白皮书_v3.0.pdf",
                        Size = "5.2 MB",
                        Url = "/files/docs/oms_whitepaper_v3.pdf", // 示例路径
                        UploadDate = now.AddDays(-30)
                    },
                    new omsapi.Models.Entities.Sales.SalesProductDoc
                    {
                        Title = "企业数字化转型解决方案(制造业版).pptx",
                        Size = "15.8 MB",
                        Url = "/files/docs/solution_manufacturing.pptx",
                        UploadDate = now.AddDays(-20)
                    },
                    new omsapi.Models.Entities.Sales.SalesProductDoc
                    {
                        Title = "OMS系统客户成功案例集锦.pdf",
                        Size = "8.4 MB",
                        Url = "/files/docs/success_cases.pdf",
                        UploadDate = now.AddDays(-15)
                    },
                    new omsapi.Models.Entities.Sales.SalesProductDoc
                    {
                        Title = "SaaS版报价单及服务清单_2024Q1.xlsx",
                        Size = "45 KB",
                        Url = "/files/docs/price_list_2024q1.xlsx",
                        UploadDate = now.AddDays(-5)
                    },
                    new omsapi.Models.Entities.Sales.SalesProductDoc
                    {
                        Title = "系统操作手册(管理员版).docx",
                        Size = "3.2 MB",
                        Url = "/files/docs/manual_admin.docx",
                        UploadDate = now.AddDays(-60)
                    }
                );
                await context.SaveChangesAsync();
            }

            // 5. 流程规则
            if (!await context.SalesProcessRules.AnyAsync())
            {
                context.SalesProcessRules.AddRange(
                    new omsapi.Models.Entities.Sales.SalesProcessRule
                    {
                        Title = "商机报备与保护制度",
                        Content = "1. 所有新接触客户必须在24小时内录入CRM系统，否则视为公共资源。\n2. 报备有效期为3个月，期间其他销售人员不得跟进。\n3. 若3个月内无实质性进展（阶段未推进），系统将自动释放至公海池。\n4. 跨区域撞单情况，以系统最早录入时间为准。",
                        CreatedAt = now
                    },
                    new omsapi.Models.Entities.Sales.SalesProcessRule
                    {
                        Title = "合同审批及盖章规范",
                        Content = "1. 标准合同（金额<50万）：销售经理审批 -> 财务审批 -> 法务备案 -> 用印。\n2. 非标合同或金额>=50万：销售总监审批 -> 财务总监审批 -> 法务总监审批 -> 总经理审批 -> 用印。\n3. 所有合同必须附带技术协议附件。\n4. 严禁先盖章后签字。",
                        CreatedAt = now
                    },
                    new omsapi.Models.Entities.Sales.SalesProcessRule
                    {
                        Title = "销售提成发放细则",
                        Content = "1. 提成计算基数：以实际回款金额为准（不含税）。\n2. 发放节点：回款次月发放50%，项目验收后发放剩余50%。\n3. 离职员工未结提成：已回款部分按正常比例发放，未回款部分不再计提。\n4. 季度销售冠军额外奖励1%提成点。",
                        CreatedAt = now
                    },
                     new omsapi.Models.Entities.Sales.SalesProcessRule
                    {
                        Title = "客户接待标准流程",
                        Content = "1. 预约：确认客户来访人数、职位、关注点，提前预定会议室。\n2. 接待：前台登记，引导至会议室，提供茶水（矿泉水/茶/咖啡）。\n3. 演示：连接投影仪，准备好演示环境，演示时长控制在30分钟内。\n4. 送别：送至电梯口或公司门口，并在当天发送感谢短信/邮件。",
                        CreatedAt = now
                    }
                );
                await context.SaveChangesAsync();
            }
        }

        private static async Task SeedContractDataAsync(OmsContext context)
        {
            var now = DateTime.Now;

            // 1. 合同模板
            if (!await context.ContractTemplates.AnyAsync())
            {
                context.ContractTemplates.AddRange(
                    new ContractTemplate
                    {
                        Name = "标准产品销售合同",
                        Type = "sales",
                        Description = "适用于一般标准产品的销售业务",
                        Status = "active",
                        FileName = "standard_sales_contract_v1.docx",
                        CreatedAt = now,
                        UpdatedAt = now
                    },
                    new ContractTemplate
                    {
                        Name = "原材料采购框架协议",
                        Type = "purchase",
                        Description = "适用于长期原材料采购合作",
                        Status = "active",
                        FileName = "material_purchase_agreement.pdf",
                        CreatedAt = now,
                        UpdatedAt = now
                    },
                    new ContractTemplate
                    {
                        Name = "技术服务合同",
                        Type = "service",
                        Description = "适用于软件开发及技术支持服务",
                        Status = "active",
                        FileName = "tech_service_contract.docx",
                        CreatedAt = now,
                        UpdatedAt = now
                    },
                    new ContractTemplate
                    {
                        Name = "员工劳动合同（标准版）",
                        Type = "labor",
                        Description = "全职员工标准劳动合同",
                        Status = "active",
                        FileName = "employee_labor_contract.docx",
                        CreatedAt = now,
                        UpdatedAt = now
                    }
                );
                await context.SaveChangesAsync();
            }

            // 2. 合同知识库分类与文件
            if (!await context.ContractKnowledgeCategories.AnyAsync())
            {
                // Root
                var root = new ContractKnowledgeCategory { Name = "合同知识库", SortOrder = 1, CreatedAt = now };
                context.ContractKnowledgeCategories.Add(root);
                await context.SaveChangesAsync();

                // Level 1
                var laws = new ContractKnowledgeCategory { Name = "法律法规", ParentId = root.Id, SortOrder = 1, CreatedAt = now };
                var policies = new ContractKnowledgeCategory { Name = "公司制度", ParentId = root.Id, SortOrder = 2, CreatedAt = now };
                var templates = new ContractKnowledgeCategory { Name = "合同范本", ParentId = root.Id, SortOrder = 3, CreatedAt = now };
                var risks = new ContractKnowledgeCategory { Name = "风险案例", ParentId = root.Id, SortOrder = 4, CreatedAt = now };
                
                context.ContractKnowledgeCategories.AddRange(laws, policies, templates, risks);
                await context.SaveChangesAsync();

                // Level 2
                var civilCode = new ContractKnowledgeCategory { Name = "民法典", ParentId = laws.Id, SortOrder = 1, CreatedAt = now };
                var tenderLaw = new ContractKnowledgeCategory { Name = "招标投标法", ParentId = laws.Id, SortOrder = 2, CreatedAt = now };
                var constructLaw = new ContractKnowledgeCategory { Name = "建筑法", ParentId = laws.Id, SortOrder = 3, CreatedAt = now };
                
                var contractPolicy = new ContractKnowledgeCategory { Name = "合同管理制度", ParentId = policies.Id, SortOrder = 1, CreatedAt = now };
                var sealPolicy = new ContractKnowledgeCategory { Name = "印章使用规范", ParentId = policies.Id, SortOrder = 2, CreatedAt = now };

                var purchaseTpl = new ContractKnowledgeCategory { Name = "采购类", ParentId = templates.Id, SortOrder = 1, CreatedAt = now };
                var salesTpl = new ContractKnowledgeCategory { Name = "销售类", ParentId = templates.Id, SortOrder = 2, CreatedAt = now };
                var leaseTpl = new ContractKnowledgeCategory { Name = "租赁类", ParentId = templates.Id, SortOrder = 3, CreatedAt = now };

                context.ContractKnowledgeCategories.AddRange(
                    civilCode, tenderLaw, constructLaw,
                    contractPolicy, sealPolicy,
                    purchaseTpl, salesTpl, leaseTpl
                );
                await context.SaveChangesAsync();

                // Files
                context.ContractKnowledgeFiles.AddRange(
                    new ContractKnowledgeFile { Name = "中华人民共和国民法典.pdf", Type = "pdf", Size = 5452595, Uploader = "系统管理员", UploadTime = now, CategoryId = civilCode.Id },
                    new ContractKnowledgeFile { Name = "合同审查要点指南.docx", Type = "doc", Size = 1572864, Uploader = "法务部", UploadTime = now, CategoryId = contractPolicy.Id },
                    new ContractKnowledgeFile { Name = "2023年度合同台账模板.xlsx", Type = "xls", Size = 46080, Uploader = "财务部", UploadTime = now, CategoryId = contractPolicy.Id },
                    new ContractKnowledgeFile { Name = "常见合同风险提示.txt", Type = "txt", Size = 12288, Uploader = "风控部", UploadTime = now, CategoryId = risks.Id },
                    new ContractKnowledgeFile { Name = "建设工程施工合同(示范文本).docx", Type = "doc", Size = 2936012, Uploader = "工程部", UploadTime = now, CategoryId = constructLaw.Id }
                );
                await context.SaveChangesAsync();
            }

            // 3. 合同统计
            if (!await context.ContractStats.AnyAsync())
            {
                context.ContractStats.AddRange(
                    new ContractStat
                    {
                        PeriodType = "Year",
                        StatDate = now,
                        TotalContracts = 158,
                        TotalContractsGrowth = 12.5m,
                        TotalAmount = 25800000,
                        AmountCompletionRate = 78,
                        ReceivedAmount = 18500000,
                        ReceivedRate = 71.7m,
                        PendingInvoiceAmount = 450000,
                        InvoicedAmount = 12005000,
                        CreatedAt = now
                    },
                     new ContractStat
                    {
                        PeriodType = "Quarter",
                        StatDate = now,
                        TotalContracts = 45,
                        TotalContractsGrowth = 5.2m,
                        TotalAmount = 8500000,
                        AmountCompletionRate = 60,
                        ReceivedAmount = 5000000,
                        ReceivedRate = 58.8m,
                        PendingInvoiceAmount = 150000,
                        InvoicedAmount = 4000000,
                        CreatedAt = now
                    },
                     new ContractStat
                    {
                        PeriodType = "Month",
                        StatDate = now,
                        TotalContracts = 12,
                        TotalContractsGrowth = 2.0m,
                        TotalAmount = 2500000,
                        AmountCompletionRate = 30,
                        ReceivedAmount = 800000,
                        ReceivedRate = 32.0m,
                        PendingInvoiceAmount = 50000,
                        InvoicedAmount = 700000,
                        CreatedAt = now
                    }
                );
                await context.SaveChangesAsync();
            }

            // 4. 合同列表 (Sales & Purchase)
            if (!await context.Contracts.AnyAsync())
            {
                context.Contracts.AddRange(
                    // Sales
                    new ContractMain
                    {
                        ContractNo = "XS2025122001",
                        ContractName = "企业云服务年度订阅",
                        Type = "sales",
                        PartnerName = "YY科技股份有限公司",
                        SignDate = DateTime.Parse("2025-12-05"),
                        TotalAmount = 50000.00m,
                        PaidAmount = 20000.00m,
                        LatestTransactionDate = DateTime.Parse("2025-12-10"),
                        Status = "completed",
                        Description = "按季度付款",
                        Manager = "Sales Manager",
                        CreatedAt = now
                    },
                    new ContractMain
                    {
                        ContractNo = "XS2025121503",
                        ContractName = "CRM系统维护服务",
                        Type = "sales",
                        PartnerName = "BB网络科技有限公司",
                        SignDate = DateTime.Parse("2025-12-15"),
                        TotalAmount = 12000.00m,
                        PaidAmount = 0.00m,
                        Status = "executing",
                        Description = "首付款未到",
                        Manager = "Sales Manager",
                        CreatedAt = now
                    },
                    new ContractMain
                    {
                        ContractNo = "XS2025112009",
                        ContractName = "数据中心扩容硬件销售",
                        Type = "sales",
                        PartnerName = "CC数据中心",
                        SignDate = DateTime.Parse("2025-11-20"),
                        TotalAmount = 450000.00m,
                        PaidAmount = 450000.00m,
                        LatestTransactionDate = DateTime.Parse("2025-11-25"),
                        Status = "completed",
                        Description = "已全额到账",
                        Manager = "Sales Manager",
                        CreatedAt = now
                    },
                    // Purchase
                    new ContractMain
                    {
                        ContractNo = "CG2025120101",
                        ContractName = "智慧城市二期项目采购合同",
                        Type = "purchase",
                        PartnerName = "XX市政集团",
                        SignDate = DateTime.Parse("2025-12-01"),
                        TotalAmount = 1200000.00m,
                        PaidAmount = 400000.00m,
                        LatestTransactionDate = DateTime.Parse("2025-12-05"),
                        Status = "executing",
                        Description = "预付款已付",
                        Manager = "Purchase Manager",
                        CreatedAt = now
                    },
                    new ContractMain
                    {
                        ContractNo = "CG2025121008",
                        ContractName = "办公设备采购协议",
                        Type = "purchase",
                        PartnerName = "AA贸易公司",
                        SignDate = DateTime.Parse("2025-12-10"),
                        TotalAmount = 120000.00m,
                        PaidAmount = 12000.00m,
                        LatestTransactionDate = DateTime.Parse("2025-12-11"),
                        Status = "executing",
                        Description = "定金已付",
                        Manager = "Purchase Manager",
                        CreatedAt = now
                    },
                    new ContractMain
                    {
                        ContractNo = "CG2025111505",
                        ContractName = "服务器集群采购",
                        Type = "purchase",
                        PartnerName = "Dell供应商",
                        SignDate = DateTime.Parse("2025-11-15"),
                        TotalAmount = 500000.00m,
                        PaidAmount = 500000.00m,
                        LatestTransactionDate = DateTime.Parse("2025-11-20"),
                        Status = "completed",
                        Description = "设备已验收",
                        Manager = "Purchase Manager",
                        CreatedAt = now
                    }
                );
                await context.SaveChangesAsync();
            }

            // 5. 合同详情 (Details for XS2025122001)
            var detailContract = await context.Contracts.FirstOrDefaultAsync(c => c.ContractNo == "XS2025122001");
            if (detailContract != null && !await context.ContractPaymentPlans.AnyAsync(p => p.ContractId == detailContract.Id))
            {
                // Payment Plans
                context.ContractPaymentPlans.AddRange(
                    new ContractPaymentPlan
                    {
                        ContractId = detailContract.Id,
                        Phase = "第一期",
                        DueDate = DateTime.Parse("2025-12-10"),
                        Amount = 20000.00m,
                        Condition = "合同签订后5个工作日",
                        Status = "paid"
                    },
                    new ContractPaymentPlan
                    {
                        ContractId = detailContract.Id,
                        Phase = "第二期",
                        DueDate = DateTime.Parse("2026-03-10"),
                        Amount = 15000.00m,
                        Condition = "项目中期验收",
                        Status = "pending"
                    },
                    new ContractPaymentPlan
                    {
                        ContractId = detailContract.Id,
                        Phase = "第三期",
                        DueDate = DateTime.Parse("2026-06-10"),
                        Amount = 15000.00m,
                        Condition = "项目终验",
                        Status = "pending"
                    }
                );

                // Payment Records
                context.ContractPaymentRecords.Add(
                    new ContractPaymentRecord
                    {
                        ContractId = detailContract.Id,
                        PaymentDate = DateTime.Parse("2025-12-10"),
                        Amount = 20000.00m,
                        Method = "银行转账",
                        Operator = "张三",
                        Remark = "首付款"
                    }
                );

                // Invoices
                context.ContractInvoices.Add(
                    new ContractInvoice
                    {
                        ContractId = detailContract.Id,
                        InvoiceNo = "FP20251210001",
                        InvoiceDate = DateTime.Parse("2025-12-10"),
                        Amount = 20000.00m,
                        Type = "增值税专用发票",
                        Status = "issued"
                    }
                );

                // Contacts
                context.ContractContacts.AddRange(
                    new ContractContact
                    {
                        ContractId = detailContract.Id,
                        Name = "李四",
                        Role = "客户项目经理",
                        Phone = "13800138000",
                        Email = "lisi@yytech.com"
                    },
                    new ContractContact
                    {
                        ContractId = detailContract.Id,
                        Name = "王五",
                        Role = "财务对接人",
                        Phone = "13900139000",
                        Email = "wangwu@yytech.com"
                    }
                );

                // Attachments
                context.ContractAttachments.AddRange(
                    new ContractAttachment
                    {
                        ContractId = detailContract.Id,
                        FileName = "合同扫描件.pdf",
                        FilePath = "/uploads/contracts/scan_20251205.pdf",
                        Size = "2.5 MB",
                        UploadDate = DateTime.Parse("2025-12-05")
                    },
                    new ContractAttachment
                    {
                        ContractId = detailContract.Id,
                        FileName = "技术协议.docx",
                        FilePath = "/uploads/contracts/tech_20251205.docx",
                        Size = "1.2 MB",
                        UploadDate = DateTime.Parse("2025-12-05")
                    },
                    new ContractAttachment
                    {
                        ContractId = detailContract.Id,
                        FileName = "补充协议一.pdf",
                        FilePath = "/uploads/contracts/supp_20251215.pdf",
                        Size = "0.8 MB",
                        UploadDate = DateTime.Parse("2025-12-15")
                    }
                );

                await context.SaveChangesAsync();
            }
        }
    }
}
