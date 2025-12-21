# 金兰®综合信息管理系统 (JinLan OMS)

金兰®综合信息管理系统是一款为企业提供一体化业务数据管理解决方案的平台，旨在实现合同、财务、项目、客户、供应商等核心业务流程的数字化管理与协同。系统采用模块化松耦合设计，各模块既可独立运行，又能通过标准接口实现数据深度互通。

## 🌟 核心功能

### 1. 合同全生命周期管理
- **模板管理**：支持基于历史合同快速生成标准模板，支持复杂格式及动态表格。
- **在线签署**：集成电子签章，支持移动端手写签字与防篡改保护。
- **执行跟踪**：关键节点自动提醒，变更记录全程留痕，履约异常预警。
- **归档检索**：支持全文检索与权限分级访问控制。

### 2. 项目管理
- **统筹管理**：提供看板、甘特图等多视图，支持资源分配与冲突检测。
- **文档协同**：项目文档集中存储，支持版本控制与外部安全分享。
- **成本控制**：预算与实际支出实时对比，成本超支预警。

### 3. 财务管理
- **应收应付**：自动关联合同款项，生成收付款计划与账龄分析。
- **发票管理**：支持发票OCR识别、验真及红冲作废流程。
- **报表分析**：多维度收支统计，自动生成利润趋势及部门业绩报表。

### 4. 客户与供应商管理 (CRM & SRM)
- **客户360°视图**：聚合基础信息、联系人关系及合作历史，支持信用评估与分级。
- **供应商管理**：履约能力评分，采购价格对比及合作风险预警。

### 其他模块
- **库存管理**：出入库管理、库存追踪、盘点分析。
- **BI数据分析**：销售、财务、采购等多维度数据可视化驾驶舱。
- **个人中心**：待办事项、网盘、消息通知、日程管理。

## 🛠️ 技术栈

### 后端
- **框架**: .NET 8 / 9
- **数据库**: MySQL 8.0+
- **ORM**: Entity Framework Core
- **API 文档**: Swagger / OpenAPI
- **日志**: Serilog

### 前端
- **框架**: Vue 3 + TypeScript
- **构建工具**: Vite
- **UI 组件库**: Ant Design Vue
- **状态管理**: Pinia
- **图表库**: ECharts
- **路由管理**: Vue Router

## 📂 目录结构

```
OMS/
├── backend/           # 后端项目源码
│   ├── omsapi/        # Web API 项目
│   └── ...
├── frontend/          # 前端项目源码
│   ├── src/
│   │   ├── components/  # 公共组件
│   │   ├── layouts/     # 布局组件
│   │   ├── router/      # 路由配置
│   │   ├── stores/      # Pinia 状态管理
│   │   ├── views/       # 页面视图
│   │   └── ...
│   └── ...
├── 功能.md            # 系统功能需求规划方案
└── README.md          # 项目说明文档
```

## 🚀 快速开始

### 后端启动

1. 进入后端目录：
   ```bash
   cd backend/omsapi
   ```

2. 配置数据库连接：
   修改 `appsettings.json` 中的 `ConnectionStrings:DefaultConnection` 为你的 MySQL 连接字符串。

3. 运行项目：
   ```bash
   dotnet run
   ```
   
   或者使用热重载模式：
   ```bash
   dotnet watch
   ```

### 前端启动

1. 进入前端目录：
   ```bash
   cd frontend
   ```

2. 安装依赖：
   ```bash
   npm install
   # 或
   yarn install
   ```

3. 启动开发服务器：
   ```bash
   npm run dev
   # 或
   yarn dev
   ```

4. 构建生产版本：
   ```bash
   npm run build
   ```

## 🗄️ 数据库迁移管理

在开发过程中，如果需要清理大量的迁移文件并重新生成一个初始迁移（同时保留现有数据库数据），请按照以下步骤操作：

### 1. 删除旧的迁移文件
删除 `backend/omsapi/Migrations` 文件夹。

### 2. 清理数据库迁移历史
**重要**：不要删除业务数据表！只删除 EF Core 的版本记录表。
在数据库管理工具（如 Navicat, Workbench）中执行 SQL：
```sql
DELETE FROM `__EFMigrationsHistory`;
```
或者直接删除该表（EF Core 会自动重建）：
```sql
DROP TABLE `__EFMigrationsHistory`;
```

### 3. 重新生成迁移文件
在 `backend/omsapi` 目录下执行：
```bash
dotnet ef migrations add InitialCreate
```
这将基于当前的实体模型生成一个新的、完整的迁移文件。

### 4. 这里的 update 仅用于创建历史表
**注意**：由于数据库中已经存在业务表（如 `sys_user`），直接运行 `update` 可能会报错 "Table already exists"。
实际上，如果你确定数据库结构与当前模型完全一致，你不需要真正执行 DDL 语句，只需要让 EF Core 认为已经应用了迁移。

但标准的 EF Core 没有直接的 "mark as applied" 命令。通常的做法是：
1. 生成 SQL 脚本：
   ```bash
   dotnet ef migrations script -o script.sql
   ```
2. 手动在数据库中插入一条记录到 `__EFMigrationsHistory` 表，表示该迁移已应用。
   或者，如果仅仅是开发环境，且你刚删除了 `__EFMigrationsHistory` 表，你可以尝试运行：
   ```bash
   dotnet ef database update
   ```
   如果 EF Core 检测到表已存在，它可能会报错。如果报错，请手动将 `InitialCreate` 插入到 `__EFMigrationsHistory` 表中（包含 MigrationId 和 ProductVersion）。

   **更简单的做法（开发环境）**：
   如果数据不重要，直接 Drop Database 然后重新 Update 是最省事的。
   **如果数据重要（且要保留）**：
   你需要手动处理：
   1. 删除 `Migrations` 文件夹。
   2. `dotnet ef migrations add InitialCreate`。
   3. 打开生成的 `..._InitialCreate.cs` 文件，注释掉 `Up()` 方法中的所有 `CreateTable` 代码（因为表已经存在了）。
   4. `dotnet ef database update`（这会创建 `__EFMigrationsHistory` 表并记录迁移已应用，但不会重复创建业务表）。
   5. **恢复** `..._InitialCreate.cs` 文件中的代码（取消注释），以便将来部署到新环境时能正确创建表。

## 📄 许可证

Private / Proprietary
