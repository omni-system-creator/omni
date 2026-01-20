# Agent Guidelines for OMS Repository

## Build Commands

### Backend (C# .NET 10)
- Run: `cd backend/omsapi && dotnet run`
- Hot reload: `dotnet watch`
- Build: `dotnet build`

### Frontend PC (Vue 3 + TypeScript)
- Dev: `cd frontend && npm run dev`
- Build: `npm run build`
- Preview: `npm run preview`

### BigView (Data Visualization)
- Dev: `cd bigview && npm run dev`
- Build: `npm run build`
- Lint: `npm run lint` / `npm run lint:fix`
- New component: `npm run new`

### Frontend H5 (Mobile)
- Dev: `cd frontend.h5 && npm run dev`
- Build: `npm run build`

## Code Style Guidelines

### Backend (C#)
- Use async/await for all async operations
- Services use [AutoInject(ServiceLifetime.Scoped)] attribute
- Controllers return ApiResponse<T> wrapper
- XML comments on all public APIs
- ImplicitUsings enabled, nullable reference types enabled
- Controller naming: {Entity}Controller, Service: {Entity}Service
- DTO suffix for data transfer objects, Entity suffix for database entities

### Frontend (TypeScript/Vue 3)
- Single quotes, no semicolons, 2-space indentation (Prettier: 120 char width)
- Auto-import Vue APIs (ref, reactive, computed, watch, etc.) via unplugin-auto-import
- Auto-import Ant Design Vue components
- Component naming: PascalCase for files, PascalCase in templates
- Use script setup with lang="ts"
- Pinia stores use defineStore with Composition API
- API functions in src/api/{module}.ts using request utility from utils/request
- Error handling: use message.error() from ant-design-vue for user feedback
- Use @/ alias for src directory imports
- Types defined in src/types/ or alongside files

### Testing
- No test framework configured - verify changes manually

### Git Commits
- Follow conventional commits via commitlint: `type: description`

## Code Review & Verification Skills

作为 OMS 项目的智能助手，在交付代码前必须执行以下审查技能：

### 1. 架构与安全审查 (Architecture & Security)
- **数据隔离 (OrgId Isolation)**
  - [Backend] **手动过滤**：DbContext 未启用全局过滤，所有 Service 查询方法（Get/List）**必须**显式添加 `.Where(x => x.OrgId == currentOrgId)`。
  - [Backend] **越权检查**：Update/Delete 操作必须校验目标数据的 `OrgId` 是否属于当前用户上下文。
  - [Frontend] **视图过滤**：列表页应根据 `UserStore.currentOrgId` 过滤或标记跨组织数据。
- **事务管理 (Transaction)**
  - [Backend] 涉及多表更新（如主子表保存）必须使用 `using var transaction = _context.Database.BeginTransaction()`。

### 2. 前端组件与交互 (Frontend Components & UX)
- **布局标准 (Layout Standards)**
  - **结构组件**：左右/上下结构**必须**使用 `SplitLayout`，禁止手写 Flex/Grid 布局，确保拖拽调整与持久化。
  - **容器适配**：`Card`、`Tab`、`Table` 等容器组件**必须**适应父容器大小（`height: 100%` 或 `flex: 1`），禁止出现双重滚动条。
  - **表格与操作规范 (Table & Operation Standards)**
    - **序号显示**：表格左侧**必须**包含序号列，分页时需支持跨页连续计数。
    - **操作展示**：操作列**必须**居中，使用 Icon 图标（带 `title`）代替文字；超过 3 个操作时**必须**收纳至 `MoreOutlined` 菜单。
- **弹窗体验 (Modal UX)**
  - **复杂弹窗**：内容繁多或需参照背景内容的弹窗，**必须**支持拖拽（`useDraggableModal`）和最大化。
  - **人员选择**：使用 `UserSelector` 时必须处理回显（`initial-display-data`）和完整对象同步。
  - **加载反馈**：提交操作必须绑定 `loading` 状态。
- **图标规范**：使用 `DynamicIcon` 时需校验图标有效性。

### 3. 数据库与后端 (Database & Backend)
- **多库适配 (Multi-Context Migrations)**
  - **三库同步**：修改 `OmsContext` 实体后，必须分别生成 **MySQL**、**SQLServer**、**PostgreSQL** 的迁移文件。
  - **向量库独立**：`KbNode` 等向量相关实体修改需单独更新 `OmsPgContext`。
- **架构安全**
  - **OrgId 隔离**：所有查询显式添加 `.Where(x => x.OrgId == currentOrgId)`。
  - **事务管理**：多表操作必用 `BeginTransaction`。
  - **异步规范**：严禁 `.Result`，全链路 `async/await`。

### 4. 代码质量与自查 (Quality & Self-Correction)
- **模拟运行**：脑补完整数据流（UI -> API -> DB -> UI）。
- **边界测试**：自问“管理员/跨组织/空数据”场景表现。
- **类型安全**：DTO/Entity 分离，API 返回值强类型。

### 5. RBAC 与系统配置 (RBAC & System Config)
- **全局超级管理员**
  - RoleCode 为 `SuperAdmin` 的角色为全局超级管理员，拥有跨组织的系统级管理能力（包括系统配置等）。
- **组织级系统管理员**
  - 每个组织自动创建 `{组织字母简称}-Admin` 管理员角色（例如 OrgA 对应 `ORGA-Admin`）。
  - `{组织字母简称}-Admin` 角色中的用户视为该组织的系统管理员，只能管理各自组织范围内的配置与数据。
