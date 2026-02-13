# OMS Skills 使用指南

本项目包含8个自定义skills，帮助快速开发和维护OMS系统。

## 可用的Skills

### 1. `/add-api` - 添加后端API
**用途**: 创建新的API端点，包括Controller、Service、DTOs

**使用场景**:
- 需要添加新的业务模块API
- 创建CRUD接口
- 遵循OMS的服务模式和安全规范

**示例**:
```
/add-api 创建产品管理API
/add-api 添加订单相关的接口
```

**自动生成**:
- DTOs (Create/Update/Query)
- Service接口和实现（带OrgId过滤）
- Controller（返回ApiResponse）
- 自动注入配置

---

### 2. `/add-entity` - 添加数据库实体
**用途**: 创建新的数据库实体并生成三个数据库的迁移文件

**使用场景**:
- 需要新增数据表
- 添加业务实体
- 确保多数据库支持

**示例**:
```
/add-entity 添加Product实体，包含名称、价格、库存字段
/add-entity 创建Order表
```

**自动生成**:
- Entity类（继承BaseEntity）
- MySQL迁移文件
- SQL Server迁移文件
- PostgreSQL迁移文件
- DbContext配置

---

### 3. `/add-page` - 添加前端页面（PC）
**用途**: 创建符合OMS UI标准的前端页面

**使用场景**:
- 添加新的管理页面
- 创建列表、表单、详情页
- 遵循UI规范（SplitLayout、表格标准等）

**示例**:
```
/add-page 创建产品管理页面
/add-page 添加订单列表和编辑页面
```

**自动生成**:
- API模块（TypeScript）
- Vue组件（带表格、表单、模态框）
- 路由配置
- 符合UI标准（行号、操作列、拖拽模态框等）

---

### 4. `/add-h5-page` - 添加移动端页面
**用途**: 创建使用Vant 4的移动端页面

**使用场景**:
- 添加H5移动页面
- 创建移动端列表、表单、详情页
- 使用Vant组件库

**示例**:
```
/add-h5-page 创建移动端产品列表
/add-h5-page 添加订单详情页
```

**自动生成**:
- 移动端Vue组件
- Vant组件集成
- 下拉刷新、无限滚动
- 移动端路由

---

### 5. `/migrate-db` - 创建数据库迁移
**用途**: 为所有三个数据库创建迁移文件

**使用场景**:
- 修改数据库结构
- 添加字段、索引
- 确保MySQL、MSSQL、PostgreSQL同步

**示例**:
```
/migrate-db 为Product表添加Category字段
/migrate-db 创建索引优化查询性能
```

**自动生成**:
- MySQL迁移SQL
- SQL Server迁移SQL
- PostgreSQL迁移SQL
- 统一版本号

---

### 6. `/check-orgid` - 检查OrgId安全
**用途**: 审计代码确保所有查询都正确过滤OrgId

**使用场景**:
- 安全审计
- 检查多租户隔离
- 发现潜在的数据泄露风险

**示例**:
```
/check-orgid 审计所有Service
/check-orgid 检查ProductService的安全性
```

**输出**:
- 安全审计报告
- 违规代码位置
- 修复建议
- 可选自动修复

---

### 7. `/review-code` - 代码审查
**用途**: 全面审查代码质量、安全性、最佳实践

**使用场景**:
- Pull Request审查
- 代码质量检查
- 确保遵循OMS规范

**示例**:
```
/review-code 审查最近的改动
/review-code 检查ProductService.cs
```

**检查项**:
- OrgId安全
- 代码规范
- UI标准
- 性能问题
- 最佳实践

---

### 8. `/debug-issue` - 调试问题
**用途**: 系统化地调试和排查问题

**使用场景**:
- 遇到错误或bug
- 功能不正常
- 需要系统化排查

**示例**:
```
/debug-issue 产品列表显示为空
/debug-issue API返回401错误
```

**调试流程**:
- 收集信息
- 识别问题层
- 检查常见问题
- 系统化排查
- 提供修复方案

---

## 使用技巧

### 1. 组合使用
创建完整功能模块：
```
1. /add-entity 创建Product实体
2. /add-api 创建Product API
3. /add-page 创建产品管理页面
4. /check-orgid 检查安全性
5. /review-code 审查代码
```

### 2. 自动触发
某些skills会根据上下文自动触发：
- 当你说"添加API"时，会自动加载 `/add-api`
- 当你说"审查代码"时，会自动加载 `/review-code`
- 当你说"调试"时，会自动加载 `/debug-issue`

### 3. 手动调用
也可以显式调用：
```
/add-api
/check-orgid
/review-code
```

### 4. 带参数调用
某些skills支持参数：
```
/add-api Product
/add-entity Order name:string price:decimal
```

## 最佳实践

### 开发新功能
1. 使用 `/add-entity` 创建数据模型
2. 使用 `/add-api` 创建后端接口
3. 使用 `/add-page` 创建前端页面
4. 使用 `/check-orgid` 检查安全性
5. 使用 `/review-code` 审查代码质量

### 修复Bug
1. 使用 `/debug-issue` 系统化排查
2. 修复代码
3. 使用 `/review-code` 确保修复质量
4. 使用 `/check-orgid` 确保没有引入安全问题

### 代码审查
1. 使用 `/review-code` 全面审查
2. 使用 `/check-orgid` 专项检查安全
3. 根据报告修复问题
4. 再次审查确认

## 注意事项

1. **OrgId是关键**: 几乎所有skills都强调OrgId过滤，这是OMS多租户架构的核心
2. **多数据库支持**: 涉及数据库的操作必须考虑三个数据库
3. **UI标准**: 前端页面必须遵循既定的UI规范
4. **安全第一**: 所有代码都要经过安全检查

## 自定义Skills

如需添加新的skill，在 `.claude/skills/{skill-name}/SKILL.md` 创建文件：

```yaml
---
name: my-skill
description: What this skill does
disable-model-invocation: false
allowed-tools: Read, Write, Edit
---

# My Skill

Instructions for the skill...
```

## 获取帮助

- 查看具体skill的详细说明：打开 `.claude/skills/{skill-name}/SKILL.md`
- 遇到问题：使用 `/debug-issue` 或直接询问
- 建议改进：直接提出，我们会更新skills
